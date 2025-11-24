//
//  RealityKitTests.swift
//  Research Web Crawler Tests
//
//  Tests for RealityKit 3D visualization components
//

import XCTest
import RealityKit
@testable import ResearchWebCrawler

@MainActor
final class RealityKitTests: XCTestCase {
    var graphScene: GraphScene!

    override func setUp() async throws {
        graphScene = GraphScene()
    }

    override func tearDown() async throws {
        graphScene = nil
    }

    // MARK: - GraphScene Tests

    func testGraphSceneInitialization() {
        XCTAssertNotNil(graphScene.rootEntity)
        XCTAssertNotNil(graphScene.nodesLayer)
        XCTAssertNotNil(graphScene.edgesLayer)
        XCTAssertNotNil(graphScene.labelsLayer)
        XCTAssertNotNil(graphScene.environmentEntity)

        // Verify hierarchy
        XCTAssertTrue(graphScene.rootEntity.children.contains(graphScene.nodesLayer))
        XCTAssertTrue(graphScene.rootEntity.children.contains(graphScene.edgesLayer))
        XCTAssertTrue(graphScene.rootEntity.children.contains(graphScene.labelsLayer))
    }

    func testGraphSceneRenderGraph() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        graphScene.renderGraph(graph, sources: sources)

        // Should have renderer assigned
        XCTAssertNotNil(graphScene.graphRenderer)

