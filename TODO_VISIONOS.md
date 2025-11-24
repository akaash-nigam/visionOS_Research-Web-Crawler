# TODO: visionOS Development Tasks

This document tracks all tasks that need to be completed on macOS with Xcode and visionOS SDK.

**Created**: December 2024
**Status**: Ready for macOS/Xcode environment
**Branch**: `claude/review-design-docs-017Ar7fEhviptg6xVXSXt5yC`

---

## 📋 Overview

All MVP features are implemented but haven't been compiled or tested due to Linux environment limitations. This checklist covers everything needed to make the app production-ready.

---

## 🔨 Phase 1: Build & Compilation

### 1.1 Initial Setup
- [ ] Clone repository on macOS machine
- [ ] Open `ResearchWebCrawler.xcodeproj` in Xcode 15.2+
- [ ] Verify visionOS SDK is installed
- [ ] Select Apple Vision Pro Simulator as destination
- [ ] Configure code signing (Team selection)

### 1.2 Dependencies
- [ ] Verify Swift Package Manager fetches dependencies
- [ ] Confirm SwiftSoup (2.6.0+) resolves correctly
- [ ] Check for any dependency conflicts

### 1.3 Build Project
- [ ] Run initial build (⌘B)
- [ ] Fix any compilation errors:
  - Missing imports
  - Type mismatches
  - API availability issues
  - Syntax errors

**Expected Issues:**
- New files may need to be added to Xcode project
- Some APIs might need visionOS availability checks
- Preview providers might need adjustments

---

## 🧪 Phase 2: Unit Testing

### 2.1 Run Existing Tests
- [ ] Run all unit tests (⌘U)
- [ ] Review test results (expect 175+ tests)
- [ ] Document any failures

### 2.2 Epic 6 & 8 Integration
The newly added code for Epic 6 & 8 doesn't have tests yet:

**Epic 6: Graph Interactions**
- [ ] Test `GraphInteractionManager`:
  - [ ] Node selection (single & multi)
  - [ ] Drag-to-connect gestures
  - [ ] Context menu actions
  - [ ] Keyboard shortcuts
- [ ] Test `NodeSelectionView` rendering
- [ ] Test `ConnectionCreatorView` UI
- [ ] Test `GraphContextMenuView` actions

**Epic 8: Onboarding**
- [ ] Test `FirstRunManager`:
  - [ ] First run detection
  - [ ] State persistence
  - [ ] Reset functionality
- [ ] Test `SampleDataGenerator`:
  - [ ] Sample project creation
  - [ ] Source generation
  - [ ] Reference creation
- [ ] Test `WelcomeView` rendering
- [ ] Test `TutorialView` flow

### 2.3 Integration Testing
- [ ] Test GraphInteractionManager with GraphManager
- [ ] Test onboarding flow with main app
- [ ] Test sample data integration with persistence
- [ ] Verify FirstRunManager triggers welcome screen

### 2.4 Fix Test Failures
- [ ] Document all test failures
- [ ] Prioritize critical failures
- [ ] Fix broken tests
- [ ] Re-run tests until all pass

**Target**: 237+ tests passing, 85%+ coverage maintained

---

## 🎨 Phase 3: UI/UX Testing

### 3.1 Welcome & Onboarding
- [ ] Launch app fresh (no previous data)
- [ ] Verify welcome screen appears
- [ ] Test all 4 feature cards display correctly
- [ ] Test "Start Tutorial" button
- [ ] Complete full tutorial flow
- [ ] Test "Skip for Now" button
- [ ] Verify onboarding doesn't show on second launch

### 3.2 Graph Interactions
- [ ] Open project with multiple sources
- [ ] Test node selection:
  - [ ] Single tap selects node
  - [ ] Node highlights correctly
  - [ ] Detail panel appears
- [ ] Test multi-select mode:
  - [ ] Toggle multi-select
  - [ ] Select multiple nodes
  - [ ] Bulk actions work
- [ ] Test drag-to-connect:
  - [ ] Tap and hold on node
  - [ ] Drag toward another node
  - [ ] Connection line follows
  - [ ] Release creates connection
  - [ ] Connection type selector appears
- [ ] Test context menu:
  - [ ] Long press on node
  - [ ] Context menu appears
  - [ ] All actions work (edit, delete, favorite, etc.)
  - [ ] Keyboard shortcuts work

