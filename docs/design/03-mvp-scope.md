# MVP Scope Definition

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

This document defines the Minimum Viable Product (MVP) for Research Web Crawler. The MVP will validate core value propositions while remaining achievable within 3 months of development.

## MVP Goal

**Primary Goal**: Demonstrate that 3D spatial knowledge graphs provide superior research organization compared to traditional linear tools.

**Success Criteria**:
- Users can build a 50-source knowledge graph in < 30 minutes
- Users report the graph helps them see relationships they missed
- 20+ beta testers complete onboarding and create projects
- NPS > 50 from beta users

## MVP Core Value Proposition

"See your research in 3D space. Connect ideas with gestures. Discover relationships you never noticed."

## What's IN the MVP

### Phase 1: MVP Features (Months 1-3)

#### 1. Basic 3D Knowledge Graph ✅
**Status**: Must Have
**Value**: Core differentiator

**Included**:
- ✅ 3D nodes representing sources
- ✅ Basic node types: Article, Paper, Book, Note
- ✅ Node size based on importance (manual)
- ✅ Node color by type
- ✅ Force-directed layout only (simplest to implement)
- ✅ Tap to select, double-tap to view
- ✅ Pinch and drag to zoom/pan
- ✅ Support up to 100 sources (MVP limit)

**Excluded** (Post-MVP):
- ❌ Multiple layout algorithms (hierarchical, radial, etc.)
- ❌ Advanced filtering and search
- ❌ Clustering and topic grouping
- ❌ Animated transitions
- ❌ Timeline view

#### 2. Manual Connection Creation ✅
**Status**: Must Have
**Value**: Core interaction paradigm

**Included**:
- ✅ Drag from one node to another to create connection
- ✅ Three connection types: Related, Supports, Contradicts
- ✅ Add simple text annotation to connection
- ✅ Delete connections
- ✅ View connections list

**Excluded** (Post-MVP):
- ❌ Connection strength (weak/moderate/strong)
- ❌ Bi-directional connections
- ❌ Batch connection creation
- ❌ Connection templates
- ❌ Rich text annotations

#### 3. Basic Source Management ✅
**Status**: Must Have
**Value**: Foundation for graph

**Included**:
- ✅ Add source from URL (web scraping)
- ✅ Add source manually (title, author, URL)
- ✅ Upload PDF (store locally)
- ✅ View source details (title, author, date, URL, notes)
- ✅ Edit source metadata
- ✅ Delete source
- ✅ Add plain text notes to source
- ✅ Basic metadata extraction (title, author from web/PDF)

**Excluded** (Post-MVP):
- ❌ Safari share extension
- ❌ Voice notes
- ❌ Photo/OCR capture
- ❌ Import from Zotero/Mendeley
- ❌ Advanced PDF parsing (highlights, annotations)
- ❌ Full-text search within PDFs
- ❌ Tags and collections
- ❌ Favorites/ratings

#### 4. Simple Citation Export ✅
**Status**: Must Have
**Value**: Practical utility for researchers

**Included**:
- ✅ Auto-generate citation from metadata
- ✅ Two styles: APA and MLA only
- ✅ Export bibliography as plain text
- ✅ Copy individual citation

**Excluded** (Post-MVP):
- ❌ Chicago, Harvard, IEEE styles
- ❌ BibTeX, RIS export
- ❌ Word document export
- ❌ Inline citation insertion
- ❌ Duplicate detection
- ❌ DOI lookup
- ❌ Citation Style Language (CSL) processor

#### 5. Local-Only Storage ✅
**Status**: Must Have
**Value**: Simplicity, privacy

**Included**:
- ✅ SwiftData for metadata
- ✅ Custom JSON serialization for graph
- ✅ Local file storage for PDFs
- ✅ Single project support (no multi-project for MVP)
- ✅ Auto-save

**Excluded** (Post-MVP):
- ❌ CloudKit sync
- ❌ Multi-device support
- ❌ Collaboration
- ❌ Multiple projects
- ❌ Import/export of projects
- ❌ Backup/restore

#### 6. Basic Onboarding ✅
**Status**: Must Have
**Value**: User activation

**Included**:
- ✅ Welcome screen
- ✅ Tutorial: Add first source
- ✅ Tutorial: Create first connection
- ✅ Tutorial: View graph
- ✅ Sample project with 5 pre-loaded sources

**Excluded** (Post-MVP):
- ❌ Interactive tutorial with checkpoints
- ❌ Video tutorials
- ❌ Context-sensitive help
- ❌ Tips and tricks

#### 7. Essential Settings ✅
**Status**: Must Have
**Value**: Basic configuration

**Included**:
- ✅ Light/dark mode toggle
- ✅ Default citation style
- ✅ Clear all data (for testing)

**Excluded** (Post-MVP):
- ❌ Node style customization
- ❌ Layout parameters
- ❌ Privacy settings
- ❌ Subscription management
- ❌ Account settings

## What's OUT of the MVP

### Features Explicitly Excluded

