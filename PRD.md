# Product Requirements Document: Research Web Crawler

## Executive Summary

Research Web Crawler transforms research and knowledge discovery on Apple Vision Pro by visualizing information sources as an interactive 3D node network, enabling users to drag connections between concepts, receive AI suggestions for missing links, and auto-organize citations spatially—making complex research intuitive and visually navigable.

## Product Vision

Empower researchers, students, writers, and knowledge workers to explore, connect, and synthesize information more effectively by transforming the linear web browsing experience into a spatial knowledge graph where insights emerge from visual patterns and AI-guided exploration.

## Target Users

### Primary Users
- Graduate students writing theses and dissertations
- Academic researchers conducting literature reviews
- Journalists investigating complex stories
- Writers and authors researching books
- Product managers conducting market research
- Consultants building knowledge bases

### Secondary Users
- Undergraduate students for term papers
- Lawyers researching case law
- Doctors researching medical literature
- Hobbyists exploring topics deeply
- Fact-checkers verifying information

## Market Opportunity

- Research software market: $3.2B by 2027
- Knowledge management tools: $1.1B annually
- 4.9 billion internet users conducting research
- Academic research tools: Zotero (millions of users), Mendeley (6M+)
- Average researcher spends 40% of time searching and organizing information
- Traditional tools (spreadsheets, bookmarks) inadequate for complex research

## Core Features

### 1. 3D Knowledge Graph Visualization

**Description**: Research sources visualized as interconnected nodes in 3D space with relationships shown as connecting lines

**User Stories**:
- As a researcher, I want to see how my sources relate to each other at a glance
- As a student, I want to identify gaps in my research coverage
- As a writer, I want to explore topic clusters spatially

**Acceptance Criteria**:
- Each source (web page, PDF, article) appears as a 3D node
- Node size represents importance/relevance
- Node color represents source type or topic cluster
- Connections show relationships (cites, supports, contradicts, related to)
- Interactive: tap to open, drag to reposition, pinch to zoom
- Multiple graph layouts (force-directed, hierarchical, radial)
- Filtering by date, source type, relevance
- Search across all nodes

**Technical Requirements**:
- Graph database (Neo4j or custom)
- Force-directed layout algorithms
- RealityKit for 3D rendering
- Web scraping and content extraction
- NLP for relationship detection
- Performance: 1,000+ nodes without lag

**Node Types & Visualization**:
```
Node Categories:
- 📄 Article/Blog Post: Blue sphere
- 📰 News: Orange sphere
- 📚 Academic Paper: Purple cube
- 📖 Book: Brown book icon
- 🎥 Video: Red play button
- 📊 Dataset: Green cylinder
- 🐦 Social Media: Light blue bird icon
- 🌐 Wikipedia: Gray "W" icon

Node Size Mapping:
- Citation count (for papers)
- Word count (for articles)
- User-assigned importance (manual)
- Relevance score (AI-determined)

Relationship Types:
- Cites: Solid line
- Supports: Green line
- Contradicts: Red line
- Related to: Dotted line
- Authored by: Thin connecting line to author node
- Published in: Line to journal/publisher node

Graph Layouts:
1. Force-Directed: Nodes repel, relationships attract
2. Hierarchical: Tree structure (topic → subtopic → sources)
3. Radial: Central topic with sources radiating outward
4. Timeline: Chronological arrangement
5. Cluster: Topic clusters with spring layout
6. Custom: User manually arranges nodes
```

### 2. Drag-to-Connect Concept Linking

**Description**: Create connections between concepts and sources by literally dragging lines between nodes

**User Stories**:
- As a researcher, I want to connect related concepts with a gesture
- As a student, I want to annotate why two sources are related
- As a writer, I want to build argument chains visually