### 3.3 Node Selection Panel
- [ ] Verify metadata displays correctly
- [ ] Test all action buttons:
  - [ ] "Details" opens full view
  - [ ] "Edit" opens editor
  - [ ] Star toggles favorite
- [ ] Test connection list
- [ ] Test navigation to referenced sources
- [ ] Verify panel dismisses correctly

### 3.4 Connection Creator
- [ ] Test connection type picker
- [ ] Verify all 5 connection types work
- [ ] Test connection preview
- [ ] Test "Create Connection" button
- [ ] Test "Cancel" functionality
- [ ] Verify connection appears in graph

### 3.5 Sample Data
- [ ] Generate sample project
- [ ] Verify 7 sources created
- [ ] Verify connections exist
- [ ] Check source metadata is complete
- [ ] Verify graph visualizes correctly

---

## 🔗 Phase 4: Integration Points

### 4.1 Connect New Code to Existing Systems

**GraphInteractionManager Integration:**
- [ ] Add GraphInteractionManager to GraphView
- [ ] Wire up gesture recognizers
- [ ] Connect to GraphScene for entity updates
- [ ] Integrate with PersistenceManager for saves

**FirstRunManager Integration:**
- [ ] Add check in App initialization
- [ ] Show WelcomeView on first run
- [ ] Integrate with main navigation flow

**Sample Data Integration:**
- [ ] Add "Try Sample Project" to welcome
- [ ] Add "Load Demo Data" to project list
- [ ] Integrate with tutorial flow

### 4.2 Update Main Views

**GraphView Updates:**
```swift
// Add to GraphView
@Environment(GraphInteractionManager.self) private var interactionManager

// Add gesture handlers
.gesture(tapGesture)
.gesture(dragGesture)
.gesture(longPressGesture)

// Add overlay views
.overlay {
    if interactionManager.selectedNode != nil {
        NodeSelectionView()
    }
}
.overlay {
    if interactionManager.pendingConnection != nil {
        ConnectionCreatorView()
    }
}
```

**App Initialization:**
```swift
// Add FirstRunManager check
@State private var showWelcome = FirstRunManager.shared.shouldShowWelcome()

// Show welcome sheet
.sheet(isPresented: $showWelcome) {
    WelcomeView()
}
```

**Missing View Files:**
- [ ] Create `SourceDetailView.swift` (referenced but not created)
- [ ] Create `SourceEditView.swift` (referenced but not created)
- [ ] Update existing views to use new interaction system

### 4.3 RealityKit Integration

**GraphScene Updates Needed:**
- [ ] Add `updateNodePosition(nodeId:position:)` method
- [ ] Add `highlightNode(nodeId:scale:emission:color:)` method
- [ ] Test entity highlighting works
- [ ] Test node dragging updates entities
- [ ] Verify edges update when nodes move

---

## ⚡ Phase 5: Performance

### 5.1 Profiling
- [ ] Profile app with Instruments
- [ ] Check memory usage:
  - [ ] Small projects (<20 sources)
  - [ ] Medium projects (50-100 sources)
  - [ ] Large projects (200+ sources)
- [ ] Monitor graph rendering FPS
- [ ] Profile layout algorithm performance
- [ ] Check for memory leaks

### 5.2 Optimization
- [ ] Optimize graph layout for large datasets
- [ ] Improve search performance
- [ ] Optimize RealityKit entity updates
- [ ] Reduce memory footprint if needed

**Performance Targets:**
- 60 FPS at 100 nodes
- <2s layout time for 100 nodes
- <100ms search for 1000 sources
- <500MB memory for 10k sources

---

## 🐛 Phase 6: Bug Fixes

### 6.1 Common Expected Issues

**Compilation Errors:**
- [ ] Missing @MainActor annotations
- [ ] Observable framework issues
- [ ] Environment injection problems
- [ ] Preview provider errors

**Runtime Errors:**
- [ ] Force unwrapping nil values
- [ ] Missing environment objects
- [ ] SwiftData context issues
- [ ] RealityKit entity errors

**UI Issues:**
- [ ] Layout problems in different window sizes
- [ ] Gesture conflicts
- [ ] Animation glitches
- [ ] Memory leaks in views

