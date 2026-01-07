# MVP Implementation Roadmap

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Ready for Implementation
- **Target Timeline**: 12 weeks (3 months)

## Overview

This document breaks down the MVP into implementable epics, with clear tasks, dependencies, and acceptance criteria. Each epic represents 1-2 weeks of work.

## Epic Overview

| # | Epic | Duration | Dependencies | Priority |
|---|------|----------|--------------|----------|
| 0 | Project Setup & Foundation | 1 week | None | P0 |
| 1 | Data Models & Persistence | 1 week | Epic 0 | P0 |
| 2 | 3D Graph Visualization (Basic) | 2 weeks | Epic 1 | P0 |
| 3 | Graph Layout Algorithm | 1.5 weeks | Epic 2 | P0 |
| 4 | Source Management | 2 weeks | Epic 1 | P0 |
| 5 | Web Scraping & Content Extraction | 1.5 weeks | Epic 4 | P0 |
| 6 | Graph Interaction & Gestures | 2 weeks | Epic 2, 3 | P0 |
| 7 | Citation Formatting & Export | 1 week | Epic 4 | P1 |
| 8 | Onboarding & Tutorial | 1 week | Epic 2, 4, 6 | P1 |
| 9 | Polish & Testing | 2 weeks | All | P0 |

**Total: 14 weeks** (with buffer for unknowns)

---

## Epic 0: Project Setup & Foundation

**Duration**: 1 week
**Goal**: Set up development environment and project structure

### User Stories
- As a developer, I need a properly configured Xcode project so I can start building features
- As a developer, I need a clear project structure so the codebase is maintainable

### Tasks

#### 0.1 Create Xcode Project
- [ ] Create new visionOS app project
- [ ] Set deployment target to visionOS 2.0+
- [ ] Configure app identifier: `com.researchapp.webcrawler`
- [ ] Set up provisioning profiles

#### 0.2 Project Structure
```
ResearchWebCrawler/
├── App/
│   ├── ResearchWebCrawlerApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── Project.swift
│   ├── Source.swift
│   ├── Connection.swift
│   └── Graph.swift
├── Views/
│   ├── MainGraphView.swift
│   ├── SourceDetailView.swift
│   └── SettingsView.swift
├── ViewModels/
│   ├── GraphViewModel.swift
│   └── SourceViewModel.swift
├── Services/
│   ├── GraphManager.swift
│   ├── ContentProcessor.swift
│   ├── CitationEngine.swift
│   └── PersistenceManager.swift
├── RealityKit/
│   ├── GraphScene.swift
│   ├── NodeEntity.swift
│   ├── EdgeEntity.swift
│   └── InteractionManager.swift
├── Utilities/
│   ├── Extensions/
│   └── Helpers/
└── Resources/
    └── Assets.xcassets
```

#### 0.3 Add Dependencies
- [ ] Add SwiftSoup (SPM) for HTML parsing
- [ ] Configure SwiftData
- [ ] Set up RealityKit

#### 0.4 Configure Git & CI
- [ ] Create `.gitignore` for Swift/Xcode
- [ ] Set up GitHub Actions for CI (optional for MVP)
- [ ] Create `CONTRIBUTING.md`

#### 0.5 Basic App Shell
- [ ] Create main app entry point
- [ ] Set up SwiftUI navigation structure
- [ ] Add placeholder views for main screens
- [ ] Verify app launches on simulator

### Acceptance Criteria
- ✅ App builds and launches on visionOS simulator
- ✅ Project structure follows architecture design
- ✅ Dependencies installed and working
- ✅ Git repository configured

### Estimated Effort
- **Development**: 2-3 days
- **Testing**: 0.5 day
- **Total**: 3-4 days

---

## Epic 1: Data Models & Persistence

**Duration**: 1 week
**Goal**: Implement core data models and local persistence

### User Stories
- As a user, I need my research data saved locally so I don't lose my work
- As a developer, I need well-defined data models so features can build on them

