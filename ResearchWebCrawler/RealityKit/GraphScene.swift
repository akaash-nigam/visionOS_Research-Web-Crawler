//
//  GraphScene.swift
//  Research Web Crawler
//
//  Main RealityKit scene for 3D graph visualization
//

import RealityKit
import SwiftUI

@MainActor
final class GraphScene: ObservableObject {
    // MARK: - Properties

    /// Root entity for the entire scene
    let rootEntity: Entity

    /// Container for all graph nodes
    let nodesLayer: Entity

    /// Container for all graph edges
    let edgesLayer: Entity

    /// Container for labels
    let labelsLayer: Entity

    /// Environment entity (lighting, background)
    let environmentEntity: Entity

    /// Reference to graph renderer
    var graphRenderer: GraphRenderer?

    /// Camera controller
    var cameraController: CameraController?

    // MARK: - Initialization

    init() {
        rootEntity = Entity()
        nodesLayer = Entity()
        nodesLayer.name = "NodesLayer"

        edgesLayer = Entity()
        edgesLayer.name = "EdgesLayer"

        labelsLayer = Entity()
        labelsLayer.name = "LabelsLayer"

        environmentEntity = Entity()
        environmentEntity.name = "Environment"

        setupHierarchy()
        setupLighting()

        print("✅ GraphScene initialized")
    }

    // MARK: - Setup

    private func setupHierarchy() {
        // Build entity hierarchy
        rootEntity.addChild(environmentEntity)
        rootEntity.addChild(edgesLayer)  // Edges behind nodes
        rootEntity.addChild(nodesLayer)
        rootEntity.addChild(labelsLayer) // Labels in front

        // Position scene in front of user
        rootEntity.position = [0, 1.5, -2]
    }

    private func setupLighting() {
        // Add ambient light
        var ambientLight = PointLightComponent(
            color: .white,
            intensity: 2000,
            attenuationRadius: 10
        )
        environmentEntity.components.set(ambientLight)
        environmentEntity.position = [0, 2, 0]

        // Add directional light for better depth perception
        let directionalLight = Entity()
        var dirLight = DirectionalLightComponent()
        dirLight.intensity = 1000
        directionalLight.components.set(dirLight)
        directionalLight.position = [2, 3, -1]
        directionalLight.look(at: [0, 0, 0], from: directionalLight.position, relativeTo: nil)
        environmentEntity.addChild(directionalLight)
    }

    // MARK: - Public Methods

    func renderGraph(_ graph: Graph, sources: [Source]) {
        clearScene()

        let renderer = GraphRenderer(
            scene: self,
            graph: graph,
            sources: sources
        )
        self.graphRenderer = renderer

        renderer.render()

        print("✅ Rendered graph: \(graph.nodes.count) nodes, \(graph.edges.count) edges")
    }

    func clearScene() {
        nodesLayer.children.removeAll()
        edgesLayer.children.removeAll()
        labelsLayer.children.removeAll()
    }

    func updateNodePosition(_ nodeId: UUID, position: SIMD3<Float>) {
        guard let nodeEntity = findNodeEntity(nodeId) else { return }
        nodeEntity.position = position

        // Update connected edges
        graphRenderer?.updateEdgesForNode(nodeId)
    }

    func findNodeEntity(_ nodeId: UUID) -> NodeEntity? {
        for child in nodesLayer.children {
            if let nodeEntity = child as? NodeEntity,
               nodeEntity.sourceId == nodeId {
                return nodeEntity
            }
        }
        return nil
    }

    func highlightNode(_ nodeId: UUID) {
        guard let nodeEntity = findNodeEntity(nodeId) else { return }
        nodeEntity.setHighlighted(true)
    }

    func unhighlightNode(_ nodeId: UUID) {
        guard let nodeEntity = findNodeEntity(nodeId) else { return }
        nodeEntity.setHighlighted(false)
    }

    func unhighlightAllNodes() {
        for child in nodesLayer.children {
            if let nodeEntity = child as? NodeEntity {
                nodeEntity.setHighlighted(false)
            }
        }
    }
}
