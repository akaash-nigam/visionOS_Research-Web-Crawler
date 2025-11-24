//
//  Project.swift
//  Research Web Crawler
//
//  Represents a research project containing sources and connections
//

import Foundation
import SwiftData

@Model
final class Project {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Project name
    var name: String

    /// Project description
    var projectDescription: String?

    /// Creation date
    var created: Date

    /// Last modification date
    var modified: Date

    /// Last opened date
    var lastOpened: Date?

    /// Owner user ID (Apple ID)
    var ownerId: String

    /// Whether project is shared with others
    var isShared: Bool

    /// Number of sources in project
    var sourceCount: Int

    /// Number of connections in project
    var connectionCount: Int

    /// Default layout type
    var defaultLayoutType: String

    /// Default citation style
    var defaultCitationStyle: String

    /// Path to graph data file (JSON)
    var graphDataPath: String?

    /// Relationships
    @Relationship(deleteRule: .cascade) var sources: [Source]
    @Relationship(deleteRule: .cascade) var collections: [Collection]

    // MARK: - Initialization

    init(
        name: String,
        ownerId: String,
        description: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.projectDescription = description
        self.ownerId = ownerId
        self.created = Date()
        self.modified = Date()
        self.isShared = false
        self.sourceCount = 0
        self.connectionCount = 0
        self.defaultLayoutType = "forceDirected"
        self.defaultCitationStyle = "apa"
        self.sources = []
        self.collections = []
    }

    // MARK: - Methods

    func updateModified() {
        self.modified = Date()
    }

    func incrementSourceCount() {
        sourceCount += 1
        updateModified()
    }

    func decrementSourceCount() {
        sourceCount = max(0, sourceCount - 1)
        updateModified()
    }

    func incrementConnectionCount() {
        connectionCount += 1
        updateModified()
    }

    func decrementConnectionCount() {
        connectionCount = max(0, connectionCount - 1)
        updateModified()
    }
}
