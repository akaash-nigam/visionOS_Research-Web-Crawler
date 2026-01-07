# Testing Strategy Document

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

Comprehensive testing strategy for Research Web Crawler, including unit tests, integration tests, UI tests, performance tests, and beta testing approach.

## Testing Pyramid

```
           ╱╲
          ╱  ╲ Manual Testing (10%)
         ╱────╲
        ╱      ╲ UI Tests (20%)
       ╱────────╲
      ╱          ╲ Integration Tests (30%)
     ╱────────────╲
    ╱              ╲ Unit Tests (40%)
   ╱────────────────╲
```

## Unit Testing

### Scope
Test individual functions and classes in isolation.

### Tools
- XCTest (Swift standard)
- Quick/Nimble (BDD style, optional)

### Coverage Target
- **Minimum**: 70%
- **Goal**: 85%
- **Critical paths**: 100%

### Examples

#### Graph Data Structure

```swift
final class GraphTests: XCTestCase {
    var graph: Graph!

    override func setUp() {
        graph = Graph(projectId: UUID())
    }

    func testAddNode() {
        let nodeId = UUID()
        graph.addNode(GraphNode(sourceId: nodeId, position: .zero, size: 0.05, color: .blue))

        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertNotNil(graph.nodes[nodeId])
    }

    func testAddEdge() {
        let node1 = UUID()
        let node2 = UUID()

        graph.addNode(GraphNode(sourceId: node1, position: .zero, size: 0.05, color: .blue))
        graph.addNode(GraphNode(sourceId: node2, position: [1, 0, 0], size: 0.05, color: .blue))

        let connection = Connection(from: node1, to: node2, type: .related, createdBy: "test")
        graph.addEdge(connection)

        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertTrue(graph.isConnected(from: node1, to: node2))
    }

    func testFindNeighbors() {
        let node1 = UUID()
        let node2 = UUID()
        let node3 = UUID()

        graph.addNode(GraphNode(sourceId: node1, position: .zero, size: 0.05, color: .blue))
        graph.addNode(GraphNode(sourceId: node2, position: [1, 0, 0], size: 0.05, color: .blue))
        graph.addNode(GraphNode(sourceId: node3, position: [0, 1, 0], size: 0.05, color: .blue))

        graph.addEdge(Connection(from: node1, to: node2, type: .related, createdBy: "test"))
        graph.addEdge(Connection(from: node1, to: node3, type: .related, createdBy: "test"))

        let neighbors = graph.neighbors(of: node1)

        XCTAssertEqual(neighbors.count, 2)
        XCTAssertTrue(neighbors.contains(node2))
        XCTAssertTrue(neighbors.contains(node3))
    }
}
```

#### Force-Directed Layout

```swift
final class ForceDirectedLayoutTests: XCTestCase {
    func testLayoutConvergence() {
        let layout = ForceDirectedLayout()

        // Create simple graph
        let node1 = UUID()
        let node2 = UUID()

        layout.nodes = [
            node1: GraphNode(sourceId: node1, position: .zero, size: 0.05, color: .blue),
            node2: GraphNode(sourceId: node2, position: [0.1, 0, 0], size: 0.05, color: .blue)
        ]

        layout.edges = [Connection(from: node1, to: node2, type: .related, createdBy: "test")]

        // Run layout
        let positions = layout.compute()

        // Check convergence (nodes should be ~1.0 units apart)
        let distance = length(positions[node1]! - positions[node2]!)
        XCTAssertEqual(distance, layout.k, accuracy: 0.1)
    }

    func testPerformance() {
        // Test with 100 nodes
        let layout = ForceDirectedLayout()

        for _ in 0..<100 {
            let nodeId = UUID()
            layout.nodes[nodeId] = GraphNode(
                sourceId: nodeId,
                position: [Float.random(in: -5...5), Float.random(in: -5...5), Float.random(in: -5...5)],
                size: 0.05,
                color: .blue
            )
        }

        measure {
            _ = layout.compute()
        }

        // Should complete in < 3 seconds
    }
}
```

#### Citation Formatting

