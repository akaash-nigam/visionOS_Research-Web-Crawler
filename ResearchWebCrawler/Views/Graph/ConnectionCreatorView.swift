//
//  ConnectionCreatorView.swift
//  Research Web Crawler
//
//  Drag-to-connect interface for creating relationships between sources
//

import SwiftUI
import RealityKit

struct ConnectionCreatorView: View {
    @Environment(GraphInteractionManager.self) private var interactionManager
    @Environment(GraphManager.self) private var graphManager

    @State private var selectedConnectionType: ConnectionType = .references
    @State private var showingTypePicker = false

    var body: some View {
        VStack {
            if let (fromId, toId) = interactionManager.pendingConnection {
                connectionCreationPanel(from: fromId, to: toId)
            }
        }
    }

    // MARK: - Connection Panel

    @ViewBuilder
    private func connectionCreationPanel(from: UUID, to: UUID?) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Creating Connection")
                    .font(.headline)

                Spacer()

                Button {
                    interactionManager.cancelConnection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            // From source
            if let fromSource = graphManager.sources.first(where: { $0.id == from }) {
                sourceCard(source: fromSource, label: "From")
            }

            // Connection type selector
            connectionTypePicker

            // To source (if hovering)
            if let toId = to,
               let toSource = graphManager.sources.first(where: { $0.id == toId }) {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                sourceCard(source: toSource, label: "To")

                // Complete button
                Button {
                    if let targetNode = graphManager.nodes.first(where: { $0.id == toId }) {
                        interactionManager.completeConnection(
                            to: targetNode,
                            type: selectedConnectionType
                        )
                    }
                } label: {
                    Label("Create Connection", systemImage: "link.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            } else {
                // Instructions
                VStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("Tap a node to connect")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 100)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
    }

    // MARK: - Source Card

    @ViewBuilder
    private func sourceCard(source: Source, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 4) {
                Text(source.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                if !source.authors.isEmpty {
                    Text(source.authors.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Connection Type Picker

    @ViewBuilder
    private var connectionTypePicker: some View {
        Menu {
            ForEach(ConnectionType.allCases, id: \.self) { type in
                Button {
                    selectedConnectionType = type
                } label: {
                    Label(
                        type.displayName,
                        systemImage: type.icon
                    )
                }
            }
        } label: {
            HStack {
                Label(
                    selectedConnectionType.displayName,
                    systemImage: selectedConnectionType.icon
                )
                .font(.subheadline)

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Connection Type Extensions

extension ConnectionType: CaseIterable {
    static var allCases: [ConnectionType] {
        [.references, .citedBy, .related, .contradicts, .supports]
    }

    var displayName: String {
        switch self {
        case .references: return "References"
        case .citedBy: return "Cited By"
        case .related: return "Related To"
        case .contradicts: return "Contradicts"
        case .supports: return "Supports"
        }
    }

    var icon: String {
        switch self {
        case .references: return "arrow.right.circle"
        case .citedBy: return "arrow.left.circle"
        case .related: return "link.circle"
        case .contradicts: return "xmark.circle"
        case .supports: return "checkmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .references: return .blue
        case .citedBy: return .purple
        case .related: return .green
        case .contradicts: return .red
        case .supports: return .mint
        }
    }

    var description: String {
        switch self {
        case .references:
            return "This source references or cites the target"
        case .citedBy:
            return "This source is cited by the target"
        case .related:
            return "This source is related to the target"
        case .contradicts:
            return "This source contradicts the target"
        case .supports:
            return "This source supports the target"
        }
    }
}

// MARK: - Connection Browser View

/// View for browsing and managing connections
struct ConnectionBrowserView: View {
    let source: Source
    @Environment(GraphManager.self) private var graphManager
    @Environment(GraphInteractionManager.self) private var interactionManager

    var body: some View {
        List {
            if !source.references.isEmpty {
                Section("Outgoing References (\(source.references.count))") {
                    ForEach(source.references, id: \.targetId) { reference in
                        if let target = graphManager.sources.first(where: { $0.id == reference.targetId }) {
                            ConnectionRowDetailed(
                                source: target,
                                type: reference.type,
                                onNavigate: {
                                    if let node = graphManager.nodes.first(where: { $0.id == target.id }) {
                                        interactionManager.selectNode(node)
                                    }
                                },
                                onDelete: {
                                    source.removeReference(to: reference.targetId)
                                    graphManager.persistenceManager.saveSource(source)
                                }
                            )
                        }
                    }
                }
            }

            // Incoming references
            let incomingRefs = graphManager.sources.filter { s in
                s.references.contains { $0.targetId == source.id }
            }

            if !incomingRefs.isEmpty {
                Section("Incoming References (\(incomingRefs.count))") {
                    ForEach(incomingRefs) { refSource in
                        if let reference = refSource.references.first(where: { $0.targetId == source.id }) {
                            ConnectionRowDetailed(
                                source: refSource,
                                type: reference.type,
                                onNavigate: {
                                    if let node = graphManager.nodes.first(where: { $0.id == refSource.id }) {
                                        interactionManager.selectNode(node)
                                    }
                                },
                                onDelete: {
                                    refSource.removeReference(to: source.id)
                                    graphManager.persistenceManager.saveSource(refSource)
                                }
                            )
                        }
                    }
                }
            }

            if source.references.isEmpty && incomingRefs.isEmpty {
                ContentUnavailableView(
                    "No Connections",
                    systemImage: "link.badge.plus",
                    description: Text("This source has no connections yet. Start by adding a reference to another source.")
                )
            }
        }
        .navigationTitle("Connections")
    }
}

struct ConnectionRowDetailed: View {
    let source: Source
    let type: String
    let onNavigate: () -> Void
    let onDelete: () -> Void

    private var connectionType: ConnectionType {
        ConnectionType(rawValue: type) ?? .references
    }

    var body: some View {
        HStack(spacing: 12) {
            // Type indicator
            Image(systemName: connectionType.icon)
                .font(.title3)
                .foregroundStyle(connectionType.color)
                .frame(width: 30)

            // Source info
            VStack(alignment: .leading, spacing: 4) {
                Text(source.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if !source.authors.isEmpty {
                    Text(source.authors.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(connectionType.displayName)
                    .font(.caption2)
                    .foregroundStyle(connectionType.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(connectionType.color.opacity(0.1))
                    .clipShape(Capsule())
            }

            Spacer()

            // Actions
            Button {
                onNavigate()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview("Connection Creator") {
    ConnectionCreatorView()
        .environment(GraphInteractionManager(graphManager: GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self)))))
        .environment(GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self))))
}

#Preview("Connection Browser") {
    NavigationStack {
        ConnectionBrowserView(
            source: Source(title: "Test", type: .academicPaper, projectId: UUID(), addedBy: "test")
        )
        .environment(GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self))))
        .environment(GraphInteractionManager(graphManager: GraphManager(persistenceManager: PersistenceManager(modelContainer: try! ModelContainer(for: Project.self, Source.self)))))
    }
}
