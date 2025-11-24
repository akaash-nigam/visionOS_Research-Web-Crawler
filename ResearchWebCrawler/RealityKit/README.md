# RealityKit 3D Graph Visualization

This directory contains the RealityKit-based 3D visualization system for rendering research graphs in immersive space.

## Architecture

### Component Overview

```
GraphImmersiveView (SwiftUI)
    ├── GraphScene (RealityKit Scene Manager)
    │   ├── Root Entity
    │   ├── Environment Layer (Lighting)
    │   ├── Edges Layer (Connection lines)
    │   ├── Nodes Layer (Source spheres)
    │   └── Labels Layer (Text labels)
    ├── GraphRenderer (Rendering Engine)
    │   ├── NodeEntity Management
    │   └── EdgeEntity Management
    └── CameraController (Interaction)
        ├── Pan
        ├── Zoom
        └── Rotate
```

## Core Components

### GraphScene.swift

Main RealityKit scene manager that owns the entity hierarchy.

**Key Features:**
- Layered entity structure for proper depth ordering
- Lighting setup (ambient + directional)
- Graph rendering coordination
- Node highlighting and selection

**Usage:**
```swift
let scene = GraphScene()
scene.renderGraph(graph, sources: sources)
scene.highlightNode(nodeId)
```

### NodeEntity.swift

3D sphere entities representing source nodes in the graph.

**Features:**
- Sphere mesh with customizable size and color
- Collision detection for tap interactions
- Visual states: normal, highlighted, selected
- Smooth appearance animations
- Pulse animation for selection feedback

**Color Coding:**
- Blue: Articles
- Purple: Academic Papers
- Brown: Books
- Orange: News
- Red: Videos
- etc.

### EdgeEntity.swift

Cylindrical line entities representing connections between nodes.

**Features:**
- Dynamic line rendering between two nodes
- Connection type color coding
- Bidirectional connection support
- Line thickness based on connection strength
- Auto-updates when nodes move

**Connection Type Colors:**
- Blue: Cites
- Green: Supports
- Red: Contradicts
- Gray: Related
- Purple: Derived From
- Orange: Mentions
- Teal: Builds On
- Pink: Critiques

### GraphRenderer.swift

Batch rendering engine that creates and manages node/edge entities.

**Responsibilities:**
- Create NodeEntity for each graph node
- Create EdgeEntity for each graph edge
- Update entities when graph changes
- Handle add/remove operations
- Manage highlighting and selection

**Performance:**
- Efficient O(1) lookups via dictionaries
- Batch rendering for initial graph
- Incremental updates for changes

### CameraController.swift

Manages camera movement and user interaction.

**Controls:**
- **Pinch Gesture**: Zoom in/out (0.5m - 10m range)
- **Drag Gesture**: Rotate camera around graph
- **Pan**: Move focal point in 3D space

**Features:**
- Smooth interpolation (15% smoothing factor)
- Spherical coordinate system
- Pitch constraints (-60° to +60°)
- Focus on specific nodes
- Camera state serialization

## Usage Examples

### Basic Rendering

```swift
import SwiftUI
import RealityKit

struct MyView: View {
    @EnvironmentObject var graphManager: GraphManager
    @StateObject private var graphScene = GraphScene()

    var body: some View {
        RealityView { content in
            content.add(graphScene.rootEntity)
            graphScene.renderGraph(
                graphManager.graph,
                sources: graphManager.sources
            )
        }
    }
}
```

### Adding Gestures

```swift
RealityView { content in
    // ... setup
}
.gesture(MagnifyGesture().onChanged { value in
    cameraController.handlePinchGesture(value.magnification)
})
.gesture(DragGesture().onChanged { value in
    cameraController.handleDragGesture(
        value.translation,
        type: .rotate
    )
})
```

### Camera Update Loop

```swift
.task {
    while !Task.isCancelled {
        let deltaTime = 1.0 / 60.0 // 60 FPS
        cameraController.update(deltaTime: Float(deltaTime))
        try? await Task.sleep(nanoseconds: 16_666_666)
    }
}
```

### Highlighting Nodes

```swift
// Highlight node and connected edges
graphRenderer.highlightNode(nodeId)

// Unhighlight
graphRenderer.unhighlightNode(nodeId)

// Unhighlight all
graphRenderer.unhighlightAll()
```

### Selecting Nodes

```swift
// Select with animation
graphRenderer.selectNode(nodeId)

// Focus camera on selected node
if let node = graph.nodes[nodeId] {
    cameraController.focusOn(
        position: node.position,
        distance: 1.5
    )
}

// Deselect
graphRenderer.deselectNode(nodeId)
```

## Performance Considerations

### Target Performance
- **100 nodes**: Solid 60 FPS
- **50 edges**: Smooth rendering
- **Camera updates**: 60 FPS

### Optimization Techniques
1. **Efficient Data Structures**: Dictionary lookups for O(1) access
2. **Batch Rendering**: Initial graph rendered in one pass
3. **Incremental Updates**: Only update changed entities
4. **LOD (Future)**: Reduce detail for distant nodes
5. **Culling (Future)**: Hide off-screen entities

### Memory Management
- Weak references between entities to prevent retain cycles
- Entity cleanup on scene clear
- Proper parent-child relationships

## Testing

### Test Data Generation

Use `GraphTestData` utility to generate sample graphs:

```swift
// Small graph (10 nodes) - basic testing
let (graph, sources) = GraphTestData.smallGraph()

// Medium graph (50 nodes) - interaction testing
let (graph, sources) = GraphTestData.mediumGraph()

// Large graph (100 nodes) - performance testing
let (graph, sources) = GraphTestData.largeGraph()

// Specialized patterns
let (graph, sources) = GraphTestData.starGraph(spokeCount: 20)
let (graph, sources) = GraphTestData.chainGraph(length: 15)
let (graph, sources) = GraphTestData.clusteredGraph(
    clusterCount: 5,
    nodesPerCluster: 10
)
```

### Running Tests

```bash
# Run all RealityKit tests
xcodebuild test -scheme ResearchWebCrawler -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run specific test class
xcodebuild test -scheme ResearchWebCrawler -only-testing:RealityKitTests
```

## Future Enhancements

### Planned Features (Epic 3+)
- Force-directed layout algorithm (Fruchterman-Reingold)
- Animated layout transitions
- Level of Detail (LOD) system
- Frustum culling
- Text labels for nodes
- Connection strength visualization
- Minimap for navigation
- VR hand tracking gestures

### Visual Effects
- Particle effects for node creation
- Glow effects for selection
- Trail effects for moving nodes
- Connection flow animations

## Troubleshooting

### Common Issues

**Issue**: Nodes not appearing
- Check that GraphScene.renderGraph() is called after sources are loaded
- Verify graph.nodes is not empty
- Check console for rendering errors

**Issue**: Poor performance
- Reduce node count below 100
- Check that update loop is running at 60 FPS
- Profile with Instruments for bottlenecks

**Issue**: Camera not responding
- Verify CameraController.rootEntity is set
- Check that gesture handlers are attached
- Ensure update loop is running

**Issue**: Edges not updating when nodes move
- Call graphRenderer.updateEdgesForNode(nodeId) after position changes
- Verify weak references to nodes are not nil

## Code Style

- All RealityKit classes marked `@MainActor`
- Entity hierarchy follows layer pattern (edges behind nodes)
- Position in meters (1.0 = 1 meter in real space)
- Colors use UIColor with alpha for transparency
- Animations use Entity.move() for smooth transitions

## References

- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos)
- [Spatial Computing Best Practices](https://developer.apple.com/documentation/visionos)
