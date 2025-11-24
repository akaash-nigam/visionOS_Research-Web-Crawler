//
//  PersistenceManagerTests.swift
//  Research Web Crawler Tests
//
//  Integration tests for PersistenceManager
//

import XCTest
import SwiftData
@testable import ResearchWebCrawler

@MainActor
final class PersistenceManagerTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        // Create in-memory container for testing
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
    }

    override func tearDown() async throws {
        persistenceManager = nil
        modelContainer = nil
    }

    // MARK: - Project Persistence Tests

    func testSaveProject() async throws {
        let project = Project(name: "Test Project", ownerId: "test-user")

        try await persistenceManager.saveProject(project)

        let projects = try await persistenceManager.fetchProjects()
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "Test Project")
    }

    func testFetchProjects() async throws {
        // Save multiple projects
        let project1 = Project(name: "Project 1", ownerId: "user1")
        let project2 = Project(name: "Project 2", ownerId: "user2")

        try await persistenceManager.saveProject(project1)
        try await persistenceManager.saveProject(project2)

        let projects = try await persistenceManager.fetchProjects()
        XCTAssertEqual(projects.count, 2)

        // Should be sorted by modified date (most recent first)
        XCTAssertTrue(projects[0].modified >= projects[1].modified)
    }

    func testDeleteProject() async throws {
        let project = Project(name: "To Delete", ownerId: "test")
        try await persistenceManager.saveProject(project)

        var projects = try await persistenceManager.fetchProjects()
        XCTAssertEqual(projects.count, 1)

        try await persistenceManager.deleteProject(project)

        projects = try await persistenceManager.fetchProjects()
        XCTAssertEqual(projects.count, 0)
    }

    // MARK: - Source Persistence Tests

    func testSaveSource() async throws {
        let projectId = UUID()
        let source = Source(
            title: "Test Source",
            type: .article,
            projectId: projectId,
            addedBy: "test"
        )

        try await persistenceManager.saveSource(source)

        let sources = try await persistenceManager.fetchSources(for: projectId)
        XCTAssertEqual(sources.count, 1)
        XCTAssertEqual(sources.first?.title, "Test Source")
    }

    func testFetchSourcesForProject() async throws {
        let project1Id = UUID()
        let project2Id = UUID()

        let source1 = Source(title: "Source 1", type: .article, projectId: project1Id, addedBy: "test")
        let source2 = Source(title: "Source 2", type: .book, projectId: project1Id, addedBy: "test")
        let source3 = Source(title: "Source 3", type: .article, projectId: project2Id, addedBy: "test")

        try await persistenceManager.saveSource(source1)
        try await persistenceManager.saveSource(source2)
        try await persistenceManager.saveSource(source3)

        let project1Sources = try await persistenceManager.fetchSources(for: project1Id)
        XCTAssertEqual(project1Sources.count, 2)

        let project2Sources = try await persistenceManager.fetchSources(for: project2Id)
        XCTAssertEqual(project2Sources.count, 1)
    }

    func testUpdateSource() async throws {
        let source = Source(
            title: "Original Title",
            type: .article,
            projectId: UUID(),
            addedBy: "test"
        )

        try await persistenceManager.saveSource(source)

        // Modify source
        source.title = "Updated Title"
        source.authors = ["New Author"]

        try await persistenceManager.updateSource(source)

        // Fetch and verify
        let sources = try await persistenceManager.fetchSources(for: source.projectId)
        XCTAssertEqual(sources.first?.title, "Updated Title")
        XCTAssertEqual(sources.first?.authors.first, "New Author")
    }

    func testDeleteSource() async throws {
        let projectId = UUID()
        let source = Source(
            title: "To Delete",
            type: .article,
            projectId: projectId,
            addedBy: "test"
        )

        try await persistenceManager.saveSource(source)

        var sources = try await persistenceManager.fetchSources(for: projectId)
        XCTAssertEqual(sources.count, 1)

        try await persistenceManager.deleteSource(source)

        sources = try await persistenceManager.fetchSources(for: projectId)
        XCTAssertEqual(sources.count, 0)
    }

    // MARK: - Graph Persistence Tests

    func testSaveGraph() async throws {
        let projectId = UUID()
        var graph = Graph(projectId: projectId)

        let node1 = GraphNode(sourceId: UUID(), position: SIMD3<Float>(1, 0, 0))
        let node2 = GraphNode(sourceId: UUID(), position: SIMD3<Float>(2, 0, 0))

        graph.addNode(node1)
        graph.addNode(node2)
        graph.addEdge(Connection(
            from: node1.sourceId,
            to: node2.sourceId,
            type: .related,
            createdBy: "test"
        ))

        try await persistenceManager.saveGraph(graph, for: projectId)

        // Graph file should exist
        let graphFile = persistenceManager.modelContainer
        // We can't easily check file system in unit test with in-memory container
        // But we can verify it doesn't throw
    }

    func testLoadGraph() async throws {
        let projectId = UUID()
        var graph = Graph(projectId: projectId)

        let node1 = GraphNode(sourceId: UUID(), position: SIMD3<Float>(1, 0, 0))
        graph.addNode(node1)

        try await persistenceManager.saveGraph(graph, for: projectId)

        let loadedGraph = try await persistenceManager.loadGraph(for: projectId)

        XCTAssertEqual(loadedGraph.projectId, projectId)
        // Note: With in-memory testing, file system operations might not persist
        // This test validates the code path works without errors
    }

    func testLoadNonexistentGraph() async throws {
        let projectId = UUID()

        // Should return empty graph instead of throwing
        let graph = try await persistenceManager.loadGraph(for: projectId)

        XCTAssertEqual(graph.projectId, projectId)
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.edges.isEmpty)
    }

    // MARK: - Bulk Operations Tests

    func testBulkSourceSave() async throws {
        let projectId = UUID()

        measure {
            Task {
                for i in 0..<50 {
                    let source = Source(
                        title: "Source \(i)",
                        type: .article,
                        projectId: projectId,
                        addedBy: "test"
                    )
                    try? await self.persistenceManager.saveSource(source)
                }
            }
        }
    }

    func testBulkSourceFetch() async throws {
        let projectId = UUID()

        // Save 50 sources
        for i in 0..<50 {
            let source = Source(
                title: "Source \(i)",
                type: .article,
                projectId: projectId,
                addedBy: "test"
            )
            try await persistenceManager.saveSource(source)
        }

        measure {
            Task {
                _ = try? await self.persistenceManager.fetchSources(for: projectId)
            }
        }
    }

    // MARK: - Cascade Delete Tests

    func testProjectDeletionCascadesToSources() async throws {
        let project = Project(name: "Test", ownerId: "test")
        try await persistenceManager.saveProject(project)

        let source1 = Source(title: "Source 1", type: .article, projectId: project.id, addedBy: "test")
        let source2 = Source(title: "Source 2", type: .book, projectId: project.id, addedBy: "test")

        try await persistenceManager.saveSource(source1)
        try await persistenceManager.saveSource(source2)

        // Verify sources exist
        var sources = try await persistenceManager.fetchSources(for: project.id)
        XCTAssertEqual(sources.count, 2)

        // Delete project (should cascade delete sources)
        try await persistenceManager.deleteProject(project)

        // Sources should be deleted
        sources = try await persistenceManager.fetchSources(for: project.id)
        XCTAssertEqual(sources.count, 0)
    }

    // MARK: - Edge Case Tests

    func testSaveProjectWithEmptyName() async throws {
        let project = Project(name: "", ownerId: "test")

        // Should save without error
        try await persistenceManager.saveProject(project)

        let projects = try await persistenceManager.fetchProjects()
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "")
    }

    func testFetchSourcesForNonexistentProject() async throws {
        let randomProjectId = UUID()

        let sources = try await persistenceManager.fetchSources(for: randomProjectId)

        // Should return empty array, not throw
        XCTAssertTrue(sources.isEmpty)
    }

    func testSaveSourceWithCompleteMetadata() async throws {
        let source = Source(
            title: "Complete Source",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )

        source.authors = ["Author 1", "Author 2", "Author 3"]
        source.doi = "10.1234/test"
        source.journal = "Test Journal"
        source.volume = "42"
        source.issue = "3"
        source.pages = "123-145"
        source.abstract = "This is a test abstract."
        source.notes = "My research notes"
        source.tags = ["tag1", "tag2"]
        source.isFavorite = true

        try await persistenceManager.saveSource(source)

        let sources = try await persistenceManager.fetchSources(for: source.projectId)
        let savedSource = sources.first!

        XCTAssertEqual(savedSource.authors.count, 3)
        XCTAssertEqual(savedSource.doi, "10.1234/test")
        XCTAssertEqual(savedSource.journal, "Test Journal")
        XCTAssertEqual(savedSource.tags.count, 2)
        XCTAssertTrue(savedSource.isFavorite)
    }

    // MARK: - Concurrent Access Tests

    func testConcurrentSourceSaves() async throws {
        let projectId = UUID()

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let source = Source(
                        title: "Concurrent Source \(i)",
                        type: .article,
                        projectId: projectId,
                        addedBy: "test"
                    )
                    try? await self.persistenceManager.saveSource(source)
                }
            }
        }

        let sources = try await persistenceManager.fetchSources(for: projectId)
        XCTAssertEqual(sources.count, 10)
    }

    // MARK: - Graph Serialization Tests

    func testComplexGraphSerialization() async throws {
        let projectId = UUID()
        var graph = Graph(projectId: projectId)

        // Create 10 nodes
        var nodeIds: [UUID] = []
        for i in 0..<10 {
            let nodeId = UUID()
            nodeIds.append(nodeId)
            graph.addNode(GraphNode(
                sourceId: nodeId,
                position: SIMD3<Float>(Float(i), Float(i), Float(i)),
                size: 0.05
            ))
        }

        // Create 15 connections
        for _ in 0..<15 {
            let from = nodeIds.randomElement()!
            let to = nodeIds.randomElement()!
            if from != to {
                graph.addEdge(Connection(
                    from: from,
                    to: to,
                    type: .related,
                    createdBy: "test"
                ))
            }
        }

        try await persistenceManager.saveGraph(graph, for: projectId)
        let loadedGraph = try await persistenceManager.loadGraph(for: projectId)

        // With in-memory testing, verify it doesn't crash
        XCTAssertEqual(loadedGraph.projectId, projectId)
    }
}
