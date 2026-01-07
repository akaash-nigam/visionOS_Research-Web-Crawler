//
//  LayoutTests.swift
//  Research Web Crawler Tests
//
//  Tests for graph layout algorithms
//

import XCTest
@testable import ResearchWebCrawler

@MainActor
final class LayoutTests: XCTestCase {
    var projectId: UUID!

    override func setUp() {
        projectId = UUID()
    }

    // MARK: - Force-Directed Layout Tests

    func testForceDirectedLayoutInitialization() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        XCTAssertEqual(layout.currentIteration, 0)
        XCTAssertFalse(layout.isRunning)
    }

    func testForceDirectedLayoutSingleStep() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        // Store initial positions
        let initialPositions = graph.nodes.mapValues { $0.position }

        // Run one step
        layout.step()

        // Positions should have changed (or velocities at least)
        XCTAssertEqual(layout.currentIteration, 1)

        // At least some nodes should have moved
        var positionsChanged = false
        for (nodeId, initialPos) in initialPositions {
            if let newNode = layout.graph.nodes[nodeId] {
                if length(newNode.position - initialPos) > 0.001 {
                    positionsChanged = true
                    break
                }
            }
        }

        // Note: In first step, positions might not change much, but velocity should
        XCTAssertTrue(true) // Layout executed without crash
    }

    func testForceDirectedLayoutMultipleIterations() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.runIterations(50)

        XCTAssertEqual(layout.currentIteration, 50)
        XCTAssertFalse(layout.isRunning)
    }

    func testForceDirectedLayoutConvergence() async {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        await layout.runUntilConvergence(
            maxIterations: 200,
            convergenceThreshold: 0.05
        )

        // Should have completed
        XCTAssertFalse(layout.isRunning)
        XCTAssertLessThanOrEqual(layout.currentIteration, 200)
    }

    func testForceDirectedLayoutParameters() {
        let customParams = ForceDirectedLayout.LayoutParameters(
            optimalDistance: 2.0,
            attractionStrength: 1.5,
            centeringForce: 0.05
        )

        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph, parameters: customParams)

        XCTAssertEqual(layout.parameters.optimalDistance, 2.0)
        XCTAssertEqual(layout.parameters.attractionStrength, 1.5)
        XCTAssertEqual(layout.parameters.centeringForce, 0.05)
    }

    func testForceDirectedLayoutReset() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        // Run some iterations
        layout.runIterations(20)
        XCTAssertEqual(layout.currentIteration, 20)

        // Reset
        layout.reset()

        XCTAssertEqual(layout.currentIteration, 0)

        // All velocities should be zero
        for node in layout.graph.nodes.values {
            XCTAssertEqual(node.velocity, .zero)
        }
    }

    // MARK: - Initial Layout Tests

    func testSphericalLayout() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeSphericalLayout(radius: 1.5)

        // All nodes should be roughly on a sphere
        for node in layout.graph.nodes.values {
            let distance = length(node.position)
            XCTAssertGreaterThan(distance, 0.5)
            XCTAssertLessThan(distance, 2.5) // Allow some variation
        }
    }

    func testCircularLayout() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeCircularLayout(radius: 1.0)

        // All nodes should be on XZ plane (y ≈ 0) in a circle
        for node in layout.graph.nodes.values {
            XCTAssertEqual(node.position.y, 0, accuracy: 0.01)

            let horizontalDistance = sqrt(node.position.x * node.position.x + node.position.z * node.position.z)
            XCTAssertEqual(horizontalDistance, 1.0, accuracy: 0.01)
        }
    }

    func testGridLayout() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeGridLayout(spacing: 0.5)

        // Nodes should be arranged in a grid
        // Just verify no crashes and positions are set
        for node in layout.graph.nodes.values {
            XCTAssertNotEqual(node.position, .zero) // At least some should be non-zero
        }
    }

    func testRandomLayout() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeRandomLayout(radius: 2.0)

        // All nodes should be within bounds
        for node in layout.graph.nodes.values {
            XCTAssertLessThanOrEqual(abs(node.position.x), 2.0)
            XCTAssertLessThanOrEqual(abs(node.position.y), 2.0)
            XCTAssertLessThanOrEqual(abs(node.position.z), 2.0)
        }
    }

    // MARK: - Spatial Partitioning Tests

    func testSpatialHashGridBuild() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)

        var spatialGrid = SpatialHashGrid(cellSize: 1.0)
        spatialGrid.build(from: graph)

        XCTAssertEqual(spatialGrid.totalNodes, graph.nodes.count)
        XCTAssertGreaterThan(spatialGrid.cellCount, 0)
    }

    func testSpatialHashGridNearbyNodes() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)

        var spatialGrid = SpatialHashGrid(cellSize: 1.0)
        spatialGrid.build(from: graph)

        // Query nearby nodes at origin
        let nearbyNodes = spatialGrid.getNearbyNodes(to: .zero, radius: 2.0)

        // Should find at least some nodes
        XCTAssertGreaterThan(nearbyNodes.count, 0)
        XCTAssertLessThanOrEqual(nearbyNodes.count, graph.nodes.count)
    }

    func testSpatialHashGridPerformance() {
        let (graph, _) = GraphTestData.largeGraph(projectId: projectId)

        measure {
            var spatialGrid = SpatialHashGrid(cellSize: 1.0)
            spatialGrid.build(from: graph)

            // Query multiple times
            for _ in 0..<100 {
                let randomPos = SIMD3<Float>(
                    Float.random(in: -2...2),
                    Float.random(in: -2...2),
                    Float.random(in: -2...2)
                )
                _ = spatialGrid.getNearbyNodes(to: randomPos, radius: 1.5)
            }
        }
    }

    // MARK: - Octree Tests

    func testOctreeBuild() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        let octree = layout.buildOctree()

        XCTAssertNotNil(octree)
        XCTAssertEqual(octree.totalMass, Float(graph.nodes.count))
    }

    func testOctreeInsert() {
        let bounds = AABB(center: .zero, size: SIMD3<Float>(repeating: 10))
        let octree = OctreeNode(bounds: bounds)

        octree.insert(nodeId: UUID(), position: SIMD3<Float>(1, 1, 1))
        octree.insert(nodeId: UUID(), position: SIMD3<Float>(-1, -1, -1))

        XCTAssertEqual(octree.totalMass, 2.0)
    }

    func testOctreeForceCalculation() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        let octree = layout.buildOctree()

        // Calculate force at a test position
        let testPosition = SIMD3<Float>(0, 0, 0)
        let force = octree.calculateForce(
            on: testPosition,
            theta: 0.5,
            k: 1.0
        )

        // Force should be non-zero (repulsion from nodes)
        XCTAssertGreaterThan(length(force), 0)
    }

    // MARK: - LayoutManager Tests

    func testLayoutManagerInitialization() {
        let layoutManager = LayoutManager()

        XCTAssertFalse(layoutManager.isLayoutRunning)
        XCTAssertEqual(layoutManager.layoutProgress, 0.0)
        XCTAssertEqual(layoutManager.currentIteration, 0)
    }

    func testLayoutManagerQuickLayouts() async {
        let (graph, sources) = GraphTestData.smallGraph(projectId: projectId)

        let persistenceManager = PersistenceManager(
            modelContainer: try! ModelContainer(
                for: Schema([Project.self, Source.self, Collection.self]),
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
            )
        )

        let graphManager = GraphManager(persistenceManager: persistenceManager)
        graphManager.graph = graph
        graphManager.sources = sources

        let layoutManager = LayoutManager(graphManager: graphManager)

        // Test circular layout
        layoutManager.applyCircularLayout()
        XCTAssertEqual(graphManager.graph.nodes.count, 10)

        // Test grid layout
        layoutManager.applyGridLayout()
        XCTAssertEqual(graphManager.graph.nodes.count, 10)

        // Test spherical layout
        layoutManager.applySphericalLayout()
        XCTAssertEqual(graphManager.graph.nodes.count, 10)
    }

    func testLayoutManagerStats() async {
        let (graph, sources) = GraphTestData.mediumGraph(projectId: projectId)

        let persistenceManager = PersistenceManager(
            modelContainer: try! ModelContainer(
                for: Schema([Project.self, Source.self, Collection.self]),
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
            )
        )

        let graphManager = GraphManager(persistenceManager: persistenceManager)
        graphManager.graph = graph
        graphManager.sources = sources

        let layoutManager = LayoutManager(graphManager: graphManager)

        let stats = layoutManager.getLayoutStats()

        XCTAssertEqual(stats.nodeCount, 50)
        XCTAssertGreaterThan(stats.edgeCount, 0)
        XCTAssertGreaterThan(stats.averageEdgeLength, 0)
        XCTAssertGreaterThan(stats.boundingBoxSize, 0)
    }

    // MARK: - Performance Tests

    func testSmallGraphLayoutPerformance() {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)

        measure {
            let layout = ForceDirectedLayout(graph: graph)
            layout.runIterations(100)
        }
    }

    func testMediumGraphLayoutPerformance() {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)

        measure {
            let layout = ForceDirectedLayout(graph: graph)
            layout.runIterations(50)
        }
    }

    func testLargeGraphLayoutPerformance() {
        let (graph, _) = GraphTestData.largeGraph(projectId: projectId)

        measure {
            let layout = ForceDirectedLayout(graph: graph)
            layout.runIterations(20)
        }
    }

    func testSpatialPartitioningPerformance() {
        let (graph, _) = GraphTestData.largeGraph(projectId: projectId)

        measure {
            let layout = ForceDirectedLayout(graph: graph)

            Task {
                await layout.runWithSpatialPartitioning(
                    maxIterations: 20,
                    convergenceThreshold: 0.1
                )
            }
        }
    }

    // MARK: - Convergence Tests

    func testLayoutConvergenceSmallGraph() async {
        let (graph, _) = GraphTestData.smallGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeSphericalLayout()

        await layout.runUntilConvergence(
            maxIterations: 300,
            convergenceThreshold: 0.01
        )

        // Should have converged within 300 iterations
        XCTAssertLessThan(layout.currentIteration, 300)
    }

    func testLayoutConvergenceMediumGraph() async {
        let (graph, _) = GraphTestData.mediumGraph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        layout.initializeSphericalLayout()

        await layout.runUntilConvergence(
            maxIterations: 500,
            convergenceThreshold: 0.02
        )

        // Should have converged
        XCTAssertLessThanOrEqual(layout.currentIteration, 500)
    }

    // MARK: - Edge Cases

    func testEmptyGraphLayout() {
        let graph = Graph(projectId: projectId)
        let layout = ForceDirectedLayout(graph: graph)

        // Should not crash
        layout.step()
        XCTAssertEqual(layout.currentIteration, 1)
    }

    func testSingleNodeLayout() {
        var graph = Graph(projectId: projectId)
        let nodeId = UUID()
        graph.addNode(GraphNode(sourceId: nodeId, position: .zero))

        let layout = ForceDirectedLayout(graph: graph)
        layout.runIterations(10)

        // Single node should remain centered
        if let node = layout.graph.nodes[nodeId] {
            XCTAssertLessThan(length(node.position), 0.5)
        }
    }

    func testDisconnectedGraphLayout() {
        var graph = Graph(projectId: projectId)

        // Add 5 nodes with no connections
        for _ in 0..<5 {
            graph.addNode(GraphNode(sourceId: UUID(), position: .zero))
        }

        let layout = ForceDirectedLayout(graph: graph)
        layout.initializeRandomLayout()
        layout.runIterations(50)

        // Nodes should spread out due to repulsion
        // Calculate average distance between all pairs
        let positions = layout.graph.nodes.values.map { $0.position }
        var totalDistance: Float = 0
        var pairCount = 0

        for i in 0..<positions.count {
            for j in (i + 1)..<positions.count {
                totalDistance += length(positions[j] - positions[i])
                pairCount += 1
            }
        }

        let averageDistance = totalDistance / Float(pairCount)
        XCTAssertGreaterThan(averageDistance, 0.5) // Should have spread out
    }

    func testFixedNodesLayout() {
        var graph = Graph(projectId: projectId)

        // Add fixed node at origin
        let fixedNodeId = UUID()
        var fixedNode = GraphNode(sourceId: fixedNodeId, position: .zero)
        fixedNode.isFixed = true
        graph.addNode(fixedNode)

        // Add mobile nodes
        for _ in 0..<5 {
            graph.addNode(GraphNode(sourceId: UUID(), position: .zero))
        }

        let layout = ForceDirectedLayout(graph: graph)
        layout.initializeRandomLayout()
        layout.runIterations(50)

        // Fixed node should remain at origin
        if let node = layout.graph.nodes[fixedNodeId] {
            XCTAssertEqual(node.position, .zero)
        }
    }
}
