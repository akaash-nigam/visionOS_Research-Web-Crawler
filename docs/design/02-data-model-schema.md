# Data Model & Schema Design

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

This document defines the complete data model for Research Web Crawler, including entity schemas, relationships, storage strategies, and data flow patterns.

## Storage Architecture

### Storage Layers

```
┌─────────────────────────────────────────────┐
│          SwiftData (Metadata)               │
│  - Projects, Users, Settings                │
│  - Source Metadata, Collections             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│       Custom Graph Store (In-Memory)        │
│  - Graph Structure (Adjacency List)         │
│  - Layout Coordinates, Visual State         │
│  - Serialized to JSON/ProtoBuf              │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│          File System                        │
│  - PDFs, Images, Voice Notes                │
│  - Cached Web Content                       │
│  - Export Files                             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│          CloudKit (Sync)                    │
│  - Synced subset of above                   │
│  - Shared space data                        │
└─────────────────────────────────────────────┘
```

## Core Data Models

### 1. Project

**Purpose**: Top-level container for a research project

```swift
@Model
final class Project {
    // Identity
    @Attribute(.unique) var id: UUID
    var name: String
    var description: String?

    // Metadata
    var created: Date
    var modified: Date
    var lastOpened: Date?

    // Ownership & Sharing
    var ownerId: String // Apple ID
    var isShared: Bool
    var sharedWith: [SharedUser] // See below

    // Graph Data Reference
    var graphFileURL: URL? // Points to graph JSON file

    // Settings
    var defaultLayout: LayoutType
    var defaultCitationStyle: CitationStyle

    // Statistics
    var sourceCount: Int
    var connectionCount: Int

    // Relationships
    @Relationship(deleteRule: .cascade) var sources: [Source]
    @Relationship(deleteRule: .cascade) var collections: [Collection]
    @Relationship(deleteRule: .cascade) var comments: [Comment]

    init(name: String, ownerId: String) {
        self.id = UUID()
        self.name = name
        self.ownerId = ownerId
        self.created = Date()
        self.modified = Date()
        self.isShared = false
        self.sharedWith = []
        self.sourceCount = 0
        self.connectionCount = 0
        self.defaultLayout = .forceDirected
        self.defaultCitationStyle = .apa
        self.sources = []
        self.collections = []
        self.comments = []
    }
}

enum LayoutType: String, Codable {
    case forceDirected
    case hierarchical
    case radial
    case timeline
    case cluster
    case custom
}

enum CitationStyle: String, Codable {
    case apa
    case mla
    case chicago
    case harvard
    case ieee
    case vancouver
}
```

### 2. Source (Node)

**Purpose**: Represents a single information source in the knowledge graph

