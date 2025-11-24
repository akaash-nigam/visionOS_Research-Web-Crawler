# Research Web Crawler - User Guide

Welcome to the Research Web Crawler for Apple Vision Pro! This comprehensive guide will help you master all features of the app.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Projects](#projects)
3. [Adding Sources](#adding-sources)
4. [3D Graph Visualization](#3d-graph-visualization)
5. [Managing Connections](#managing-connections)
6. [Search & Filter](#search--filter)
7. [Collections](#collections)
8. [Citations & Bibliography](#citations--bibliography)
9. [Tips & Tricks](#tips--tricks)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Launch

When you first launch Research Web Crawler, you'll see a welcome screen introducing you to the app's key features.

**Options:**
- **Start Tutorial**: Interactive walkthrough of all features (recommended for new users)
- **Skip for Now**: Jump straight into using the app

### System Requirements

- **Device**: Apple Vision Pro
- **OS**: visionOS 2.0 or later
- **Storage**: 100MB minimum (more for PDFs and large projects)
- **Internet**: Optional (required for web scraping)

### Interface Overview

The app consists of four main areas:

1. **Project List**: Your research projects
2. **Source Library**: All sources in the current project
3. **3D Graph View**: Immersive visualization
4. **Detail Panel**: Information about selected items

---

## Projects

### What is a Project?

A project is a collection of related research sources. Think of it as a folder for organizing sources around a specific topic, paper, or research area.

**Examples:**
- "PhD Dissertation - Machine Learning"
- "Literature Review - Climate Change"
- "Book Research - Historical Fiction"

### Creating a Project

1. Tap the **"+"** button in the top-right corner
2. Enter a **project name** (required)
3. Add a **description** (optional but recommended)
4. Tap **"Create"**

**Tips:**
- Use descriptive names that indicate the project's scope
- Add a detailed description to remember the project's purpose
- Include relevant keywords in the description for easier searching

### Managing Projects

**Open a Project:**
- Tap any project in the list to open it

**Edit a Project:**
1. Long press on a project
2. Select "Edit"
3. Update name or description
4. Tap "Save"

**Delete a Project:**
1. Swipe left on a project
2. Tap "Delete"
3. Confirm deletion

⚠️ **Warning**: Deleting a project deletes all its sources and cannot be undone!

### Switching Projects

- Tap the back button in the top-left to return to project list
- Select a different project to switch
- Each project maintains its own sources and graph

---

## Adding Sources

There are three ways to add sources to your project.

### Method 1: Manual Entry

**Best for**: Complete control over all metadata

**Steps:**
1. Tap **"Add Source"** button
2. Select **"Add Manually"**
3. Fill in the form:
   - **Title** (required)
   - **Authors** (one per line or comma-separated)
   - **Source Type** (paper, book, article, etc.)
   - **Publication Date**
   - **Journal** (for academic papers)
   - **Volume, Issue, Pages**
   - **DOI** (Digital Object Identifier)
   - **ISBN** (for books)
   - **URL**
   - **Abstract**
   - **Tags** (keywords)
   - **Notes** (your personal notes)
4. Tap **"Save"**

**Pro Tips:**
- Fill in as much metadata as possible for better citations
- Use tags liberally to enable powerful filtering later
- Add notes immediately while thoughts are fresh
- Mark important sources as favorites with the star button

### Method 2: Web Scraping

**Best for**: Quickly capturing online sources

**Steps:**
1. Tap **"Add Source"** button
2. Select **"From URL"**
3. Paste or type the URL
4. Tap **"Scrape"**
5. Wait while metadata is extracted (5-10 seconds)
6. Review and edit auto-populated fields
7. Tap **"Save"**

**What Gets Auto-Extracted:**
- ✅ Title
- ✅ Authors
- ✅ Description/Abstract
- ✅ Publication date
- ✅ DOI (if available)
- ✅ Journal name (for academic sources)
- ✅ Keywords (converted to tags)

**Supported Sites:**
- Academic databases (arXiv, PubMed, JSTOR)
- Publisher sites (Springer, Elsevier, Wiley)
- Wikipedia articles
- News sites
- Blogs and personal websites

**Troubleshooting:**
- If scraping fails, check your internet connection
- Some sites block automated scraping - use manual entry instead
- Rate limiting: Wait 1 second between scrapes

### Method 3: PDF Upload

**Best for**: Adding downloaded papers and books

**Steps:**
1. Tap **"Add Source"** button
2. Select **"From PDF"**
3. Browse your files
4. Select the PDF file
5. PDF filename auto-fills the title
6. Add additional metadata
7. Tap **"Save"**

**Features:**
- PDF is stored with the source
- Access PDF anytime from source details
- PDF filename suggests the title
- File size shown in source details

**Tips:**
- Rename PDFs with descriptive names before importing
- PDFs are stored locally on your device
- Large PDFs (>50MB) may take time to import

### Editing Sources

**Edit Anytime:**
1. Select a source (tap node or list item)
2. Tap "Edit" button
3. Modify any fields
4. Tap "Save"

**Bulk Editing:**
- Select multiple sources (long press to enable)
- Tap "Edit Selected"
- Apply tags, mark as favorite, or delete

---

## 3D Graph Visualization

The 3D graph is where Research Web Crawler truly shines. Your sources become nodes in 3D space, connected by their relationships.

### Understanding the Graph

**Nodes** (Spheres):
- Each sphere represents one source
- Color indicates source type:
  - 🔵 Blue = Academic Paper
  - 🟤 Brown = Book
  - 🟠 Orange = Article
  - 🟢 Green = Website
  - 🔴 Red = Video
  - 🟣 Purple = Podcast
  - (See all 11 types in the legend)
- Size can indicate importance (coming soon)

**Edges** (Lines):
- Lines connect related sources
- Direction shows reference flow (A → B means "A references B")
- Color indicates relationship type:
  - Blue = References
  - Purple = Cited By
  - Green = Related
  - Red = Contradicts
  - Mint = Supports

### Navigation Controls

**Rotate the Graph:**
- Drag with one hand to rotate
- Natural spatial gestures

**Zoom:**
- Pinch with two hands to zoom in/out
- Double-tap air to zoom to fit all nodes

**Pan:**
- Drag with two hands to move the graph
- Center the graph on a specific area

**Reset View:**
- Tap the "Reset" button to return to default view

### Interacting with Nodes

**Select a Node:**
- Tap any node to select it
- Selected node highlights in bright color
- Detail panel shows source information

**Move a Node:**
- Tap and drag a node to reposition it
- Release to drop in new position
- Graph layout adjusts automatically

**Multi-Select:**
1. Enable multi-select mode (toolbar button)
2. Tap multiple nodes to select them
3. Perform bulk actions:
   - Export citations
   - Delete all
   - Add to collection

### Graph Layout

**Auto Layout:**
- Tap "Re-layout" to organize nodes automatically
- Uses force-directed algorithm
- Related nodes cluster together
- Unconnected nodes spread out

**Layout Takes Time:**
- Small graphs (<20 nodes): Instant
- Medium graphs (20-100 nodes): 1-5 seconds
- Large graphs (100+ nodes): 10-30 seconds

**Manual Positioning:**
- Move nodes manually for custom layouts
- Manual positions persist across sessions
- Tap "Re-layout" anytime to reset

---

## Managing Connections

Connections (references) between sources reveal how research builds upon previous work.

### Creating Connections

**Method 1: Drag-to-Connect (Recommended)**
1. Tap and hold on the source node
2. Drag your finger toward the target node
3. A line appears following your finger
4. Release when hovering over target
5. Select connection type
6. Tap "Create"

**Method 2: From Source Details**
1. Select a source (tap its node)
2. Tap "Add Reference"
3. Choose target from list
4. Select connection type
5. Tap "Add"

### Connection Types

Choose the type that best describes the relationship:

**References** (→):
- This source cites or references the target
- Most common type
- Example: Your paper references Einstein's work

**Cited By** (←):
- This source is cited by the target
- Reverse of "References"
- Auto-created when you add a reference

**Related** (⟷):
- Sources on similar topics
- Bidirectional relationship
- Example: Two papers on the same subject

**Contradicts** (⊗):
- This source disagrees with the target
- Useful for tracking debates
- Example: Conflicting research findings

**Supports** (✓):
- This source provides evidence for the target
- Shows agreement or validation
- Example: Replication studies

### Managing Connections

**View All Connections:**
1. Select a source
2. Scroll to "Connections" section
3. See:
   - Outgoing references (what this cites)
   - Incoming references (what cites this)

**Delete a Connection:**
- Swipe left on connection in list
- Tap "Delete"
- Connection removed (source remains)

**Navigate Connections:**
- Tap any connection to jump to that source
- Follow citation chains through your research

---

## Search & Filter

Find exactly what you need in large projects.

### Text Search

**Search Box** (top of screen):
1. Tap search box
2. Type your query
3. Results update in real-time

**Searches Across:**
- ✓ Title
- ✓ Authors
- ✓ Abstract
- ✓ Notes
- ✓ Journal name

**Search Tips:**
- Case-insensitive
- Partial matches work ("quantum" finds "quantum computing")
- Search multiple words: all must match
- Clear search to see all sources again

### Filters

Apply filters to narrow down sources:

**Filter by Type:**
- Academic Papers
- Books
- Articles
- Websites
- Videos
- Podcasts
- And more...

**Filter by Tags:**
- Tap tag chips to filter
- Multiple tags: shows sources with ANY tag
- Clear tags to remove filter

**Filter by Favorites:**
- Toggle "Favorites Only"
- Shows only starred sources

**Filter by Date:**
- Publication date ranges
- Date added to project
- Last modified date

**Filter by Collections:**
- Select a collection
- Shows only sources in that collection

**Filter by Connections:**
- "Has References" - sources that cite others
- "Is Referenced" - sources cited by others
- "Unconnected" - isolated sources

### Sorting

Sort sources by:

1. **Title (A-Z)**
2. **Title (Z-A)**
3. **Date Added (Newest)**
4. **Date Added (Oldest)**
5. **Publication Date (Newest)**
6. **Publication Date (Oldest)**
7. **Author (A-Z)**

**Change Sort Order:**
- Tap sort picker
- Select desired option
- List reorders instantly

### Combining Filters

Stack multiple filters for powerful queries:

**Example:** "Show me favorite academic papers about 'neural networks' from 2020-2023"
1. Toggle "Favorites Only"
2. Filter type: "Academic Papers"
3. Search: "neural networks"
4. Date range: 2020-2023

---

## Collections

Collections are curated groups of sources within a project.

### What are Collections?

Think of collections as "playlists" for your research:
- Group sources by theme
- Create reading lists
- Organize by chapter or section
- Track sources for specific purposes

**Examples:**
- "Chapter 2 Sources"
- "Must Read Papers"
- "Methodology References"
- "Historical Context"

### Creating Collections

1. Tap **"Collections"** tab
2. Tap **"+"** button
3. Enter collection **name**
4. Add **description** (optional)
5. Tap **"Create"**

### Adding Sources to Collections

**Method 1: From Collection View**
1. Open collection
2. Tap "Add Sources"
3. Select sources (checkboxes)
4. Tap "Add"

**Method 2: From Source Details**
1. View any source
2. Tap "Add to Collection"
3. Select target collection(s)
4. Source added to collection(s)

**Method 3: Multi-Select**
1. Enable multi-select in source list
2. Select multiple sources
3. Tap "Add to Collection"
4. Choose collection

### Managing Collections

**Rename a Collection:**
1. Long press collection
2. Tap "Rename"
3. Enter new name

**Delete a Collection:**
- Swipe left on collection
- Tap "Delete"
- Note: Sources remain in project!

**Reorder Sources:**
- Drag handles to reorder
- Custom order persists

### Using Collections

**Filter by Collection:**
- Tap collection name
- Graph shows only collection sources
- Badge indicates filtered view

**Export Collection:**
- Generate bibliography for entire collection
- Export as BibTeX
- Share collection list

---

## Citations & Bibliography

Generate perfect citations effortlessly.

### Single Citation

**Copy One Citation:**
1. Select a source
2. Tap "Copy Citation"
3. Choose format (APA, MLA, Chicago)
4. Citation copied to clipboard
5. Paste anywhere

**Citation Formats:**

**APA 7th Edition:**
```
Smith, J. (2023). Understanding neural networks. Journal of AI, 45(2), 123-145. https://doi.org/10.1234/jai.2023.001
```

**MLA 9th Edition:**
```
Smith, John. "Understanding Neural Networks." Journal of AI, vol. 45, no. 2, 2023, pp. 123-145.
```

**Chicago 17th Edition:**
```
Smith, John. "Understanding Neural Networks." Journal of AI 45, no. 2 (March 2023): 123-145.
```

### Generate Bibliography

**Create Bibliography:**
1. Tap **"Bibliography"** button
2. Select sources to include:
   - Select individual sources, OR
   - Select entire collection, OR
   - Use "Select All"
3. Choose citation style
4. Tap **"Generate"**

**Preview:**
- Review formatted bibliography
- Sources sorted alphabetically by author
- Proper formatting applied
- Hanging indents included

**Export Options:**
- **Copy to Clipboard**: Paste into any document
- **Share**: Send via email, messages, etc.
- **Export to BibTeX**: For LaTeX documents
- **Include Notes**: Add your notes after each citation

### BibTeX Export

**For LaTeX Users:**
1. Generate bibliography
2. Select "Export to BibTeX"
3. BibTeX file created with:
   - Unique citation keys
   - All metadata fields
   - Proper escaping
   - Ready to use

**BibTeX Example:**
```bibtex
@article{smith2023understanding,
  title = {Understanding Neural Networks},
  author = {John Smith},
  journal = {Journal of AI},
  volume = {45},
  number = {2},
  pages = {123--145},
  year = {2023},
  doi = {10.1234/jai.2023.001}
}
```

### Citation Tips

**For Best Results:**
- Fill in complete metadata when adding sources
- Include DOI for academic papers
- Add page numbers for book chapters
- Specify publication dates

**Common Issues:**
- Missing author: Shows "Unknown Author"
- Missing date: Shows "(n.d.)" for "no date"
- Missing title: Required field!

---

## Tips & Tricks

### Keyboard Shortcuts (visionOS)

- **Delete**: Remove selected source/connection
- **Escape**: Deselect all
- **C**: Copy citation of selected source
- **E**: Edit selected source
- **F**: Toggle favorite
- **A**: Add connection from selected source

### Spatial Gestures

**Pinch & Zoom:**
- Use natural pinch gestures
- Zoom into dense clusters
- Zoom out for overview

**Hand Tracking:**
- Point at nodes to highlight
- Grab gesture to drag
- Pinch to select

### Organization Best Practices

**Naming Conventions:**
- Use consistent tag naming
- Create tag hierarchy (e.g., "AI", "AI-NLP", "AI-Vision")
- Review and merge duplicate tags

**Project Structure:**
- One project per major research area
- Use collections for sub-topics
- Keep projects focused (< 200 sources recommended)

**Metadata Habits:**
- Add sources completely the first time
- Review and update periodically
- Use notes field liberally
- Tag immediately upon adding

### Performance Tips

**For Large Projects:**
- Use collections to focus on subsets
- Filter aggressively
- Manual layout for specific areas
- Consider splitting into multiple projects (200+ sources)

**Storage Management:**
- PDFs consume most space
- Check storage in device settings
- Delete unused projects
- Archive completed projects

### Workflow Examples

**Literature Review:**
1. Create project for review topic
2. Web scrape key papers
3. Add notes as you read
4. Create connections between papers
5. Organize into themed collections
6. Generate annotated bibliography

**Thesis/Dissertation:**
1. Create project for entire thesis
2. Create collections for each chapter
3. Add sources to relevant collections
4. Track which sources cited where (notes)
5. Generate chapter-specific bibliographies
6. Export final bibliography

**Reading Group:**
1. Create shared project concept
2. Add all group readings
3. Use notes for discussion points
4. Track connections between readings
5. Generate reading list to share

---

## Troubleshooting

### Common Issues

**Problem**: Sources not appearing in graph
- **Solution**: Check if filters are active
- **Solution**: Ensure sources belong to current project
- **Solution**: Try "Re-layout" button

**Problem**: Web scraping fails
- **Solution**: Check internet connection
- **Solution**: Try again (rate limiting may be active)
- **Solution**: Some sites block scrapers - use manual entry
- **Solution**: Check URL is accessible in browser

**Problem**: Graph is slow/laggy
- **Solution**: Too many sources visible - use filters
- **Solution**: Close other apps to free memory
- **Solution**: Restart app
- **Solution**: Consider splitting project

**Problem**: Can't find a source
- **Solution**: Clear all filters
- **Solution**: Check you're in the right project
- **Solution**: Use search instead of browsing
- **Solution**: Check if accidentally deleted

**Problem**: Citations formatting wrong
- **Solution**: Review source metadata
- **Solution**: Ensure authors in correct format
- **Solution**: Check date fields
- **Solution**: Add missing DOI/ISBN

### Getting Help

**In-App:**
- Tap "?" icon for context-sensitive help
- Check tutorial videos
- Review tooltips (hover over buttons)

**Online:**
- Documentation: [website]/docs
- Video tutorials: [website]/tutorials
- FAQ: [website]/faq
- GitHub Issues: Report bugs

**Contact:**
- Email: support@researchwebcrawler.com
- Twitter: @ResearchCrawler
- Community forum: [website]/community

### Data & Privacy

**Your Data:**
- All data stored locally on your device
- No cloud sync (yet)
- No telemetry or tracking
- You own all your data

**Backup:**
- Projects stored in app container
- iCloud backup includes app data
- Manual export coming soon

**Reset:**
- Delete app to remove all data
- Projects gone permanently
- Cannot recover deleted projects

---

## What's Next?

You're now ready to master Research Web Crawler!

**Explore Advanced Features:**
- Experiment with different graph layouts
- Create complex filter combinations
- Build comprehensive collections
- Master spatial navigation

**Stay Updated:**
- Check for app updates regularly
- Follow development blog
- Join the community
- Request features

**Share Your Experience:**
- Rate the app on App Store
- Share with colleagues
- Write a review
- Provide feedback

---

**Happy Researching! 🔬**

Research Web Crawler Team
Version 1.0 | December 2024
