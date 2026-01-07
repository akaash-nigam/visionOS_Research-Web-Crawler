# System Architecture Document

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Executive Summary

Research Web Crawler is a native visionOS application that creates a 3D spatial knowledge graph for research and information discovery. The system is designed as a client-first architecture with optional cloud sync, emphasizing offline-first capabilities, performance, and user privacy.

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     visionOS Application                         │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   SwiftUI    │  │  RealityKit  │  │   Core ML    │          │
│  │  Interface   │  │  3D Renderer │  │   On-Device  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Application Layer                        │       │
│  │  - Graph Manager   - Citation Engine                 │       │
│  │  - Content Processor - Collaboration Manager         │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Data Layer                               │       │
│  │  - SwiftData (Local DB) - Graph Database             │       │
│  │  - File Storage         - Cache Manager              │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
└───────────────────────────┬───────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │   CloudKit   │ │  LLM Service │ │  Citation    │
    │   Sync       │ │  (GPT/Claude)│ │  APIs        │
    │   (iCloud)   │ │              │ │  (CrossRef)  │
    └──────────────┘ └──────────────┘ └──────────────┘
```

## Component Architecture

### 1. Presentation Layer

#### 1.1 SwiftUI Views
- **MainGraphView**: Primary 3D graph visualization
- **SourceDetailView**: Individual source information
- **AIInsightsPanel**: AI suggestions and recommendations
- **CitationExportView**: Bibliography generation and export
- **CollaborationView**: Team and shared space management
- **SettingsView**: App configuration and preferences

#### 1.2 RealityKit Scene
- **GraphScene**: Main 3D scene containing all nodes and edges
- **NodeEntity**: Individual source representations
- **EdgeEntity**: Connection lines between nodes
- **InteractionHandlers**: Gesture recognition and manipulation

### 2. Application Layer

#### 2.1 Graph Manager
**Responsibilities**:
- Manage graph data structure in memory
- Handle node/edge CRUD operations
- Execute layout algorithms
- Maintain graph state and history
- Coordinate with persistence layer

**Key Classes**:
```swift
GraphManager
├── Graph (data structure)
├── LayoutEngine
│   ├── ForceDirectedLayout
│   ├── HierarchicalLayout
│   ├── RadialLayout
│   └── TimelineLayout
├── FilterEngine
└── SearchEngine
```

#### 2.2 Content Processor
**Responsibilities**:
- Web scraping and content extraction
- PDF parsing and text extraction
- Metadata extraction and normalization
- Content caching and management

**Key Classes**:
```swift
ContentProcessor
├── WebScraper
├── PDFParser
├── MetadataExtractor
├── ContentCache
└── URLSessionManager
```

#### 2.3 AI Service Manager
**Responsibilities**:
- Interface with LLM APIs
- Manage AI suggestions and recommendations
- Context preparation and prompt engineering
- Rate limiting and cost management

**Key Classes**:
```swift
AIServiceManager
├── LLMClient (protocol)
│   ├── OpenAIClient
│   └── AnthropicClient
├── PromptEngine
├── SuggestionGenerator
└── CostTracker
```

#### 2.4 Citation Engine
**Responsibilities**:
- Citation formatting (APA, MLA, Chicago, etc.)
- Bibliography generation
- Duplicate detection
- Import/export (BibTeX, RIS, etc.)

**Key Classes**:
```swift
CitationEngine
├── CSLProcessor
├── CitationFormatter
├── DuplicateDetector
└── BibliographyExporter
```

#### 2.5 Collaboration Manager
**Responsibilities**:
- Multi-user coordination
- Real-time sync
- Conflict resolution
- Permission management

**Key Classes**:
```swift
CollaborationManager
├── SyncCoordinator
├── ConflictResolver
├── PermissionManager
└── ActivityTracker
```

### 3. Data Layer

#### 3.1 Persistence Strategy

**Primary Storage: SwiftData**
- User preferences and settings
- Project metadata
- Source metadata (title, author, URL, etc.)
- Annotations and notes
- Collections and tags

**Graph Storage: Custom In-Memory + Disk**
- In-memory adjacency list for performance
- Serialized to disk using Codable
- Separate file per project for isolation
- Format: JSON or Protocol Buffers

**File Storage**
- PDFs: Documents directory
- Cached web content: Caches directory
- Images/screenshots: Documents directory
- Voice notes: Documents directory

#### 3.2 Data Model Overview

```swift
// Core Entities
Project
├── id: UUID
├── name: String
├── created: Date
├── modified: Date
├── sharedWith: [User]
└── graphData: GraphSnapshot

Source (Node)
├── id: UUID
├── type: SourceType
├── title: String
├── authors: [String]
├── date: Date
├── url: URL?
├── doi: String?
├── metadata: [String: Any]
├── content: String?
├── notes: String
├── tags: [String]
└── collectionId: UUID?

