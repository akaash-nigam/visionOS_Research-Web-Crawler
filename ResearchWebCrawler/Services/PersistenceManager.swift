//
//  PersistenceManager.swift
//  Research Web Crawler
//
//  Handles all persistence operations
//

import Foundation
import SwiftData

final class PersistenceManager {
    // MARK: - Properties

    let modelContainer: ModelContainer
    private let graphDirectory: URL

    // MARK: - Initialization

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        // Setup graph data directory
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        self.graphDirectory = documentsPath.appendingPathComponent("Graphs")

        // Create directory if needed
        try? FileManager.default.createDirectory(
            at: graphDirectory,
            withIntermediateDirectories: true
        )

        print("✅ Persistence manager initialized")
        print("📁 Graph directory: \(graphDirectory.path)")
    }

    // MARK: - Project Operations

    @MainActor
    func fetchProjects() async throws -> [Project] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.modified, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    func saveProject(_ project: Project) async throws {
        let context = ModelContext(modelContainer)
        context.insert(project)
        try context.save()
    }

    @MainActor
    func deleteProject(_ project: Project) async throws {
        let context = ModelContext(modelContainer)
        context.delete(project)
        try context.save()

        // Delete graph file
        let graphFile = graphDirectory.appendingPathComponent("\(project.id.uuidString).json")
        try? FileManager.default.removeItem(at: graphFile)
    }

    // MARK: - Source Operations

    @MainActor
    func fetchSources(for projectId: UUID) async throws -> [Source] {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<Source> { source in
            source.projectId == projectId
        }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.created, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    func saveSource(_ source: Source) async throws {
        let context = ModelContext(modelContainer)
        context.insert(source)
        try context.save()
    }

    @MainActor
    func updateSource(_ source: Source) async throws {
        let context = ModelContext(modelContainer)
        try context.save()
    }

    @MainActor
    func deleteSource(_ source: Source) async throws {
        let context = ModelContext(modelContainer)
        context.delete(source)
        try context.save()

        // Delete associated PDF if exists
        if let pdfPath = source.pdfFilePath,
           let pdfURL = URL(string: pdfPath) {
            try? FileManager.default.removeItem(at: pdfURL)
        }
    }

    // MARK: - Graph Operations

    func saveGraph(_ graph: Graph, for projectId: UUID) async throws {
        let graphFile = graphDirectory.appendingPathComponent("\(projectId.uuidString).json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(graph)

        try data.write(to: graphFile)
        print("✅ Saved graph: \(graphFile.lastPathComponent)")
    }

    func loadGraph(for projectId: UUID) async throws -> Graph {
        let graphFile = graphDirectory.appendingPathComponent("\(projectId.uuidString).json")

        guard FileManager.default.fileExists(atPath: graphFile.path) else {
            // Return empty graph if file doesn't exist
            return Graph(projectId: projectId)
        }

        let data = try Data(contentsOf: graphFile)
        let decoder = JSONDecoder()
        let graph = try decoder.decode(Graph.self, from: data)

        print("✅ Loaded graph: \(graphFile.lastPathComponent)")
        return graph
    }

    func deleteGraph(for projectId: UUID) async throws {
        let graphFile = graphDirectory.appendingPathComponent("\(projectId.uuidString).json")
        try FileManager.default.removeItem(at: graphFile)
    }
}
