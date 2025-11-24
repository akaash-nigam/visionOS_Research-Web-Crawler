# 3D Rendering & Interaction Architecture

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

This document details the 3D rendering architecture using RealityKit, including scene structure, node rendering, graph layout algorithms, gesture interactions, and performance optimization strategies.

## RealityKit Scene Architecture

### Scene Hierarchy

```
ImmersiveSpace
└── RootEntity
    ├── GraphContainerEntity
    │   ├── NodesLayer
    │   │   ├── NodeEntity (Source 1)
    │   │   ├── NodeEntity (Source 2)
    │   │   └── ... (up to N nodes)
    │   ├── EdgesLayer
    │   │   ├── EdgeEntity (Connection 1)
    │   │   ├── EdgeEntity (Connection 2)
    │   │   └── ... (up to M edges)
    │   └── LabelsLayer
    │       ├── LabelEntity (Label 1)
    │       └── ... (labels for visible nodes)
    ├── UILayer (floating panels)
    │   ├── ToolbarEntity
    │   ├── SearchPanelEntity
    │   └── AIPanelEntity
    └── EnvironmentEntity (background, lighting)
```

### Entity Definitions

#### NodeEntity
```swift
final class NodeEntity: Entity, HasModel, HasCollision {
    // Identity
    var sourceId: UUID
    var sourceType: SourceType

    // Visual State
    var nodeSize: Float
    var nodeColor: UIColor
    var isSelected: Bool = false
    var isHighlighted: Bool = false

    // Layout
    var position: SIMD3<Float>
    var velocity: SIMD3<Float> = .zero // For force-directed layout
    var isFixed: Bool = false // User manually positioned

    // LOD (Level of Detail)
    var lodLevel: LODLevel = .high

    init(sourceId: UUID, type: SourceType, position: SIMD3<Float>) {
        self.sourceId = sourceId
        self.sourceType = type
        self.position = position
        self.nodeSize = 0.05 // Default 5cm sphere
        self.nodeColor = type.defaultColor
        super.init()

        setupGeometry()
        setupCollision()
    }

    func setupGeometry() {
        let mesh = MeshResource.generateSphere(radius: nodeSize)
        let material = SimpleMaterial(color: nodeColor, isMetallic: false)
        self.components[ModelComponent.self] = ModelComponent(
            mesh: mesh,
            materials: [material]
        )
    }

    func setupCollision() {
        let shape = ShapeResource.generateSphere(radius: nodeSize)
        self.components[CollisionComponent.self] = CollisionComponent(
            shapes: [shape],
            isStatic: false
        )
    }

    func updateLOD(distanceFromCamera: Float) {
        switch distanceFromCamera {
        case 0..<2.0:
            lodLevel = .high
        case 2.0..<5.0:
            lodLevel = .medium
        default:
            lodLevel = .low
        }
        applyLOD()
    }

    func applyLOD() {
        switch lodLevel {
        case .high:
            // Full detail geometry, show label
            components[ModelComponent.self]?.mesh =
                MeshResource.generateSphere(radius: nodeSize)
        case .medium:
            // Simplified geometry, smaller label
            components[ModelComponent.self]?.mesh =
                MeshResource.generateBox(size: [nodeSize*2, nodeSize*2, nodeSize*2])
        case .low:
            // Billboard or point, no label
            components[ModelComponent.self]?.mesh =
                MeshResource.generatePlane(width: nodeSize, depth: nodeSize)
        }
    }
}

enum LODLevel {
    case high    // < 2m from camera
    case medium  // 2-5m from camera
    case low     // > 5m from camera
}
```

#### EdgeEntity
```swift
final class EdgeEntity: Entity, HasModel {
    var connectionId: UUID
    var fromNodeId: UUID
    var toNodeId: UUID
    var connectionType: ConnectionType

    var lineColor: UIColor
    var lineWidth: Float = 0.005 // 5mm

    var fromPosition: SIMD3<Float>
    var toPosition: SIMD3<Float>

    init(connectionId: UUID, from: UUID, to: UUID, type: ConnectionType,
         fromPos: SIMD3<Float>, toPos: SIMD3<Float>) {
        self.connectionId = connectionId
        self.fromNodeId = from
        self.toNodeId = to
        self.connectionType = type
        self.fromPosition = fromPos
        self.toPosition = toPos
        self.lineColor = type.defaultColor
        super.init()

        createLine()
    }

    func createLine() {
        let line = createLineMesh(from: fromPosition, to: toPosition, width: lineWidth)
        let material = UnlitMaterial(color: lineColor)
        self.components[ModelComponent.self] = ModelComponent(
            mesh: line,
            materials: [material]
        )
    }

    func updatePositions(from: SIMD3<Float>, to: SIMD3<Float>) {
        self.fromPosition = from
        self.toPosition = to
        createLine()
    }

    private func createLineMesh(from: SIMD3<Float>, to: SIMD3<Float>,
                                width: Float) -> MeshResource {
        // Create cylindrical mesh between two points
        let direction = to - from
        let distance = length(direction)
        let midpoint = (from + to) / 2

        let cylinder = MeshResource.generateCylinder(
            height: distance,
            radius: width / 2
        )

        // Transform to connect from -> to
        // (Implementation details: rotation quaternion, translation)
        return cylinder
    }
}
```