        // Should have nodes in layer
        XCTAssertEqual(graphScene.nodesLayer.children.count, 10)
    }

    func testGraphSceneClearScene() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        graphScene.renderGraph(graph, sources: sources)
        XCTAssertGreaterThan(graphScene.nodesLayer.children.count, 0)

        graphScene.clearScene()
        XCTAssertEqual(graphScene.nodesLayer.children.count, 0)
        XCTAssertEqual(graphScene.edgesLayer.children.count, 0)
    }

    func testGraphSceneFindNodeEntity() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        graphScene.renderGraph(graph, sources: sources)

        // Find first node
        let nodeId = graph.nodes.keys.first!
        let foundNode = graphScene.findNodeEntity(nodeId)

        XCTAssertNotNil(foundNode)
        XCTAssertEqual(foundNode?.sourceId, nodeId)
    }

    // MARK: - NodeEntity Tests

    func testNodeEntityCreation() {
        let nodeId = UUID()
        let position = SIMD3<Float>(1, 0, 0)

        let node = NodeEntity(
            sourceId: nodeId,
            type: .article,
            position: position,
            size: 0.05,
            color: .blue
        )

        XCTAssertEqual(node.sourceId, nodeId)
        XCTAssertEqual(node.position, position)
        XCTAssertEqual(node.nodeSize, 0.05)

        // Should have model component
        XCTAssertNotNil(node.components[ModelComponent.self])

        // Should have collision component
        XCTAssertNotNil(node.components[CollisionComponent.self])
    }

    func testNodeEntityHighlighting() {
        let node = NodeEntity(
            sourceId: UUID(),
            type: .article,
            position: .zero,
            color: .blue
        )

        // Test highlighting
        node.setHighlighted(true)
        // Visual state should update (verified manually)

        node.setHighlighted(false)
        // Should return to normal state
    }

    func testNodeEntityUpdateSize() {
        let node = NodeEntity(
            sourceId: UUID(),
            type: .article,
            position: .zero,
            size: 0.05,
            color: .blue
        )

        let originalSize = node.nodeSize
        let newSize: Float = 0.1

        node.updateSize(newSize)

        XCTAssertEqual(node.nodeSize, newSize)
        XCTAssertNotEqual(node.nodeSize, originalSize)
    }

    // MARK: - GraphRenderer Tests

    func testGraphRendererInitialization() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        let renderer = GraphRenderer(
            scene: graphScene,
            graph: graph,
            sources: sources
        )

        XCTAssertNotNil(renderer.scene)
        XCTAssertEqual(renderer.graph.nodes.count, 10)
        XCTAssertEqual(renderer.sources.count, 10)
    }

    func testGraphRendererRender() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        let renderer = GraphRenderer(
            scene: graphScene,
            graph: graph,
            sources: sources
        )

        renderer.render()

        // Should render all nodes
        XCTAssertEqual(graphScene.nodesLayer.children.count, graph.nodes.count)

        // Should render all edges
        XCTAssertEqual(graphScene.edgesLayer.children.count, graph.edges.count)
    }

    func testGraphRendererPerformanceMetrics() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.mediumGraph(projectId: projectId)

        let renderer = GraphRenderer(
            scene: graphScene,
            graph: graph,
            sources: sources
        )

        renderer.render()

        let metrics = renderer.getPerformanceMetrics()
        XCTAssertEqual(metrics.nodes, 50)
        XCTAssertGreaterThan(metrics.edges, 0)
    }

    // MARK: - CameraController Tests

    func testCameraControllerInitialization() {
        let controller = CameraController()

        XCTAssertEqual(controller.cameraDistance, 2.0)
        XCTAssertEqual(controller.cameraRotation, .zero)
        XCTAssertEqual(controller.cameraOffset, .zero)
    }

    func testCameraControllerZoom() {
        let controller = CameraController()

        let initialDistance = controller.cameraDistance

        controller.zoom(delta: 0.5)
        controller.update(deltaTime: 1.0)

        // Distance should increase
        XCTAssertGreaterThan(controller.cameraDistance, initialDistance)

        controller.zoom(delta: -1.0)
        controller.update(deltaTime: 1.0)

        // Distance should decrease
        XCTAssertLessThan(controller.cameraDistance, initialDistance + 0.5)
    }

    func testCameraControllerPan() {
        let controller = CameraController()

        let initialOffset = controller.cameraOffset

        controller.pan(delta: SIMD2<Float>(1, 0))
        controller.update(deltaTime: 1.0)

        // Offset should change
        XCTAssertNotEqual(controller.cameraOffset, initialOffset)
    }

    func testCameraControllerRotate() {
        let controller = CameraController()

        controller.rotate(delta: SIMD2<Float>(1, 0.5))
        controller.update(deltaTime: 1.0)

        // Rotation should change
        XCTAssertNotEqual(controller.cameraRotation.x, 0)
        XCTAssertNotEqual(controller.cameraRotation.y, 0)
    }

    func testCameraControllerReset() {
        let controller = CameraController()

        // Make changes
        controller.zoom(delta: 1.0)
        controller.rotate(delta: SIMD2<Float>(1, 1))
        controller.update(deltaTime: 1.0)

        // Reset
        controller.resetCamera()

        // Should return to defaults
        XCTAssertEqual(controller.cameraDistance, 2.0)
        XCTAssertEqual(controller.cameraRotation, .zero)
        XCTAssertEqual(controller.cameraOffset, .zero)
    }

    func testCameraControllerFocusOn() {
        let controller = CameraController()

        let targetPosition = SIMD3<Float>(1, 2, 3)
        let targetDistance: Float = 1.5

        controller.focusOn(position: targetPosition, distance: targetDistance)
        controller.update(deltaTime: 1.0)

        // Should move towards target
        XCTAssertNotEqual(controller.cameraOffset, .zero)
    }

    func testCameraControllerStatePreservation() {
        let controller = CameraController()

        // Set custom state
        controller.zoom(delta: 0.5)
        controller.rotate(delta: SIMD2<Float>(0.3, 0.2))
        controller.update(deltaTime: 1.0)

        // Get state
        let state = controller.getCameraState()

        // Create new controller and restore state
        let newController = CameraController()
        newController.setCameraState(state, animated: false)

        // Should match original
        XCTAssertEqual(newController.cameraDistance, controller.cameraDistance, accuracy: 0.01)
        XCTAssertEqual(newController.cameraRotation.x, controller.cameraRotation.x, accuracy: 0.01)
        XCTAssertEqual(newController.cameraRotation.y, controller.cameraRotation.y, accuracy: 0.01)
    }

    // MARK: - Test Data Generation Tests

    func testSmallGraphGeneration() {
        let (graph, sources) = GraphTestData.smallGraph()

        XCTAssertEqual(graph.nodes.count, 10)
        XCTAssertEqual(sources.count, 10)
        XCTAssertGreaterThan(graph.edges.count, 0)
    }

    func testMediumGraphGeneration() {
        let (graph, sources) = GraphTestData.mediumGraph()

        XCTAssertEqual(graph.nodes.count, 50)
        XCTAssertEqual(sources.count, 50)
        XCTAssertGreaterThan(graph.edges.count, 20)
    }

    func testLargeGraphGeneration() {
        let (graph, sources) = GraphTestData.largeGraph()

        XCTAssertEqual(graph.nodes.count, 100)
        XCTAssertEqual(sources.count, 100)
        XCTAssertGreaterThan(graph.edges.count, 50)
    }

    func testStarGraphGeneration() {
        let (graph, sources) = GraphTestData.starGraph(spokeCount: 15)

        XCTAssertEqual(graph.nodes.count, 16) // 1 center + 15 spokes
        XCTAssertEqual(sources.count, 16)
        XCTAssertEqual(graph.edges.count, 15) // All connected to center
    }

    func testChainGraphGeneration() {
        let (graph, sources) = GraphTestData.chainGraph(length: 12)

        XCTAssertEqual(graph.nodes.count, 12)
        XCTAssertEqual(sources.count, 12)
        XCTAssertEqual(graph.edges.count, 11) // Linear chain
    }

    func testClusteredGraphGeneration() {
        let (graph, sources) = GraphTestData.clusteredGraph(
            clusterCount: 4,
            nodesPerCluster: 8
        )

        XCTAssertEqual(graph.nodes.count, 32) // 4 * 8
        XCTAssertEqual(sources.count, 32)
        XCTAssertGreaterThan(graph.edges.count, 30)
    }

    // MARK: - Performance Tests

    func testLargeGraphRenderingPerformance() {
        measure {
            let projectId = UUID()
            let (graph, sources) = GraphTestData.largeGraph(projectId: projectId)

            let scene = GraphScene()
            scene.renderGraph(graph, sources: sources)
        }
    }

    func testGraphUpdatePerformance() {
        let projectId = UUID()
        let (graph, sources) = GraphTestData.mediumGraph(projectId: projectId)

        graphScene.renderGraph(graph, sources: sources)

        measure {
            // Update all node positions
            for nodeId in graph.nodes.keys {
                let newPosition = SIMD3<Float>(
                    Float.random(in: -1...1),
                    Float.random(in: -1...1),
                    Float.random(in: -1...1)
                )
                graphScene.updateNodePosition(nodeId, position: newPosition)
            }
        }
    }
}
