# Graph Layout System

This directory contains the graph layout algorithms for automatically positioning nodes in 3D space.

## Architecture

```
LayoutManager
    ├── ForceDirectedLayout (Fruchterman-Reingold)
    │   ├── Repulsive forces (all pairs)
    │   ├── Attractive forces (edges)
    │   └── Simulated annealing
    ├── SpatialPartitioning
    │   ├── Spatial Hash Grid (O(n) average)
    │   └── Barnes-Hut Octree (O(n log n))
    └── Initial Layouts
        ├── Spherical
        ├── Circular
        ├── Grid
        └── Random
```

## Core Components

### ForceDirectedLayout.swift

Implements the Fruchterman-Reingold force-directed algorithm for automatic graph layout.

**Algorithm Overview:**
1. **Repulsive Forces**: All nodes repel each other like charged particles
   - Formula: `f_r(d) = k² / d` (where k = optimal distance)
2. **Attractive Forces**: Connected nodes attract along edges like springs
   - Formula: `f_a(d) = d² / k`
3. **Simulated Annealing**: Temperature-based damping prevents oscillation
4. **Convergence**: Iterates until energy change falls below threshold

**Features:**
- Configurable layout parameters
- Multiple initial layout presets
- Convergence detection
- Fixed node support
- Boundary constraints

**Usage:**
```swift
let layout = ForceDirectedLayout(
    graph: graph,
    parameters: .default
)

// Initialize positions
layout.initializeSphericalLayout()

// Run until convergence
await layout.runUntilConvergence(
    maxIterations: 500,
    convergenceThreshold: 0.01
)

// Apply result
graphManager.graph = layout.graph
```

### LayoutManager.swift

High-level manager that coordinates layout operations with the UI and graph visualization.

**Responsibilities:**
- Apply layout algorithms to current graph
- Update visual representation during layout
- Provide layout presets and quick layouts
- Track layout progress and statistics

**Quick Layouts:**
```swift
layoutManager.applyCircularLayout()  // Circular in XZ plane
layoutManager.applyGridLayout()      // 2D grid
layoutManager.applySphericalLayout() // 3D sphere (Fibonacci)
layoutManager.randomizeLayout()      // Random positions
```

**Force-Directed Layout:**
```swift
await layoutManager.applyForceDirectedLayout(
    preset: .default,      // or .tight, .loose, .fast, .slow
    initialLayout: .spherical,
    animated: true
)
```

### SpatialPartitioning.swift

Performance optimizations for force calculations on large graphs.

#### Spatial Hash Grid

Divides 3D space into uniform cells for fast neighbor queries.

**Complexity:**
- Build: O(n)
- Query: O(1) average case
- Memory: O(n)

**Usage:**
```swift
var spatialGrid = SpatialHashGrid(cellSize: 1.0)
spatialGrid.build(from: graph)

let nearbyNodes = spatialGrid.getNearbyNodes(
    to: position,
    radius: 2.0
)
```

#### Barnes-Hut Octree

Hierarchical space subdivision for approximate force calculations.

**Complexity:**
- Build: O(n log n)
- Force calculation: O(n log n)
- Memory: O(n)

**Usage:**
```swift
let octree = layout.buildOctree()

await layout.runWithSpatialPartitioning(
    maxIterations: 500,
    convergenceThreshold: 0.01
)
```

### LayoutControlView.swift

SwiftUI interface for layout operations with parameter controls.

**Features:**
- Quick layout buttons (Circular, Grid, Sphere, Random)
- Force-directed layout controls
- Preset selection (Default, Tight, Loose, Fast, Slow)
- Initial layout selection
- Animation toggle
- Advanced parameter editor
- Real-time progress tracking
- Layout statistics display

## Layout Parameters

### Default Parameters

```swift
LayoutParameters(
    optimalDistance: 1.0,        // Ideal node spacing
    initialTemperature: 10.0,    // Starting temperature
    minTemperature: 0.1,         // Minimum temperature
    cooling: 0.95,               // Cooling rate (5% per step)
    damping: 0.8,                // Movement damping
    attractionStrength: 1.0,     // Edge attraction multiplier
    centeringForce: 0.01,        // Pull towards origin
    useBounds: true,             // Constrain to bounding box
    boundSize: 5.0               // Bounding box size
)
```