### Tasks

#### 1.1 Define SwiftData Models
- [ ] Implement `Project` model
- [ ] Implement `Source` model
- [ ] Implement `Collection` model
- [ ] Add relationships between models
- [ ] Add validation rules

**Files to Create**:
- `Models/Project.swift`
- `Models/Source.swift`
- `Models/Collection.swift`
- `Models/SourceType.swift`
- `Models/CitationStyle.swift`

#### 1.2 Implement Graph Data Structure
- [ ] Create `Graph` struct (Codable)
- [ ] Create `GraphNode` struct
- [ ] Create `Connection` struct
- [ ] Implement adjacency list
- [ ] Add graph manipulation methods (addNode, addEdge, removeNode, etc.)

**Files to Create**:
- `Models/Graph.swift`
- `Models/GraphNode.swift`
- `Models/Connection.swift`
- `Models/ConnectionType.swift`

#### 1.3 Implement Persistence Manager
- [ ] Create `PersistenceManager` singleton
- [ ] Implement SwiftData ModelContainer setup
- [ ] Implement graph serialization (JSON)
- [ ] Implement file storage for PDFs
- [ ] Add auto-save functionality

**Files to Create**:
- `Services/PersistenceManager.swift`
- `Services/GraphSerializer.swift`

#### 1.4 Write Unit Tests
- [ ] Test data model creation
- [ ] Test relationships
- [ ] Test graph operations
- [ ] Test serialization/deserialization
- [ ] Test persistence save/load

**Files to Create**:
- `Tests/ModelTests.swift`
- `Tests/GraphTests.swift`
- `Tests/PersistenceTests.swift`

### Acceptance Criteria
- ✅ All data models compile without errors
- ✅ SwiftData persistence works (create, read, update, delete)
- ✅ Graph structure supports 100+ nodes efficiently
- ✅ Data persists across app restarts
- ✅ Unit tests pass with >80% coverage

### Estimated Effort
- **Development**: 4 days
- **Testing**: 1 day
- **Total**: 5 days

---

## Epic 2: 3D Graph Visualization (Basic)

**Duration**: 2 weeks
**Goal**: Render nodes and edges in 3D space using RealityKit

### User Stories
- As a user, I want to see my sources as 3D nodes so I can visualize my research spatially
- As a user, I want to see connections between sources so I understand relationships

### Tasks

#### 2.1 Setup RealityKit Scene
- [ ] Create `GraphScene` class
- [ ] Initialize ImmersiveSpace
- [ ] Set up root entity hierarchy
- [ ] Add ambient lighting
- [ ] Configure camera

**Files to Create**:
- `RealityKit/GraphScene.swift`
- `Views/GraphImmersiveView.swift`

#### 2.2 Implement NodeEntity
- [ ] Create `NodeEntity` class (inherits Entity)
- [ ] Generate sphere mesh for nodes
- [ ] Implement node coloring by type
- [ ] Add collision component
- [ ] Implement node sizing logic

**Files to Create**:
- `RealityKit/NodeEntity.swift`
- `RealityKit/NodeVisuals.swift`

#### 2.3 Implement EdgeEntity
- [ ] Create `EdgeEntity` class
- [ ] Generate line/cylinder mesh between points
- [ ] Implement edge coloring by type
- [ ] Add edge update method (when nodes move)

**Files to Create**:
- `RealityKit/EdgeEntity.swift`
- `RealityKit/LineRenderer.swift`

#### 2.4 Implement Graph Renderer
- [ ] Create `GraphRenderer` class
- [ ] Implement renderGraph(graph: Graph)
- [ ] Batch create node entities
- [ ] Batch create edge entities
- [ ] Add nodes/edges to scene

**Files to Create**:
- `RealityKit/GraphRenderer.swift`

#### 2.5 Basic Camera Controls
- [ ] Implement pan gesture (2 fingers)
- [ ] Implement zoom (pinch)
- [ ] Implement rotation (twist)
- [ ] Smooth camera movement