#### LabelEntity
```swift
final class LabelEntity: Entity, HasModel {
    var text: String
    var attachedToNode: UUID
    var offset: SIMD3<Float> = [0, 0.08, 0] // 8cm above node

    init(text: String, nodeId: UUID, position: SIMD3<Float>) {
        self.text = text
        self.attachedToNode = nodeId
        super.init()

        createTextMesh(at: position + offset)
    }

    func createTextMesh(at position: SIMD3<Float>) {
        // Use TextMesh or billboard with text texture
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.02) // 2cm text
        )

        let material = SimpleMaterial(color: .white, isMetallic: false)
        self.components[ModelComponent.self] = ModelComponent(
            mesh: textMesh,
            materials: [material]
        )

        self.position = position
    }

    func updatePosition(_ position: SIMD3<Float>) {
        self.position = position + offset
    }

    func setBillboard(_ enabled: Bool) {
        // Make label always face camera
        if enabled {
            // Add billboard component
        }
    }
}
```

## Graph Layout Algorithms

### Force-Directed Layout (MVP)

**Algorithm**: Fruchterman-Reingold

```swift
final class ForceDirectedLayout {
    var nodes: [UUID: NodeEntity]
    var edges: [EdgeEntity]

    // Parameters
    var k: Float = 1.0          // Optimal distance between nodes
    var c_spring: Float = 0.1   // Spring stiffness
    var c_repel: Float = 0.5    // Repulsion strength
    var damping: Float = 0.9    // Velocity damping
    var maxIterations: Int = 100
    var convergenceThreshold: Float = 0.01

    var boundingBox: BoundingBox = BoundingBox(
        min: [-5, -5, -5],
        max: [5, 5, 5]
    )

    func compute() -> [UUID: SIMD3<Float>] {
        var positions: [UUID: SIMD3<Float>] = [:]
        var velocities: [UUID: SIMD3<Float>] = [:]

        // Initialize positions (random or from saved state)
        for (id, node) in nodes {
            positions[id] = node.position
            velocities[id] = .zero
        }

        for iteration in 0..<maxIterations {
            var forces: [UUID: SIMD3<Float>] = [:]

            // Initialize forces
            for id in nodes.keys {
                forces[id] = .zero
            }

            // Repulsive forces (all pairs)
            for (id1, pos1) in positions {
                guard !nodes[id1]!.isFixed else { continue }

                for (id2, pos2) in positions where id1 != id2 {
                    let delta = pos1 - pos2
                    let distance = length(delta)

                    if distance > 0 {
                        let repulsion = c_repel * (k * k) / distance
                        let direction = normalize(delta)
                        forces[id1]! += direction * repulsion
                    }
                }
            }

            // Attractive forces (connected nodes)
            for edge in edges {
                let pos1 = positions[edge.fromNodeId]!
                let pos2 = positions[edge.toNodeId]!
                let delta = pos2 - pos1
                let distance = length(delta)

                if distance > 0 {
                    let attraction = c_spring * (distance - k)
                    let direction = normalize(delta)

                    if !nodes[edge.fromNodeId]!.isFixed {
                        forces[edge.fromNodeId]! += direction * attraction
                    }
                    if !nodes[edge.toNodeId]!.isFixed {
                        forces[edge.toNodeId]! -= direction * attraction
                    }
                }
            }

            // Update velocities and positions
            var totalMovement: Float = 0
            for (id, force) in forces {
                guard !nodes[id]!.isFixed else { continue }

                velocities[id]! += force
                velocities[id]! *= damping

                let movement = velocities[id]!
                positions[id]! += movement

                // Apply bounding box
                positions[id]! = clamp(positions[id]!, boundingBox)

                totalMovement += length(movement)
            }

            // Check convergence
            let avgMovement = totalMovement / Float(nodes.count)
            if avgMovement < convergenceThreshold {
                print("Converged after \(iteration) iterations")
                break
            }
        }

        return positions
    }

    func computeAsync(completion: @escaping ([UUID: SIMD3<Float>]) -> Void) {
        Task.detached(priority: .userInitiated) {
            let positions = self.compute()
            await MainActor.run {
                completion(positions)
            }
        }
    }
}
```

