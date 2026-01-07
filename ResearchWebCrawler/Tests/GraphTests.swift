//
//  GraphTests.swift
//  Research Web Crawler Tests
//
//  Unit tests for Graph data structure
//

import XCTest
@testable import ResearchWebCrawler

final class GraphTests: XCTestCase {
    var graph: Graph!
    let projectId = UUID()

    override func setUp() {
        super.setUp()
        graph = Graph(projectId: projectId)
    }

    override func tearDown() {
        graph = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testGraphInitialization() {
        XCTAssertEqual(graph.projectId, projectId)
        XCTAssertEqual(graph.version, 1)
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.edges.isEmpty)
        XCTAssertTrue(graph.adjacencyList.isEmpty)
    }

    // MARK: - Node Operations

    func testAddNode() {
        let nodeId = UUID()
        let node = GraphNode(
            sourceId: nodeId,
            position: SIMD3<Float>(0, 0, 0)
        )

        graph.addNode(node)

        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertNotNil(graph.nodes[nodeId])
        XCTAssertNotNil(graph.adjacencyList[nodeId])
        XCTAssertTrue(graph.adjacencyList[nodeId]!.isEmpty)
    }

    func testAddMultipleNodes() {
        for i in 0..<10 {
            let nodeId = UUID()
            let node = GraphNode(
                sourceId: nodeId,
                position: SIMD3<Float>(Float(i), 0, 0)
            )
            graph.addNode(node)
        }

        XCTAssertEqual(graph.nodes.count, 10)
        XCTAssertEqual(graph.adjacencyList.count, 10)
    }

    func testRemoveNode() {
        let nodeId = UUID()
        let node = GraphNode(sourceId: nodeId, position: .zero)

        graph.addNode(node)
        XCTAssertEqual(graph.nodes.count, 1)

        graph.removeNode(nodeId)
        XCTAssertEqual(graph.nodes.count, 0)
        XCTAssertNil(graph.nodes[nodeId])
        XCTAssertNil(graph.adjacencyList[nodeId])
    }

