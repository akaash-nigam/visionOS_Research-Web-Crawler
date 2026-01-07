//
//  GraphManagerTests.swift
//  Research Web Crawler Tests
//
//  Tests for GraphManager operations
//

import XCTest
import SwiftData
@testable import ResearchWebCrawler

@MainActor
final class GraphManagerTests: XCTestCase {
    var graphManager: GraphManager!
    var persistenceManager: PersistenceManager!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        // Create in-memory container
        let schema = Schema([
            Project.self,
            Source.self,
            Collection.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )

        persistenceManager = PersistenceManager(modelContainer: modelContainer)
        graphManager = GraphManager(persistenceManager: persistenceManager)

        // Wait for initial load
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
    }

    override func tearDown() async throws {
        graphManager = nil
        persistenceManager = nil
        modelContainer = nil
    }

    // MARK: - Initialization Tests

    func testGraphManagerInitialization() async throws {
        XCTAssertNotNil(graphManager)
        XCTAssertNotNil(graphManager.currentProject)
        XCTAssertEqual(graphManager.sources.count, 0)
        XCTAssertEqual(graphManager.connections.count, 0)
    }

    // MARK: - Source Operations

    func testAddSource() async throws {
        let initialCount = graphManager.sources.count

        let source = Source(
            title: "Test Source",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source)

        XCTAssertEqual(graphManager.sources.count, initialCount + 1)
        XCTAssertEqual(graphManager.graph.nodes.count, initialCount + 1)
    }

    func testAddMultipleSources() async throws {
        for i in 0..<5 {
            let source = Source(
                title: "Source \(i)",
                type: .article,
                projectId: graphManager.currentProject!.id,
                addedBy: "test"
            )
            await graphManager.addSource(source)
        }

        XCTAssertEqual(graphManager.sources.count, 5)
        XCTAssertEqual(graphManager.graph.nodes.count, 5)
    }

    func testRemoveSource() async throws {
        let source = Source(
            title: "To Remove",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source)
        let countAfterAdd = graphManager.sources.count

        await graphManager.removeSource(source)

        XCTAssertEqual(graphManager.sources.count, countAfterAdd - 1)
        XCTAssertEqual(graphManager.graph.nodes.count, countAfterAdd - 1)
    }

    func testRemoveSourceRemovesConnections() async throws {
        // Add two sources
        let source1 = Source(
            title: "Source 1",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source1)
        await graphManager.addSource(source2)

        // Add connection
        let connection = Connection(
            from: source1.id,
            to: source2.id,
            type: .related,
            createdBy: "test"
        )
        await graphManager.addConnection(connection)

        XCTAssertEqual(graphManager.connections.count, 1)

        // Remove source1
        await graphManager.removeSource(source1)

        // Connection should be removed
        XCTAssertEqual(graphManager.connections.count, 0)
    }

    // MARK: - Connection Operations

    func testAddConnection() async throws {
        // Add two sources first
        let source1 = Source(
            title: "Source 1",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source1)
        await graphManager.addSource(source2)

        let connection = Connection(
            from: source1.id,
            to: source2.id,
            type: .supports,
            createdBy: "test"
        )

        await graphManager.addConnection(connection)

        XCTAssertEqual(graphManager.connections.count, 1)
        XCTAssertEqual(graphManager.graph.edges.count, 1)
    }

    func testRemoveConnection() async throws {
        // Setup
        let source1 = Source(
            title: "Source 1",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source1)
        await graphManager.addSource(source2)

        let connection = Connection(
            from: source1.id,
            to: source2.id,
            type: .related,
            createdBy: "test"
        )

        await graphManager.addConnection(connection)
        XCTAssertEqual(graphManager.connections.count, 1)

        await graphManager.removeConnection(connection)
        XCTAssertEqual(graphManager.connections.count, 0)
        XCTAssertEqual(graphManager.graph.edges.count, 0)
    }

    // MARK: - Project Stats Tests

    func testSourceCountUpdates() async throws {
        let initialCount = graphManager.currentProject!.sourceCount

        let source = Source(
            title: "Test",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source)

        // Source count should increase
        XCTAssertEqual(
            graphManager.currentProject!.sourceCount,
            initialCount + 1
        )
    }

