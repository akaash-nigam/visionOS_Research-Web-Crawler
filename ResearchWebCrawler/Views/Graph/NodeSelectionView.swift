//
//  NodeSelectionView.swift
//  Research Web Crawler
//
//  Displays information about selected node(s) and provides interaction controls
//

import SwiftUI

struct NodeSelectionView: View {
    @Environment(GraphInteractionManager.self) private var interactionManager
    @Environment(GraphManager.self) private var graphManager

    @State private var showingFullDetails = false
    @State private var showingEditor = false

    var body: some View {
        if let node = interactionManager.selectedNode {
            selectionPanel(for: node)
        } else if !interactionManager.selectedNodes.isEmpty {
            multiSelectionPanel
        }
    }

    // MARK: - Single Selection

    @ViewBuilder
    private func selectionPanel(for node: GraphNode) -> some View {
        if let source = graphManager.sources.first(where: { $0.id == node.id }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if !source.authors.isEmpty {
                            Text(source.authors.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Button {
                        interactionManager.deselectAll()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Metadata
                metadataSection(for: source)

                Divider()

                // Actions
                actionButtons(for: node, source: source)

                // Connections
                if !source.references.isEmpty {
                    Divider()
                    connectionsSection(for: source)
                }
            }
            .padding(20)
            .frame(width: 350)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .sheet(isPresented: $showingFullDetails) {
                SourceDetailView(source: source)
            }
            .sheet(isPresented: $showingEditor) {
                SourceEditView(source: source)
            }
        }
    }

    @ViewBuilder
    private func metadataSection(for source: Source) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            MetadataRow(
                icon: "book.closed",
                label: "Type",
                value: source.type.rawValue.capitalized
            )

            if let journal = source.journal {
                MetadataRow(
                    icon: "doc.text",
                    label: "Journal",
                    value: journal
                )
            }

            if let publicationDate = source.publicationDate {
                MetadataRow(
                    icon: "calendar",
                    label: "Published",
                    value: publicationDate.formatted(date: .abbreviated, time: .omitted)
                )
            }

            if let doi = source.doi {
                MetadataRow(
                    icon: "link",
                    label: "DOI",
                    value: doi
                )
            }

            if !source.tags.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    FlowLayout(spacing: 6) {
                        ForEach(source.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private func actionButtons(for node: GraphNode, source: Source) -> some View {
        HStack(spacing: 12) {
            Button {
                showingFullDetails = true
            } label: {
                Label("Details", systemImage: "info.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                showingEditor = true
            } label: {
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                source.isFavorite.toggle()
                graphManager.persistenceManager.saveSource(source)
            } label: {
                Image(systemName: source.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(source.isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.bordered)
        }
        .buttonBorderShape(.capsule)
    }

    @ViewBuilder
    private func connectionsSection(for source: Source) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("References (\(source.references.count))")
                .font(.headline)

            ForEach(source.references.prefix(3), id: \.targetId) { reference in
                if let targetSource = graphManager.sources.first(where: { $0.id == reference.targetId }) {
                    ConnectionRow(
                        title: targetSource.title,
                        type: reference.type
                    ) {
                        // Navigate to target node
                        if let targetNode = graphManager.nodes.first(where: { $0.id == reference.targetId }) {
                            interactionManager.selectNode(targetNode)
                        }
                    }
                }
            }

            if source.references.count > 3 {
                Button {
                    showingFullDetails = true
                } label: {
                    Text("+\(source.references.count - 3) more")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    // MARK: - Multi Selection

    @ViewBuilder
    private var multiSelectionPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(interactionManager.selectedNodes.count) nodes selected")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    interactionManager.deselectAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(spacing: 12) {
                Button {
                    exportSelectedCitations()
                } label: {
                    Label("Export Citations", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    deleteSelectedNodes()
                } label: {
                    Label("Delete All", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .buttonBorderShape(.capsule)
        }
        .padding(20)
        .frame(width: 300)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
    }

    // MARK: - Actions

    private func exportSelectedCitations() {
        let selectedSources = graphManager.sources.filter {
            interactionManager.selectedNodes.contains($0.id)
        }

        let bibliography = CitationFormatter.generateBibliography(
            sources: selectedSources,
            style: .apa
        )

        UIPasteboard.general.string = bibliography
    }

    private func deleteSelectedNodes() {
        for nodeId in interactionManager.selectedNodes {
            if let source = graphManager.sources.first(where: { $0.id == nodeId }) {
                graphManager.persistenceManager.deleteSource(source)
            }
        }

        interactionManager.deselectAll()

        if let project = graphManager.currentProject {
            graphManager.loadProject(project)
        }
    }
}

// MARK: - Supporting Views

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

struct ConnectionRow: View {
    let title: String
    let type: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: connectionIcon(for: type))
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .frame(width: 20)

                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private func connectionIcon(for type: String) -> String {
        switch type {
        case "references": return "arrow.right"
        case "cited_by": return "arrow.left"
        case "related": return "link"
        case "contradicts": return "xmark"
        case "supports": return "checkmark"
        default: return "link"
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    NodeSelectionView()
        .environment(GraphInteractionManager(graphManager: GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self)))))
        .environment(GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self))))
}
