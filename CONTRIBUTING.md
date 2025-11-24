# Contributing to Research Web Crawler

Thank you for your interest in contributing to Research Web Crawler! This document provides guidelines and instructions for contributing.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Project Structure](#project-structure)
5. [Coding Guidelines](#coding-guidelines)
6. [Making Changes](#making-changes)
7. [Testing](#testing)
8. [Submitting Pull Requests](#submitting-pull-requests)
9. [Reporting Bugs](#reporting-bugs)
10. [Feature Requests](#feature-requests)
11. [Documentation](#documentation)
12. [Community](#community)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, gender identity, sexual orientation, disability, ethnicity, religion, or age.

### Expected Behavior

- ✅ Use welcoming and inclusive language
- ✅ Be respectful of differing viewpoints and experiences
- ✅ Gracefully accept constructive criticism
- ✅ Focus on what is best for the community
- ✅ Show empathy towards other community members

### Unacceptable Behavior

- ❌ Harassment, trolling, or discriminatory comments
- ❌ Personal or political attacks
- ❌ Public or private harassment
- ❌ Publishing others' private information
- ❌ Other conduct inappropriate in a professional setting

### Enforcement

Violations of the code of conduct can be reported to conduct@researchwebcrawler.com. All reports will be reviewed and investigated confidentially.

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.2+** with visionOS SDK
- **Apple Vision Pro** or visionOS Simulator
- **Git** for version control
- **GitHub account** for contributions

### Skills Welcome

We welcome contributors with various skills:

- **Swift Development**: Core app functionality
- **visionOS/RealityKit**: 3D visualization
- **UI/UX Design**: Interface improvements
- **Documentation**: Guides, tutorials, translations
- **Testing**: QA, bug reporting, test writing
- **Design**: Icons, graphics, marketing materials

### Ways to Contribute

1. **Code**: Fix bugs, add features, improve performance
2. **Documentation**: Write guides, improve README, add comments
3. **Testing**: Report bugs, write tests, perform QA
4. **Design**: Create icons, mockups, marketing materials
5. **Translation**: Localize the app (coming soon)
6. **Community**: Answer questions, help users, write blog posts

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub first, then:

git clone https://github.com/YOUR_USERNAME/visionOS_Research-Web-Crawler.git
cd visionOS_Research-Web-Crawler
```

### 2. Open in Xcode

```bash
cd ResearchWebCrawler
open ResearchWebCrawler.xcodeproj
```

### 3. Configure Signing

1. Select the project in Xcode
2. Go to "Signing & Capabilities"
3. Select your Team
4. Xcode will handle provisioning

### 4. Install Dependencies

Dependencies are managed via Swift Package Manager (included in Xcode):

```swift
// Package.swift dependencies:
- SwiftSoup (for HTML parsing)
```

Xcode will automatically fetch dependencies on first build.

### 5. Build and Run

1. Select scheme: **ResearchWebCrawler**
2. Select destination: **Apple Vision Pro Simulator**
3. Press **⌘R** to build and run

---

## Project Structure

```
visionOS_Research-Web-Crawler/
├── ResearchWebCrawler/           # Main app code
│   ├── App/                      # App lifecycle
│   ├── Models/                   # Data models
│   │   ├── Project.swift
│   │   ├── Source.swift
│   │   └── Collection.swift
│   ├── Services/                 # Business logic
│   │   ├── PersistenceManager.swift
│   │   ├── GraphManager.swift
│   │   ├── WebScraper.swift
│   │   └── CitationFormatter.swift
│   ├── Views/                    # SwiftUI views
│   │   ├── Projects/
│   │   ├── Sources/
│   │   ├── Graph/
│   │   └── Onboarding/
│   ├── RealityKit/              # 3D visualization
│   │   ├── GraphScene.swift
│   │   ├── NodeEntity.swift
│   │   └── EdgeEntity.swift
│   ├── Layout/                   # Graph layout algorithms
│   │   ├── ForceDirectedLayout.swift
│   │   └── LayoutManager.swift
│   ├── Utilities/               # Helper functions
│   │   └── Validation.swift
│   ├── ViewModels/              # View models
│   └── Tests/                   # Unit tests
├── docs/                         # Documentation
│   ├── design/                  # Design documents
│   ├── USER_GUIDE.md
│   ├── QUICK_START.md
│   └── TEST_EXECUTION_GUIDE.md
├── README.md                     # Project overview
├── CONTRIBUTING.md              # This file
├── LICENSE                      # MIT License
└── MVP_STATUS.md                # Development status
```

### Key Directories

**Models/** - SwiftData models with persistence
**Services/** - Business logic, no UI dependencies
**Views/** - SwiftUI views, minimal logic
**RealityKit/** - 3D rendering and entity management
**Layout/** - Graph layout algorithms
**Tests/** - Comprehensive test suite

---

## Coding Guidelines

### Swift Style Guide

We follow Apple's Swift API Design Guidelines with some additions:

#### Naming Conventions

```swift
// Types: UpperCamelCase
class GraphManager { }
struct Source { }
enum SourceType { }

// Functions and properties: lowerCamelCase
func addSource() { }
var sourceCount: Int

// Constants: lowerCamelCase
let maxNodeCount = 1000

// Private properties: leading underscore (optional)
private var _internalCache: [String: Any]
```

#### Code Organization

```swift
// MARK: - Used for major sections
class MyClass {
    // MARK: - Properties

    var publicProperty: String
    private var privateProperty: Int

    // MARK: - Initialization

    init() { }

    // MARK: - Public Methods

    func publicMethod() { }

    // MARK: - Private Methods

    private func privateMethod() { }
}
```

#### SwiftUI Views

```swift
struct MyView: View {
    // MARK: - Properties

    @State private var localState: String = ""
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        content
    }

    // MARK: - View Builders

    @ViewBuilder
    private var content: some View {
        VStack {
            // View code
        }
    }

    // MARK: - Methods

    private func handleAction() {
        // Action handling
    }
}
```

### Documentation Comments

Use DocC-style comments for public APIs:

```swift
/// Manages the 3D knowledge graph visualization.
///
/// `GraphManager` coordinates between the data model and RealityKit scene,
/// handling node creation, layout application, and user interactions.
///
/// ## Topics
/// ### Loading Data
/// - ``loadProject(_:)``
/// - ``unloadProject()``
///
/// ### Layout
/// - ``applyLayout()``
/// - ``updateNodePositions()``
@MainActor
class GraphManager: ObservableObject {

    /// Loads a project and creates the graph visualization.
    ///
    /// - Parameter project: The project to load
    /// - Throws: `GraphError.tooManyNodes` if node count exceeds limit
    func loadProject(_ project: Project) throws {
        // Implementation
    }
}
```

### Error Handling

```swift
// Define custom errors
enum GraphError: LocalizedError {
    case tooManyNodes
    case invalidLayout

    var errorDescription: String? {
        switch self {
        case .tooManyNodes:
            return "Graph contains too many nodes to render efficiently."
        case .invalidLayout:
            return "The selected layout algorithm is not valid for this graph."
        }
    }
}

// Use do-catch for recoverable errors
do {
    try manager.loadProject(project)
} catch {
    print("Failed to load project: \(error.localizedDescription)")
}

// Use guard for preconditions
guard !sources.isEmpty else {
    throw GraphError.invalidLayout
}
```

### Async/Await

```swift
// Prefer async/await over completion handlers
func fetchData() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// Mark UI updates with @MainActor
@MainActor
func updateUI() {
    self.isLoading = false
}

// Use Task for async work in sync context
Button("Load") {
    Task {
        await loadData()
    }
}
```

### Observable Framework

```swift
// Use @Observable for state management
@Observable
class GraphManager {
    var nodes: [GraphNode] = []
    var selectedNode: GraphNode?

    func selectNode(_ node: GraphNode) {
        selectedNode = node
        // Views automatically update
    }
}

// Consume in views with @Environment
struct MyView: View {
    @Environment(GraphManager.self) private var graphManager

    var body: some View {
        Text("Nodes: \(graphManager.nodes.count)")
    }
}
```

### SwiftData

```swift
// Model with relationships
@Model
final class Source {
    var id: UUID
    var title: String
    var project: Project?

    init(title: String, project: Project?) {
        self.id = UUID()
        self.title = title
        self.project = project
    }
}

// Query in views
struct SourceListView: View {
    @Query(sort: \Source.title) var sources: [Source]

    var body: some View {
        List(sources) { source in
            Text(source.title)
        }
    }
}
```

---

## Making Changes

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `perf/` - Performance improvements

### 2. Make Your Changes

- Write clean, readable code
- Follow the coding guidelines above
- Add comments for complex logic
- Update documentation as needed

### 3. Write Tests

All new code should include tests:

```swift
@MainActor
final class YourFeatureTests: XCTestCase {
    var manager: YourManager!

    override func setUp() async throws {
        manager = YourManager()
    }

    func testYourFeature() {
        // Given
        let input = "test"

        // When
        let result = manager.process(input)

        // Then
        XCTAssertEqual(result, "expected")
    }
}
```

### 4. Run Tests

```bash
# In Xcode: ⌘U to run all tests

# Or command line:
xcodebuild test -scheme ResearchWebCrawler \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### 5. Commit Your Changes

```bash
git add .
git commit -m "Add feature: brief description

Longer description of what changed and why.
Fixes #123"
```

Commit message guidelines:
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description of changes
- Reference issues: "Fixes #123" or "Relates to #456"

### 6. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

---

## Testing

### Running Tests

**All Tests:**
```bash
⌘U in Xcode
```

**Specific Test Class:**
```bash
xcodebuild test \
  -scheme ResearchWebCrawler \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:ResearchWebCrawlerTests/GraphManagerTests
```

**Specific Test Method:**
```bash
xcodebuild test \
  -scheme ResearchWebCrawler \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -only-testing:ResearchWebCrawlerTests/GraphManagerTests/testLoadProject
```

### Test Types

1. **Unit Tests** - Test individual components
2. **Integration Tests** - Test component interactions
3. **UI Tests** - Test user interface (requires simulator)
4. **Performance Tests** - Benchmark critical operations

### Writing Good Tests

```swift
// Good test structure
func testFeatureName() {
    // Given - Set up test conditions
    let input = createTestInput()

    // When - Execute the code under test
    let result = systemUnderTest.process(input)

    // Then - Verify the results
    XCTAssertEqual(result, expectedOutput)
}

// Test naming: test + What + When + Expected
func testLoadProject_WhenEmpty_ReturnsZeroNodes()
func testAddSource_WithValidData_SuccessfullyAdds()
func testSearch_WithEmptyQuery_ReturnsAllSources()
```

### Test Coverage

We aim for:
- **Models**: 90%+ coverage
- **Services**: 85%+ coverage
- **Utilities**: 85%+ coverage
- **Views**: 40%+ (harder to test)

Check coverage in Xcode:
1. Run tests with coverage: ⌘U
2. Editor → Show Code Coverage
3. View coverage report

---

## Submitting Pull Requests

### Before Submitting

Checklist:
- [ ] Code follows style guidelines
- [ ] All tests pass
- [ ] New tests added for new code
- [ ] Documentation updated
- [ ] No merge conflicts with main
- [ ] Commit messages are clear
- [ ] PR description is complete

### Creating the PR

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Set base: `main` ← compare: `your-branch`
4. Fill in the PR template:

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
Describe how you tested these changes.

## Screenshots (if applicable)
Add screenshots for UI changes.

## Checklist
- [ ] Tests pass locally
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No breaking changes

## Related Issues
Fixes #123
Relates to #456
```

### PR Review Process

1. **Automated Checks** run (tests, linting, etc.)
2. **Code Review** by maintainers
3. **Discussion** and requested changes
4. **Approval** when ready
5. **Merge** to main branch

### Addressing Review Comments

```bash
# Make requested changes
git add .
git commit -m "Address review comments"
git push origin feature/your-feature-name
```

PR automatically updates with new commits.

---

## Reporting Bugs

### Before Reporting

1. **Search existing issues** - May already be reported
2. **Try latest version** - May already be fixed
3. **Reproduce the bug** - Ensure it's consistent
4. **Gather information** - Logs, screenshots, steps

### Creating a Bug Report

Use the bug report template:

```markdown
**Describe the Bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Screenshots**
If applicable, add screenshots.

**Environment**
- Device: Apple Vision Pro
- OS: visionOS 2.1
- App Version: 1.0.2

**Additional Context**
Any other relevant information.
```

---

## Feature Requests

### Submitting Feature Requests

1. Check existing feature requests
2. Describe the feature clearly
3. Explain the use case
4. Provide examples if possible

Template:

```markdown
**Feature Description**
Clear description of the feature.

**Problem it Solves**
What problem does this solve?

**Proposed Solution**
How might this work?

**Alternatives Considered**
Other approaches you've thought about.

**Additional Context**
Mockups, examples, related features.
```

---

## Documentation

### Types of Documentation

1. **Code Comments** - Explain complex logic
2. **DocC Comments** - API documentation
3. **README** - Project overview
4. **Guides** - User and developer guides
5. **Design Docs** - Architecture and decisions

### Writing Documentation

**Good Documentation:**
- Clear and concise
- Uses examples
- Explains "why" not just "what"
- Kept up-to-date with code

**Example:**

```swift
/// Applies a force-directed layout algorithm to position nodes.
///
/// The algorithm uses simulated annealing to minimize edge crossings
/// and distribute nodes evenly in 3D space. This process can take
/// several seconds for large graphs (100+ nodes).
///
/// ```swift
/// manager.applyLayout()
/// // Graph automatically redraws with new positions
/// ```
///
/// - Note: Call this on the main thread only
/// - Complexity: O(n²) where n is the number of nodes
/// - Warning: Performance degrades significantly above 500 nodes
func applyLayout() {
    // Implementation
}
```

---

## Community

### Communication Channels

- **GitHub Discussions** - Q&A and announcements
- **Discord** - Real-time chat (coming soon)
- **Twitter** - Updates and news
- **Blog** - Deep dives and tutorials

### Getting Help

- **Questions**: Use GitHub Discussions
- **Bugs**: Create an issue
- **Security**: Email security@researchwebcrawler.com
- **General**: Discord or Twitter

### Recognition

Contributors are recognized:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Featured in blog posts (for major contributions)
- Invited to contributor Discord channel

---

## Legal

### Contributor License Agreement

By contributing, you agree that:

1. You have the right to submit your contribution
2. Your contribution is licensed under the MIT License
3. You grant us rights to use your contribution

### Copyright

- Original code: © Research Web Crawler Team
- Contributions: © Respective contributors
- All code: MIT License

---

## Questions?

If you have questions not covered here:

1. Check the [FAQ](docs/FAQ.md)
2. Search [GitHub Discussions](https://github.com/yourusername/visionOS_Research-Web-Crawler/discussions)
3. Ask in #contributors channel on Discord
4. Email: contribute@researchwebcrawler.com

---

## Thank You! 🙏

Every contribution, no matter how small, makes a difference. Thank you for helping make Research Web Crawler better!

---

**Happy Contributing! 🚀**

Research Web Crawler Team