### 6.2 Testing Edge Cases
- [ ] Empty project (0 sources)
- [ ] Single source project
- [ ] Very large project (500+ sources)
- [ ] Malformed metadata
- [ ] Missing required fields
- [ ] Duplicate connections
- [ ] Circular references

---

## 📱 Phase 7: Device Testing

### 7.1 Simulator Testing
- [ ] Test on visionOS Simulator
- [ ] Test all gestures work
- [ ] Verify 3D rendering
- [ ] Test multi-window support
- [ ] Test background/foreground transitions

### 7.2 Physical Device (if available)
- [ ] Deploy to Apple Vision Pro
- [ ] Test real-world performance
- [ ] Test hand tracking gestures
- [ ] Verify spatial audio (if applicable)
- [ ] Test eye tracking (if applicable)
- [ ] Check battery usage

---

## ♿ Phase 8: Accessibility

### 8.1 VoiceOver
- [ ] Enable VoiceOver
- [ ] Navigate entire app
- [ ] Verify all elements have labels
- [ ] Test all interactive elements
- [ ] Verify reading order is logical

### 8.2 Dynamic Type
- [ ] Test with largest text size
- [ ] Test with smallest text size
- [ ] Verify no text clipping
- [ ] Check layout adapts correctly

### 8.3 Other Accessibility
- [ ] Test with Reduce Motion enabled
- [ ] Test with Increase Contrast
- [ ] Verify color contrast ratios
- [ ] Test keyboard navigation

---

## 📦 Phase 9: App Store Preparation

### 9.1 Assets & Metadata
- [ ] Create app icon (all required sizes)
- [ ] Take screenshots (all required sizes):
  - [ ] Screenshot 1: 3D Graph Overview
  - [ ] Screenshot 2: Source Details
  - [ ] Screenshot 3: Web Scraping
  - [ ] Screenshot 4: Citation Generation
  - [ ] Screenshot 5: Search & Filter
  - [ ] Screenshot 6: Collections
  - [ ] Screenshot 7: Graph Interactions
- [ ] Record app preview video (30s or 60s)
- [ ] Prepare promotional artwork

### 9.2 App Store Connect
- [ ] Create app in App Store Connect
- [ ] Fill in metadata from `APP_STORE_MATERIALS.md`:
  - [ ] App name
  - [ ] Subtitle
  - [ ] Description
  - [ ] Keywords
  - [ ] Categories
  - [ ] Privacy policy URL
  - [ ] Support URL
- [ ] Upload screenshots
- [ ] Upload preview video
- [ ] Set pricing ($19.99 suggested)
- [ ] Select countries

### 9.3 Build Preparation
- [ ] Bump version to 1.0
- [ ] Update build number
- [ ] Set release/debug configurations
- [ ] Enable all optimizations
- [ ] Configure app privacy details:
  - [ ] Data collection: None
  - [ ] Data use: None
  - [ ] Tracking: No
- [ ] Add required usage descriptions
- [ ] Review entitlements

### 9.4 TestFlight
- [ ] Upload build to TestFlight
- [ ] Add internal testers
- [ ] Test TestFlight build
- [ ] Collect beta feedback
- [ ] Fix critical issues
- [ ] Upload final build

### 9.5 Submission
- [ ] Complete App Store Connect forms
- [ ] Add export compliance info
- [ ] Add content rights info
- [ ] Review all metadata one final time
- [ ] Submit for review
- [ ] Respond to any review questions

---

## 📝 Phase 10: Documentation Updates

### 10.1 User Documentation
- [ ] Verify USER_GUIDE.md is accurate
- [ ] Update QUICK_START.md with any changes
- [ ] Create video tutorials (optional)
- [ ] Update FAQ based on testing

### 10.2 Developer Documentation
- [ ] Update README.md with final status
- [ ] Update CONTRIBUTING.md if needed
- [ ] Add DocC comments to new public APIs
- [ ] Generate API documentation

### 10.3 Project Status
- [ ] Update MVP_STATUS.md to 100% complete
- [ ] Create CHANGELOG.md for v1.0
- [ ] Update TODO (this file) with completion status

---

## 🚀 Phase 11: Launch