### Future Layouts (Post-MVP)

#### Hierarchical Layout
```swift
// Tree-based layout (parent-child relationships)
// Uses Reingold-Tilford algorithm
```

#### Radial Layout
```swift
// Central node with concentric circles
// Nodes arranged by degree of separation
```

#### Timeline Layout
```swift
// Chronological arrangement on X-axis
// Y-axis for topics, Z-axis for importance
```

## Gesture & Interaction System

### Gesture Recognition

```swift
final class GraphInteractionManager {
    weak var graphContainer: Entity?
    var selectedNode: NodeEntity?
    var isDraggingConnection: Bool = false
    var connectionStartNode: NodeEntity?
    var temporaryLine: EdgeEntity?

    func setupGestures() {
        // Tap: Select node
        let tapGesture = SpatialTapGesture()
            .targetedToEntity(where: .has(NodeEntity.self))
            .onEnded { value in
                self.handleNodeTap(value.entity as! NodeEntity)
            }

        // Drag: Move node
        let dragGesture = DragGesture()
            .targetedToEntity(where: .has(NodeEntity.self))
            .onChanged { value in
                self.handleNodeDrag(value)
            }

        // Pinch-Drag: Create connection
        let pinchDragGesture = LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture())
            .targetedToEntity(where: .has(NodeEntity.self))
            .onChanged { value in
                self.handleConnectionDrag(value)
            }
            .onEnded { value in
                self.handleConnectionRelease(value)
            }

        // Two-finger: Pan/Zoom graph
        let panGesture = MagnifyGesture()
            .onChanged { value in
                self.handleGraphZoom(value.magnification)
            }

        graphContainer?.gestures = [
            tapGesture, dragGesture, pinchDragGesture, panGesture
        ]
    }

    func handleNodeTap(_ node: NodeEntity) {
        // Deselect previous
        selectedNode?.isSelected = false

        // Select new
        selectedNode = node
        node.isSelected = true

        // Update visual (outline, glow)
        updateNodeVisuals(node)

        // Notify UI to show details
        NotificationCenter.default.post(
            name: .nodeSelected,
            object: node.sourceId
        )
    }

    func handleNodeDrag(_ value: EntityTargetValue<DragGesture.Value>) {
        guard let node = value.entity as? NodeEntity else { return }

        // Convert 2D drag to 3D position
        let translation = value.translation3D
        node.position += translation
        node.isFixed = true // User positioning

        // Update connected edges
        updateConnectedEdges(for: node)
    }

    func handleConnectionDrag(_ value: SequenceGesture.Value) {
        switch value {
        case .first(let longPress) where longPress:
            // Long press detected, start connection
            if let node = getTargetNode(from: value) {
                isDraggingConnection = true
                connectionStartNode = node

                // Visual feedback
                node.isHighlighted = true

                // Create temporary line
                temporaryLine = EdgeEntity(
                    connectionId: UUID(),
                    from: node.sourceId,
                    to: UUID(),
                    type: .related,
                    fromPos: node.position,
                    toPos: node.position
                )
                graphContainer?.addChild(temporaryLine!)
            }

        case .second(_, let drag):
            // Update temporary line to follow hand
            if let startNode = connectionStartNode {
                let handPosition = getHandPosition(from: drag)
                temporaryLine?.updatePositions(
                    from: startNode.position,
                    to: handPosition
                )
            }

        default:
            break
        }
    }

    func handleConnectionRelease(_ value: SequenceGesture.Value) {
        guard isDraggingConnection,
              let startNode = connectionStartNode,
              let endNode = getTargetNode(atPosition: getReleasePosition(value)),
              startNode.sourceId != endNode.sourceId else {
            // Invalid connection, cleanup
            cleanupConnectionDrag()
            return
        }

        // Valid connection, show type selector
        showConnectionTypeSelector(from: startNode, to: endNode)

        cleanupConnectionDrag()
    }

    private func cleanupConnectionDrag() {
        isDraggingConnection = false
        connectionStartNode?.isHighlighted = false
        connectionStartNode = nil
        temporaryLine?.removeFromParent()
        temporaryLine = nil
    }

    private func updateConnectedEdges(for node: NodeEntity) {
        // Find all edges connected to this node
        // Update their positions
    }
}
```

### Camera Controls