**Files to Create**:
- `RealityKit/CameraController.swift`

#### 2.6 Test with Sample Data
- [ ] Create sample project with 10 sources
- [ ] Create sample connections
- [ ] Render sample graph
- [ ] Verify visual appearance
- [ ] Test camera controls

**Files to Create**:
- `Utilities/SampleDataGenerator.swift`

### Acceptance Criteria
- ✅ Graph with 50 nodes renders in < 5 seconds
- ✅ Nodes are visually distinct by type
- ✅ Edges connect correct nodes
- ✅ Camera controls work smoothly
- ✅ Maintains 60fps with 50 nodes

### Estimated Effort
- **Development**: 8 days
- **Testing**: 2 days
- **Total**: 10 days

---

## Epic 3: Graph Layout Algorithm

**Duration**: 1.5 weeks
**Goal**: Implement force-directed layout for automatic node positioning

### User Stories
- As a user, I want nodes automatically arranged so I don't have to position them manually
- As a user, I want connected nodes near each other so relationships are visible

### Tasks

#### 3.1 Implement Force-Directed Layout
- [ ] Create `ForceDirectedLayout` class
- [ ] Implement repulsion force (all node pairs)
- [ ] Implement attraction force (connected nodes)
- [ ] Implement velocity and damping
- [ ] Add convergence detection

**Files to Create**:
- `Services/Layout/ForceDirectedLayout.swift`
- `Services/Layout/LayoutAlgorithm.swift` (protocol)

#### 3.2 Optimize Performance
- [ ] Use spatial partitioning (quadtree/octree)
- [ ] Limit force calculations to nearby nodes
- [ ] Run layout on background thread
- [ ] Add iteration limit (max 100)

**Files to Create**:
- `Services/Layout/SpatialPartitioning.swift`

#### 3.3 Layout Parameters Tuning
- [ ] Tune spring constant (k)
- [ ] Tune repulsion strength
- [ ] Tune damping factor
- [ ] Test with various graph sizes (10, 50, 100 nodes)

#### 3.4 Integrate with Graph Renderer
- [ ] Call layout algorithm before rendering
- [ ] Apply calculated positions to nodes
- [ ] Animate transition to new layout
- [ ] Add "Re-layout" button to UI

#### 3.5 Write Tests
- [ ] Test layout convergence
- [ ] Test performance with 100 nodes
- [ ] Test edge cases (isolated nodes, dense clusters)

**Files to Create**:
- `Tests/LayoutTests.swift`
- `Tests/LayoutPerformanceTests.swift`

### Acceptance Criteria
- ✅ Layout completes in < 3 seconds for 100 nodes
- ✅ Connected nodes are positioned near each other
- ✅ Graph is visually balanced and readable
- ✅ No node overlaps
- ✅ Layout is deterministic (same graph = same layout)

### Estimated Effort
- **Development**: 6 days
- **Testing/Tuning**: 2 days
- **Total**: 8 days

---

## Epic 4: Source Management

**Duration**: 2 weeks
**Goal**: Add, view, edit, and delete sources

### User Stories
- As a user, I want to add sources manually so I can build my research graph
- As a user, I want to view source details so I can reference information
- As a user, I want to edit source metadata so I can correct errors

### Tasks

#### 4.1 Source Detail View
- [ ] Create `SourceDetailView` SwiftUI view
- [ ] Display all source fields (title, authors, date, URL, etc.)
- [ ] Add edit mode
- [ ] Save changes to database
- [ ] Delete source functionality

**Files to Create**:
- `Views/SourceDetailView.swift`
- `ViewModels/SourceDetailViewModel.swift`

#### 4.2 Add Source Manually
- [ ] Create "Add Source" form view
- [ ] Input fields: title, authors, type, URL, date, notes
- [ ] Validation (required fields)
- [ ] Save to database
- [ ] Add node to graph