### 11.1 Pre-Launch
- [ ] Prepare press release
- [ ] Schedule social media posts
- [ ] Prepare launch email
- [ ] Set up analytics (if adding)
- [ ] Prepare support channels

### 11.2 Launch Day
- [ ] Monitor App Store approval
- [ ] Release when approved
- [ ] Send press release
- [ ] Post on social media
- [ ] Send launch email
- [ ] Post on Product Hunt
- [ ] Engage with community

### 11.3 Post-Launch
- [ ] Monitor crash reports
- [ ] Respond to reviews
- [ ] Track downloads
- [ ] Collect user feedback
- [ ] Plan first update

---

## 🔄 Phase 12: Post-Launch Updates

### 12.1 Bug Fixes (v1.0.1)
- [ ] Fix any critical bugs from user reports
- [ ] Improve stability
- [ ] Quick turnaround (<2 weeks)

### 12.2 Performance Update (v1.1)
- [ ] Optimize based on real-world usage
- [ ] Improve large graph performance
- [ ] Enhance web scraping
- [ ] 2-4 weeks after launch

### 12.3 Feature Updates (v1.2+)
- [ ] Cloud sync (opt-in)
- [ ] Collaboration features
- [ ] Additional citation formats
- [ ] PDF annotations
- [ ] Full-text search
- [ ] Export improvements

---

## ⚠️ Known Issues to Address

### Critical (Must Fix Before Launch)
- [ ] Verify all force unwraps are safe or replaced
- [ ] Ensure proper error handling everywhere
- [ ] Fix any data loss scenarios
- [ ] Verify persistence works correctly

### High Priority
- [ ] Optimize memory usage for large projects
- [ ] Improve graph layout convergence speed
- [ ] Add loading indicators for slow operations
- [ ] Handle offline mode gracefully

### Medium Priority
- [ ] Add undo/redo support
- [ ] Improve web scraping success rate
- [ ] Add more citation formats
- [ ] Better error messages

### Low Priority
- [ ] Add keyboard shortcuts reference
- [ ] Add tips/hints system
- [ ] Improve animations
- [ ] Add more graph layout options

---

## 📊 Success Criteria

### Minimum Viable Product (v1.0)
- ✅ All 9 epics implemented
- [ ] All tests passing (237+)
- [ ] 85%+ code coverage maintained
- [ ] No critical bugs
- [ ] Performance targets met
- [ ] Passes App Store review
- [ ] User documentation complete

### Quality Metrics
- [ ] Crash-free rate >99%
- [ ] App Store rating >4.0
- [ ] User retention >60% (day 7)
- [ ] Support request rate <5%

---

## 🎯 Priority Order

**Week 1: Make it Work**
1. Phase 1: Build & Compilation
2. Phase 2: Unit Testing (critical failures only)
3. Phase 4: Integration Points
4. Phase 6: Bug Fixes (critical only)

**Week 2: Make it Right**
5. Phase 3: UI/UX Testing
6. Phase 2: Unit Testing (complete)
7. Phase 5: Performance
8. Phase 6: Bug Fixes (all)

**Week 3: Make it Ship**
9. Phase 7: Device Testing
10. Phase 8: Accessibility
11. Phase 9: App Store Preparation
12. Phase 10: Documentation Updates

**Week 4: Launch**
13. Phase 11: Launch

---

## 📞 Support Contacts

**If you get stuck:**
- GitHub Issues: Create issue with `[visionOS]` tag
- Email: dev@researchwebcrawler.com
- Documentation: See docs/ directory
- Community: [Discord/Forum link]

---

## ✅ Completion Tracking

**Started**: [ ]
**Build Complete**: [ ]
**Tests Passing**: [ ]
**UI Tested**: [ ]
**Performance Optimized**: [ ]
**App Store Submitted**: [ ]
**Launched**: [ ]

---

**Good luck! 🚀 You've got all the code - now make it shine on visionOS!**

---

## Appendix: Quick Commands

```bash
# Build project
xcodebuild -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro' build

# Run tests
xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test
xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -only-testing:ResearchWebCrawlerTests/GraphInteractionManagerTests

# Archive for App Store
xcodebuild archive -scheme ResearchWebCrawler -archivePath ./build/ResearchWebCrawler.xcarchive

# Generate code coverage
xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -enableCodeCoverage YES
```

---

Last Updated: December 2024
