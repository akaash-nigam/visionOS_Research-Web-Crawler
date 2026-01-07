# Research Web Crawler - Implementation

This directory contains the Swift source code for the Research Web Crawler visionOS application.

## Project Structure

```
ResearchWebCrawler/
├── App/                          # App entry point
│   └── ResearchWebCrawlerApp.swift
├── Models/                       # Data models
│   ├── Project.swift            # Research project
│   ├── Source.swift             # Information source
│   ├── Collection.swift         # Source collections
│   └── Graph.swift              # Graph structure
├── Views/                        # SwiftUI views
│   ├── ContentView.swift        # Main view
│   ├── Onboarding/              # Welcome & tutorial
│   ├── Source/                  # Source management
│   ├── Graph/                   # 3D visualization
│   └── Settings/                # App settings
├── ViewModels/                   # View models (future)
├── Services/                     # Business logic
│   ├── GraphManager.swift       # Graph operations
│   ├── PersistenceManager.swift # Data persistence
│   ├── ContentProcessor/        # Web scraping (future)
│   ├── Citation/                # Citation formatting (future)
│   └── Layout/                  # Layout algorithms (future)
├── RealityKit/                   # 3D rendering (future)
├── Utilities/                    # Helper functions
│   ├── Extensions/
│   └── Helpers/
├── Resources/                    # Assets, localizations
└── Tests/                        # Unit tests

## Setup Instructions

### Requirements

- macOS 14.0+
- Xcode 16.0+
- visionOS 2.0+ SDK
- Apple Vision Pro device or simulator

### Installation

1. **Open the Xcode Project**

   From the root directory, open the `.xcodeproj` file:
   ```bash
   open visionOS_Research-Web-Crawler.xcodeproj
   ```

2. **Install Dependencies**

   Dependencies are managed via Swift Package Manager (SPM). They should automatically resolve when you open the project. If not:
   - File → Packages → Resolve Package Versions

   **Dependencies:**
   - [SwiftSoup](https://github.com/scinfu/SwiftSoup) - HTML parsing

3. **Select Target**

   - Select the "ResearchWebCrawler" scheme
   - Choose "Apple Vision Pro" simulator or your connected device

4. **Build and Run**

   - Press ⌘R or click the Run button
   - The app will build and launch

## Current Implementation Status

### Epic 0: Project Setup ✅ (COMPLETED)
- [x] Project structure created
- [x] SwiftData models defined
- [x] Graph data structure implemented
- [x] Services (GraphManager, PersistenceManager)
- [x] Basic UI views (placeholders)
- [x] App compiles and runs

### Epic 1: Data Models & Persistence (NEXT)
- [ ] Complete SwiftData implementation
- [ ] Graph serialization/deserialization
- [ ] File storage for PDFs
- [ ] Unit tests

### Future Epics
- Epic 2: 3D Graph Visualization
- Epic 3: Graph Layout Algorithm
- Epic 4: Source Management
- Epic 5: Web Scraping
- Epic 6: Graph Interaction
- Epic 7: Citation Formatting
- Epic 8: Onboarding
- Epic 9: Polish & Testing

See `docs/MVP_IMPLEMENTATION_ROADMAP.md` for complete roadmap.

## Key Features (Current)

### ✅ Implemented
- Basic app structure
- Data models (Project, Source, Collection, Graph)
- Persistence layer
- Source management UI (manual entry)
- Settings view
- Onboarding placeholder

### 🚧 In Progress
- None (Epic 0 complete)

### 📋 Planned
- 3D graph visualization (Epic 2)
- Force-directed layout (Epic 3)
- Web scraping (Epic 5)
- Connection creation (Epic 6)
- Citation formatting (Epic 7)

## Architecture Overview

### Data Flow

```
User Action
    ↓
SwiftUI View
    ↓
ViewModel/Manager
    ↓
Service Layer (GraphManager, PersistenceManager)
    ↓
SwiftData / File System
```

### Key Classes

- **ResearchWebCrawlerApp**: Main app entry point, initializes ModelContainer
- **GraphManager**: @Observable class managing graph state and operations
- **PersistenceManager**: Handles all persistence (SwiftData + file system)
- **Project/Source/Collection**: SwiftData models
- **Graph**: Custom graph structure with nodes and edges

### Persistence Strategy

- **SwiftData**: User-created data (Projects, Sources, Collections)
- **JSON Files**: Graph structure (nodes, edges, layout)
- **File System**: PDFs, cached content, exports

## Development Workflow

### Adding a New Feature

1. **Create branch** (optional): `git checkout -b feature/feature-name`
2. **Implement feature** in appropriate directory
3. **Write tests** in `Tests/` directory
4. **Update this README** if needed
5. **Commit** with clear message
6. **Test** on simulator and device
7. **Merge** when complete

### Running Tests

```bash
# Run all tests
⌘U in Xcode

# Or via command line
xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

### Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint (optional, config included)
- Document public APIs with comments
- Use MARK: comments to organize code

## Troubleshooting

### Build Errors

**"Cannot find type 'Project' in scope"**
- Ensure all model files are in the Xcode target
- Clean build folder (⇧⌘K)

**"Package resolution failed"**
- Delete `.build` folder
- File → Packages → Reset Package Caches

### Runtime Issues

**"Failed to create ModelContainer"**
- Check SwiftData schema is correct
- Verify models have `@Model` macro
- Check for conflicting model versions

**"Graph file not found"**
- Normal for first run (creates empty graph)
- Check Documents/Graphs directory exists

### Performance Issues

**Slow graph rendering**
- Check node count (should be < 100 for MVP)
- Profile with Instruments
- See Epic 2 for optimization strategies

## Resources

- [visionOS Documentation](https://developer.apple.com/visionos/)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [Project Design Docs](../docs/design/)

## Contributing

See `MVP_IMPLEMENTATION_ROADMAP.md` for current priorities and task breakdowns.

## License

Copyright © 2025 Research Web Crawler. All rights reserved.