```swift
@Model
final class Source {
    // Identity
    @Attribute(.unique) var id: UUID
    var projectId: UUID

    // Core Metadata
    var title: String
    var authors: [String]
    var publicationDate: Date?
    var type: SourceType

    // Identifiers
    var url: URL?
    var doi: String?
    var isbn: String?
    var arxivId: String?
    var pmid: String? // PubMed ID

    // Publication Info
    var publisher: String?
    var journal: String?
    var volume: String?
    var issue: String?
    var pages: String?

    // Content
    var abstract: String?
    var fullText: String? // Extracted text
    var contentHash: String? // SHA-256 of content

    // Files
    var pdfFileURL: URL?
    var imageURLs: [URL] // Screenshots, figures

    // User Annotations
    var notes: String?
    var highlights: [Highlight]
    var tags: [String]
    var rating: Int? // 1-5 stars

    // Organization
    var collectionId: UUID?
    var isFavorite: Bool

    // Metadata
    var created: Date
    var modified: Date
    var addedBy: String // User ID

    // Graph Visualization
    var nodeSize: Double? // Computed or manual
    var nodeColor: Color? // Custom color override
    var position: Vector3D? // Saved position (custom layout)

    // AI-Generated
    var relevanceScore: Double? // 0.0-1.0
    var topicClusters: [String] // e.g., ["climate change", "agriculture"]
    var keyPhrases: [String]
    var embeddingVector: [Float]? // For semantic search

    // Statistics
    var citationCount: Int? // How many times it's cited in academic lit
    var connectionCount: Int // How many edges in our graph

    init(title: String, type: SourceType, projectId: UUID, addedBy: String) {
        self.id = UUID()
        self.title = title
        self.type = type
        self.projectId = projectId
        self.addedBy = addedBy
        self.authors = []
        self.highlights = []
        self.tags = []
        self.imageURLs = []
        self.isFavorite = false
        self.created = Date()
        self.modified = Date()
        self.connectionCount = 0
    }
}

enum SourceType: String, Codable, CaseIterable {
    case article
    case academicPaper
    case book
    case bookChapter
    case news
    case blogPost
    case video
    case podcast
    case dataset
    case socialMedia
    case wikipedia
    case patent
    case thesis
    case presentation
    case note // User-created note
    case other

    var displayName: String {
        switch self {
        case .article: return "Article"
        case .academicPaper: return "Academic Paper"
        case .book: return "Book"
        case .bookChapter: return "Book Chapter"
        case .news: return "News Article"
        case .blogPost: return "Blog Post"
        case .video: return "Video"
        case .podcast: return "Podcast"
        case .dataset: return "Dataset"
        case .socialMedia: return "Social Media"
        case .wikipedia: return "Wikipedia"
        case .patent: return "Patent"
        case .thesis: return "Thesis/Dissertation"
        case .presentation: return "Presentation"
        case .note: return "Note"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .academicPaper: return "graduationcap"
        case .book: return "book"
        case .bookChapter: return "book.pages"
        case .news: return "newspaper"
        case .blogPost: return "text.bubble"
        case .video: return "play.rectangle"
        case .podcast: return "mic"
        case .dataset: return "chart.bar"
        case .socialMedia: return "bubble.left.and.bubble.right"
        case .wikipedia: return "globe"
        case .patent: return "lightbulb"
        case .thesis: return "scroll"
        case .presentation: return "rectangle.on.rectangle"
        case .note: return "note.text"
        case .other: return "doc"
        }
    }
}

struct Highlight: Codable, Identifiable {
    var id: UUID
    var text: String
    var note: String?
    var color: HighlightColor
    var created: Date

    enum HighlightColor: String, Codable {
        case yellow, green, blue, pink, purple
    }
}

struct Vector3D: Codable {
    var x: Double
    var y: Double
    var z: Double
}
```

### 3. Connection (Edge)

**Purpose**: Represents relationships between sources

**Storage**: Stored in custom graph file (not SwiftData)

```swift
struct Connection: Codable, Identifiable {
    // Identity
    var id: UUID
    var fromSourceId: UUID
    var toSourceId: UUID

    // Relationship
    var type: ConnectionType
    var strength: ConnectionStrength
    var bidirectional: Bool

    // Annotation
    var annotation: String?
    var evidence: String? // Quote or reason for connection

    // Metadata
    var created: Date
    var modified: Date
    var createdBy: String // User ID

    // AI-Suggested
    var isAISuggested: Bool
    var suggestionConfidence: Double? // 0.0-1.0
    var userConfirmed: Bool // Did user accept suggestion?

    // Visualization
    var lineColor: Color?
    var lineWidth: Double?

    init(from: UUID, to: UUID, type: ConnectionType, createdBy: String) {
        self.id = UUID()
        self.fromSourceId = from
        self.toSourceId = to
        self.type = type
        self.strength = .moderate
        self.bidirectional = false
        self.created = Date()
        self.modified = Date()
        self.createdBy = createdBy
        self.isAISuggested = false
        self.userConfirmed = false
    }
}

enum ConnectionType: String, Codable, CaseIterable {
    case cites
    case supports
    case contradicts
    case related
    case quotes
    case inspires
    case extends
    case critiques
    case methodology
    case sameAuthor
    case custom

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
        case .methodology: return "Same Methodology"
        case .sameAuthor: return "Same Author"
        case .custom: return "Custom"
        }
    }

    var defaultColor: Color {
        switch self {
        case .cites: return .blue
        case .supports: return .green
        case .contradicts: return .red
        case .related: return .gray
        case .quotes: return .yellow
        case .inspires: return .orange
        case .extends: return .purple
        case .critiques: return .pink
        case .methodology: return .teal
        case .sameAuthor: return .brown
        case .custom: return .gray
        }
    }
}

enum ConnectionStrength: String, Codable {
    case weak
    case moderate
    case strong
}
```