**Files to Create**:
- `Views/AddSourceView.swift`
- `Views/AddSourceManualView.swift`

#### 4.3 Source List View
- [ ] Create list of all sources
- [ ] Group by type
- [ ] Search functionality
- [ ] Tap to view details
- [ ] Swipe to delete

**Files to Create**:
- `Views/SourceListView.swift`
- `ViewModels/SourceListViewModel.swift`

#### 4.4 PDF Upload
- [ ] Add file picker for PDFs
- [ ] Save PDF to documents directory
- [ ] Extract PDF metadata (title, author)
- [ ] Link PDF to source
- [ ] View PDF in app (PDFKit)

**Files to Create**:
- `Services/PDFManager.swift`
- `Views/PDFViewerView.swift`

#### 4.5 Source Notes
- [ ] Add notes text editor in detail view
- [ ] Auto-save notes
- [ ] Rich text support (optional)

#### 4.6 Write Tests
- [ ] Test source CRUD operations
- [ ] Test validation
- [ ] Test PDF upload

**Files to Create**:
- `Tests/SourceManagementTests.swift`

### Acceptance Criteria
- ✅ Can add source manually with all fields
- ✅ Can upload and view PDF
- ✅ Can edit source metadata
- ✅ Can delete source (with confirmation)
- ✅ Source list shows all sources
- ✅ Search filters sources correctly

### Estimated Effort
- **Development**: 8 days
- **Testing**: 2 days
- **Total**: 10 days

---

## Epic 5: Web Scraping & Content Extraction

**Duration**: 1.5 weeks
**Goal**: Add sources from URLs automatically

### User Stories
- As a user, I want to add sources from URLs so I don't have to type metadata manually
- As a user, I want article content extracted so I can reference it later

### Tasks

#### 5.1 Implement Web Scraper
- [ ] Create `WebScraper` class using SwiftSoup
- [ ] Fetch HTML from URL
- [ ] Parse HTML document
- [ ] Extract main content (article text)

**Files to Create**:
- `Services/ContentProcessor/WebScraper.swift`

#### 5.2 Implement Metadata Extractor
- [ ] Extract Open Graph tags (og:title, og:description, etc.)
- [ ] Extract meta tags (author, date, publisher)
- [ ] Extract JSON-LD structured data
- [ ] Extract citation metadata (for academic papers)
- [ ] Fallback to HTML parsing (title tag, etc.)

**Files to Create**:
- `Services/ContentProcessor/MetadataExtractor.swift`

#### 5.3 Add Source from URL
- [ ] Create "Add from URL" view
- [ ] Input URL field
- [ ] Show loading indicator
- [ ] Scrape and extract metadata
- [ ] Pre-fill source form with extracted data
- [ ] Allow user to edit before saving

**Files to Create**:
- `Views/AddSourceFromURLView.swift`

#### 5.4 Implement Rate Limiting
- [ ] Add rate limiter (1 request per second per domain)
- [ ] Show error if rate limited
- [ ] Respect robots.txt (basic)

**Files to Create**:
- `Services/ContentProcessor/RateLimiter.swift`
- `Services/ContentProcessor/RobotsChecker.swift`

#### 5.5 Content Caching
- [ ] Cache scraped content (7 days)
- [ ] Check cache before scraping
- [ ] Clear old cache entries

**Files to Create**:
- `Services/ContentProcessor/ContentCache.swift`

#### 5.6 Error Handling
- [ ] Handle network errors
- [ ] Handle invalid URLs
- [ ] Handle scraping failures
- [ ] Show user-friendly error messages

#### 5.7 Write Tests
- [ ] Mock scraper for testing
- [ ] Test metadata extraction with sample HTML
- [ ] Test error handling

**Files to Create**:
- `Tests/WebScraperTests.swift`
- `Tests/MetadataExtractorTests.swift`

### Acceptance Criteria
- ✅ Can add source from URL
- ✅ Metadata automatically extracted (title, author, date)
- ✅ Works with major sites (news, blogs, academic)
- ✅ Handles errors gracefully
- ✅ Scraping completes in < 5 seconds