#### 1. AI Suggestions ❌
**Why Excluded**: Complex, costly, requires backend
**Post-MVP**: Phase 2 (Month 4-6)
- Missing link suggestions
- Gap identification
- Contradiction detection
- Source recommendations

#### 2. Collaboration & Sharing ❌
**Why Excluded**: Requires CloudKit, complex conflict resolution
**Post-MVP**: Phase 3 (Month 7-9)
- Shared research spaces
- Real-time collaboration
- Comments and discussions
- Permissions

#### 3. Advanced Layouts ❌
**Why Excluded**: Nice-to-have, force-directed is sufficient
**Post-MVP**: Phase 2 (Month 4-6)
- Hierarchical
- Radial
- Timeline
- Cluster

#### 4. Multi-Modal Input ❌
**Why Excluded**: Complex integrations
**Post-MVP**: Phase 2 (Month 4-6)
- Safari share extension
- Voice notes
- Photo/OCR
- Email forwarding

#### 5. Advanced Citation Features ❌
**Why Excluded**: Complex CSL implementation
**Post-MVP**: Phase 2 (Month 4-6)
- All citation styles
- BibTeX/RIS export
- DOI/ISBN lookup
- Duplicate detection

#### 6. Multi-Project Support ❌
**Why Excluded**: Adds UI complexity
**Post-MVP**: Phase 2 (Month 4-6)
- Multiple projects
- Project switching
- Project templates

#### 7. iOS Companion App ❌
**Why Excluded**: Separate platform
**Post-MVP**: Phase 4 (Month 10-12)
- iPhone/iPad app
- Cross-platform sync

#### 8. Performance Optimization for 1000+ Sources ❌
**Why Excluded**: MVP limited to 100 sources
**Post-MVP**: Phase 4 (Month 10-12)
- LOD optimization
- Instanced rendering
- Progressive loading

## MVP User Journey

### Initial Experience

1. **Launch App**
   - Welcome screen: "Build your research in 3D"
   - Button: "Start Tutorial" or "Skip"

2. **Tutorial** (If selected)
   - Screen 1: "This is your research space" (empty 3D view)
   - Screen 2: "Add your first source" (paste URL or enter manually)
   - Screen 3: "Watch it appear as a 3D node"
   - Screen 4: "Add another source"
   - Screen 5: "Connect them" (drag gesture tutorial)
   - Screen 6: "You're ready to research!"

3. **First Project**
   - Empty graph OR sample project with 5 sources
   - Floating "+" button to add sources

### Core Loop

```
Add Source → View in Graph → Connect to Others → Add Notes → Repeat
                ↓
            Export Citations (when needed)
```

### Key Workflows

#### Workflow 1: Add Source from Web
```
1. User finds article online
2. Copies URL
3. Taps "+" button in app
4. Selects "Add from URL"
5. Pastes URL
6. App scrapes metadata (title, author)
7. User confirms/edits
8. Node appears in graph
9. User drags to position
```

#### Workflow 2: Create Connection
```
1. User looks at two related nodes
2. Pinches first node
3. Drags hand toward second node
4. Line follows hand
5. Releases on second node
6. Popup: Select type (Related/Supports/Contradicts)
7. Optionally adds annotation
8. Connection created
```

#### Workflow 3: Export Bibliography
```
1. User taps menu button
2. Selects "Export Citations"
3. Chooses style (APA or MLA)
4. Bibliography generated
5. User copies to clipboard
6. Pastes into their document
```

## MVP Technical Stack

### Frameworks
- **visionOS 2.0+**: Platform
- **SwiftUI**: UI
- **RealityKit**: 3D rendering
- **SwiftData**: Local database
- **Foundation**: Networking, file I/O

### Third-Party (Minimal)
- **SwiftSoup**: HTML parsing (for web scraping)
- **PDFKit**: PDF parsing
- Optional: **Alamofire** (if URLSession insufficient)

### No Backend Required
- Everything runs on-device
- No API keys needed for MVP
- No subscription/auth

## MVP Development Timeline

### Month 1: Core Infrastructure
**Weeks 1-2**:
- ✅ Setup Xcode project
- ✅ Define SwiftData models
- ✅ Implement graph data structure
- ✅ Basic RealityKit scene setup

**Weeks 3-4**:
- ✅ Implement force-directed layout algorithm
- ✅ Render nodes as basic shapes
- ✅ Implement camera controls (pan, zoom)
- ✅ Basic gesture recognition

**Milestone 1**: Can render 50 nodes in 3D space with pan/zoom

### Month 2: Content & Interaction
**Weeks 5-6**:
- ✅ Web scraping implementation
- ✅ Metadata extraction
- ✅ PDF upload and parsing
- ✅ Source CRUD operations
- ✅ Source detail view

**Weeks 7-8**:
- ✅ Connection creation (drag gesture)
- ✅ Connection rendering (lines between nodes)
- ✅ Connection annotation UI
- ✅ Node selection and highlighting

**Milestone 2**: Can add sources and connect them