### Preset Variations

**Tight** - Compact layout
- `optimalDistance: 0.5`
- `attractionStrength: 1.5`

**Loose** - Spread out layout
- `optimalDistance: 2.0`
- `attractionStrength: 0.7`

**Fast** - Quick convergence
- `initialTemperature: 5.0`
- `cooling: 0.9`
- `maxIterations: 200`

**Slow** - High quality
- `cooling: 0.98`
- `damping: 0.9`
- `maxIterations: 800`

## Initial Layouts

### Spherical Layout

Distributes nodes uniformly on a sphere using Fibonacci sphere algorithm.

**Properties:**
- Even distribution
- No clustering
- Good for disconnected graphs

**Formula:**
```
φ = π(3 - √5)  // Golden angle
y = 1 - (i / (n-1)) * 2
r = √(1 - y²)
θ = φ * i
```

### Circular Layout

Places nodes in a circle on the XZ plane.

**Properties:**
- All nodes at same distance from center
- Good for cycle graphs
- Easy to understand

### Grid Layout

Arranges nodes in a 2D grid pattern.

**Properties:**
- Regular spacing
- Grid size = √n × √n
- Good for dense graphs

### Random Layout

Places nodes at random positions within bounding box.

**Properties:**
- No structure
- Good starting point for force-directed
- Fast initialization

## Performance

### Complexity Analysis

| Algorithm | Time | Space | Notes |
|-----------|------|-------|-------|
| Basic Force-Directed | O(n² × i) | O(n) | i = iterations |
| With Spatial Hash | O(n × i) | O(n) | Average case |
| With Barnes-Hut | O(n log n × i) | O(n) | Worst case |

### Benchmark Results

**Small Graph (10 nodes, 15 edges)**
- Iterations to convergence: ~50
- Time: <0.1s
- Memory: <1MB

**Medium Graph (50 nodes, 100 edges)**
- Iterations to convergence: ~200
- Time: ~0.5s
- Memory: ~2MB

**Large Graph (100 nodes, 200 edges)**
- Iterations to convergence: ~400
- Time: ~2s (with spatial partitioning)
- Memory: ~5MB

### Optimization Tips

1. **Use Spatial Partitioning** for graphs >30 nodes
2. **Start with spherical layout** for better convergence
3. **Use Fast preset** for quick previews
4. **Adjust optimalDistance** based on graph density
5. **Enable bounds** to prevent nodes from drifting

## Usage Examples

### Basic Force-Directed Layout

```swift
let (graph, sources) = GraphTestData.mediumGraph()
let layout = ForceDirectedLayout(graph: graph)

// Initialize
layout.initializeSphericalLayout()

// Run
await layout.runUntilConvergence()

// Apply
graphManager.graph = layout.graph
```

### Custom Parameters

```swift
let customParams = ForceDirectedLayout.LayoutParameters(
    optimalDistance: 1.5,
    attractionStrength: 1.2,
    centeringForce: 0.02,
    cooling: 0.97
)

let layout = ForceDirectedLayout(
    graph: graph,
    parameters: customParams
)
```

### Animated Layout with Progress

```swift
let layoutManager = LayoutManager(
    graphManager: graphManager,
    graphScene: graphScene
)

await layoutManager.applyForceDirectedLayout(
    preset: .default,
    initialLayout: .spherical,
    animated: true
)
```

### Manual Stepping

```swift
let layout = ForceDirectedLayout(graph: graph)
layout.initializeCircularLayout()

for _ in 0..<100 {
    layout.step()
    updateVisualization(layout.graph)
}
```

### Spatial Optimization

```swift
let layout = ForceDirectedLayout(graph: graph)
layout.initializeSphericalLayout()

await layout.runWithSpatialPartitioning(
    maxIterations: 500,
    convergenceThreshold: 0.01
)
```

## Integration with UI

### Adding Layout Controls

