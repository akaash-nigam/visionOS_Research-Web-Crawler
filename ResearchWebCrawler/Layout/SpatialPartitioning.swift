//
//  SpatialPartitioning.swift
//  Research Web Crawler
//
//  Spatial hash grid for optimizing force-directed layout
//

import Foundation
import simd

/// Spatial hash grid for fast neighbor queries
struct SpatialHashGrid {
    // MARK: - Properties

    /// Cell size for spatial hashing
    private let cellSize: Float

    /// Hash grid storage: cell key -> node IDs in that cell
    private var grid: [SIMD3<Int>: Set<UUID>] = [:]

    /// Node positions cache for quick access
    private var nodePositions: [UUID: SIMD3<Float>] = [:]

    // MARK: - Initialization

    init(cellSize: Float = 1.0) {
        self.cellSize = cellSize
    }

    // MARK: - Grid Operations

    /// Build grid from graph nodes
    mutating func build(from graph: Graph) {
        grid.removeAll()
        nodePositions.removeAll()

        for (nodeId, node) in graph.nodes {
            let cellKey = getCellKey(for: node.position)
            grid[cellKey, default: []].insert(nodeId)
            nodePositions[nodeId] = node.position
        }
    }

    /// Get nearby nodes within specified radius
    func getNearbyNodes(to position: SIMD3<Float>, radius: Float) -> [UUID] {
        var nearbyNodes: [UUID] = []

        // Calculate cell range to check
        let cellRadius = Int(ceil(radius / cellSize))
        let centerCell = getCellKey(for: position)

        // Check cells in range
        for dx in -cellRadius...cellRadius {
            for dy in -cellRadius...cellRadius {
                for dz in -cellRadius...cellRadius {
                    let cellKey = SIMD3<Int>(
                        centerCell.x + dx,
                        centerCell.y + dy,
                        centerCell.z + dz
                    )

                    if let nodes = grid[cellKey] {
                        for nodeId in nodes {
                            if let nodePos = nodePositions[nodeId] {
                                let distance = length(nodePos - position)
                                if distance <= radius {
                                    nearbyNodes.append(nodeId)
                                }
                            }
                        }
                    }
                }
            }
        }

        return nearbyNodes
    }

    /// Get all nodes in the same cell
    func getNodesInCell(containing position: SIMD3<Float>) -> Set<UUID> {
        let cellKey = getCellKey(for: position)
        return grid[cellKey] ?? []
    }

    /// Get cell key for position
    private func getCellKey(for position: SIMD3<Float>) -> SIMD3<Int> {
        return SIMD3<Int>(
            Int(floor(position.x / cellSize)),
            Int(floor(position.y / cellSize)),
            Int(floor(position.z / cellSize))
        )
    }

    /// Clear grid
    mutating func clear() {
        grid.removeAll()
        nodePositions.removeAll()
    }

    // MARK: - Statistics

    var cellCount: Int {
        return grid.count
    }

    var totalNodes: Int {
        return nodePositions.count
    }

    func getAverageNodesPerCell() -> Float {
        guard cellCount > 0 else { return 0 }
        return Float(totalNodes) / Float(cellCount)
    }
}

// MARK: - Optimized Force-Directed Layout

extension ForceDirectedLayout {
    /// Run force-directed layout with spatial partitioning optimization
    func runWithSpatialPartitioning(
        maxIterations: Int = 500,
        convergenceThreshold: Float = 0.01,
        progressCallback: ((Int, Float) -> Void)? = nil
    ) async {
        isRunning = true
        var previousEnergy: Float = .infinity
        var spatialGrid = SpatialHashGrid(cellSize: parameters.optimalDistance * 2.0)

        for iteration in 0..<maxIterations {
            // Rebuild spatial grid
            spatialGrid.build(from: graph)

            // Calculate forces using spatial optimization
            calculateRepulsiveForcesWithSpatialGrid(&spatialGrid)
            calculateAttractiveForces()
            applyForces()
            coolTemperature()

            currentIteration = iteration + 1

            // Calculate total kinetic energy
            let energy = calculateTotalEnergy()

            // Check convergence
            let energyChange = abs(energy - previousEnergy)
            if energyChange < convergenceThreshold {
                print("✅ Layout converged after \(iteration) iterations")
                print("   Grid stats: \(spatialGrid.cellCount) cells, avg \(String(format: "%.1f", spatialGrid.getAverageNodesPerCell())) nodes/cell")
                break
            }

            previousEnergy = energy

            // Report progress
            progressCallback?(iteration, energy)

            // Yield to avoid blocking
            if iteration % 10 == 0 {
                await Task.yield()
            }
        }

        isRunning = false
    }

    /// Calculate repulsive forces using spatial grid (O(n) average case)
    private func calculateRepulsiveForcesWithSpatialGrid(_ grid: inout SpatialHashGrid) {
        let k = parameters.optimalDistance
        let influenceRadius = k * 3.0 // Only consider nodes within 3x optimal distance

        for (nodeId, var node) in graph.nodes {
            // Get nearby nodes using spatial grid
            let nearbyNodeIds = grid.getNearbyNodes(to: node.position, radius: influenceRadius)

            // Calculate repulsion from nearby nodes only
            for otherNodeId in nearbyNodeIds {
                guard nodeId != otherNodeId,
                      let otherNode = graph.nodes[otherNodeId] else { continue }

                // Calculate distance vector
                let delta = otherNode.position - node.position
                let distance = length(delta)

                // Avoid division by zero
                guard distance > 0.001 else { continue }

                // Fruchterman-Reingold repulsive force: f_r(d) = k² / d
                let repulsiveForce = (k * k) / distance
                let direction = normalize(delta)

                // Apply force (repel)
                node.velocity -= direction * repulsiveForce
            }

            // Update node
            graph.nodes[nodeId] = node
        }
    }
}