**Acceptance Criteria**:
- Draw connection by dragging from one node to another
- Select relationship type (supports, contradicts, etc.)
- Add notes to connections (why are these related?)
- Bi-directional and uni-directional connections
- Connection strength (weak, moderate, strong)
- Batch operations (connect one source to many)
- Delete/modify connections easily
- Export connection as citation/footnote

**Technical Requirements**:
- Hand tracking for precise dragging
- Line rendering with labels
- Connection metadata storage
- Undo/redo for connection changes

**Connection Features**:
```
Creating Connections:
1. Look at source node, pinch to select
2. Drag hand toward target node
3. Line draws in real-time following hand
4. Release on target node
5. Popup: Select relationship type
6. Optionally add note
7. Connection saved

Relationship Types:
- ✅ Supports: Green solid line
- ❌ Contradicts: Red solid line
- 📎 Cites: Blue solid line
- 🔗 Related: Gray dotted line
- 📖 Quotes: Yellow line
- 💡 Inspires: Orange dashed line
- 🔄 Circular Reference: Curved loop

Connection Annotations:
┌────────────────────────┐
│ Why connected?         │
│ "Both discuss climate  │
│  change impact on      │
│  agriculture in Asia"  │
│                        │
│ Relationship: Supports │
│ Strength: Strong       │
│ Added: Nov 20, 2025   │
└────────────────────────┘

Batch Connecting:
- Select multiple nodes (multi-pinch)
- Drag to target node
- All selected connect to target
- Useful for: Multiple sources supporting one claim
```

### 3. AI-Suggested Missing Links

**Description**: AI analyzes the knowledge graph and suggests connections, sources, or concepts the user should explore

**User Stories**:
- As a researcher, I want AI to identify gaps in my literature review
- As a student, I want suggestions for additional sources
- As a writer, I want to discover unexpected connections between topics

**Acceptance Criteria**:
- AI analyzes graph structure and content
- Suggests missing connections between existing nodes
- Recommends new sources to explore
- Identifies contradictions in user's argument
- Highlights consensus vs. disputed topics
- Finds bridge concepts (connecting disconnected clusters)
- Serendipity mode: Random but relevant suggestions
- Confidence scores on suggestions

**Technical Requirements**:
- LLM integration (GPT-4 or Claude)
- Semantic search across sources
- Graph analysis algorithms (centrality, community detection)
- Recommendation engine
- Web search API for source discovery

**AI Suggestion Types**:
```
1. Missing Connections:
   "These two sources discuss similar topics but aren't connected:
   - Smith (2022) on urban planning
   - Jones (2023) on sustainable cities
   Suggested relationship: Related / Supporting"

2. Gap Identification:
   "Your research focuses on climate impacts but lacks sources on:
   - Economic costs of adaptation
   - Policy frameworks
   Suggested sources: [3 recommendations]"

3. Contradictions Detected:
   "⚠️ Potential contradiction:
   - Source A claims X
   - Source B claims NOT X
   Review these sources to reconcile or note disagreement"

4. Bridge Concepts:
   "You have disconnected clusters on:
   - Machine Learning (5 sources)
   - Healthcare (7 sources)
   Bridge concept: 'Medical AI Applications'
   Suggested sources: [3 links]"

5. Authoritative Sources:
   "High-impact sources you're missing:
   - Seminal paper by Nobel laureate (cited 5,000+ times)
   - Recent meta-analysis
   - Government report"

6. Serendipity:
   "Tangentially related discovery:
   - Unexpected connection to [field]
   - Could inspire new research direction"

AI Insight Panel:
┌──────────────────────────────┐
│ 🤖 AI Research Assistant     │
│                              │
│ Suggestions (4):             │
│ • Missing link: A → B        │
│ • Gap: Economic analysis     │
│ • New source: Recent study   │
│ • Contradiction: Review X&Y  │
│                              │
│ [Review] [Ignore All]        │
└──────────────────────────────┘
```

### 4. Smart Citation & Reference Management

**Description**: Automatic citation extraction, formatting, and spatial organization