```swift
final class GraphCameraController {
    var cameraEntity: Entity
    var targetPosition: SIMD3<Float> = .zero
    var targetDistance: Float = 5.0
    var currentDistance: Float = 5.0

    // Smooth camera movement
    var smoothSpeed: Float = 0.1

    func update(deltaTime: Float) {
        // Smooth interpolation
        currentDistance = lerp(
            currentDistance,
            targetDistance,
            smoothSpeed
        )

        // Update camera position
        cameraEntity.position = targetPosition + [0, 0, currentDistance]
        cameraEntity.look(at: targetPosition)
    }

    func zoomTo(distance: Float, animated: Bool = true) {
        if animated {
            targetDistance = distance
        } else {
            currentDistance = distance
            targetDistance = distance
        }
    }

    func focusOn(node: NodeEntity, animated: Bool = true) {
        targetPosition = node.position
        zoomTo(distance: 2.0, animated: animated)
    }

    func fitGraphInView(nodes: [NodeEntity]) {
        // Calculate bounding box
        let positions = nodes.map { $0.position }
        let bounds = calculateBounds(positions)

        // Calculate distance to fit all nodes
        let size = length(bounds.max - bounds.min)
        let fov: Float = 60.0 * .pi / 180.0
        let distance = size / tan(fov / 2)

        targetPosition = (bounds.min + bounds.max) / 2
        targetDistance = distance * 1.2 // Add 20% padding
    }
}
```

## Performance Optimization

### Level of Detail (LOD)

```swift
final class LODManager {
    var nodes: [NodeEntity]
    var cameraPosition: SIMD3<Float>

    func update() {
        for node in nodes {
            let distance = length(node.position - cameraPosition)
            node.updateLOD(distanceFromCamera: distance)
        }
    }

    // Visibility culling
    func cullInvisibleNodes(frustum: Frustum) {
        for node in nodes {
            let isVisible = frustum.contains(node.position)
            node.isEnabled = isVisible
        }
    }
}
```

### Instanced Rendering

```swift
// For nodes of the same type/size, use instanced rendering
final class InstancedNodeRenderer {
    var instances: [InstancedNode] = []

    struct InstancedNode {
        var transform: Transform
        var color: UIColor
    }

    func render(nodes: [NodeEntity]) {
        // Group by type
        let grouped = Dictionary(grouping: nodes) { $0.sourceType }

        for (type, typeNodes) in grouped {
            instances = typeNodes.map { node in
                InstancedNode(
                    transform: Transform(
                        translation: node.position,
                        rotation: .identity,
                        scale: [node.nodeSize, node.nodeSize, node.nodeSize]
                    ),
                    color: node.nodeColor
                )
            }

            // Render all instances in single draw call
            renderInstances(instances, geometry: type.mesh)
        }
    }
}
```

### Edge Rendering Optimization

```swift
// Only render visible edges
final class EdgeRenderer {
    var edges: [EdgeEntity]
    var visibleNodeIds: Set<UUID>

    func renderVisibleEdges() {
        for edge in edges {
            let fromVisible = visibleNodeIds.contains(edge.fromNodeId)
            let toVisible = visibleNodeIds.contains(edge.toNodeId)

            edge.isEnabled = fromVisible && toVisible
        }
    }

    // Simplified edge rendering for distant edges
    func simplifyDistantEdges(cameraPosition: SIMD3<Float>) {
        for edge in edges {
            let midpoint = (edge.fromPosition + edge.toPosition) / 2
            let distance = length(midpoint - cameraPosition)

            if distance > 5.0 {
                edge.lineWidth = 0.002 // Thinner
            } else {
                edge.lineWidth = 0.005 // Normal
            }
        }
    }
}
```

### Lazy Loading

```swift
final class LazyGraphLoader {
    var allNodes: [NodeEntity]
    var loadedNodes: Set<UUID> = []
    var loadRadius: Float = 10.0
    var cameraPosition: SIMD3<Float>

    func updateLoadedRegion() {
        for node in allNodes {
            let distance = length(node.position - cameraPosition)
            let shouldLoad = distance < loadRadius

            if shouldLoad && !loadedNodes.contains(node.sourceId) {
                loadNode(node)
                loadedNodes.insert(node.sourceId)
            } else if !shouldLoad && loadedNodes.contains(node.sourceId) {
                unloadNode(node)
                loadedNodes.remove(node.sourceId)
            }
        }
    }

    func loadNode(_ node: NodeEntity) {
        node.setupGeometry()
        node.isEnabled = true
    }

    func unloadNode(_ node: NodeEntity) {
        node.isEnabled = false
        // Release geometry resources
    }
}
```

