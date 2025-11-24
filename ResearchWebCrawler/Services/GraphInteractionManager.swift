//
//  GraphInteractionManager.swift
//  Research Web Crawler
//
//  Epic 6: Graph Interaction & Gestures
//  Manages all user interactions with the 3D graph including:
//  - Node selection and highlighting
//  - Drag-to-connect gestures
//  - Node positioning
//  - Context menu handling
//

import Foundation
import RealityKit
import SwiftUI
import Observation

/// Manages all interactive behaviors for the 3D knowledge graph
@Observable
@MainActor
final class GraphInteractionManager {

    // MARK: - Published State

    /// Currently selected node
    var selectedNode: GraphNode?

    /// Currently hovered node (for highlighting)
    var hoveredNode: GraphNode?

    /// Nodes currently being dragged
    var draggingNodes: Set<UUID> = []

    /// Connection being created (from → to)
    var pendingConnection: (from: UUID, to: UUID?)?

    /// Whether multi-select mode is active
    var isMultiSelectMode = false

    /// Set of selected nodes in multi-select mode
    var selectedNodes: Set<UUID> = []

    /// Current interaction mode
    var interactionMode: InteractionMode = .navigation

    // MARK: - Dependencies

    private let graphManager: GraphManager
    private let graphScene: GraphScene?

    // MARK: - Interaction State

    private var dragStartPosition: SIMD3<Float>?
    private var nodeOriginalPositions: [UUID: SIMD3<Float>] = [:]

    // MARK: - Initialization

    init(graphManager: GraphManager, graphScene: GraphScene? = nil) {
        self.graphManager = graphManager
        self.graphScene = graphScene
    }

    // MARK: - Node Selection

    /// Select a node and optionally deselect others
    func selectNode(_ node: GraphNode, exclusive: Bool = true) {
        if exclusive && !isMultiSelectMode {
            deselectAll()
        }

        selectedNode = node

        if isMultiSelectMode {
            selectedNodes.insert(node.id)
        }

        // Update visual state
        updateNodeHighlight(node, isSelected: true)

        // Notify for UI updates
        NotificationCenter.default.post(
            name: .nodeSelected,
            object: node
        )
    }

    /// Deselect a specific node
    func deselectNode(_ node: GraphNode) {
        if selectedNode?.id == node.id {
            selectedNode = nil
        }

        selectedNodes.remove(node.id)
        updateNodeHighlight(node, isSelected: false)

        NotificationCenter.default.post(
            name: .nodeDeselected,
            object: node
        )
    }

    /// Deselect all nodes
    func deselectAll() {
        if let node = selectedNode {
            updateNodeHighlight(node, isSelected: false)
        }

        for nodeId in selectedNodes {
            if let node = graphManager.nodes.first(where: { $0.id == nodeId }) {
                updateNodeHighlight(node, isSelected: false)
            }
        }

        selectedNode = nil
        selectedNodes.removeAll()
    }

    /// Toggle multi-select mode
    func toggleMultiSelectMode() {
        isMultiSelectMode.toggle()

        if !isMultiSelectMode {
            // Clear multi-selection when exiting mode
            let previouslySelected = selectedNode
            deselectAll()
            if let node = previouslySelected {
                selectNode(node)
            }
        }
    }

    // MARK: - Node Hovering

    /// Update hovered node for visual feedback
    func setHoveredNode(_ node: GraphNode?) {
        // Remove previous hover effect
        if let previousHover = hoveredNode {
            updateNodeHighlight(previousHover, isHovered: false)
        }

        hoveredNode = node

        // Apply new hover effect
        if let node = node {
            updateNodeHighlight(node, isHovered: true)
        }
    }

    // MARK: - Node Dragging

    /// Start dragging a node
    func startDragging(_ node: GraphNode, at position: SIMD3<Float>) {
        draggingNodes.insert(node.id)
        dragStartPosition = position

        // Store original positions for selected nodes
        if isMultiSelectMode && selectedNodes.contains(node.id) {
            // Drag all selected nodes together
            for nodeId in selectedNodes {
                if let n = graphManager.nodes.first(where: { $0.id == nodeId }) {
                    nodeOriginalPositions[n.id] = n.position
                    draggingNodes.insert(n.id)
                }
            }
        } else {
            nodeOriginalPositions[node.id] = node.position
        }
    }