**User Stories**:
- As a student, I want citations auto-generated in APA, MLA, or Chicago style
- As a researcher, I want to organize sources by project
- As a writer, I want footnotes linked to spatial nodes

**Acceptance Criteria**:
- Auto-extract metadata (author, date, title, URL, DOI)
- Support citation styles: APA, MLA, Chicago, Harvard, IEEE, Vancouver
- Detect duplicate sources
- Export bibliography (BibTeX, RIS, Word, plain text)
- Inline citation insertion (drag node to document)
- PDF annotation integration (Zotero, Mendeley import)
- Notes attached to each source
- Tags and collections for organization

**Technical Requirements**:
- Metadata extraction (web scraping, DOI lookup, ISBN API)
- Citation Style Language (CSL) for formatting
- Duplicate detection (fuzzy matching)
- Export formatters
- PDF parsing (PyMuPDF or similar)

**Citation Features**:
```
Auto-Metadata Extraction:
- Web Article: Scrape title, author, date, publisher
- Academic Paper: DOI lookup (CrossRef API)
- Book: ISBN lookup (Google Books API, OpenLibrary)
- PDF: Extract from document metadata
- Manual entry: For sources without metadata

Citation Formatting:
Input: Smith, J. (2023). Climate Change Impacts. Nature, 45(2), 123-145.

APA: Smith, J. (2023). Climate change impacts. Nature, 45(2), 123-145.
MLA: Smith, John. "Climate Change Impacts." Nature, vol. 45, no. 2, 2023, pp. 123-145.
Chicago: Smith, John. "Climate Change Impacts." Nature 45, no. 2 (2023): 123-145.

Bibliography Export:
- Word (.docx): Formatted reference list
- BibTeX (.bib): For LaTeX users
- RIS (.ris): For EndNote, Mendeley
- Plain Text: Copy-paste ready
- JSON: Structured data export

Source Card:
┌────────────────────────────┐
│ 📄 Climate Tipping Points  │
│                            │
│ Author: Smith et al.       │
│ Year: 2023                 │
│ Journal: Nature Climate    │
│ DOI: 10.1038/s41558-...   │
│                            │
│ Tags: [climate] [tipping]  │
│ Collection: Thesis Ch. 3   │
│                            │
│ Notes: Key finding on...   │
│                            │
│ [Cite] [Open] [Edit]       │
└────────────────────────────┘

Duplicate Detection:
"⚠️ Possible duplicate:
Existing: Smith (2023) Nature Climate
New: Smith et al. (2023) Nat. Clim. Change
Same DOI detected. Merge sources?"
```

### 5. Multi-Modal Content Capture

**Description**: Add sources to graph from multiple input methods (web, PDF, notes, voice)

**User Stories**:
- As a researcher, I want to add web articles by sharing from Safari
- As a student, I want to upload PDFs of course readings
- As a writer, I want to voice-record ideas and add as nodes

**Acceptance Criteria**:
- Safari share sheet integration
- PDF upload and parsing
- Manual entry for books, lectures
- Voice note recording (transcribed to text)
- Photo/screenshot capture (OCR for text extraction)
- Import from Zotero, Mendeley, EndNote
- Clipboard monitoring (copy URL, auto-suggest adding)
- Email forwarding (send article to research@app, auto-adds)

**Technical Requirements**:
- Share extension for iOS/visionOS
- PDF parsing library
- Speech-to-text (on-device)
- OCR (Vision framework)
- Import parsers for research tools
- Email processing (optional)