Connection (Edge)
├── id: UUID
├── fromNodeId: UUID
├── toNodeId: UUID
├── type: ConnectionType
├── strength: Double
├── annotation: String?
└── created: Date

Collection
├── id: UUID
├── name: String
├── color: Color
└── sourceIds: [UUID]
```

#### 3.3 Cache Strategy

**Memory Cache**:
- Recent graph layouts (LRU, max 5 projects)
- Rendered node geometries
- Frequently accessed source content

**Disk Cache**:
- Web page content (7 days TTL)
- Scraped metadata (30 days TTL)
- AI suggestions (24 hours TTL)
- Thumbnail images (permanent)

### 4. External Services

#### 4.1 CloudKit Integration
**Purpose**: Cross-device sync and collaboration

**Synced Data**:
- Project metadata
- Source metadata
- Graph structure (nodes and edges)
- Annotations and notes
- Shared space permissions

**Not Synced**:
- PDF files (too large, user downloads separately)
- Full web page caches
- Temporary data

**Sync Strategy**: Background sync with conflict resolution

#### 4.2 LLM Service (OpenAI/Anthropic)
**Purpose**: AI suggestions and recommendations

**API Usage**:
- Suggestion generation: GPT-4-turbo or Claude Sonnet
- Semantic search: Text-embedding-3-large
- Content summarization: GPT-4-turbo

**Rate Limiting**:
- Free tier: 10 requests/day
- Pro tier: Unlimited (cost-monitored)

**Privacy**: User content sent to API with explicit consent

#### 4.3 Citation APIs
**CrossRef** (DOI lookup):
- Free, no auth required
- Rate limit: 50 req/sec

**Google Books API** (ISBN lookup):
- Free with API key
- Quota: 1,000 requests/day

**OpenLibrary** (ISBN lookup):
- Free, no auth
- Backup for Google Books

#### 4.4 Academic Search APIs
**Google Scholar** (via SerpAPI):
- Paid service
- Used for source discovery

**Semantic Scholar**:
- Free API
- Academic paper metadata

### 5. Security Architecture

#### 5.1 Data Protection
- **At Rest**: FileVault encryption (OS-level)
- **In Transit**: TLS 1.3 for all network requests
- **API Keys**: Stored in Keychain

#### 5.2 Sandboxing
- Web content rendered in isolated WKWebView
- PDF parsing in separate process (if possible)

#### 5.3 Privacy
- No telemetry without user consent
- User content stays on-device by default
- LLM API calls require explicit permission
- Clear data deletion on account removal

## Technology Stack

### Core Frameworks
- **visionOS 2.0+**: Platform SDK
- **SwiftUI**: UI framework
- **RealityKit**: 3D rendering
- **SwiftData**: Local persistence
- **CloudKit**: Sync and collaboration
- **Core ML**: On-device ML (optional)

### Third-Party Dependencies
- **Swift-Collections**: Efficient graph data structures
- **SwiftSoup**: HTML parsing
- **PDFKit/CGPDFDocument**: PDF parsing
- **SWXMLHash**: XML parsing (for RIS, CSL)
- **Alamofire**: (Optional) HTTP networking
- **KeychainAccess**: Secure credential storage

### External Services
- **OpenAI API** or **Anthropic API**: LLM
- **CrossRef API**: DOI resolution
- **Google Books API**: ISBN lookup
- **Semantic Scholar API**: Academic search

## Deployment Architecture

### Development Environment
- Xcode 16.0+
- Swift 6.0+
- visionOS Simulator
- Apple Vision Pro hardware (testing)

### Production Environment
- TestFlight for beta distribution
- App Store for public release
- CloudKit Production environment
- CDN for static assets (future)

### Backend Services (Future)
Currently, the app is **fully client-side** with no custom backend. Future backend may include:
- API gateway for LLM calls (to hide API keys)
- Web scraping service (to avoid client IP rate limits)
- Analytics and telemetry service
- Subscription management

## Performance Targets

### Rendering Performance
- **Target**: 60fps with 1,000 nodes
- **Strategies**:
  - Level-of-detail (LOD) for distant nodes
  - Instanced rendering for identical geometries
  - Frustum culling
  - Lazy edge rendering (only visible connections)

### Data Performance
- **Graph load**: < 2 seconds (1,000 nodes)
- **Search**: < 500ms (10,000 sources)
- **Layout calculation**: < 3 seconds (1,000 nodes)
- **Strategies**:
  - Indexed search (in-memory)
  - Incremental layout updates
  - Background thread for expensive operations

### Network Performance
- **Web scraping**: < 5 seconds per page
- **Metadata lookup**: < 2 seconds per source
- **AI suggestion**: < 10 seconds
- **Strategies**:
  - Parallel requests (max 5 concurrent)
  - Request caching
  - Progressive rendering

## Scalability Considerations

### Data Scale
- **MVP**: Support up to 1,000 sources per project
- **Phase 2**: Support up to 10,000 sources
- **Strategy**: Pagination, virtual scrolling, progressive loading

### User Scale
- **MVP**: Single user, local only
- **Phase 2**: Collaboration with 5 users per space
- **Phase 3**: Public sharing with view-only access

### Storage Scale
- **Conservative**: 100 sources = ~500MB (with PDFs)
- **Heavy User**: 1,000 sources = ~5GB
- **Mitigation**: Selective PDF download, cloud storage offload

## Development Phases

### Phase 1: MVP (Months 1-3)
**Goal**: Core functionality, single user, local-only

**Components**:
- Basic 3D graph visualization
- Web scraping and PDF import
- Manual connection creation
- Simple citation formatting
- Local storage only

### Phase 2: AI & Sync (Months 4-6)
**Goal**: AI suggestions and cross-device sync

**Components**:
- LLM integration for suggestions
- CloudKit sync
- Advanced layouts
- Enhanced citation engine

### Phase 3: Collaboration (Months 7-9)
**Goal**: Team collaboration and sharing

**Components**:
- Shared research spaces
- Real-time collaboration
- Comments and discussions
- Permission management

### Phase 4: Polish & Scale (Months 10-12)
**Goal**: Performance optimization and additional features

**Components**:
- Performance optimization (10,000+ sources)
- Additional import/export formats
- Voice commands
- iOS companion app

## Key Technical Decisions

### 1. Graph Database: Custom In-Memory
**Decision**: Build custom graph structure instead of Neo4j
**Rationale**:
- Native Swift performance
- No server dependency
- Full control over data format
- Easier to sync via CloudKit
**Trade-off**: We build our own graph algorithms

### 2. LLM Provider: OpenAI GPT-4 (Primary)
**Decision**: Use OpenAI with fallback to Anthropic Claude
**Rationale**:
- Mature API
- Good performance
- Cost-effective
**Trade-off**: Network dependency, API costs

### 3. Sync: CloudKit
**Decision**: Use Apple's CloudKit for sync
**Rationale**:
- Native iOS/visionOS integration
- User privacy (Apple doesn't see data)
- Free tier sufficient for MVP
- Easy authentication via Apple ID
**Trade-off**: Limited to Apple ecosystem

### 4. Citation Processing: CSL + Custom Parser
**Decision**: Use Citation Style Language (CSL) with custom Swift parser
**Rationale**:
- Industry standard
- Supports all major styles
- Open source styles available
**Trade-off**: Need to implement CSL processor in Swift

### 5. Web Scraping: Client-Side
**Decision**: Scrape from device, not server
**Rationale**:
- No backend required
- User IP for rate limiting
- Simpler architecture
**Trade-off**: Slower, client battery impact

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| RealityKit performance with 1000+ nodes | High | LOD, instancing, culling, profiling |
| CloudKit sync conflicts | Medium | CRDT-like resolution, timestamp-based merging |
| LLM API costs | Medium | Rate limiting, caching, user quotas |
| Web scraping blocked/rate-limited | Medium | Respect robots.txt, exponential backoff, caching |
| Graph layout too slow | High | Background threads, incremental updates, simpler algorithms |
| Storage growth (PDFs) | Medium | Optional PDF storage, cloud offload, compression |

## Testing Strategy

### Unit Tests
- Graph algorithms (layout, search, filtering)
- Citation formatting
- Metadata extraction
- Data model serialization

### Integration Tests
- CloudKit sync
- LLM API integration
- Web scraping pipeline
- PDF parsing

### Performance Tests
- 1,000 node rendering
- 10,000 source search
- Layout calculation benchmarks
- Memory profiling

### UI Tests
- Core user flows
- Gesture recognition
- Collaboration scenarios

## Open Questions

1. **Graph Database**: Should we reconsider Neo4j for Phase 2 when scaling?
2. **Backend**: When do we need a custom backend (scraping proxy, API gateway)?
3. **Embeddings**: Should we compute local embeddings for semantic search?
4. **Real-time Collab**: SharePlay vs. custom WebSocket implementation?
5. **Mobile Apps**: iOS/iPadOS companion app architecture?

## Next Steps

1. Validate RealityKit performance with prototype (1,000 nodes)
2. Design detailed data model schema
3. Prototype force-directed layout algorithm
4. Test web scraping with top 10 academic sites
5. Design CloudKit schema for sync

## References

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Citation Style Language](https://citationstyles.org/)
- [Force-Directed Graph Algorithms](https://en.wikipedia.org/wiki/Force-directed_graph_drawing)