### Estimated Effort
- **Development**: 6 days
- **Testing**: 2 days
- **Total**: 8 days

---

## Epic 6: Graph Interaction & Gestures

**Duration**: 2 weeks
**Goal**: Select nodes, create connections via gestures

### User Stories
- As a user, I want to tap nodes to see details so I can learn more about sources
- As a user, I want to drag between nodes to create connections so I can link related sources

### Tasks

#### 6.1 Implement Node Selection
- [ ] Add tap gesture recognizer to nodes
- [ ] Highlight selected node (outline, glow)
- [ ] Show floating info panel for selected node
- [ ] Deselect on tap outside

**Files to Create**:
- `RealityKit/InteractionManager.swift`
- `Views/NodeInfoPanel.swift`

#### 6.2 Implement Connection Creation Gesture
- [ ] Long-press on node to start connection
- [ ] Drag hand toward target node
- [ ] Draw temporary line following hand
- [ ] Release on target to complete
- [ ] Show connection type selector

**Files to Create**:
- `RealityKit/ConnectionGestureHandler.swift`
- `Views/ConnectionTypeSelector.swift`

#### 6.3 Connection Type Selection
- [ ] Popup menu with options: Related, Supports, Contradicts
- [ ] Visual preview of connection type (color)
- [ ] Create connection on selection
- [ ] Add to graph data structure

#### 6.4 Connection Annotation
- [ ] Optional annotation text field
- [ ] Save annotation with connection
- [ ] Display annotation on hover/tap

**Files to Create**:
- `Views/ConnectionAnnotationView.swift`

#### 6.5 Node Dragging (Manual Positioning)
- [ ] Add drag gesture to nodes
- [ ] Update node position in real-time
- [ ] Mark node as "fixed" (exclude from layout)
- [ ] Update connected edges

#### 6.6 Delete Connection
- [ ] Tap connection to select
- [ ] Show delete button
- [ ] Remove from graph

#### 6.7 Write Tests
- [ ] Test gesture recognition
- [ ] Test connection creation
- [ ] Test UI tests for gestures

**Files to Create**:
- `Tests/InteractionTests.swift`
- `UITests/GraphGestureUITests.swift`

### Acceptance Criteria
- ✅ Tap node shows details
- ✅ Can create connection by dragging between nodes
- ✅ Connection type selector appears and works
- ✅ Can add annotation to connection
- ✅ Can manually drag nodes to reposition
- ✅ Gestures feel responsive and natural

### Estimated Effort
- **Development**: 8 days
- **Testing**: 2 days
- **Total**: 10 days

---

## Epic 7: Citation Formatting & Export

**Duration**: 1 week
**Goal**: Generate citations and export bibliography

### User Stories
- As a user, I want citations auto-formatted so I can use them in my writing
- As a user, I want to export a bibliography so I can paste it into my document

### Tasks

#### 7.1 Implement Citation Formatters
- [ ] Create `CitationFormatter` protocol
- [ ] Implement APA formatter
- [ ] Implement MLA formatter
- [ ] Handle different source types (article, book, website)

**Files to Create**:
- `Services/Citation/CitationFormatter.swift`
- `Services/Citation/APAFormatter.swift`
- `Services/Citation/MLAFormatter.swift`

#### 7.2 Citation Engine
- [ ] Create `CitationEngine` class
- [ ] Format single citation
- [ ] Generate full bibliography
- [ ] Sort bibliography (by author, date, title)

**Files to Create**:
- `Services/Citation/CitationEngine.swift`

#### 7.3 Export Bibliography View
- [ ] Create export view
- [ ] Select citation style (APA/MLA)
- [ ] Generate bibliography
- [ ] Copy to clipboard button
- [ ] Share sheet integration

**Files to Create**:
- `Views/ExportBibliographyView.swift`
- `ViewModels/ExportViewModel.swift`

