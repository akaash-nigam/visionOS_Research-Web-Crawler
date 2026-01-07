//
//  Graph.swift
//  Research Web Crawler
//
//  Represents the graph structure with nodes and edges
//

import Foundation

// MARK: - Graph

struct Graph: Codable {
    // MARK: - Properties

    var projectId: UUID
    var version: Int
    var lastModified: Date

    /// Nodes (sourceId -> node data)
    var nodes: [UUID: GraphNode]

    /// Edges (connectionId -> connection)
    var edges: [UUID: Connection]

    /// Adjacency list for fast traversal
    var adjacencyList: [UUID: Set<UUID>]

    /// Layout state
    var layoutState: LayoutState

    // MARK: - Initialization

    init(projectId: UUID) {
        self.projectId = projectId
        self.version = 1
        self.lastModified = Date()
        self.nodes = [:]
        self.edges = [:]
        self.adjacencyList = [:]
        self.layoutState = LayoutState()
    }

    // MARK: - Node Operations

    mutating func addNode(_ node: GraphNode) {
        nodes[node.sourceId] = node
        adjacencyList[node.sourceId] = []
        lastModified = Date()
    }

    mutating func removeNode(_ sourceId: UUID) {
        nodes.removeValue(forKey: sourceId)
        adjacencyList.removeValue(forKey: sourceId)

        // Remove all edges connected to this node
        let connectedEdges = edges.filter { $0.value.fromSourceId == sourceId || $0.value.toSourceId == sourceId }
        for (edgeId, _) in connectedEdges {
            removeEdge(edgeId)
        }

        lastModified = Date()
    }

    // MARK: - Edge Operations

    mutating func addEdge(_ connection: Connection) {
        edges[connection.id] = connection

        // Update adjacency list
        adjacencyList[connection.fromSourceId, default: []].insert(connection.toSourceId)
        if connection.bidirectional {
            adjacencyList[connection.toSourceId, default: []].insert(connection.fromSourceId)
        }

        lastModified = Date()
    }

    mutating func removeEdge(_ connectionId: UUID) {
        guard let connection = edges[connectionId] else { return }

        edges.removeValue(forKey: connectionId)

        // Update adjacency list
        adjacencyList[connection.fromSourceId]?.remove(connection.toSourceId)
        if connection.bidirectional {
            adjacencyList[connection.toSourceId]?.remove(connection.fromSourceId)
        }

        lastModified = Date()
    }

    // MARK: - Query Methods

    func neighbors(of sourceId: UUID) -> [UUID] {
        Array(adjacencyList[sourceId] ?? [])
    }

    func isConnected(from: UUID, to: UUID) -> Bool {
        adjacencyList[from]?.contains(to) ?? false
    }

    func degree(of sourceId: UUID) -> Int {
        adjacencyList[sourceId]?.count ?? 0
    }
}

// MARK: - GraphNode

struct GraphNode: Codable, Identifiable {
    var id: UUID { sourceId }

    let sourceId: UUID
    var position: SIMD3<Float>
    var velocity: SIMD3<Float>
    var size: Float
    var color: CodableColor
    var isFixed: Bool

    init(
        sourceId: UUID,
        position: SIMD3<Float> = .zero,
        size: Float = 0.05,
        color: CodableColor = CodableColor(red: 0, green: 0, blue: 1, alpha: 1)
    ) {
        self.sourceId = sourceId
        self.position = position
        self.velocity = .zero
        self.size = size
        self.color = color
        self.isFixed = false
    }
}

// MARK: - Connection

struct Connection: Codable, Identifiable {
    // MARK: - Properties

    var id: UUID
    var fromSourceId: UUID
    var toSourceId: UUID
    var type: ConnectionType
    var strength: ConnectionStrength
    var bidirectional: Bool
    var annotation: String?
    var created: Date
    var modified: Date
    var createdBy: String

    // MARK: - Initialization

    init(
        from: UUID,
        to: UUID,
        type: ConnectionType,
        createdBy: String,
        annotation: String? = nil
    ) {
        self.id = UUID()
        self.fromSourceId = from
        self.toSourceId = to
        self.type = type
        self.strength = .moderate
        self.bidirectional = false
        self.annotation = annotation
        self.created = Date()
        self.modified = Date()
        self.createdBy = createdBy
    }
}

// MARK: - ConnectionType

enum ConnectionType: String, Codable, CaseIterable {
    case cites
    case supports
    case contradicts
    case related
    case quotes
    case inspires
    case extends
    case critiques

    var displayName: String {
        switch self {
        case .cites: return "Cites"
        case .supports: return "Supports"
        case .contradicts: return "Contradicts"
        case .related: return "Related"
        case .quotes: return "Quotes"
        case .inspires: return "Inspires"
        case .extends: return "Extends"
        case .critiques: return "Critiques"
        }
    }

    var color: CodableColor {
        switch self {
        case .cites: return CodableColor(red: 0, green: 0, blue: 1, alpha: 1) // Blue
        case .supports: return CodableColor(red: 0, green: 1, blue: 0, alpha: 1) // Green
        case .contradicts: return CodableColor(red: 1, green: 0, blue: 0, alpha: 1) // Red
        case .related: return CodableColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1) // Gray
        case .quotes: return CodableColor(red: 1, green: 1, blue: 0, alpha: 1) // Yellow
        case .inspires: return CodableColor(red: 1, green: 0.5, blue: 0, alpha: 1) // Orange
        case .extends: return CodableColor(red: 0.5, green: 0, blue: 0.5, alpha: 1) // Purple
        case .critiques: return CodableColor(red: 1, green: 0, blue: 0.5, alpha: 1) // Pink
        }
    }
}

// MARK: - ConnectionStrength

enum ConnectionStrength: String, Codable {
    case weak
    case moderate
    case strong
}

// MARK: - LayoutState

struct LayoutState: Codable {
    var currentLayout: String
    var cameraPosition: SIMD3<Float>?
    var cameraTarget: SIMD3<Float>?
    var zoom: Float

    init() {
        self.currentLayout = "forceDirected"
        self.zoom = 1.0
    }
}

// MARK: - CodableColor

struct CodableColor: Codable {
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float

    init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