**Input Methods**:
```
1. Web Article (Safari Share):
   - Browse web in Safari
   - Tap Share → Research Web Crawler
   - Article added to graph
   - Metadata auto-extracted

2. PDF Upload:
   - Drag PDF file into app
   - App extracts title, author, highlights
   - Creates node with full-text search

3. Manual Entry:
   - Tap "Add Source" floating button
   - Enter: Title, Author, Year, URL/ISBN
   - Optionally add notes
   - Node created

4. Voice Note:
   - Say "Add research note"
   - Speak idea or summary
   - Transcribed to text node
   - Can link to existing sources

5. Screenshot/Photo:
   - Capture image of book page, whiteboard
   - OCR extracts text
   - Node created with image + text

6. Import from Tools:
   - Connect Zotero account
   - Select library to import
   - All sources added to graph
   - Maintains collections/tags

7. Email (Power User):
   - Forward article to your@research-app.com
   - Auto-processed and added
   - Reply email with confirmation

Quick Add Panel:
┌────────────────────────┐
│ Add Source             │
│                        │
│ • 🌐 From Web (Share)  │
│ • 📄 Upload PDF        │
│ • ✏️ Manual Entry      │
│ • 🎙️ Voice Note       │
│ • 📷 Photo/Screenshot  │
│ • 📥 Import Library    │
└────────────────────────┘
```

### 6. Collaborative Research Spaces

**Description**: Share knowledge graphs with team members for collaborative research projects

**User Stories**:
- As a research team, we want shared access to our literature review
- As a professor, I want to review a student's research graph
- As co-authors, we want to build a knowledge base together