### 4. Graph Structure

**Purpose**: In-memory representation of the complete graph

```swift
struct Graph: Codable {
    var projectId: UUID
    var version: Int
    var lastModified: Date

    // Core graph data
    var nodes: [UUID: GraphNode] // sourceId -> node data
    var edges: [UUID: Connection] // connectionId -> connection

    // Adjacency list for fast traversal
    var adjacencyList: [UUID: [UUID]] // sourceId -> [connected sourceIds]

    // Layout data
    var layoutState: LayoutState

    // Metadata
    var metadata: GraphMetadata

    init(projectId: UUID) {
        self.projectId = projectId
        self.version = 1
        self.lastModified = Date()
        self.nodes = [:]
        self.edges = [:]
        self.adjacencyList = [:]
        self.layoutState = LayoutState()
        self.metadata = GraphMetadata()
    }
}

struct GraphNode: Codable {
    var sourceId: UUID
    var position: Vector3D
    var velocity: Vector3D // For force-directed layout
    var size: Double
    var color: Color
    var isFixed: Bool // User manually positioned
}

struct LayoutState: Codable {
    var currentLayout: LayoutType
    var cameraPosition: Vector3D?
    var cameraTarget: Vector3D?
    var zoom: Double
    var parameters: [String: Double] // Layout-specific params
}

struct GraphMetadata: Codable {
    var totalEnergy: Double? // For force-directed layout
    var clusters: [Cluster]?
    var centralNodes: [UUID]? // High centrality
    var isolatedNodes: [UUID]? // No connections
}

struct Cluster: Codable, Identifiable {
    var id: UUID
    var name: String?
    var nodeIds: [UUID]
    var centroid: Vector3D
    var color: Color
}
```

### 5. Collection

**Purpose**: User-defined groups of sources

```swift
@Model
final class Collection {
    @Attribute(.unique) var id: UUID
    var projectId: UUID
    var name: String
    var description: String?
    var color: Color
    var icon: String?

    var created: Date
    var modified: Date

    // Relationships
    var sourceIds: [UUID] // Sources in this collection

    init(name: String, projectId: UUID, color: Color) {
        self.id = UUID()
        self.name = name
        self.projectId = projectId
        self.color = color
        self.created = Date()
        self.modified = Date()
        self.sourceIds = []
    }
}
```

### 6. Comment

**Purpose**: Collaborative comments on sources or connections

```swift
@Model
final class Comment {
    @Attribute(.unique) var id: UUID
    var projectId: UUID

    // What is being commented on
    var targetType: CommentTargetType
    var targetId: UUID // Source ID or Connection ID

    // Content
    var text: String
    var authorId: String
    var authorName: String

    // Threading
    var parentCommentId: UUID? // For replies
    var replyCount: Int

    // Metadata
    var created: Date
    var modified: Date
    var isEdited: Bool
    var isResolved: Bool

    init(text: String, targetType: CommentTargetType, targetId: UUID,
         authorId: String, authorName: String, projectId: UUID) {
        self.id = UUID()
        self.text = text
        self.targetType = targetType
        self.targetId = targetId
        self.authorId = authorId
        self.authorName = authorName
        self.projectId = projectId
        self.created = Date()
        self.modified = Date()
        self.isEdited = false
        self.isResolved = false
        self.replyCount = 0
    }
}

enum CommentTargetType: String, Codable {
    case source
    case connection
    case project
}
```

### 7. SharedUser

**Purpose**: Represents a user with access to a shared project

```swift
struct SharedUser: Codable, Identifiable {
    var id: String // Apple ID or email
    var name: String
    var email: String
    var role: CollaboratorRole
    var addedDate: Date
    var lastActive: Date?

    enum CollaboratorRole: String, Codable {
        case owner
        case editor
        case commenter
        case viewer
    }
}
```

### 8. AISuggestion

**Purpose**: AI-generated recommendations