```swift
final class CitationFormatterTests: XCTestCase {
    func testAPAJournalArticle() {
        let source = Source(
            title: "Climate Change Impacts on Agriculture",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )
        source.authors = ["Smith, John", "Doe, Jane"]
        source.publicationDate = Date(year: 2023, month: 5, day: 1)
        source.journal = "Nature Climate Change"
        source.volume = "13"
        source.issue = "5"
        source.pages = "412-425"
        source.doi = "10.1038/s41558-023-01234-5"

        let citation = APAFormatter().format(source)

        let expected = "Smith, J. & Doe, J. (2023). Climate change impacts on agriculture. Nature Climate Change, 13(5), 412-425. https://doi.org/10.1038/s41558-023-01234-5"

        XCTAssertEqual(citation, expected)
    }

    func testMLABook() {
        let source = Source(
            title: "Research Methods in Education",
            type: .book,
            projectId: UUID(),
            addedBy: "test"
        )
        source.authors = ["Cohen, Louis", "Manion, Lawrence", "Morrison, Keith"]
        source.publicationDate = Date(year: 2018, month: 1, day: 1)
        source.publisher = "Routledge"

        let citation = MLAFormatter().format(source)

        let expected = "Cohen, Louis, et al. Research Methods in Education. Routledge, 2018."

        XCTAssertEqual(citation, expected)
    }
}
```

#### Web Scraping

```swift
final class WebScraperTests: XCTestCase {
    func testMetadataExtraction() throws {
        let html = """
        <html>
        <head>
            <meta property="og:title" content="Test Article">
            <meta property="og:description" content="Test description">
            <meta name="citation_author" content="John Smith">
            <meta name="citation_doi" content="10.1234/test">
        </head>
        <body><p>Content</p></body>
        </html>
        """

        let doc = try SwiftSoup.parse(html)
        let scraper = WebScraper()
        let metadata = try scraper.extractMetadata(from: doc, url: URL(string: "https://test.com")!)

        XCTAssertEqual(metadata.title, "Test Article")
        XCTAssertEqual(metadata.authors, ["John Smith"])
        XCTAssertEqual(metadata.doi, "10.1234/test")
    }

    func testContentExtraction() throws {
        let html = """
        <html>
        <body>
            <article>
                <h1>Article Title</h1>
                <p>First paragraph.</p>
                <p>Second paragraph.</p>
            </article>
        </body>
        </html>
        """

        let doc = try SwiftSoup.parse(html)
        let scraper = WebScraper()
        let content = try scraper.extractMainContent(from: doc)

        XCTAssertTrue(content.contains("First paragraph"))
        XCTAssertTrue(content.contains("Second paragraph"))
    }
}
```

## Integration Testing

### Scope
Test interactions between components.

### Examples

#### Source Addition Flow

```swift
final class SourceAdditionIntegrationTests: XCTestCase {
    var contentProcessor: ContentProcessor!
    var graphManager: GraphManager!
    var citationEngine: CitationEngine!

    override func setUp() async throws {
        contentProcessor = ContentProcessor()
        graphManager = GraphManager()
        citationEngine = CitationEngine()
    }

    func testAddSourceFromURL() async throws {
        let url = URL(string: "https://example.com/article")!

        // 1. Scrape and extract metadata
        let source = try await contentProcessor.processURL(url)

        XCTAssertFalse(source.title.isEmpty)
        XCTAssertNotNil(source.authors)

        // 2. Add to graph
        graphManager.addSource(source)

        XCTAssertEqual(graphManager.sources.count, 1)
        XCTAssertEqual(graphManager.graph.nodes.count, 1)

        // 3. Generate citation
        let citation = citationEngine.formatCitation(source, style: .apa)

        XCTAssertFalse(citation.isEmpty)
    }
}
```

#### CloudKit Sync

