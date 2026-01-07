//
//  GraphContextMenuView.swift
//  Research Web Crawler
//
//  Context menu for graph node interactions
//

import SwiftUI

struct GraphContextMenuView: View {
    let node: GraphNode
    @Environment(GraphInteractionManager.self) private var interactionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            if let source = getSource(for: node) {
                contextMenuHeader(source: source)
            }

            Divider()

            // Actions
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(interactionManager.getContextActions(for: node), id: \.title) { action in
                        ContextMenuItem(action: action) {
                            interactionManager.executeAction(action)
                            dismiss()
                        }
                    }
                }
            }
        }
        .frame(width: 280)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 20)
    }

    @ViewBuilder
    private func contextMenuHeader(source: Source) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: source.type.icon)
                    .font(.title2)
                    .foregroundStyle(source.type.color)

                Spacer()

                if source.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }

            Text(source.title)
                .font(.headline)
                .lineLimit(2)

            if !source.authors.isEmpty {
                Text(source.authors.prefix(2).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
    }

    private func getSource(for node: GraphNode) -> Source? {
        // In real implementation, would access through environment
        return nil
    }
}

struct ContextMenuItem: View {
    let action: GraphContextAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.body)
                    .foregroundStyle(iconColor)
                    .frame(width: 24)

                Text(action.title)
                    .font(.subheadline)
                    .foregroundStyle(textColor)

                Spacer()

                if let shortcut = keyboardShortcut {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(uiColor: .systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Color(uiColor: .systemGray6)
                .opacity(0)
        )
        .hoverEffect()
    }

    private var iconColor: Color {
        switch action {
        case .delete:
            return .red
        case .toggleFavorite:
            return .yellow
        default:
            return .primary
        }
    }

    private var textColor: Color {
        switch action {
        case .delete:
            return .red
        default:
            return .primary
        }
    }

    private var keyboardShortcut: String? {
        switch action {
        case .edit:
            return "E"
        case .toggleFavorite:
            return "F"
        case .copyCitation:
            return "C"
        case .delete:
            return "⌫"
        case .addConnection:
            return "A"
        default:
            return nil
        }
    }
}

// MARK: - Source Type Extensions

extension SourceType {
    var icon: String {
        switch self {
        case .academicPaper: return "doc.text"
        case .book: return "book"
        case .article: return "newspaper"
        case .website: return "globe"
        case .video: return "video"
        case .podcast: return "waveform"
        case .presentation: return "rectangle.on.rectangle"
        case .thesis: return "graduationcap"
        case .report: return "doc.richtext"
        case .dataset: return "chart.bar.doc.horizontal"
        case .other: return "doc"
        }
    }

    var color: Color {
        switch self {
        case .academicPaper: return .blue
        case .book: return .brown
        case .article: return .orange
        case .website: return .green
        case .video: return .red
        case .podcast: return .purple
        case .presentation: return .pink
        case .thesis: return .indigo
        case .report: return .teal
        case .dataset: return .cyan
        case .other: return .gray
        }
    }
}

// MARK: - Immersive Context Menu Presenter

/// Presents context menu in 3D space near the tapped node
@MainActor
class ImmersiveContextMenuPresenter: ObservableObject {
    @Published var isPresented = false
    @Published var node: GraphNode?
    @Published var position: SIMD3<Float> = .zero

    func present(node: GraphNode, at position: SIMD3<Float>) {
        self.node = node
        self.position = position
        self.isPresented = true
    }

    func dismiss() {
        isPresented = false
        node = nil
    }
}

/// View that displays context menu in 3D space
struct ImmersiveContextMenu: View {
    @ObservedObject var presenter: ImmersiveContextMenuPresenter
    @Environment(GraphInteractionManager.self) private var interactionManager

    var body: some View {
        ZStack {
            if presenter.isPresented, let node = presenter.node {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        presenter.dismiss()
                    }

                GraphContextMenuView(node: node)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: presenter.isPresented)
    }
}

// MARK: - Quick Actions View

/// Floating action buttons for common operations
struct QuickActionsView: View {
    @Environment(GraphInteractionManager.self) private var interactionManager
    @Binding var showingQuickActions: Bool

    var body: some View {
        if showingQuickActions {
            VStack(spacing: 16) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    label: "Add Source",
                    color: .blue
                ) {
                    // Trigger add source sheet
                }

                QuickActionButton(
                    icon: "link.badge.plus",
                    label: "Add Connection",
                    color: .green
                ) {
                    if let node = interactionManager.selectedNode {
                        interactionManager.startConnectionFrom(node)
                    }
                }

                QuickActionButton(
                    icon: "arrow.triangle.2.circlepath",
                    label: "Re-layout",
                    color: .purple
                ) {
                    // Trigger layout recalculation
                }

                QuickActionButton(
                    icon: "square.on.square",
                    label: "Multi-Select",
                    color: .orange
                ) {
                    interactionManager.toggleMultiSelectMode()
                }

                Divider()
                    .frame(width: 40)

                QuickActionButton(
                    icon: "xmark",
                    label: "Close",
                    color: .gray
                ) {
                    showingQuickActions = false
                }
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Context Menu") {
    let node = GraphNode(
        id: UUID(),
        position: SIMD3<Float>(0, 0, 0),
        sourceId: UUID()
    )

    return GraphContextMenuView(node: node)
        .environment(GraphInteractionManager(
            graphManager: GraphManager(
                persistenceManager: PersistenceManager(
                    modelContainer: try! ModelContainer(for: Project.self, Source.self)
                )
            )
        ))
}

#Preview("Quick Actions") {
    @Previewable @State var showing = true

    return QuickActionsView(showingQuickActions: $showing)
        .environment(GraphInteractionManager(
            graphManager: GraphManager(
                persistenceManager: PersistenceManager(
                    modelContainer: try! ModelContainer(for: Project.self, Source.self)
                )
            )
        ))
}