```swift
struct GraphView: View {
    @EnvironmentObject var graphManager: GraphManager
    @State private var showLayoutControls = false

    var body: some View {
        VStack {
            // Graph visualization
            GraphImmersiveView()

            // Layout controls button
            Button("Layout") {
                showLayoutControls = true
            }
        }
        .sheet(isPresented: $showLayoutControls) {
            LayoutControlView(
                layoutManager: LayoutManager(
                    graphManager: graphManager
                )
            )
        }
    }
}
```

### Monitoring Progress

```swift
@Observable
class MyViewModel {
    let layoutManager: LayoutManager

    func applyLayout() async {
        await layoutManager.applyForceDirectedLayout(
            preset: .default,
            initialLayout: .spherical,
            animated: true
        )

        // Access progress
        print("Progress: \(layoutManager.layoutProgress)")
        print("Iteration: \(layoutManager.currentIteration)")
    }
}
```

## Algorithm Details

### Fruchterman-Reingold Algorithm

**Pseudocode:**
```
for iteration in 1..maxIterations:
    // Calculate repulsive forces
    for all node pairs (u, v):
        delta = position[v] - position[u]
        force = k² / |delta|
        disp[u] -= normalize(delta) * force
        disp[v] += normalize(delta) * force

    // Calculate attractive forces
    for all edges (u, v):
        delta = position[v] - position[u]
        force = |delta|² / k
        disp[u] += normalize(delta) * force
        disp[v] -= normalize(delta) * force

    // Limit displacement by temperature
    for all nodes v:
        position[v] += normalize(disp[v]) * min(|disp[v]|, temperature)
        position[v] = clamp(position[v], bounds)

    // Cool temperature
    temperature *= coolingFactor
```

### Simulated Annealing

Temperature decreases each iteration, limiting node displacement:

```
temperature[t+1] = temperature[t] * cooling
displacement = min(|velocity|, temperature)
```

This prevents oscillation and helps convergence.

### Convergence Detection

Layout stops when energy change is below threshold:

```
energy = Σ |velocity[i]| for all nodes
if |energy - previousEnergy| < threshold:
    converged = true
```

## Testing

### Unit Tests

Run layout tests:
```bash
xcodebuild test -scheme ResearchWebCrawler -only-testing:LayoutTests
```

### Test Coverage

- ForceDirectedLayout: 35+ tests
- SpatialPartitioning: 8+ tests
- LayoutManager: 10+ tests
- Performance benchmarks: 5+ tests

### Performance Testing

```swift
func testLargeGraphPerformance() {
    let (graph, _) = GraphTestData.largeGraph()

    measure {
        let layout = ForceDirectedLayout(graph: graph)
        layout.runIterations(50)
    }
}
```

## Future Enhancements

### Planned Features
- Multi-threading for force calculations
- GPU acceleration via Metal
- Energy-based stopping criteria
- Stress minimization metric
- Hierarchical layout for large graphs
- Constraint-based layout (align, distribute)
- Layout serialization/deserialization
- Undo/redo for layout changes

### Advanced Algorithms
- Kamada-Kawai (stress minimization)
- Linlog layout (cluster detection)
- Hierarchical layout (tree-like)
- Multi-level layout (coarsening)

## References

- Fruchterman, T. M. J., & Reingold, E. M. (1991). "Graph Drawing by Force-directed Placement"
- Barnes, J., & Hut, P. (1986). "A hierarchical O(N log N) force-calculation algorithm"
- Fibonacci Sphere: [blog post](https://extremelearning.com.au/how-to-evenly-distribute-points-on-a-sphere-more-effectively-than-the-canonical-fibonacci-lattice/)

## Troubleshooting

**Issue**: Layout not converging
- Increase `maxIterations`
- Decrease `convergenceThreshold`
- Try different initial layout
- Adjust `cooling` rate (slower = 0.98)

**Issue**: Nodes flying apart
- Decrease `optimalDistance`
- Increase `attractionStrength`
- Increase `centeringForce`
- Enable `useBounds`

**Issue**: Nodes clustering too much
- Increase `optimalDistance`
- Decrease `attractionStrength`
- Use `.loose` preset

**Issue**: Poor performance
- Use spatial partitioning
- Reduce `maxIterations`
- Use `.fast` preset
- Update visualization less frequently
