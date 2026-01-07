//
//  GraphRenderer.swift
//  Research Web Crawler
//
//  Renders graph nodes and edges in RealityKit scene
//

import RealityKit
import SwiftUI

@MainActor
final class GraphRenderer {
    // MARK: - Properties

    weak var scene: GraphScene?
    let graph: Graph
    let sources: [Source]

    private var nodeEntities: [UUID: NodeEntity] = [:]
    private var edgeEntities: [UUID: EdgeEntity] = [:]

    // Source lookup for efficient access
    private var sourceDict: [UUID: Source] = [:]

    // MARK: - Initialization

    init(scene: GraphScene, graph: Graph, sources: [Source]) {
        self.scene = scene
        self.graph = graph
        self.sources = sources

        // Build source dictionary for O(1) lookup
        for source in sources {
            sourceDict[source.id] = source
        }
    }

    // MARK: - Rendering

    func render() {
        guard let scene = scene else { return }

        // Clear existing entities
        nodeEntities.removeAll()
        edgeEntities.removeAll()

        // Render all nodes
        renderNodes(scene: scene)

        // Render all edges
        renderEdges(scene: scene)

        print("✅ GraphRenderer rendered \(nodeEntities.count) nodes, \(edgeEntities.count) edges")
    }

    private func renderNodes(scene: GraphScene) {
        for (sourceId, graphNode) in graph.nodes {
            guard let source = sourceDict[sourceId] else {
                print("⚠️ Source not found for node: \(sourceId)")
                continue
            }

            // Create node entity
            let nodeEntity = NodeEntity(
                sourceId: sourceId,
                type: source.type,
                position: graphNode.position,
                size: graphNode.size,
                color: colorForSourceType(source.type)
            )

            // Add to scene
            scene.nodesLayer.addChild(nodeEntity)

            // Store reference
            nodeEntities[sourceId] = nodeEntity

            // Animate appearance
            nodeEntity.animateAppearance()
        }
    }

    private func renderEdges(scene: GraphScene) {
        for (connectionId, connection) in graph.edges {
            guard let fromNode = nodeEntities[connection.fromSourceId],
                  let toNode = nodeEntities[connection.toSourceId] else {
                print("⚠️ Node entities not found for edge: \(connectionId)")
                continue
            }

            // Create edge entity
            let edgeEntity = EdgeEntity(
                connection: connection,
                fromNode: fromNode,
                toNode: toNode
            )

            // Add to scene
            scene.edgesLayer.addChild(edgeEntity)

            // Store reference
            edgeEntities[connectionId] = edgeEntity

            // Animate appearance
            edgeEntity.animateAppearance()
        }
    }

    // MARK: - Updates

    func updateNodePosition(_ nodeId: UUID, position: SIMD3<Float>) {
        guard let nodeEntity = nodeEntities[nodeId] else { return }

        nodeEntity.position = position

        // Update all connected edges
        updateEdgesForNode(nodeId)
    }

    func updateEdgesForNode(_ nodeId: UUID) {
        // Find all edges connected to this node
        for (_, edgeEntity) in edgeEntities {
            if edgeEntity.connection.fromSourceId == nodeId ||
               edgeEntity.connection.toSourceId == nodeId {
                edgeEntity.updateGeometry()
            }
        }
    }

    func addNode(_ graphNode: GraphNode, source: Source) {
        guard let scene = scene else { return }

        let nodeEntity = NodeEntity(
            sourceId: graphNode.sourceId,
            type: source.type,
            position: graphNode.position,
            size: graphNode.size,
            color: colorForSourceType(source.type)
        )

        scene.nodesLayer.addChild(nodeEntity)
        nodeEntities[graphNode.sourceId] = nodeEntity
        sourceDict[source.id] = source

        nodeEntity.animateAppearance()
    }

    func removeNode(_ nodeId: UUID) {
        guard let nodeEntity = nodeEntities[nodeId] else { return }

        // Remove all connected edges
        let connectedEdges = edgeEntities.filter { (_, edge) in
            edge.connection.fromSourceId == nodeId ||
            edge.connection.toSourceId == nodeId
        }

        for (edgeId, edgeEntity) in connectedEdges {
            edgeEntity.removeFromParent()
            edgeEntities.removeValue(forKey: edgeId)
        }

        // Remove node
        nodeEntity.removeFromParent()
        nodeEntities.removeValue(forKey: nodeId)
        sourceDict.removeValue(forKey: nodeId)
    }

    func addEdge(_ connection: Connection) {
        guard let scene = scene,
              let fromNode = nodeEntities[connection.fromSourceId],
              let toNode = nodeEntities[connection.toSourceId] else {
            print("⚠️ Cannot add edge: nodes not found")
            return
        }

        let edgeEntity = EdgeEntity(
            connection: connection,
            fromNode: fromNode,
            toNode: toNode
        )

        scene.edgesLayer.addChild(edgeEntity)
        edgeEntities[connection.id] = edgeEntity

        edgeEntity.animateAppearance()
    }

    func removeEdge(_ connectionId: UUID) {
        guard let edgeEntity = edgeEntities[connectionId] else { return }

        edgeEntity.removeFromParent()
        edgeEntities.removeValue(forKey: connectionId)
    }

    // MARK: - Highlighting

    func highlightNode(_ nodeId: UUID) {
        nodeEntities[nodeId]?.setHighlighted(true)

        // Highlight connected edges
        for (_, edge) in edgeEntities {
            if edge.connection.fromSourceId == nodeId ||
               edge.connection.toSourceId == nodeId {
                edge.setHighlighted(true)
            }
        }
    }

    func unhighlightNode(_ nodeId: UUID) {
        nodeEntities[nodeId]?.setHighlighted(false)

        // Unhighlight connected edges
        for (_, edge) in edgeEntities {
            if edge.connection.fromSourceId == nodeId ||
               edge.connection.toSourceId == nodeId {
                edge.setHighlighted(false)
            }
        }
    }

    func unhighlightAll() {
        for (_, node) in nodeEntities {
            node.setHighlighted(false)
        }
        for (_, edge) in edgeEntities {
            edge.setHighlighted(false)
        }
    }

    func selectNode(_ nodeId: UUID) {
        nodeEntities[nodeId]?.setSelected(true)
        nodeEntities[nodeId]?.animatePulse()
    }

    func deselectNode(_ nodeId: UUID) {
        nodeEntities[nodeId]?.setSelected(false)
    }

    // MARK: - Utilities

    private func colorForSourceType(_ type: SourceType) -> UIColor {
        switch type {
        case .article:
            return UIColor.systemBlue
        case .academicPaper:
            return UIColor.systemPurple
        case .book:
            return UIColor.systemBrown
        case .bookChapter:
            return UIColor.systemBrown.withAlphaComponent(0.8)
        case .news:
            return UIColor.systemOrange
        case .blog:
            return UIColor.systemTeal
        case .video:
            return UIColor.systemRed
        case .podcast:
            return UIColor.systemPink
        case .dataset:
            return UIColor.systemGreen
        case .website:
            return UIColor.systemGray
        case .other:
            return UIColor.systemGray2
        }
    }

    // MARK: - Performance Monitoring

    func getPerformanceMetrics() -> (nodes: Int, edges: Int) {
        return (nodes: nodeEntities.count, edges: edgeEntities.count)
    }
}