```swift
final class CloudKitSyncIntegrationTests: XCTestCase {
    func testRoundTripSync() async throws {
        let syncManager = SyncManager()

        // 1. Create local source
        let source = Source(
            title: "Test Source",
            type: .article,
            projectId: testProject.id,
            addedBy: "test"
        )
        try await localDB.save(source)

        // 2. Sync to CloudKit
        try await syncManager.pushChanges()

        // 3. Clear local database
        try await localDB.delete(source)

        // 4. Pull from CloudKit
        try await syncManager.pullChanges()

        // 5. Verify source restored
        let restored = try await localDB.fetch(Source.self, id: source.id)
        XCTAssertEqual(restored.title, "Test Source")
    }

    func testConflictResolution() async throws {
        // 1. Create source locally and remotely with different titles
        let localSource = Source(title: "Local Title", ...)
        let remoteSource = Source(title: "Remote Title", ...)
        remoteSource.id = localSource.id
        remoteSource.modified = Date().addingTimeInterval(60) // 1 minute newer

        // 2. Sync
        try await syncManager.startSync()

        // 3. Verify newer version wins
        let result = try await localDB.fetch(Source.self, id: localSource.id)
        XCTAssertEqual(result.title, "Remote Title")
    }
}
```

## UI Testing

### Scope
Test complete user flows in the UI.

### Tools
- XCUITest

### Examples

#### Onboarding Flow

```swift
final class OnboardingUITests: XCTestCase {
    func testOnboardingFlow() {
        let app = XCUIApplication()
        app.launch()

        // Welcome screen
        XCTAssertTrue(app.staticTexts["Build your research in 3D"].exists)
        app.buttons["Start Tutorial"].tap()

        // Tutorial step 1
        XCTAssertTrue(app.staticTexts["This is your research space"].exists)
        app.buttons["Next"].tap()

        // Tutorial step 2
        XCTAssertTrue(app.staticTexts["Add your first source"].exists)
        app.buttons["Next"].tap()

        // Complete tutorial
        app.buttons["Get Started"].tap()

        // Verify main screen
        XCTAssertTrue(app.buttons["Add Source"].exists)
    }
}
```

#### Add Source and Create Connection

```swift
final class GraphInteractionUITests: XCTestCase {
    func testAddSourceAndCreateConnection() {
        let app = XCUIApplication()
        app.launch()

        // Skip onboarding
        app.buttons["Skip"].tap()

        // Add first source
        app.buttons["Add Source"].tap()
        app.buttons["From URL"].tap()
        app.textFields["URL"].tap()
        app.textFields["URL"].typeText("https://example.com/article1\n")

        // Wait for scraping
        sleep(2)

        XCTAssertTrue(app.staticTexts["Article Title"].waitForExistence(timeout: 5))

        // Add second source
        app.buttons["Add Source"].tap()
        app.buttons["From URL"].tap()
        app.textFields["URL"].typeText("https://example.com/article2\n")
        sleep(2)

        // Create connection (gesture simulation)
        let node1 = app.otherElements["Node_0"]
        let node2 = app.otherElements["Node_1"]

        // Long press and drag (connection creation)
        node1.press(forDuration: 0.5, thenDragTo: node2)

        // Select connection type
        app.buttons["Related"].tap()

        // Verify connection created
        XCTAssertTrue(app.otherElements["Connection_0_1"].exists)
    }
}
```

## Performance Testing

### Metrics

- **Rendering**: 60fps with 100 nodes
- **Layout**: < 3 seconds for 100 nodes
- **Scraping**: < 5 seconds per URL
- **Search**: < 500ms for 1,000 sources
- **App Launch**: < 2 seconds

### Examples

```swift
final class PerformanceTests: XCTestCase {
    func testGraphRenderingPerformance() {
        let graphManager = GraphManager()

        // Create 100 nodes
        for _ in 0..<100 {
            let source = Source(title: "Test", type: .article, projectId: UUID(), addedBy: "test")
            graphManager.addSource(source)
        }

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            graphManager.renderGraph()
        }
    }

    func testSearchPerformance() {
        let searchEngine = SearchEngine()

        // Create 1,000 sources
        let sources = (0..<1000).map { i in
            Source(title: "Test Source \(i)", type: .article, projectId: UUID(), addedBy: "test")
        }

        measure {
            let results = searchEngine.search(query: "test", in: sources)
            XCTAssertGreaterThan(results.count, 0)
        }
    }

    func testLayoutPerformance() {
        let layout = ForceDirectedLayout()

        // 100 nodes, 150 edges
        for _ in 0..<100 {
            let nodeId = UUID()
            layout.nodes[nodeId] = GraphNode(
                sourceId: nodeId,
                position: randomPosition(),
                size: 0.05,
                color: .blue
            )
        }

        for _ in 0..<150 {
            let from = layout.nodes.keys.randomElement()!
            let to = layout.nodes.keys.randomElement()!
            layout.edges.append(Connection(from: from, to: to, type: .related, createdBy: "test"))
        }

        measure {
            _ = layout.compute()
        }
    }
}
```