// MARK: - Barnes-Hut Octree (Alternative optimization)

/// Octree node for Barnes-Hut algorithm
class OctreeNode {
    var bounds: AABB
    var centerOfMass: SIMD3<Float> = .zero
    var totalMass: Float = 0
    var nodeId: UUID?
    var children: [OctreeNode] = []
    var isLeaf: Bool = true

    init(bounds: AABB) {
        self.bounds = bounds
    }

    /// Insert a node into the octree
    func insert(nodeId: UUID, position: SIMD3<Float>, mass: Float = 1.0) {
        // Update center of mass
        let oldTotalMass = totalMass
        let newTotalMass = oldTotalMass + mass
        centerOfMass = (centerOfMass * oldTotalMass + position * mass) / newTotalMass
        totalMass = newTotalMass

        // If this is an empty leaf, store the node here
        if isLeaf && self.nodeId == nil {
            self.nodeId = nodeId
            return
        }

        // If this is a leaf with a node, subdivide
        if isLeaf && self.nodeId != nil {
            subdivide()
            isLeaf = false

            // Reinsert existing node
            if let existingNodeId = self.nodeId {
                insertIntoChild(nodeId: existingNodeId, position: centerOfMass)
            }
            self.nodeId = nil
        }

        // Insert into appropriate child
        insertIntoChild(nodeId: nodeId, position: position)
    }

    private func subdivide() {
        let center = bounds.center
        let halfSize = bounds.size / 2

        children = []

        for i in 0..<8 {
            let offset = SIMD3<Float>(
                (i & 1) == 0 ? -halfSize.x : halfSize.x,
                (i & 2) == 0 ? -halfSize.y : halfSize.y,
                (i & 4) == 0 ? -halfSize.z : halfSize.z
            ) / 2

            let childBounds = AABB(
                center: center + offset,
                size: halfSize
            )
            children.append(OctreeNode(bounds: childBounds))
        }
    }

    private func insertIntoChild(nodeId: UUID, position: SIMD3<Float>) {
        // Find which child contains this position
        let center = bounds.center
        let index = ((position.x > center.x) ? 1 : 0) |
                    ((position.y > center.y) ? 2 : 0) |
                    ((position.z > center.z) ? 4 : 0)

        if index < children.count {
            children[index].insert(nodeId: nodeId, position: position)
        }
    }

    /// Calculate force from this octree node
    func calculateForce(
        on position: SIMD3<Float>,
        theta: Float = 0.5,
        k: Float
    ) -> SIMD3<Float> {
        let delta = position - centerOfMass
        let distance = length(delta)

        guard distance > 0.001 else { return .zero }

        // Barnes-Hut criteria: if node is far enough, treat as single body
        let ratio = bounds.size.x / distance

        if isLeaf || ratio < theta {
            // Calculate repulsive force
            let force = (k * k * totalMass) / (distance * distance)
            return normalize(delta) * force
        } else {
            // Recurse into children
            var totalForce: SIMD3<Float> = .zero
            for child in children {
                totalForce += child.calculateForce(on: position, theta: theta, k: k)
            }
            return totalForce
        }
    }
}

/// Axis-Aligned Bounding Box
struct AABB {
    var center: SIMD3<Float>
    var size: SIMD3<Float>

    var min: SIMD3<Float> {
        return center - size / 2
    }

    var max: SIMD3<Float> {
        return center + size / 2
    }

    func contains(_ point: SIMD3<Float>) -> Bool {
        let min = self.min
        let max = self.max
        return point.x >= min.x && point.x <= max.x &&
               point.y >= min.y && point.y <= max.y &&
               point.z >= min.z && point.z <= max.z
    }
}

// MARK: - Barnes-Hut Force Calculation

extension ForceDirectedLayout {
    /// Build octree from current graph
    func buildOctree() -> OctreeNode {
        // Calculate bounding box
        var minPos = SIMD3<Float>(repeating: .infinity)
        var maxPos = SIMD3<Float>(repeating: -.infinity)

        for node in graph.nodes.values {
            minPos = simd_min(minPos, node.position)
            maxPos = simd_max(maxPos, node.position)
        }

        // Add padding
        let padding: Float = 1.0
        minPos -= SIMD3<Float>(repeating: padding)
        maxPos += SIMD3<Float>(repeating: padding)

        let center = (minPos + maxPos) / 2
        let size = maxPos - minPos

        // Create root octree node
        let root = OctreeNode(bounds: AABB(center: center, size: size))

        // Insert all nodes
        for (nodeId, node) in graph.nodes {
            root.insert(nodeId: nodeId, position: node.position)
        }

        return root
    }

    /// Calculate repulsive forces using Barnes-Hut algorithm
    func calculateRepulsiveForcesWithBarnesHut(
        octree: OctreeNode,
        theta: Float = 0.5
    ) {
        let k = parameters.optimalDistance

        for (nodeId, var node) in graph.nodes {
            // Calculate force from octree
            let force = octree.calculateForce(on: node.position, theta: theta, k: k)
            node.velocity += force

            graph.nodes[nodeId] = node
        }
    }
}
