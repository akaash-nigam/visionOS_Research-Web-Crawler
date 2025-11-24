//
//  ForceDirectedLayout.swift
//  Research Web Crawler
//
//  Force-directed graph layout using Fruchterman-Reingold algorithm
//

import Foundation
import simd

@MainActor
final class ForceDirectedLayout {
    // MARK: - Properties

    /// Graph to layout
    var graph: Graph

    /// Layout parameters
    var parameters: LayoutParameters

    /// Current iteration count
    private(set) var currentIteration: Int = 0

    /// Temperature for simulated annealing
    private var temperature: Float

    /// Whether layout is currently running
    private(set) var isRunning: Bool = false

    // MARK: - Initialization

    init(graph: Graph, parameters: LayoutParameters = .default) {
        self.graph = graph
        self.parameters = parameters
        self.temperature = parameters.initialTemperature
    }

    // MARK: - Layout Algorithm

    /// Run one iteration of the force-directed algorithm
    func step() {
        guard !graph.nodes.isEmpty else { return }

        currentIteration += 1

        // Calculate repulsive forces between all pairs of nodes
        calculateRepulsiveForces()

        // Calculate attractive forces along edges
        calculateAttractiveForces()

        // Apply forces with temperature-based damping
        applyForces()

        // Cool temperature (simulated annealing)
        coolTemperature()
    }

    /// Run multiple iterations
    func runIterations(_ count: Int, completion: (() -> Void)? = nil) {
        isRunning = true

        for _ in 0..<count {
            step()
        }

        isRunning = false
        completion?()
    }