**Acceptance Criteria**:
- Create shared research spaces
- Invite collaborators (view-only or edit)
- Real-time collaboration (see others' cursors/actions)
- Comment threads on nodes and connections
- Version history (who added what, when)
- Merge individual graphs into shared space
- Export shared graph for presentations
- Permissions: Owner, Editor, Commenter, Viewer

**Technical Requirements**:
- CloudKit for sync (or custom backend)
- Real-time collaboration (WebSockets or SharePlay)
- Access control system
- Conflict resolution for concurrent edits
- Activity feed / audit log

**Collaboration Features**:
```
Research Space Types:
- Personal: Private, individual research
- Shared: Team members with permissions
- Public: Read-only, shareable link

Permissions:
- Owner: Full control, can delete space
- Editor: Add/edit nodes, connections, notes
- Commenter: View, add comments only
- Viewer: Read-only access

Real-Time Collaboration:
- See team members' avatars in graph
- Live cursor showing where they're looking
- Notifications: "Jane added 3 new sources"
- Simultaneous editing with conflict resolution

Comments & Discussions:
Node Comment Thread:
┌─────────────────────────┐
│ 💬 Comments (3)         │
│                         │
│ Alice: This contradicts │
│ our hypothesis          │
│ 2 hours ago             │
│                         │
│ Bob: Agreed, we should  │
│ reconsider              │
│ 1 hour ago              │
│                         │
│ You: Let's discuss in   │
│ next meeting            │
│ Just now                │
│                         │
│ [Add Comment]           │
└─────────────────────────┘

Version History:
- Nov 20, 3:42 PM: You added "Smith (2023)"
- Nov 20, 2:15 PM: Alice connected A → B
- Nov 19, 5:30 PM: Bob added 5 sources from import
- [View Full History]

Merging Graphs:
"Alice has completed her literature review (25 sources).
Merge her graph into the shared team space?
[Review] [Merge] [Cancel]"
```

## User Experience

### Onboarding Flow
1. Welcome: "Build your research knowledge graph in 3D space"
2. Tutorial: Add first source (paste article URL)
3. Watch node materialize in space
4. Tutorial: Drag to create connection
5. AI suggests related sources
6. Add suggested source
7. View emerging graph structure
8. Ready to research

### Research Session Flow

1. Open Research Web Crawler
2. Current project: "Climate Change Impacts" (35 sources)
3. View 3D knowledge graph
4. AI suggests: "Missing link between sources A and B"
5. User draws connection
6. Browses web, finds new article
7. Shares from Safari → added to graph
8. AI: "This contradicts existing source"
9. User reviews both, adds note
10. Exports bibliography for draft writing
11. Session auto-saved

### Gesture & Voice Controls

```
Gestures:
- Tap node: Open source details
- Double-tap: Open full content (web/PDF)
- Drag: Reposition node
- Pinch-drag: Create connection
- Two-hand spread: Zoom out (full graph view)
- Rotate: Spin graph to view from different angle

Voice Commands:
- "Add source from clipboard"
- "Show me sources from 2023"
- "Find sources about climate policy"
- "Connect this to that"
- "Export bibliography in APA format"
- "What's missing in my research?"
```

## Design Specifications

### Visual Design

**Color Palette**:
- Primary: Blue #007AFF (knowledge, trust)
- Secondary: Purple #5856D6 (academic)
- Accent: Green #34C759 (connections, growth)
- Background: Dark mode default (reduces eye strain)

**Typography**:
- UI: SF Pro
- Citations: Georgia (serif, academic feel)
- Sizes: 16-24pt for readability

### Spatial Layout

**Default View**:
- Center: Knowledge graph (main focus)
- Left: Source list (linear view)
- Right: AI suggestions panel
- Bottom: Search bar and filters

## Technical Architecture

### Platform
- Apple Vision Pro (visionOS 2.0+)
- Companion iOS/Mac app (for non-Vision Pro users)
- Swift, SwiftUI, RealityKit

### System Requirements
- visionOS 2.0+
- 100GB storage (for PDFs, cached web pages)
- Internet for web scraping, AI suggestions

### Key Technologies
- **Graph Database**: Neo4j or custom
- **NLP**: For relationship extraction
- **LLM API**: GPT-4 or Claude (AI suggestions)
- **Web Scraping**: Beautiful Soup, Readability
- **PDF Parsing**: PyMuPDF
- **Citation**: CSL processor

### Performance Targets
- Graph render: < 5 seconds (1,000 nodes)
- Add source: < 3 seconds
- AI suggestion: < 10 seconds
- Search: < 1 second
- Frame rate: 60fps

## Monetization Strategy

**Freemium**:
- **Free**: 50 sources, basic features
- **Pro**: $14.99/month or $149/year
  - Unlimited sources
  - AI suggestions
  - Collaboration
  - Advanced export
  - Priority support

**Academic**: $9.99/month (with .edu email)

**Team**: $49.99/month (5 users, shared spaces)

**Revenue Streams**:
1. Subscriptions
2. B2B (universities, research institutions)
3. Partnerships (publishers, databases)

### Target Revenue
- Year 1: $1M (7,000 users @ $150 ARPU)
- Year 2: $6M (35,000 users)
- Year 3: $20M (120,000 users)

## Success Metrics

### Primary KPIs
- MAU: 50,000 in Year 1
- Premium conversion: 20%
- Avg sources per user: 100+
- Session duration: 45+ minutes
- NPS: > 60

### Research Impact
- 30% faster literature review (user survey)
- 25% more connections discovered
- 40% better citation organization

## Launch Strategy

**Phase 1**: Beta (Months 1-2) - Academics, 500 users
**Phase 2**: Launch (Month 3) - Public, App Store
**Phase 3**: Growth (Months 4-12) - Marketing to universities

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Graph too complex to navigate | High | Medium | Smart filtering, zoom levels, layouts |
| AI suggestions irrelevant | Medium | Medium | User feedback loop, model fine-tuning |
| Slow performance with large graphs | High | Medium | Optimize rendering, lazy loading |
| Competition from established tools | Medium | High | Superior UX via spatial computing |

## Success Criteria
- 100,000 users in 12 months
- 20,000 paying subscribers
- $5M revenue in 18 months
- Featured by Apple
- Adopted by 10+ universities

## Appendix

### Integrations
- Zotero, Mendeley, EndNote (import)
- Google Scholar, PubMed, arXiv (search)
- Notion, Obsidian (export)
- Microsoft Word, Google Docs (citations)