## Visual Effects

### Node States

```swift
extension NodeEntity {
    enum VisualState {
        case normal
        case selected
        case highlighted
        case dimmed
        case hidden
    }

    func applyState(_ state: VisualState) {
        switch state {
        case .normal:
            components[ModelComponent.self]?.materials = [
                SimpleMaterial(color: nodeColor, isMetallic: false)
            ]

        case .selected:
            // Add outline/glow
            components[ModelComponent.self]?.materials = [
                SimpleMaterial(color: nodeColor, isMetallic: false),
                OutlineMaterial(color: .white, width: 0.01)
            ]

        case .highlighted:
            // Pulse animation
            let animation = AnimationResource.makePulse()
            playAnimation(animation)

        case .dimmed:
            // Reduce opacity
            var material = SimpleMaterial(color: nodeColor, isMetallic: false)
            material.baseColor.tint = material.baseColor.tint.withAlphaComponent(0.3)
            components[ModelComponent.self]?.materials = [material]

        case .hidden:
            isEnabled = false
        }
    }
}
```

### Animations

```swift
// Animate node appearance
func animateNodeAppearance(_ node: NodeEntity) {
    node.scale = [0.01, 0.01, 0.01]
    node.isEnabled = true

    let scaleAnimation = FromToByAnimation(
        from: [0.01, 0.01, 0.01],
        to: [1.0, 1.0, 1.0],
        duration: 0.3,
        timing: .easeOut,
        bindTarget: .scale
    )

    node.playAnimation(scaleAnimation)
}

// Animate layout transition
func animateLayoutTransition(from old: [UUID: SIMD3<Float>],
                              to new: [UUID: SIMD3<Float>],
                              duration: TimeInterval = 0.5) {
    for (id, newPos) in new {
        guard let node = nodes[id],
              let oldPos = old[id] else { continue }

        let animation = FromToByAnimation(
            from: oldPos,
            to: newPos,
            duration: duration,
            timing: .easeInOut,
            bindTarget: .transform
        )

        node.playAnimation(animation)
    }
}
```

## Performance Targets & Benchmarks

### Frame Rate
- **Target**: 60fps
- **Minimum**: 50fps
- **Conditions**: 100 nodes, 150 edges, force-directed layout

### Rendering Budget
- **Nodes**: < 8ms per frame
- **Edges**: < 4ms per frame
- **UI**: < 2ms per frame
- **Total**: < 16ms (60fps)

### Memory Budget
- **Geometry**: < 100MB for 1,000 nodes
- **Textures**: < 50MB
- **Total Graphics Memory**: < 200MB

### Optimization Strategies

| Technique | Savings | Complexity |
|-----------|---------|------------|
| LOD | 40-60% | Medium |
| Frustum Culling | 30-50% | Low |
| Instanced Rendering | 20-40% | Medium |
| Lazy Loading | 50-70% | High |
| Edge Simplification | 10-20% | Low |

## Testing & Profiling

### Performance Tests
```swift
func testRenderingPerformance() {
    let nodes = generateTestNodes(count: 100)
    let edges = generateTestEdges(count: 150)

    measure {
        renderGraph(nodes: nodes, edges: edges)
    }

    // Assert: < 16ms per frame
    XCTAssertLessThan(averageFrameTime, 16.0)
}

func testLayoutPerformance() {
    let layout = ForceDirectedLayout()
    layout.nodes = generateTestNodes(count: 100)
    layout.edges = generateTestEdges(count: 150)

    measure {
        _ = layout.compute()
    }

    // Assert: < 3 seconds
    XCTAssertLessThan(layoutTime, 3.0)
}
```

### Profiling Tools
- **Instruments**: Time Profiler, Allocations
- **RealityKit Debugger**: Draw call count, vertex count
- **FPS Counter**: Real-time frame rate monitoring

## Accessibility

### VoiceOver Support
- Each node has accessible label (title + type)
- Spatial audio cues for node selection
- Voice commands for navigation

### Vision Accessibility
- High contrast mode
- Larger nodes and labels
- Simplified visual mode (fewer effects)

## Next Steps

1. Implement basic RealityKit scene with test nodes
2. Build force-directed layout algorithm
3. Implement gesture recognition system
4. Add LOD and performance optimizations
5. Profile with 100 nodes and iterate

## References

- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [visionOS Spatial Computing](https://developer.apple.com/visionos/)
- [Force-Directed Graph Drawing](https://en.wikipedia.org/wiki/Force-directed_graph_drawing)
- [Fruchterman-Reingold Algorithm](https://github.com/d3/d3-force)