    func testRemoveNodeRemovesConnectedEdges() {
        let node1Id = UUID()
        let node2Id = UUID()
        let node3Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node3Id, position: .zero))

        let connection1 = Connection(
            from: node1Id,
            to: node2Id,
            type: .related,
            createdBy: "test"
        )
        let connection2 = Connection(
            from: node1Id,
            to: node3Id,
            type: .supports,
            createdBy: "test"
        )

        graph.addEdge(connection1)
        graph.addEdge(connection2)

        XCTAssertEqual(graph.edges.count, 2)

        // Remove node1
        graph.removeNode(node1Id)

        // Both edges should be removed
        XCTAssertEqual(graph.edges.count, 0)
        XCTAssertEqual(graph.nodes.count, 2)
    }

    // MARK: - Edge Operations

    func testAddEdge() {
        let node1Id = UUID()
        let node2Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))

        let connection = Connection(
            from: node1Id,
            to: node2Id,
            type: .related,
            createdBy: "test"
        )

        graph.addEdge(connection)

        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertNotNil(graph.edges[connection.id])
        XCTAssertTrue(graph.adjacencyList[node1Id]!.contains(node2Id))
    }

    func testAddBidirectionalEdge() {
        let node1Id = UUID()
        let node2Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))

        var connection = Connection(
            from: node1Id,
            to: node2Id,
            type: .related,
            createdBy: "test"
        )
        connection.bidirectional = true

        graph.addEdge(connection)

        XCTAssertTrue(graph.adjacencyList[node1Id]!.contains(node2Id))
        XCTAssertTrue(graph.adjacencyList[node2Id]!.contains(node1Id))
    }

    func testRemoveEdge() {
        let node1Id = UUID()
        let node2Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))

        let connection = Connection(
            from: node1Id,
            to: node2Id,
            type: .related,
            createdBy: "test"
        )

        graph.addEdge(connection)
        XCTAssertEqual(graph.edges.count, 1)

        graph.removeEdge(connection.id)
        XCTAssertEqual(graph.edges.count, 0)
        XCTAssertFalse(graph.adjacencyList[node1Id]!.contains(node2Id))
    }

    // MARK: - Query Operations

    func testNeighbors() {
        let node1Id = UUID()
        let node2Id = UUID()
        let node3Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node3Id, position: .zero))

        graph.addEdge(Connection(from: node1Id, to: node2Id, type: .related, createdBy: "test"))
        graph.addEdge(Connection(from: node1Id, to: node3Id, type: .supports, createdBy: "test"))

        let neighbors = graph.neighbors(of: node1Id)

        XCTAssertEqual(neighbors.count, 2)
        XCTAssertTrue(neighbors.contains(node2Id))
        XCTAssertTrue(neighbors.contains(node3Id))
    }

    func testNeighborsEmptyForIsolatedNode() {
        let nodeId = UUID()
        graph.addNode(GraphNode(sourceId: nodeId, position: .zero))

        let neighbors = graph.neighbors(of: nodeId)
        XCTAssertTrue(neighbors.isEmpty)
    }

    func testIsConnected() {
        let node1Id = UUID()
        let node2Id = UUID()
        let node3Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node3Id, position: .zero))

        graph.addEdge(Connection(from: node1Id, to: node2Id, type: .related, createdBy: "test"))

        XCTAssertTrue(graph.isConnected(from: node1Id, to: node2Id))
        XCTAssertFalse(graph.isConnected(from: node2Id, to: node1Id)) // Unidirectional
        XCTAssertFalse(graph.isConnected(from: node1Id, to: node3Id))
    }

    func testDegree() {
        let node1Id = UUID()
        let node2Id = UUID()
        let node3Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node2Id, position: .zero))
        graph.addNode(GraphNode(sourceId: node3Id, position: .zero))

        XCTAssertEqual(graph.degree(of: node1Id), 0)

        graph.addEdge(Connection(from: node1Id, to: node2Id, type: .related, createdBy: "test"))
        XCTAssertEqual(graph.degree(of: node1Id), 1)

        graph.addEdge(Connection(from: node1Id, to: node3Id, type: .supports, createdBy: "test"))
        XCTAssertEqual(graph.degree(of: node1Id), 2)
    }

    // MARK: - Connection Type Tests

    func testConnectionTypes() {
        XCTAssertEqual(ConnectionType.cites.displayName, "Cites")
        XCTAssertEqual(ConnectionType.supports.displayName, "Supports")
        XCTAssertEqual(ConnectionType.contradicts.displayName, "Contradicts")
        XCTAssertEqual(ConnectionType.related.displayName, "Related")
    }

    func testConnectionTypeColors() {
        // Just verify colors are defined
        XCTAssertNotNil(ConnectionType.cites.color)
        XCTAssertNotNil(ConnectionType.supports.color)
        XCTAssertNotNil(ConnectionType.contradicts.color)
    }

    // MARK: - GraphNode Tests

    func testGraphNodeInitialization() {
        let nodeId = UUID()
        let position = SIMD3<Float>(1.0, 2.0, 3.0)
        let node = GraphNode(
            sourceId: nodeId,
            position: position,
            size: 0.1
        )

        XCTAssertEqual(node.sourceId, nodeId)
        XCTAssertEqual(node.position, position)
        XCTAssertEqual(node.size, 0.1)
        XCTAssertEqual(node.velocity, .zero)
        XCTAssertFalse(node.isFixed)
    }

    func testGraphNodeDefaultValues() {
        let node = GraphNode(sourceId: UUID())

        XCTAssertEqual(node.position, .zero)
        XCTAssertEqual(node.size, 0.05)
        XCTAssertFalse(node.isFixed)
    }

    // MARK: - Connection Tests

    func testConnectionInitialization() {
        let from = UUID()
        let to = UUID()
        let connection = Connection(
            from: from,
            to: to,
            type: .supports,
            createdBy: "test-user"
        )

        XCTAssertNotNil(connection.id)
        XCTAssertEqual(connection.fromSourceId, from)
        XCTAssertEqual(connection.toSourceId, to)
        XCTAssertEqual(connection.type, .supports)
        XCTAssertEqual(connection.strength, .moderate)
        XCTAssertFalse(connection.bidirectional)
        XCTAssertEqual(connection.createdBy, "test-user")
        XCTAssertNil(connection.annotation)
    }

    func testConnectionWithAnnotation() {
        let connection = Connection(
            from: UUID(),
            to: UUID(),
            type: .related,
            createdBy: "test",
            annotation: "Both discuss climate change"
        )

        XCTAssertEqual(connection.annotation, "Both discuss climate change")
    }

    // MARK: - Serialization Tests

    func testGraphSerialization() throws {
        // Add some nodes and edges
        let node1Id = UUID()
        let node2Id = UUID()

        graph.addNode(GraphNode(sourceId: node1Id, position: SIMD3<Float>(1, 0, 0)))
        graph.addNode(GraphNode(sourceId: node2Id, position: SIMD3<Float>(2, 0, 0)))
        graph.addEdge(Connection(from: node1Id, to: node2Id, type: .related, createdBy: "test"))

        // Serialize
        let encoder = JSONEncoder()
        let data = try encoder.encode(graph)

        // Deserialize
        let decoder = JSONDecoder()
        let decodedGraph = try decoder.decode(Graph.self, from: data)

        // Verify
        XCTAssertEqual(decodedGraph.projectId, graph.projectId)
        XCTAssertEqual(decodedGraph.nodes.count, graph.nodes.count)
        XCTAssertEqual(decodedGraph.edges.count, graph.edges.count)
        XCTAssertEqual(decodedGraph.adjacencyList.count, graph.adjacencyList.count)
    }

    func testEmptyGraphSerialization() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(graph)

        let decoder = JSONDecoder()
        let decodedGraph = try decoder.decode(Graph.self, from: data)

        XCTAssertEqual(decodedGraph.projectId, graph.projectId)
        XCTAssertTrue(decodedGraph.nodes.isEmpty)
        XCTAssertTrue(decodedGraph.edges.isEmpty)
    }

    // MARK: - Performance Tests

    func testLargeGraphCreation() {
        measure {
            var testGraph = Graph(projectId: UUID())

            for i in 0..<100 {
                let nodeId = UUID()
                testGraph.addNode(GraphNode(
                    sourceId: nodeId,
                    position: SIMD3<Float>(Float(i), 0, 0)
                ))
            }
        }
    }

    func testLargeGraphConnections() {
        // Create 100 nodes
        var nodeIds: [UUID] = []
        for i in 0..<100 {
            let nodeId = UUID()
            nodeIds.append(nodeId)
            graph.addNode(GraphNode(
                sourceId: nodeId,
                position: SIMD3<Float>(Float(i), 0, 0)
            ))
        }

        measure {
            // Add 150 random connections
            for _ in 0..<150 {
                let from = nodeIds.randomElement()!
                let to = nodeIds.randomElement()!

                if from != to {
                    let connection = Connection(
                        from: from,
                        to: to,
                        type: .related,
                        createdBy: "test"
                    )
                    graph.addEdge(connection)
                }
            }
        }
    }

    func testNeighborQueryPerformance() {
        // Create connected graph
        var nodeIds: [UUID] = []
        for i in 0..<100 {
            let nodeId = UUID()
            nodeIds.append(nodeId)
            graph.addNode(GraphNode(
                sourceId: nodeId,
                position: SIMD3<Float>(Float(i), 0, 0)
            ))
        }

        // Connect each node to 5 random others
        for nodeId in nodeIds {
            for _ in 0..<5 {
                let target = nodeIds.randomElement()!
                if nodeId != target {
                    graph.addEdge(Connection(
                        from: nodeId,
                        to: target,
                        type: .related,
                        createdBy: "test"
                    ))
                }
            }
        }

        measure {
            for nodeId in nodeIds {
                _ = graph.neighbors(of: nodeId)
            }
        }
    }

    // MARK: - Edge Cases

    func testAddEdgeWithoutNodes() {
        // Adding edge before nodes exist should still work
        // (adjacency list won't have entries, but edge is stored)
        let connection = Connection(
            from: UUID(),
            to: UUID(),
            type: .related,
            createdBy: "test"
        )

        graph.addEdge(connection)
        XCTAssertEqual(graph.edges.count, 1)
    }

    func testRemoveNonexistentNode() {
        let nodeId = UUID()
        // Should not crash
        graph.removeNode(nodeId)
        XCTAssertEqual(graph.nodes.count, 0)
    }

    func testRemoveNonexistentEdge() {
        let edgeId = UUID()
        // Should not crash
        graph.removeEdge(edgeId)
        XCTAssertEqual(graph.edges.count, 0)
    }

    func testSelfLoop() {
        let nodeId = UUID()
        graph.addNode(GraphNode(sourceId: nodeId, position: .zero))

        let connection = Connection(
            from: nodeId,
            to: nodeId, // Self loop
            type: .related,
            createdBy: "test"
        )

        graph.addEdge(connection)

        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertTrue(graph.isConnected(from: nodeId, to: nodeId))
    }
}