    /// Update dragged node positions
    func updateDragging(delta: SIMD3<Float>) {
        for nodeId in draggingNodes {
            guard let node = graphManager.nodes.first(where: { $0.id == nodeId }),
                  let originalPos = nodeOriginalPositions[nodeId] else {
                continue
            }

            let newPosition = originalPos + delta
            node.position = newPosition

            // Update entity position in RealityKit scene
            graphScene?.updateNodePosition(nodeId: nodeId, position: newPosition)
        }

        // Update connected edges
        graphManager.updateEdgePositions()
    }

    /// End dragging
    func endDragging() {
        draggingNodes.removeAll()
        dragStartPosition = nil
        nodeOriginalPositions.removeAll()

        // Optionally: Apply physics to settle nodes
        graphManager.applyLocalLayout(around: Array(draggingNodes))
    }

    // MARK: - Connection Creation

    /// Start creating a connection from a node
    func startConnectionFrom(_ node: GraphNode) {
        pendingConnection = (from: node.id, to: nil)
        interactionMode = .connectingNodes

        // Visual feedback
        updateNodeHighlight(node, isConnecting: true)
    }

    /// Update connection target as user drags
    func updateConnectionTarget(_ targetNode: GraphNode?) {
        if var pending = pendingConnection {
            pending.to = targetNode?.id
            pendingConnection = pending

            // Visual feedback for valid/invalid target
            if let target = targetNode {
                let isValid = canConnect(from: pending.from, to: target.id)
                updateNodeHighlight(target, isConnectionTarget: true, isValid: isValid)
            }
        }
    }

    /// Complete the connection
    func completeConnection(to targetNode: GraphNode, type: ConnectionType = .references) {
        guard let pending = pendingConnection,
              canConnect(from: pending.from, to: targetNode.id) else {
            cancelConnection()
            return
        }

        // Create the connection
        if let fromSource = graphManager.sources.first(where: { $0.id == pending.from }) {
            fromSource.addReference(to: targetNode.id, type: type)
            graphManager.persistenceManager.saveSource(fromSource)

            // Reload graph to reflect new connection
            if let project = graphManager.currentProject {
                graphManager.loadProject(project)
            }
        }

        // Clean up
        cancelConnection()

        // Notify
        NotificationCenter.default.post(
            name: .connectionCreated,
            object: (pending.from, targetNode.id)
        )
    }

    /// Cancel connection creation
    func cancelConnection() {
        if let pending = pendingConnection,
           let fromNode = graphManager.nodes.first(where: { $0.id == pending.from }) {
            updateNodeHighlight(fromNode, isConnecting: false)
        }

        pendingConnection = nil
        interactionMode = .navigation
    }

    /// Check if a connection is valid
    private func canConnect(from: UUID, to: UUID) -> Bool {
        // Can't connect to self
        guard from != to else { return false }

        // Check if connection already exists
        let existingConnection = graphManager.edges.contains { edge in
            edge.fromId == from && edge.toId == to
        }

        return !existingConnection
    }

    // MARK: - Context Menu Actions

    /// Get available actions for a node
    func getContextActions(for node: GraphNode) -> [GraphContextAction] {
        var actions: [GraphContextAction] = []

        // View details
        actions.append(.viewDetails(node))

        // Edit
        actions.append(.edit(node))

        // Toggle favorite
        if let source = graphManager.sources.first(where: { $0.id == node.id }) {
            actions.append(.toggleFavorite(source))
        }

        // Add connection
        actions.append(.addConnection(from: node))

        // Delete connections
        if !graphManager.edges.filter({ $0.fromId == node.id }).isEmpty {
            actions.append(.deleteConnections(node))
        }

        // Copy citation
        if let source = graphManager.sources.first(where: { $0.id == node.id }) {
            actions.append(.copyCitation(source))
        }

        // Delete
        actions.append(.delete(node))

        return actions
    }