    /// Run layout until convergence or max iterations
    func runUntilConvergence(
        maxIterations: Int = 500,
        convergenceThreshold: Float = 0.01,
        progressCallback: ((Int, Float) -> Void)? = nil
    ) async {
        isRunning = true
        var previousEnergy: Float = .infinity

        for iteration in 0..<maxIterations {
            step()

            // Calculate total kinetic energy
            let energy = calculateTotalEnergy()

            // Check convergence
            let energyChange = abs(energy - previousEnergy)
            if energyChange < convergenceThreshold {
                print("✅ Layout converged after \(iteration) iterations")
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

    // MARK: - Force Calculations

    private func calculateRepulsiveForces() {
        let k = parameters.optimalDistance
        let nodeIds = Array(graph.nodes.keys)

        // Calculate repulsion between all pairs
        for i in 0..<nodeIds.count {
            for j in (i + 1)..<nodeIds.count {
                let nodeId1 = nodeIds[i]
                let nodeId2 = nodeIds[j]

                guard var node1 = graph.nodes[nodeId1],
                      var node2 = graph.nodes[nodeId2] else { continue }

                // Calculate distance vector
                let delta = node2.position - node1.position
                let distance = length(delta)

                // Avoid division by zero
                guard distance > 0.001 else { continue }

                // Fruchterman-Reingold repulsive force: f_r(d) = k² / d
                let repulsiveForce = (k * k) / distance
                let direction = normalize(delta)

                // Apply force (repel each other)
                node1.velocity -= direction * repulsiveForce
                node2.velocity += direction * repulsiveForce

                // Update nodes
                graph.nodes[nodeId1] = node1
                graph.nodes[nodeId2] = node2
            }
        }
    }

    private func calculateAttractiveForces() {
        let k = parameters.optimalDistance

        // Calculate attraction along edges
        for edge in graph.edges.values {
            guard var node1 = graph.nodes[edge.fromSourceId],
                  var node2 = graph.nodes[edge.toSourceId] else { continue }

            // Calculate distance vector
            let delta = node2.position - node1.position
            let distance = length(delta)

            // Avoid division by zero
            guard distance > 0.001 else { continue }

            // Fruchterman-Reingold attractive force: f_a(d) = d² / k
            let attractiveForce = (distance * distance) / k
            let direction = normalize(delta)

            // Apply force (attract each other)
            node1.velocity += direction * attractiveForce * parameters.attractionStrength
            node2.velocity -= direction * attractiveForce * parameters.attractionStrength

            // Update nodes
            graph.nodes[edge.fromSourceId] = node1
            graph.nodes[edge.toSourceId] = node2
        }
    }

    private func applyForces() {
        for (nodeId, var node) in graph.nodes {
            // Skip fixed nodes
            guard !node.isFixed else { continue }

            // Limit displacement by temperature
            let displacement = node.velocity
            let displacementLength = length(displacement)

            guard displacementLength > 0.001 else {
                node.velocity = .zero
                graph.nodes[nodeId] = node
                continue
            }

            // Limit by temperature (simulated annealing)
            let limitedLength = min(displacementLength, temperature)
            let limitedDisplacement = normalize(displacement) * limitedLength

            // Update position
            node.position += limitedDisplacement * parameters.damping

            // Apply bounds if enabled
            if parameters.useBounds {
                node.position.x = clamp(node.position.x, min: -parameters.boundSize, max: parameters.boundSize)
                node.position.y = clamp(node.position.y, min: -parameters.boundSize, max: parameters.boundSize)
                node.position.z = clamp(node.position.z, min: -parameters.boundSize, max: parameters.boundSize)
            }

            // Apply gravity towards center
            if parameters.centeringForce > 0 {
                let centeringDisplacement = -node.position * parameters.centeringForce
                node.position += centeringDisplacement
            }

            // Reset velocity for next iteration
            node.velocity = .zero

            // Update graph
            graph.nodes[nodeId] = node
        }
    }

    private func coolTemperature() {
        // Linear cooling schedule
        temperature *= parameters.cooling

        // Don't go below minimum
        temperature = max(temperature, parameters.minTemperature)
    }

    // MARK: - Energy Calculation

    private func calculateTotalEnergy() -> Float {
        var totalEnergy: Float = 0

        for node in graph.nodes.values {
            totalEnergy += length(node.velocity)
        }

        return totalEnergy
    }

    // MARK: - Reset

    func reset() {
        currentIteration = 0
        temperature = parameters.initialTemperature

        // Reset velocities
        for (nodeId, var node) in graph.nodes {
            node.velocity = .zero
            graph.nodes[nodeId] = node
        }
    }

    // MARK: - Utilities

    private func clamp(_ value: Float, min: Float, max: Float) -> Float {
        return Swift.min(Swift.max(value, min), max)
    }

    // MARK: - Layout Parameters

    struct LayoutParameters {
        /// Optimal distance between nodes (k)
        var optimalDistance: Float = 1.0

        /// Initial temperature for simulated annealing
        var initialTemperature: Float = 10.0

        /// Minimum temperature
        var minTemperature: Float = 0.1

        /// Cooling rate per iteration (0.95 = 5% reduction per step)
        var cooling: Float = 0.95

        /// Damping factor to prevent oscillation
        var damping: Float = 0.8

        /// Strength of attractive forces (0.0 - 2.0)
        var attractionStrength: Float = 1.0

        /// Centering force to keep graph centered (0.0 - 0.1)
        var centeringForce: Float = 0.01

        /// Whether to constrain nodes within bounds
        var useBounds: Bool = true

        /// Size of bounding box
        var boundSize: Float = 5.0

        static let `default` = LayoutParameters()

        static let tight = LayoutParameters(
            optimalDistance: 0.5,
            attractionStrength: 1.5
        )

        static let loose = LayoutParameters(
            optimalDistance: 2.0,
            attractionStrength: 0.7
        )

        static let fast = LayoutParameters(
            initialTemperature: 5.0,
            cooling: 0.9
        )
    }
}

// MARK: - Layout Presets

extension ForceDirectedLayout {
    /// Apply a 3D spherical layout as starting point
    func initializeSphericalLayout(radius: Float = 1.5) {
        let nodeIds = Array(graph.nodes.keys)
        let count = nodeIds.count

        for (index, nodeId) in nodeIds.enumerated() {
            guard var node = graph.nodes[nodeId] else { continue }

            // Fibonacci sphere distribution
            let phi = Float.pi * (3.0 - sqrt(5.0)) // Golden angle

            let y = 1.0 - (Float(index) / Float(count - 1)) * 2.0 // y goes from 1 to -1
            let radiusAtY = sqrt(1.0 - y * y)

            let theta = phi * Float(index)

            let x = cos(theta) * radiusAtY
            let z = sin(theta) * radiusAtY

            node.position = SIMD3<Float>(x, y, z) * radius
            graph.nodes[nodeId] = node
        }
    }

    /// Apply a circular layout in XZ plane
    func initializeCircularLayout(radius: Float = 1.0) {
        let nodeIds = Array(graph.nodes.keys)
        let count = nodeIds.count

        for (index, nodeId) in nodeIds.enumerated() {
            guard var node = graph.nodes[nodeId] else { continue }

            let angle = Float(index) * (2.0 * .pi) / Float(count)
            node.position = SIMD3<Float>(
                cos(angle) * radius,
                0,
                sin(angle) * radius
            )

            graph.nodes[nodeId] = node
        }
    }

    /// Apply a grid layout
    func initializeGridLayout(spacing: Float = 0.3) {
        let nodeIds = Array(graph.nodes.keys)
        let count = nodeIds.count
        let sideLength = Int(ceil(sqrt(Float(count))))

        for (index, nodeId) in nodeIds.enumerated() {
            guard var node = graph.nodes[nodeId] else { continue }

            let row = index / sideLength
            let col = index % sideLength

            node.position = SIMD3<Float>(
                Float(col) * spacing - Float(sideLength) * spacing / 2,
                0,
                Float(row) * spacing - Float(sideLength) * spacing / 2
            )

            graph.nodes[nodeId] = node
        }
    }

    /// Apply random positions
    func initializeRandomLayout(radius: Float = 2.0) {
        for (nodeId, var node) in graph.nodes {
            node.position = SIMD3<Float>(
                Float.random(in: -radius...radius),
                Float.random(in: -radius...radius),
                Float.random(in: -radius...radius)
            )
            graph.nodes[nodeId] = node
        }
    }
}