```swift
@Model
final class AISuggestion {
    @Attribute(.unique) var id: UUID
    var projectId: UUID
    var type: SuggestionType

    // Suggestion content
    var title: String
    var description: String
    var reasoning: String?

    // Actionable data
    var suggestedSourceIds: [UUID]? // For missing links
    var suggestedURL: URL? // For new sources
    var suggestedConnectionFrom: UUID?
    var suggestedConnectionTo: UUID?
    var suggestedConnectionType: ConnectionType?

    // Metadata
    var confidence: Double // 0.0-1.0
    var created: Date
    var status: SuggestionStatus

    init(projectId: UUID, type: SuggestionType, title: String,
         description: String, confidence: Double) {
        self.id = UUID()
        self.projectId = projectId
        self.type = type
        self.title = title
        self.description = description
        self.confidence = confidence
        self.created = Date()
        self.status = .pending
    }
}

enum SuggestionType: String, Codable {
    case missingConnection
    case missingSource
    case contradiction
    case gapIdentification
    case bridgeConcept
    case duplicateDetection
    case serendipity
}

enum SuggestionStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case dismissed
}
```

### 9. User Settings

**Purpose**: User preferences and configuration

```swift
@Model
final class UserSettings {
    @Attribute(.unique) var userId: String // Apple ID

    // Display Preferences
    var theme: Theme
    var defaultLayout: LayoutType
    var nodeStyle: NodeStyle
    var showLabels: Bool
    var showMinimap: Bool

    // Citation Preferences
    var defaultCitationStyle: CitationStyle
    var citationSortOrder: CitationSortOrder

    // AI Preferences
    var enableAISuggestions: Bool
    var aiSuggestionsFrequency: AIFrequency
    var llmProvider: LLMProvider

    // Privacy
    var allowDataSharing: Bool
    var allowTelemetry: Bool

    // Subscription
    var subscriptionTier: SubscriptionTier
    var subscriptionExpiry: Date?

    // Onboarding
    var hasCompletedOnboarding: Bool
    var lastOnboardingVersion: String?

    init(userId: String) {
        self.userId = userId
        self.theme = .dark
        self.defaultLayout = .forceDirected
        self.nodeStyle = .spheres
        self.showLabels = true
        self.showMinimap = false
        self.defaultCitationStyle = .apa
        self.citationSortOrder = .author
        self.enableAISuggestions = true
        self.aiSuggestionsFrequency = .balanced
        self.llmProvider = .openai
        self.allowDataSharing = false
        self.allowTelemetry = false
        self.subscriptionTier = .free
        self.hasCompletedOnboarding = false
    }
}

enum Theme: String, Codable {
    case light, dark, auto
}

enum NodeStyle: String, Codable {
    case spheres, cubes, icons, mixed
}

enum CitationSortOrder: String, Codable {
    case author, date, title, type
}

enum AIFrequency: String, Codable {
    case realtime, balanced, manual
}

enum LLMProvider: String, Codable {
    case openai, anthropic
}

enum SubscriptionTier: String, Codable {
    case free, pro, academic, team
}
```

## CloudKit Schema

### Record Types

#### CKProject
```
- recordID: UUID (primary key)
- name: String
- description: String?
- ownerId: String (indexed)
- isShared: Bool
- created: Date
- modified: Date
- graphData: CKAsset (JSON file)
- sourceCount: Int
- connectionCount: Int
```

#### CKSource
```
- recordID: UUID (primary key)
- projectId: Reference(CKProject) (indexed)
- title: String
- authors: [String]
- type: String
- url: String?
- doi: String?
- publicationDate: Date?
- abstract: String?
- notes: String?
- tags: [String]
- created: Date
- modified: Date
- addedBy: String
```

#### CKConnection
```
- recordID: UUID (primary key)
- projectId: Reference(CKProject) (indexed)
- fromSourceId: UUID (indexed)
- toSourceId: UUID (indexed)
- type: String
- annotation: String?
- created: Date
- createdBy: String
```

#### CKComment
```
- recordID: UUID (primary key)
- projectId: Reference(CKProject) (indexed)
- targetType: String
- targetId: UUID
- text: String
- authorId: String
- authorName: String
- created: Date
```

### Sync Strategy
- **Push**: Changes synced immediately in background
- **Pull**: Fetch on app launch and periodically
- **Conflict Resolution**: Last-write-wins with timestamp
- **Selective Sync**: Only sync metadata, not large files

## Data Relationships

