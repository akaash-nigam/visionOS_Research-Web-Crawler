//
//  ModelTests.swift
//  Research Web Crawler Tests
//
//  Unit tests for SwiftData models
//

import XCTest
import SwiftData
@testable import ResearchWebCrawler

@MainActor
final class ModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

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

        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Project Tests

    func testProjectCreation() throws {
        let project = Project(
            name: "Test Project",
            ownerId: "test-user"
        )

        XCTAssertNotNil(project.id)
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.ownerId, "test-user")
        XCTAssertFalse(project.isShared)
        XCTAssertEqual(project.sourceCount, 0)
        XCTAssertEqual(project.connectionCount, 0)
        XCTAssertEqual(project.defaultLayoutType, "forceDirected")
        XCTAssertEqual(project.defaultCitationStyle, "apa")
    }

    func testProjectPersistence() throws {
        let project = Project(
            name: "Persistent Project",
            ownerId: "test-user"
        )

        modelContext.insert(project)
        try modelContext.save()

        // Fetch from context
        let descriptor = FetchDescriptor<Project>()
        let projects = try modelContext.fetch(descriptor)

        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "Persistent Project")
    }

    func testProjectSourceCountIncrement() throws {
        let project = Project(name: "Test", ownerId: "test")

        XCTAssertEqual(project.sourceCount, 0)

        project.incrementSourceCount()
        XCTAssertEqual(project.sourceCount, 1)

        project.incrementSourceCount()
        XCTAssertEqual(project.sourceCount, 2)
    }

    func testProjectSourceCountDecrement() throws {
        let project = Project(name: "Test", ownerId: "test")
        project.sourceCount = 3

        project.decrementSourceCount()
        XCTAssertEqual(project.sourceCount, 2)

        project.decrementSourceCount()
        project.decrementSourceCount()
        project.decrementSourceCount()
        // Should not go negative
        XCTAssertEqual(project.sourceCount, 0)
    }

    func testProjectModifiedDateUpdate() throws {
        let project = Project(name: "Test", ownerId: "test")
        let originalDate = project.modified

        // Wait a bit to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)

        project.updateModified()
        XCTAssertGreaterThan(project.modified, originalDate)
    }

    // MARK: - Source Tests

    func testSourceCreation() throws {
        let projectId = UUID()
        let source = Source(
            title: "Test Article",
            type: .article,
            projectId: projectId,
            addedBy: "test-user"
        )

        XCTAssertNotNil(source.id)
        XCTAssertEqual(source.title, "Test Article")
        XCTAssertEqual(source.type, .article)
        XCTAssertEqual(source.projectId, projectId)
        XCTAssertEqual(source.addedBy, "test-user")
        XCTAssertTrue(source.authors.isEmpty)
        XCTAssertTrue(source.tags.isEmpty)
        XCTAssertFalse(source.isFavorite)
        XCTAssertEqual(source.connectionCount, 0)
    }

    func testSourcePersistence() throws {
        let source = Source(
            title: "Persistent Source",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )

        modelContext.insert(source)
        try modelContext.save()

        let descriptor = FetchDescriptor<Source>()
        let sources = try modelContext.fetch(descriptor)

        XCTAssertEqual(sources.count, 1)
        XCTAssertEqual(sources.first?.title, "Persistent Source")
        XCTAssertEqual(sources.first?.type, .academicPaper)
    }

    func testSourceWithMetadata() throws {
        let source = Source(
            title: "Research Paper",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )

        source.authors = ["John Doe", "Jane Smith"]
        source.doi = "10.1234/test"
        source.journal = "Nature"
        source.abstract = "This is a test abstract."
        source.tags = ["climate", "research"]

        XCTAssertEqual(source.authors.count, 2)
        XCTAssertEqual(source.doi, "10.1234/test")
        XCTAssertNotNil(source.abstract)
        XCTAssertEqual(source.tags.count, 2)
    }

    func testSourceTypeConversion() throws {
        let source = Source(
            title: "Test",
            type: .book,
            projectId: UUID(),
            addedBy: "test"
        )

        XCTAssertEqual(source.type, .book)
        XCTAssertEqual(source.sourceType, "book")

        // Change type
        source.type = .article
        XCTAssertEqual(source.type, .article)
        XCTAssertEqual(source.sourceType, "article")
    }

    func testSourceTypeProperties() throws {
        XCTAssertEqual(SourceType.article.displayName, "Article")
        XCTAssertEqual(SourceType.article.icon, "doc.text")

        XCTAssertEqual(SourceType.academicPaper.displayName, "Academic Paper")
        XCTAssertEqual(SourceType.academicPaper.icon, "graduationcap")

        XCTAssertEqual(SourceType.book.displayName, "Book")
        XCTAssertEqual(SourceType.book.icon, "book")
    }

    // MARK: - Collection Tests

    func testCollectionCreation() throws {
        let projectId = UUID()
        let collection = Collection(
            name: "My Collection",
            projectId: projectId
        )

        XCTAssertNotNil(collection.id)
        XCTAssertEqual(collection.name, "My Collection")
        XCTAssertEqual(collection.projectId, projectId)
        XCTAssertTrue(collection.sourceIds.isEmpty)
    }

    func testCollectionAddSource() throws {
        let collection = Collection(
            name: "Test",
            projectId: UUID()
        )

        let sourceId1 = UUID()
        let sourceId2 = UUID()

        collection.addSource(sourceId1)
        XCTAssertEqual(collection.sourceIds.count, 1)
        XCTAssertTrue(collection.contains(sourceId1))

        collection.addSource(sourceId2)
        XCTAssertEqual(collection.sourceIds.count, 2)

        // Adding duplicate should not increase count
        collection.addSource(sourceId1)
        XCTAssertEqual(collection.sourceIds.count, 2)
    }

    func testCollectionRemoveSource() throws {
        let collection = Collection(
            name: "Test",
            projectId: UUID()
        )

        let sourceId1 = UUID()
        let sourceId2 = UUID()

        collection.addSource(sourceId1)
        collection.addSource(sourceId2)
        XCTAssertEqual(collection.sourceIds.count, 2)

        collection.removeSource(sourceId1)
        XCTAssertEqual(collection.sourceIds.count, 1)
        XCTAssertFalse(collection.contains(sourceId1))
        XCTAssertTrue(collection.contains(sourceId2))
    }

    func testCollectionColorConversion() throws {
        let collection = Collection(
            name: "Test",
            projectId: UUID(),
            color: .blue
        )

        // Color should be stored as hex
        XCTAssertFalse(collection.colorHex.isEmpty)
        XCTAssertTrue(collection.colorHex.hasPrefix("#"))

        // Should be able to retrieve color
        let retrievedColor = collection.color
        XCTAssertNotNil(retrievedColor)
    }

    // MARK: - Relationship Tests

    func testProjectSourceRelationship() throws {
        let project = Project(name: "Test Project", ownerId: "test")
        let source = Source(
            title: "Test Source",
            type: .article,
            projectId: project.id,
            addedBy: "test"
        )

        project.sources.append(source)

        XCTAssertEqual(project.sources.count, 1)
        XCTAssertEqual(project.sources.first?.id, source.id)
    }

    func testProjectCollectionRelationship() throws {
        let project = Project(name: "Test Project", ownerId: "test")
        let collection = Collection(
            name: "Test Collection",
            projectId: project.id
        )

        project.collections.append(collection)

        XCTAssertEqual(project.collections.count, 1)
        XCTAssertEqual(project.collections.first?.id, collection.id)
    }

    // MARK: - Validation Tests

    func testProjectNameValidation() throws {
        // Empty name should still work (no validation yet)
        let project = Project(name: "", ownerId: "test")
        XCTAssertEqual(project.name, "")

        // Long name
        let longName = String(repeating: "a", count: 200)
        let project2 = Project(name: longName, ownerId: "test")
        XCTAssertEqual(project2.name.count, 200)
    }

    func testSourceTitleValidation() throws {
        // Empty title should work (no validation yet)
        let source = Source(
            title: "",
            type: .article,
            projectId: UUID(),
            addedBy: "test"
        )
        XCTAssertEqual(source.title, "")
    }

    // MARK: - Performance Tests

    func testBulkSourceInsertion() throws {
        let project = Project(name: "Bulk Test", ownerId: "test")
        modelContext.insert(project)

        measure {
            for i in 0..<100 {
                let source = Source(
                    title: "Source \(i)",
                    type: .article,
                    projectId: project.id,
                    addedBy: "test"
                )
                modelContext.insert(source)
            }

            try! modelContext.save()
        }
    }

    func testBulkSourceFetch() throws {
        let project = Project(name: "Fetch Test", ownerId: "test")
        modelContext.insert(project)

        // Insert 100 sources
        for i in 0..<100 {
            let source = Source(
                title: "Source \(i)",
                type: .article,
                projectId: project.id,
                addedBy: "test"
            )
            modelContext.insert(source)
        }
        try modelContext.save()

        measure {
            let descriptor = FetchDescriptor<Source>()
            _ = try! modelContext.fetch(descriptor)
        }
    }
}
