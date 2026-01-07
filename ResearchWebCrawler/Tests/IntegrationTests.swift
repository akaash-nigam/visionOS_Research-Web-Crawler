//
//  IntegrationTests.swift
//  Research Web Crawler Tests
//
//  Integration tests for component interactions
//

import XCTest
import SwiftData
@testable import ResearchWebCrawler

@MainActor
final class IntegrationTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var graphManager: GraphManager!
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        // Create in-memory container
        let schema = Schema([Project.self, Source.self, Collection.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])

        persistenceManager = PersistenceManager(modelContainer: modelContainer)
        graphManager = GraphManager(persistenceManager: persistenceManager)
    }

    override func tearDown() {
        graphManager = nil
        persistenceManager = nil
        modelContainer = nil
    }

    // MARK: - Project → Source → Graph Workflow

    func testCompleteProjectWorkflow() {
        // Create project
        let project = Project(name: "Research Project", ownerId: "test")
        persistenceManager.saveProject(project)

        // Create sources
        let source1 = Source(
            title: "First Paper",
            type: .academicPaper,
            projectId: project.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Second Paper",
            type: .academicPaper,
            projectId: project.id,
            addedBy: "test"
        )

        persistenceManager.saveSource(source1)
        persistenceManager.saveSource(source2)

        // Load into graph manager
        graphManager.loadProject(project)

        // Verify graph state
        XCTAssertEqual(graphManager.sources.count, 2)
        XCTAssertEqual(graphManager.nodes.count, 2)
        XCTAssertNotNil(graphManager.currentProject)

        // Create relationship
        source2.addReference(to: source1.id)
        persistenceManager.saveSource(source2)

        // Reload and verify
        graphManager.loadProject(project)
        XCTAssertEqual(graphManager.edges.count, 1)
        XCTAssertEqual(graphManager.edges.first?.fromId, source2.id)
        XCTAssertEqual(graphManager.edges.first?.toId, source1.id)
    }

    func testMultiProjectIsolation() {
        let project1 = Project(name: "Project 1", ownerId: "test")
        let project2 = Project(name: "Project 2", ownerId: "test")

        persistenceManager.saveProject(project1)
        persistenceManager.saveProject(project2)

        let source1 = Source(
            title: "Source 1",
            type: .academicPaper,
            projectId: project1.id,
            addedBy: "test"
        )
        let source2 = Source(
            title: "Source 2",
            type: .academicPaper,
            projectId: project2.id,
            addedBy: "test"
        )

        persistenceManager.saveSource(source1)
        persistenceManager.saveSource(source2)

        // Load project 1
        graphManager.loadProject(project1)
        XCTAssertEqual(graphManager.sources.count, 1)
        XCTAssertEqual(graphManager.sources.first?.title, "Source 1")

        // Load project 2
        graphManager.loadProject(project2)
        XCTAssertEqual(graphManager.sources.count, 1)
        XCTAssertEqual(graphManager.sources.first?.title, "Source 2")
    }

    // MARK: - Web Scraping → Persistence Integration

    func testWebScrapingToPersistence() async throws {
        throw XCTSkip("Integration test - requires network connection")

        let webScraper = WebScraper()
        let project = Project(name: "Test Project", ownerId: "test")
        persistenceManager.saveProject(project)

        // Scrape URL
        let scraped = try await webScraper.scrape(url: "https://example.com")

        // Create source from scraped content
        let source = Source(
            title: scraped.title ?? "Unknown",
            type: .article,
            projectId: project.id,
            addedBy: "test"
        )
        source.authors = scraped.authors
        source.abstract = scraped.description
        source.url = scraped.url

        // Save to persistence
        persistenceManager.saveSource(source)

        // Verify saved
        let saved = persistenceManager.fetchSources(for: project.id)
        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved.first?.title, scraped.title)
    }

    // MARK: - Graph Layout → RealityKit Integration

    func testGraphLayoutToRealityKit() {
        let project = Project(name: "Layout Test", ownerId: "test")
        persistenceManager.saveProject(project)

        // Create sources
        for i in 0..<5 {
            let source = Source(
                title: "Source \(i)",
                type: .academicPaper,
                projectId: project.id,
                addedBy: "test"
            )
            persistenceManager.saveSource(source)
        }

        // Load into graph manager
        graphManager.loadProject(project)

        // Apply layout
        graphManager.applyLayout()

        // Verify all nodes have positions
        for node in graphManager.nodes {
            XCTAssertNotNil(node.position)
            XCTAssertNotEqual(node.position, .zero)
        }

        // Verify nodes are spread out (not all at same position)
        let positions = graphManager.nodes.map { $0.position }
        let uniquePositions = Set(positions.map { "\($0.x),\($0.y),\($0.z)" })
        XCTAssertGreaterThan(uniquePositions.count, 1)
    }

    // MARK: - Collection Management Integration

    func testCollectionSourcesIntegration() {
        let project = Project(name: "Collection Test", ownerId: "test")
        persistenceManager.saveProject(project)

        // Create sources
        let source1 = Source(title: "Source 1", type: .academicPaper, projectId: project.id, addedBy: "test")
        let source2 = Source(title: "Source 2", type: .book, projectId: project.id, addedBy: "test")
        let source3 = Source(title: "Source 3", type: .academicPaper, projectId: project.id, addedBy: "test")

        persistenceManager.saveSource(source1)
        persistenceManager.saveSource(source2)
        persistenceManager.saveSource(source3)

        // Create collection
        let collection = Collection(name: "My Papers", projectId: project.id, createdBy: "test")
        collection.addSource(source1.id)
        collection.addSource(source3.id)

        persistenceManager.saveCollection(collection)

        // Verify collection contains correct sources
        XCTAssertEqual(collection.sourceIds.count, 2)
        XCTAssertTrue(collection.contains(source1.id))
        XCTAssertTrue(collection.contains(source3.id))
        XCTAssertFalse(collection.contains(source2.id))

        // Load into graph manager
        graphManager.loadProject(project)

        // Filter by collection
        let collectionSources = graphManager.sources.filter { collection.contains($0.id) }
        XCTAssertEqual(collectionSources.count, 2)
    }

    // MARK: - Citation Formatting Integration

    func testCitationWithPersistence() {
        let project = Project(name: "Citation Test", ownerId: "test")
        persistenceManager.saveProject(project)

        let source = Source(
            title: "Test Paper",
            type: .academicPaper,
            projectId: project.id,
            addedBy: "test"
        )
        source.authors = ["John Doe", "Jane Smith"]
        source.journal = "Test Journal"
        source.publicationDate = Date()

        persistenceManager.saveSource(source)

        // Generate citation
        let citation = CitationFormatter.format(source, style: .apa)

        XCTAssertTrue(citation.contains("Doe, J."))
        XCTAssertTrue(citation.contains("Test Paper"))
        XCTAssertTrue(citation.contains("Test Journal"))

        // Generate bibliography for all sources
        let sources = persistenceManager.fetchSources(for: project.id)
        let bibliography = CitationFormatter.generateBibliography(
            sources: sources,
            style: .apa
        )

        XCTAssertFalse(bibliography.isEmpty)
        XCTAssertTrue(bibliography.contains("Test Paper"))
    }

    // MARK: - Search and Filter Integration

    func testSearchAcrossPersistence() {
        let project = Project(name: "Search Test", ownerId: "test")
        persistenceManager.saveProject(project)

        // Create diverse sources
        let source1 = Source(title: "Swift Programming", type: .book, projectId: project.id, addedBy: "test")
        source1.authors = ["Apple Inc."]

        let source2 = Source(title: "Python Basics", type: .book, projectId: project.id, addedBy: "test")
        source2.authors = ["Guido van Rossum"]

        let source3 = Source(title: "SwiftUI Tutorial", type: .article, projectId: project.id, addedBy: "test")
        source3.authors = ["John Doe"]

        persistenceManager.saveSource(source1)
        persistenceManager.saveSource(source2)
        persistenceManager.saveSource(source3)

        // Load into graph manager
        graphManager.loadProject(project)

        // Search for "Swift"
        let swiftResults = graphManager.sources.filter {
            $0.title.localizedCaseInsensitiveContains("Swift")
        }
        XCTAssertEqual(swiftResults.count, 2)

        // Filter by type
        let books = graphManager.sources.filter { $0.type == .book }
        XCTAssertEqual(books.count, 2)

        let articles = graphManager.sources.filter { $0.type == .article }
        XCTAssertEqual(articles.count, 1)
    }

    // MARK: - Error Recovery Integration

    func testPersistenceErrorRecovery() {
        // Test that graph manager handles missing sources gracefully
        let project = Project(name: "Error Test", ownerId: "test")
        persistenceManager.saveProject(project)

        let source = Source(
            title: "Test Source",
            type: .academicPaper,
            projectId: project.id,
            addedBy: "test"
        )
        let missingId = UUID()
        source.addReference(to: missingId)

        persistenceManager.saveSource(source)

        // Load into graph manager
        graphManager.loadProject(project)

        // Should load successfully even with missing reference
        XCTAssertEqual(graphManager.sources.count, 1)

        // Edge should not be created for missing reference
        XCTAssertEqual(graphManager.edges.count, 0)
    }

    // MARK: - Concurrent Operations

    func testConcurrentSourceAddition() async {
        let project = Project(name: "Concurrent Test", ownerId: "test")
        persistenceManager.saveProject(project)

        // Add sources concurrently
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask { [weak self] in
                    let source = Source(
                        title: "Source \(i)",
                        type: .academicPaper,
                        projectId: project.id,
                        addedBy: "test"
                    )
                    self?.persistenceManager.saveSource(source)
                }
            }
        }

        // Load and verify
        graphManager.loadProject(project)
        XCTAssertEqual(graphManager.sources.count, 10)
    }

    // MARK: - Performance Integration

    func testLargeDatasetIntegration() {
        let project = Project(name: "Large Dataset", ownerId: "test")
        persistenceManager.saveProject(project)

        // Create 100 sources
        for i in 0..<100 {
            let source = Source(
                title: "Source \(i)",
                type: .academicPaper,
                projectId: project.id,
                addedBy: "test"
            )
            persistenceManager.saveSource(source)
        }

        // Measure load time
        measure {
            graphManager.loadProject(project)
        }

        XCTAssertEqual(graphManager.sources.count, 100)
        XCTAssertEqual(graphManager.nodes.count, 100)
    }
}