#### 7.4 Copy Individual Citation
- [ ] Add "Copy Citation" button in source detail view
- [ ] Format and copy to clipboard
- [ ] Show confirmation toast

#### 7.5 Write Tests
- [ ] Test APA formatting for all source types
- [ ] Test MLA formatting
- [ ] Test bibliography generation
- [ ] Test sorting

**Files to Create**:
- `Tests/CitationFormatterTests.swift`
- `Tests/CitationEngineTests.swift`

### Acceptance Criteria
- ✅ APA and MLA citations are correctly formatted
- ✅ Can export complete bibliography
- ✅ Can copy individual citations
- ✅ Bibliography is properly sorted
- ✅ All source types supported (article, book, website)

### Estimated Effort
- **Development**: 4 days
- **Testing**: 1 day
- **Total**: 5 days

---

## Epic 8: Onboarding & Tutorial

**Duration**: 1 week
**Goal**: Welcome new users and teach core features

### User Stories
- As a new user, I want a tutorial so I understand how to use the app
- As a new user, I want a sample project so I can explore features

### Tasks

#### 8.1 Welcome Screen
- [ ] Create welcome view
- [ ] App description and value prop
- [ ] "Start Tutorial" button
- [ ] "Skip" button

**Files to Create**:
- `Views/Onboarding/WelcomeView.swift`

#### 8.2 Tutorial Flow
- [ ] Step 1: "This is your research space" (show empty graph)
- [ ] Step 2: "Add your first source" (guide to add source)
- [ ] Step 3: "Watch it appear as a node"
- [ ] Step 4: "Add another source"
- [ ] Step 5: "Connect them" (guide gesture)
- [ ] Step 6: "You're ready to research!"

**Files to Create**:
- `Views/Onboarding/TutorialView.swift`
- `Views/Onboarding/TutorialStep.swift`
- `ViewModels/TutorialViewModel.swift`

#### 8.3 Sample Project
- [ ] Create sample project with 5 sources on "Climate Change"
- [ ] Add sample connections
- [ ] Load sample on first launch (optional)

**Files to Create**:
- `Utilities/SampleProject.swift`

#### 8.4 Onboarding State Management
- [ ] Track if user completed onboarding
- [ ] Don't show again after completion
- [ ] Settings option to replay tutorial

**Files to Create**:
- `Services/OnboardingManager.swift`

#### 8.5 Write Tests
- [ ] Test onboarding state management
- [ ] UI tests for tutorial flow

**Files to Create**:
- `Tests/OnboardingTests.swift`
- `UITests/OnboardingUITests.swift`

### Acceptance Criteria
- ✅ New users see welcome screen
- ✅ Tutorial guides through key features
- ✅ Sample project loads correctly
- ✅ Tutorial can be skipped
- ✅ Tutorial doesn't show again after completion

### Estimated Effort
- **Development**: 4 days
- **Testing**: 1 day
- **Total**: 5 days

---

## Epic 9: Polish & Testing

**Duration**: 2 weeks
**Goal**: Bug fixes, performance optimization, testing

### User Stories
- As a user, I want the app to be stable so it doesn't crash
- As a user, I want good performance so the app feels responsive

### Tasks

#### 9.1 Settings View
- [ ] Create settings view
- [ ] Light/dark mode toggle
- [ ] Default citation style selector
- [ ] Clear all data button (with confirmation)
- [ ] About/version info

**Files to Create**:
- `Views/SettingsView.swift`

#### 9.2 Performance Optimization
- [ ] Profile graph rendering with Instruments
- [ ] Optimize force-directed layout
- [ ] Add LOD for distant nodes (if needed)
- [ ] Reduce memory usage
- [ ] Target: 60fps with 100 nodes

#### 9.3 Bug Fixes
- [ ] Fix any crashes found in testing
- [ ] Fix layout issues
- [ ] Fix gesture conflicts
- [ ] Fix data persistence issues