    /// Execute a context action
    func executeAction(_ action: GraphContextAction) {
        switch action {
        case .viewDetails(let node):
            selectedNode = node
            NotificationCenter.default.post(name: .showNodeDetails, object: node)

        case .edit(let node):
            NotificationCenter.default.post(name: .editNode, object: node)

        case .toggleFavorite(let source):
            source.isFavorite.toggle()
            graphManager.persistenceManager.saveSource(source)

        case .addConnection(let node):
            startConnectionFrom(node)

        case .deleteConnections(let node):
            if let source = graphManager.sources.first(where: { $0.id == node.id }) {
                source.references.removeAll()
                graphManager.persistenceManager.saveSource(source)
                if let project = graphManager.currentProject {
                    graphManager.loadProject(project)
                }
            }

        case .copyCitation(let source):
            let citation = CitationFormatter.format(source, style: .apa)
            UIPasteboard.general.string = citation

        case .delete(let node):
            if let source = graphManager.sources.first(where: { $0.id == node.id }) {
                graphManager.persistenceManager.deleteSource(source)
                if let project = graphManager.currentProject {
                    graphManager.loadProject(project)
                }
            }
        }
    }

    // MARK: - Visual Feedback

    private func updateNodeHighlight(
        _ node: GraphNode,
        isSelected: Bool = false,
        isHovered: Bool = false,
        isConnecting: Bool = false,
        isConnectionTarget: Bool = false,
        isValid: Bool = true
    ) {
        guard let scene = graphScene else { return }

        var scale: Float = 1.0
        var emission: Float = 0.0

        if isSelected {
            scale = 1.3
            emission = 0.5
        } else if isHovered {
            scale = 1.15
            emission = 0.3
        } else if isConnecting {
            emission = 0.7
        } else if isConnectionTarget {
            scale = isValid ? 1.2 : 1.1
            emission = isValid ? 0.4 : 0.0
        }

        scene.highlightNode(
            nodeId: node.id,
            scale: scale,
            emission: emission,
            color: isConnectionTarget && !isValid ? .red : nil
        )
    }

    // MARK: - Keyboard Shortcuts

    func handleKeyPress(_ key: String) {
        switch key {
        case "Delete", "Backspace":
            if let node = selectedNode {
                executeAction(.delete(node))
            }

        case "Escape":
            if pendingConnection != nil {
                cancelConnection()
            } else {
                deselectAll()
            }

        case "c":
            if let node = selectedNode,
               let source = graphManager.sources.first(where: { $0.id == node.id }) {
                executeAction(.copyCitation(source))
            }

        case "e":
            if let node = selectedNode {
                executeAction(.edit(node))
            }

        case "f":
            if let node = selectedNode,
               let source = graphManager.sources.first(where: { $0.id == node.id }) {
                executeAction(.toggleFavorite(source))
            }

        case "a":
            if let node = selectedNode {
                startConnectionFrom(node)
            }

        default:
            break
        }
    }
}

// MARK: - Supporting Types

enum InteractionMode {
    case navigation
    case selectingNodes
    case connectingNodes
    case draggingNodes
}

enum GraphContextAction {
    case viewDetails(GraphNode)
    case edit(GraphNode)
    case toggleFavorite(Source)
    case addConnection(from: GraphNode)
    case deleteConnections(GraphNode)
    case copyCitation(Source)
    case delete(GraphNode)

    var title: String {
        switch self {
        case .viewDetails: return "View Details"
        case .edit: return "Edit"
        case .toggleFavorite: return "Toggle Favorite"
        case .addConnection: return "Add Connection"
        case .deleteConnections: return "Delete Connections"
        case .copyCitation: return "Copy Citation"
        case .delete: return "Delete"
        }
    }

    var icon: String {
        switch self {
        case .viewDetails: return "info.circle"
        case .edit: return "pencil"
        case .toggleFavorite: return "star"
        case .addConnection: return "link.badge.plus"
        case .deleteConnections: return "link.badge.minus"
        case .copyCitation: return "doc.on.doc"
        case .delete: return "trash"
        }
    }
}

enum ConnectionType: String, Codable {
    case references = "references"
    case citedBy = "cited_by"
    case related = "related"
    case contradicts = "contradicts"
    case supports = "supports"
}

// MARK: - Notification Names

extension Notification.Name {
    static let nodeSelected = Notification.Name("nodeSelected")
    static let nodeDeselected = Notification.Name("nodeDeselected")
    static let showNodeDetails = Notification.Name("showNodeDetails")
    static let editNode = Notification.Name("editNode")
    static let connectionCreated = Notification.Name("connectionCreated")
}