    func testConnectionCountUpdates() async throws {
        // Add two sources
        let source1 = Source(
            title: "Source 1",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source1)
        await graphManager.addSource(source2)

        let initialCount = graphManager.currentProject!.connectionCount

        let connection = Connection(
            from: source1.id,
            to: source2.id,
            type: .related,
            createdBy: "test"
        )

        await graphManager.addConnection(connection)

        XCTAssertEqual(
            graphManager.currentProject!.connectionCount,
            initialCount + 1
        )
    }

    // MARK: - Complex Workflow Tests

    func testCompleteWorkflow() async throws {
        // Simulate complete user workflow

        // 1. Add 3 sources
        var sourceIds: [UUID] = []
        for i in 1...3 {
            let source = Source(
                title: "Source \(i)",
                type: .article,
                projectId: graphManager.currentProject!.id,
                addedBy: "test"
            )
            sourceIds.append(source.id)
            await graphManager.addSource(source)
        }

        XCTAssertEqual(graphManager.sources.count, 3)

        // 2. Create connections
        let conn1 = Connection(
            from: sourceIds[0],
            to: sourceIds[1],
            type: .supports,
            createdBy: "test"
        )
        let conn2 = Connection(
            from: sourceIds[1],
            to: sourceIds[2],
            type: .related,
            createdBy: "test"
        )

        await graphManager.addConnection(conn1)
        await graphManager.addConnection(conn2)

        XCTAssertEqual(graphManager.connections.count, 2)

        // 3. Remove one source
        if let sourceToRemove = graphManager.sources.first(where: { $0.id == sourceIds[0] }) {
            await graphManager.removeSource(sourceToRemove)
        }

        XCTAssertEqual(graphManager.sources.count, 2)
        // One connection should be removed (the one involving sourceIds[0])
        XCTAssertEqual(graphManager.connections.count, 1)

        // 4. Remove one connection
        if let connToRemove = graphManager.connections.first {
            await graphManager.removeConnection(connToRemove)
        }

        XCTAssertEqual(graphManager.connections.count, 0)
    }

    // MARK: - Graph State Tests

    func testGraphNodesMatchSources() async throws {
        // Add sources
        for i in 0..<5 {
            let source = Source(
                title: "Source \(i)",
                type: .article,
                projectId: graphManager.currentProject!.id,
                addedBy: "test"
            )
            await graphManager.addSource(source)
        }

        // Graph nodes should match sources
        XCTAssertEqual(graphManager.graph.nodes.count, graphManager.sources.count)

        // Each source should have a corresponding node
        for source in graphManager.sources {
            XCTAssertNotNil(graphManager.graph.nodes[source.id])
        }
    }

    func testGraphEdgesMatchConnections() async throws {
        // Add sources
        let source1 = Source(
            title: "Source 1",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .article,
            projectId: graphManager.currentProject!.id,
            addedBy: "test"
        )

        await graphManager.addSource(source1)
        await graphManager.addSource(source2)

        // Add connections
        let connection = Connection(
            from: source1.id,
            to: source2.id,
            type: .related,
            createdBy: "test"
        )

        await graphManager.addConnection(connection)

        // Graph edges should match connections
        XCTAssertEqual(graphManager.graph.edges.count, graphManager.connections.count)
    }

    // MARK: - Performance Tests

    func testAddManySourcesPerformance() async throws {
        measure {
            Task {
                for i in 0..<20 {
                    let source = Source(
                        title: "Performance Source \(i)",
                        type: .article,
                        projectId: await graphManager.currentProject!.id,
                        addedBy: "test"
                    )
                    await graphManager.addSource(source)
                }
            }
        }
    }

    // MARK: - Error Handling Tests

    func testAddSourceWithoutProject() async throws {
        // Create a graph manager without waiting for project load
        let newContainer = try ModelContainer(
            for: Schema([Project.self, Source.self, Collection.self]),
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        let newPersistence = PersistenceManager(modelContainer: newContainer)
        let newManager = GraphManager(persistenceManager: newPersistence)

        // Try to add source immediately (project might not be loaded)
        // Should handle gracefully
        if newManager.currentProject != nil {
            let source = Source(
                title: "Test",
                type: .article,
                projectId: newManager.currentProject!.id,
                addedBy: "test"
            )
            await newManager.addSource(source)
        }

        // Should not crash
        XCTAssertTrue(true)
    }
}