## Beta Testing

### Phases

#### Phase 1: Internal (Week 1-2)
- **Participants**: Dev team (5 people)
- **Goal**: Find critical bugs
- **Method**: Dogfooding, manual testing
- **Exit Criteria**: Zero crashes, core features work

#### Phase 2: Friends & Family (Week 3-4)
- **Participants**: 10-15 trusted users
- **Goal**: Usability feedback, edge cases
- **Method**: TestFlight, feedback form, interviews
- **Exit Criteria**: Positive feedback on core value prop

#### Phase 3: Closed Beta (Week 5-8)
- **Participants**: 50-100 beta testers
- **Goal**: Scale testing, diverse use cases
- **Method**: TestFlight, in-app feedback, analytics
- **Exit Criteria**: NPS > 50, < 5% crash rate

#### Phase 4: Open Beta (Week 9-12)
- **Participants**: 500+ users
- **Goal**: Final polish, marketing validation
- **Method**: Public TestFlight link
- **Exit Criteria**: Ready for App Store submission

### Beta Tester Recruitment

**Target Audience**:
- Graduate students (30%)
- Academic researchers (30%)
- Journalists (20%)
- Writers (20%)

**Recruitment Channels**:
- Academic subreddits (r/GradSchool, r/AskAcademia)
- Twitter (#AcademicTwitter, #PhDChat)
- University mailing lists
- Personal network

**Incentives**:
- Free Pro subscription for 6 months
- Early access to new features
- Name in credits

### Feedback Collection

#### In-App Feedback
```swift
struct FeedbackView: View {
    @State private var rating: Int = 0
    @State private var feedback: String = ""

    var body: some View {
        Form {
            Section("How would you rate Research Web Crawler?") {
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button(action: { rating = star }) {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                        }
                    }
                }
            }

            Section("What can we improve?") {
                TextEditor(text: $feedback)
                    .frame(height: 150)
            }

            Button("Submit Feedback") {
                submitFeedback(rating: rating, text: feedback)
            }
        }
    }
}
```

#### Analytics Events

Track key metrics:
- Onboarding completion rate
- Sources added per user
- Connections created per user
- Time to first connection
- Session duration
- Feature adoption
- Crash rate

### Bug Tracking

**Priority Levels**:
- **P0 (Critical)**: Crashes, data loss - fix immediately
- **P1 (High)**: Major feature broken - fix in 24 hours
- **P2 (Medium)**: Minor bug - fix in sprint
- **P3 (Low)**: Polish, nice-to-have - backlog

**Bug Report Template**:
```
Title: [Concise description]
Priority: P0/P1/P2/P3
Device: Vision Pro
visionOS Version: 2.0
App Version: 1.0.0 (123)

Steps to Reproduce:
1. ...
2. ...
3. ...

Expected Behavior:
...

Actual Behavior:
...

Screenshots/Logs:
[Attach if available]
```

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build
        run: xcodebuild -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build

      - name: Unit Tests
        run: xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

      - name: Code Coverage
        run: xcrun llvm-cov report

      - name: Upload Coverage
        uses: codecov/codecov-action@v2
```

## Quality Gates

**Before PR Merge**:
- [ ] All tests pass
- [ ] Code coverage ≥ 70%
- [ ] No compiler warnings
- [ ] Peer review approved

**Before Release**:
- [ ] All P0/P1 bugs fixed
- [ ] Performance metrics met
- [ ] Accessibility audit passed
- [ ] Beta NPS > 50
- [ ] Crash rate < 1%

## References

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [XCUITest Guide](https://developer.apple.com/documentation/xctest/user_interface_tests)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Code Coverage Best Practices](https://martinfowler.com/bliki/TestCoverage.html)
