//
//  GraphManager.swift
//  Research Web Crawler
//
//  Manages graph operations and state
//

import Foundation
import Observation

@Observable
final class GraphManager {
    // MARK: - Properties

    private let persistenceManager: PersistenceManager

    /// Current project
    var currentProject: Project?

    /// Current graph
    var graph: Graph

    /// All sources (cached)
    var sources: [Source] = []

    /// All connections (cached)
    var connections: [Connection] = []

    // MARK: - Initialization

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
        self.graph = Graph(projectId: UUID())

        // Load or create default project
        Task {
            await loadDefaultProject()
        }
    }

    // MARK: - Project Management

    @MainActor
    func loadDefaultProject() async {
        do {
            // Try to load existing project
            let projects = try await persistenceManager.fetchProjects()

            if let project = projects.first {
                currentProject = project
                graph = Graph(projectId: project.id)

                // Load graph data
                if let graphData = try? await persistenceManager.loadGraph(for: project.id) {
                    graph = graphData
                }

                // Load sources
                sources = try await persistenceManager.fetchSources(for: project.id)
                connections = Array(graph.edges.values)

                print("✅ Loaded project: \(project.name)")
            } else {
                // Create default project
                await createDefaultProject()
            }
        } catch {
            print("❌ Error loading project: \(error)")
        }
    }

    @MainActor
    private func createDefaultProject() async {
        do {
            let project = Project(
                name: "My Research",
                ownerId: "default-user"
            )

            try await persistenceManager.saveProject(project)
            currentProject = project
            graph = Graph(projectId: project.id)

            print("✅ Created default project")
        } catch {
            print("❌ Error creating project: \(error)")
        }
    }

    // MARK: - Source Operations

    @MainActor
    func addSource(_ source: Source) async {
        do {
            try await persistenceManager.saveSource(source)
            sources.append(source)

            // Add node to graph
            let node = GraphNode(
                sourceId: source.id,
                position: randomPosition(),
                size: 0.05,
                color: colorForSourceType(source.type)
            )
            graph.addNode(node)

            // Save graph
            try await persistenceManager.saveGraph(graph, for: source.projectId)

            // Update project stats
            currentProject?.incrementSourceCount()

            print("✅ Added source: \(source.title)")
        } catch {
            print("❌ Error adding source: \(error)")
        }
    }

    @MainActor
    func removeSource(_ source: Source) async {
        do {
            try await persistenceManager.deleteSource(source)
            sources.removeAll { $0.id == source.id }

            // Remove node from graph
            graph.removeNode(source.id)

            // Save graph
            try await persistenceManager.saveGraph(graph, for: source.projectId)

            // Update project stats
            currentProject?.decrementSourceCount()
            currentProject?.connectionCount = graph.edges.count

            print("✅ Removed source: \(source.title)")
        } catch {
            print("❌ Error removing source: \(error)")
        }
    }

    // MARK: - Connection Operations

    @MainActor
    func addConnection(_ connection: Connection) async {
        do {
            graph.addEdge(connection)
            connections.append(connection)

            // Save graph
            try await persistenceManager.saveGraph(graph, for: currentProject!.id)

            // Update project stats
            currentProject?.incrementConnectionCount()

            print("✅ Added connection")
        } catch {
            print("❌ Error adding connection: \(error)")
        }
    }

    @MainActor
    func removeConnection(_ connection: Connection) async {
        do {
            graph.removeEdge(connection.id)
            connections.removeAll { $0.id == connection.id }

            // Save graph
            try await persistenceManager.saveGraph(graph, for: currentProject!.id)

            // Update project stats
            currentProject?.decrementConnectionCount()

            print("✅ Removed connection")
        } catch {
            print("❌ Error removing connection: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func randomPosition() -> SIMD3<Float> {
        SIMD3<Float>(
            Float.random(in: -2...2),
            Float.random(in: -2...2),
            Float.random(in: -2...2)
        )
    }

    private func colorForSourceType(_ type: SourceType) -> CodableColor {
        switch type {
        case .article: return CodableColor(red: 0, green: 0, blue: 1, alpha: 1)
        case .academicPaper: return CodableColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
        case .book: return CodableColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1)
        default: return CodableColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
    }
}