### Month 3: Polish & Export
**Weeks 9-10**:
- ✅ Citation formatting (APA, MLA)
- ✅ Bibliography export
- ✅ Onboarding flow
- ✅ Settings screen
- ✅ Sample project data

**Weeks 11-12**:
- ✅ Bug fixes
- ✅ Performance testing (100 sources)
- ✅ UI polish
- ✅ TestFlight build
- ✅ Beta testing with 20 users

**Milestone 3**: Feature-complete MVP ready for beta

## MVP Success Metrics

### Activation Metrics
- **Onboarding Completion**: > 80%
- **First Source Added**: < 5 minutes from launch
- **First Connection Created**: < 10 minutes from launch

### Engagement Metrics
- **Sources per User**: > 20
- **Connections per User**: > 10
- **Session Duration**: > 15 minutes
- **Weekly Active Users**: > 50% of beta testers

### Satisfaction Metrics
- **NPS**: > 50
- **"Would Recommend"**: > 70%
- **"Better than Current Tools"**: > 60%

### Technical Metrics
- **Crash Rate**: < 1%
- **Load Time**: < 3 seconds
- **Frame Rate**: > 50fps with 100 sources
- **Memory Usage**: < 500MB

## MVP Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| RealityKit performance issues | Medium | High | Early prototype, simplified graphics |
| Web scraping unreliable | High | Medium | Fallback to manual entry, cache results |
| Force-directed layout too slow | Low | Medium | Optimize algorithm, limit iterations |
| User adoption (complex UI) | Medium | High | Strong onboarding, sample project |
| Development time overrun | Medium | High | Ruthlessly cut scope, focus on core |

## MVP vs. Full Vision

| Feature | MVP | Phase 2 | Phase 3 | Phase 4 |
|---------|-----|---------|---------|---------|
| 3D Graph | ✅ Basic | Advanced | - | - |
| Layouts | Force-directed | +4 more | - | - |
| Connections | Manual | +AI Suggestions | - | - |
| Sources | 100 limit | 1,000 limit | 10,000 | - |
| Citation | APA, MLA | All styles | - | - |
| Storage | Local | +CloudKit | - | - |
| Collab | - | - | ✅ Real-time | - |
| AI | - | ✅ Suggestions | +Semantic | - |
| Mobile | - | - | - | ✅ iOS app |

## Post-MVP Roadmap

### Phase 2: Intelligence (Months 4-6)
- AI-powered suggestions
- CloudKit sync
- Multiple projects
- Advanced layouts
- All citation styles

### Phase 3: Collaboration (Months 7-9)
- Shared research spaces
- Real-time collaboration
- Comments
- Version history

### Phase 4: Scale & Polish (Months 10-12)
- Support 10,000+ sources
- iOS/iPadOS app
- Performance optimization
- Advanced import/export
- Voice commands

## MVP Feature Checklist

### Must Have (Cannot Ship Without)
- [x] Add source from URL
- [x] Add source manually
- [x] Upload PDF
- [x] View 3D graph
- [x] Create connections
- [x] Export citations (APA, MLA)
- [x] Basic onboarding

### Should Have (Important, But Can Defer)
- [ ] Edit source metadata
- [ ] Delete sources/connections
- [ ] Sample project
- [ ] Settings screen
- [ ] Node size customization

### Nice to Have (Can Definitely Defer)
- [ ] Dark/light mode
- [ ] Search sources
- [ ] Filter by type
- [ ] Connection list view
- [ ] Undo/redo

## Validation Plan

### Week 1-2: Internal Testing
- Team dogfooding
- Fix critical bugs
- Performance testing

### Week 3-4: Friends & Family
- 5-10 trusted users
- Detailed feedback sessions
- Usability testing

### Week 5-8: Beta Testing
- 20-30 beta testers (academics, students)
- Surveys and interviews
- Analytics tracking
- Iterate based on feedback

### Week 9-12: Prepare for Launch
- Bug fixes
- Polish
- Marketing materials
- App Store submission

## Definition of Done

MVP is complete when:
1. ✅ All "Must Have" features implemented
2. ✅ Onboarding flow functional
3. ✅ Can add 50 sources and create 25 connections without crashes
4. ✅ Citation export works correctly
5. ✅ 60fps with 100 sources
6. ✅ Zero critical bugs
7. ✅ 20 beta testers complete full user journey
8. ✅ NPS > 50

## Next Steps

1. **Immediate**: Setup Xcode project and dependencies
2. **Week 1**: Implement data models and graph structure
3. **Week 2**: Basic RealityKit scene with test nodes
4. **Week 3**: Force-directed layout implementation
5. **Week 4**: Gesture controls and interaction

## References

- [MVP Best Practices](https://www.ycombinator.com/library/4Q-a-minimum-viable-product-is-not-a-product)
- [Force-Directed Graphs](https://en.wikipedia.org/wiki/Force-directed_graph_drawing)
- [RealityKit Performance](https://developer.apple.com/documentation/realitykit/optimizing-rendering-performance)