#### 9.4 Comprehensive Testing
- [ ] Run all unit tests (target >80% coverage)
- [ ] Run all integration tests
- [ ] Run UI tests for main flows
- [ ] Performance tests
- [ ] Memory leak detection

#### 9.5 UI/UX Polish
- [ ] Add loading indicators
- [ ] Add success/error toast messages
- [ ] Improve error messages
- [ ] Add haptic feedback
- [ ] Smooth animations

#### 9.6 Edge Cases
- [ ] Empty project (no sources)
- [ ] Single source (no connections)
- [ ] Deleted sources with connections
- [ ] Network offline
- [ ] Large graphs (100 sources)

#### 9.7 Documentation
- [ ] Inline code documentation
- [ ] README with setup instructions
- [ ] Known issues/limitations

### Acceptance Criteria
- ✅ Zero known crashes
- ✅ 60fps with 100 nodes
- ✅ Unit test coverage >80%
- ✅ All critical user flows tested
- ✅ Memory usage < 500MB
- ✅ App launch < 2 seconds

### Estimated Effort
- **Development**: 6 days
- **Testing**: 4 days
- **Total**: 10 days

---

## Development Workflow

### Daily Workflow
1. Pick next task from current epic
2. Create feature branch: `feature/epic-X-task-Y`
3. Implement task
4. Write tests
5. Commit with clear message
6. Push and create PR (if collaborating)
7. Code review (self-review if solo)
8. Merge to main branch
9. Update task status

### Weekly Milestones
- **Week 1**: Epic 0 & 1 complete (Foundation)
- **Week 2**: Epic 2 in progress (Basic 3D rendering)
- **Week 3**: Epic 2 & 3 complete (Rendering + Layout)
- **Week 4**: Epic 4 in progress (Source management)
- **Week 5**: Epic 4 & 5 complete (Sources + Scraping)
- **Week 6**: Epic 6 in progress (Interactions)
- **Week 7**: Epic 6 & 7 complete (Interactions + Citations)
- **Week 8**: Epic 8 complete (Onboarding)
- **Week 9-10**: Epic 9 (Polish & Testing)
- **Week 11**: Beta testing preparation
- **Week 12**: Bug fixes from beta, final polish

### Testing Strategy
- Write tests alongside features (not after)
- Run tests before every commit
- Use TDD for complex logic (layout algorithm, citation formatting)
- Manual testing for UI/gestures
- Performance testing weekly

### Code Review Checklist
- [ ] Code follows Swift style guide
- [ ] Tests included and passing
- [ ] No compiler warnings
- [ ] Documentation added for public APIs
- [ ] No hardcoded values
- [ ] Error handling implemented

---

## Risk Management

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RealityKit learning curve | High | Medium | Start with simple prototypes, allocate extra time |
| Force-directed layout too slow | Medium | High | Optimize early, use spatial partitioning, set max iterations |
| Web scraping unreliable | High | Medium | Focus on major sites, have manual fallback |
| Gesture recognition difficult | Medium | Medium | Test early with real device, iterate on UX |
| Scope creep | Medium | High | Stick to MVP scope, defer nice-to-haves |

---

## Definition of Done (MVP)

MVP is complete when:
- ✅ All 9 epics completed
- ✅ Can add 50 sources (manual + URL)
- ✅ Can create 25 connections
- ✅ Graph renders at 60fps
- ✅ Citations export in APA and MLA
- ✅ Onboarding works end-to-end
- ✅ Zero P0 bugs, < 5 P1 bugs
- ✅ Unit test coverage >80%
- ✅ App runs on visionOS simulator and device
- ✅ Ready for TestFlight beta

---

## Next Steps

1. **Review this roadmap** - Make sure priorities align
2. **Start Epic 0** - Set up project
3. **Establish daily standup** - Track progress
4. **Weekly demos** - Show progress on Fridays
5. **Adjust as needed** - Roadmap is flexible

Ready to start with Epic 0?