```
Project (1) ──────< (M) Source
   │                     │
   │                     │
   └──────< (M) Collection
   │                     │
   │                     │
   └──────< (M) Comment  │
                         │
                         │
Connection (M) >────────┘
   │
   │
Comment (M) >────────────┘

Project (1) ────── (M) SharedUser
```

## Data Validation Rules

### Project
- `name`: 1-100 characters, non-empty
- `sourceCount`: >= 0
- `connectionCount`: >= 0

### Source
- `title`: 1-500 characters, non-empty
- `authors`: Max 50 authors
- `tags`: Max 50 tags, each 1-30 characters
- `rating`: 1-5 or null
- `url`: Valid URL format if present
- `doi`: Valid DOI format if present

### Connection
- `fromSourceId` != `toSourceId` (no self-loops)
- Both source IDs must exist in project
- Unique constraint: (fromSourceId, toSourceId, type) per project

### Comment
- `text`: 1-5000 characters, non-empty
- `targetId` must exist

## Indexing Strategy

### SwiftData Indexes
```swift
// On Source
@Attribute(.indexed) var projectId: UUID
@Attribute(.indexed) var type: SourceType
@Attribute(.indexed) var created: Date

// On Project
@Attribute(.indexed) var ownerId: String
@Attribute(.indexed) var modified: Date

// On Comment
@Attribute(.indexed) var projectId: UUID
@Attribute(.indexed) var targetId: UUID
```

### Graph Indexes (In-Memory)
- Adjacency list for O(1) neighbor lookup
- Reverse adjacency list for incoming edges
- Source ID to node position mapping
- Tag to source IDs mapping

## Data Migration Strategy

### Version History
- v1.0: Initial schema
- v1.1: Add embeddings to Source (future)
- v1.2: Add activity log (future)

### Migration Path
```swift
// SwiftData automatically handles light migrations
// For complex migrations:
@Model
final class Source_v2 {
    // Add new field with default value
    var embeddingVector: [Float]? = nil
}
```

## Data Size Estimates

### Per Source
- Metadata: ~2KB
- Abstract: ~2KB
- Notes: ~5KB
- PDF: ~2MB (optional)
- **Total: ~10KB metadata + optional 2MB PDF**

### Per Project
- 100 sources: ~1MB + ~200MB PDFs
- 1,000 sources: ~10MB + ~2GB PDFs
- Graph structure: ~500KB for 1,000 sources

### iCloud Limits
- Free: 5GB total
- Paid: 50GB - 2TB

## Performance Optimizations

### Lazy Loading
- Load sources on-demand when viewing details
- Load graph in chunks for large projects
- Pagination for source lists

### Caching
- Cache recent projects in memory
- Cache rendered node geometries
- Cache layout calculations

### Batch Operations
- Batch CloudKit operations (max 400 records)
- Batch graph updates
- Debounce sync operations

## Data Export Formats

### Bibliography Export
- **BibTeX**: `.bib` file
- **RIS**: `.ris` file
- **EndNote XML**: `.xml` file
- **Word**: `.docx` with formatted bibliography
- **JSON**: `.json` with all metadata

### Graph Export
- **GraphML**: Standard graph format
- **JSON**: Custom format for re-import
- **CSV**: Edge list + node list
- **Image**: PNG/PDF of graph visualization

## Backup & Recovery

### Automatic Backups
- iCloud automatic backup (via CloudKit)
- Local snapshots before major operations
- Export feature for manual backups

### Recovery
- Restore from iCloud
- Import from exported JSON
- Conflict resolution UI for sync issues

## Privacy Considerations

### Local-First
- All data stored locally by default
- Sync is opt-in
- LLM API calls require consent

### Data Minimization
- Only sync necessary metadata to CloudKit
- PDFs not synced (too large)
- User controls what's shared in collaborative spaces

### Deletion
- Hard delete: Remove from CloudKit and local
- Soft delete: Mark as deleted, sync deletion
- Account deletion: Purge all user data

## Next Steps

1. Implement SwiftData models with relationships
2. Implement custom graph serialization
3. Design CloudKit schema and test sync
4. Implement data validation layer
5. Build migration system for future schema changes

## References

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Data Modeling Best Practices](https://developer.apple.com/documentation/coredata/modeling_data)
