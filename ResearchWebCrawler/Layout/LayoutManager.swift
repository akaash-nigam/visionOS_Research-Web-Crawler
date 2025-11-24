//
//  LayoutManager.swift
//  Research Web Crawler
//
//  Manages graph layout operations and animations
//

import Foundation
import Observation

@MainActor
@Observable
final class LayoutManager {
    // MARK: - Properties

    /// Reference to graph manager
    weak var graphManager: GraphManager?

    /// Reference to graph scene for visual updates
    weak var graphScene: GraphScene?

    /// Force-directed layout engine
    private var forceLayout: ForceDirectedLayout?

    /// Layout status
    private(set) var isLayoutRunning: Bool = false
    private(set) var layoutProgress: Float = 0.0
    private(set) var currentIteration: Int = 0

    /// Layout parameters
    var parameters: ForceDirectedLayout.LayoutParameters = .default {
        didSet {
            if let forceLayout = forceLayout {
                forceLayout.parameters = parameters
            }
        }
    }

    // MARK: - Initialization

    init(graphManager: GraphManager? = nil, graphScene: GraphScene? = nil) {
        self.graphManager = graphManager
        self.graphScene = graphScene
    }

    // MARK: - Layout Operations

    /// Apply force-directed layout to current graph
    func applyForceDirectedLayout(
        preset: LayoutPreset = .default,
        initialLayout: InitialLayout = .spherical,
        animated: Bool = true
    ) async {
        guard let graphManager = graphManager else {
            print("⚠️ GraphManager not set")
            return
        }

        guard graphManager.graph.nodes.count > 0 else {
            print("⚠️ No nodes to layout")
            return
        }

        isLayoutRunning = true
        layoutProgress = 0.0
        currentIteration = 0

        // Create force layout with current graph
        let forceLayout = ForceDirectedLayout(
            graph: graphManager.graph,
            parameters: preset.parameters
        )
        self.forceLayout = forceLayout

        // Initialize starting positions
        switch initialLayout {
        case .spherical:
            forceLayout.initializeSphericalLayout()
        case .circular:
            forceLayout.initializeCircularLayout()
        case .grid:
            forceLayout.initializeGridLayout()
        case .random:
            forceLayout.initializeRandomLayout()
        case .current:
            break // Keep current positions
        }

        // Run layout algorithm
        await forceLayout.runUntilConvergence(
            maxIterations: preset.maxIterations,
            convergenceThreshold: preset.convergenceThreshold
        ) { [weak self] iteration, energy in
            guard let self = self else { return }
            self.currentIteration = iteration
            self.layoutProgress = Float(iteration) / Float(preset.maxIterations)

            // Update visual representation periodically
            if animated && iteration % 5 == 0 {
                self.updateVisualization()
            }
        }

        // Apply final positions to graph
        graphManager.graph = forceLayout.graph

        // Final visual update
        updateVisualization()

        isLayoutRunning = false
        layoutProgress = 1.0

        print("✅ Layout complete: \(currentIteration) iterations")
    }

    /// Run a single layout iteration (for manual stepping)
    func stepLayout() {
        guard let forceLayout = forceLayout else { return }

        forceLayout.step()
        currentIteration = forceLayout.currentIteration

        // Apply to graph
        graphManager?.graph = forceLayout.graph

        // Update visualization
        updateVisualization()
    }

    /// Stop layout if running
    func stopLayout() {
        isLayoutRunning = false
        forceLayout?.isRunning = false
    }

    /// Reset layout algorithm
    func resetLayout() {
        forceLayout?.reset()
        currentIteration = 0
        layoutProgress = 0.0
    }

    // MARK: - Visualization Updates

    private func updateVisualization() {
        guard let graphScene = graphScene,
              let graphManager = graphManager else { return }

        // Update node positions in scene
        for (nodeId, graphNode) in graphManager.graph.nodes {
            graphScene.updateNodePosition(nodeId, position: graphNode.position)
        }
    }

    // MARK: - Quick Layouts

    /// Apply a simple circular layout
    func applyCircularLayout() {
        guard let graphManager = graphManager else { return }

        let forceLayout = ForceDirectedLayout(graph: graphManager.graph)
        forceLayout.initializeCircularLayout(radius: 1.5)

        graphManager.graph = forceLayout.graph
        updateVisualization()
    }

    /// Apply a simple grid layout
    func applyGridLayout() {
        guard let graphManager = graphManager else { return }

        let forceLayout = ForceDirectedLayout(graph: graphManager.graph)
        forceLayout.initializeGridLayout(spacing: 0.4)

        graphManager.graph = forceLayout.graph
        updateVisualization()
    }

    /// Apply a spherical layout
    func applySphericalLayout() {
        guard let graphManager = graphManager else { return }

        let forceLayout = ForceDirectedLayout(graph: graphManager.graph)
        forceLayout.initializeSphericalLayout(radius: 1.8)

        graphManager.graph = forceLayout.graph
        updateVisualization()
    }

    /// Randomize node positions
    func randomizeLayout() {
        guard let graphManager = graphManager else { return }

        let forceLayout = ForceDirectedLayout(graph: graphManager.graph)
        forceLayout.initializeRandomLayout(radius: 2.0)

        graphManager.graph = forceLayout.graph
        updateVisualization()
    }

    // MARK: - Layout Presets

    enum LayoutPreset {
        case `default`
        case tight
        case loose
        case fast
        case slow
        case custom(ForceDirectedLayout.LayoutParameters)

        var parameters: ForceDirectedLayout.LayoutParameters {
            switch self {
            case .default:
                return .default
            case .tight:
                return .tight
            case .loose:
                return .loose
            case .fast:
                return .fast
            case .slow:
                return ForceDirectedLayout.LayoutParameters(
                    cooling: 0.98,
                    damping: 0.9
                )
            case .custom(let params):
                return params
            }
        }

        var maxIterations: Int {
            switch self {
            case .fast:
                return 200
            case .slow:
                return 800
            default:
                return 500
            }
        }

        var convergenceThreshold: Float {
            switch self {
            case .fast:
                return 0.05
            case .slow:
                return 0.005
            default:
                return 0.01
            }
        }
    }

    enum InitialLayout {
        case spherical
        case circular
        case grid
        case random
        case current
    }
}

// MARK: - Layout Info

extension LayoutManager {
    /// Get current layout statistics
    func getLayoutStats() -> LayoutStats {
        guard let graphManager = graphManager else {
            return LayoutStats(
                nodeCount: 0,
                edgeCount: 0,
                averageEdgeLength: 0,
                boundingBoxSize: 0
            )
        }

        let graph = graphManager.graph

        // Calculate average edge length
        var totalLength: Float = 0
        for edge in graph.edges.values {
            guard let node1 = graph.nodes[edge.fromSourceId],
                  let node2 = graph.nodes[edge.toSourceId] else { continue }

            let distance = length(node2.position - node1.position)
            totalLength += distance
        }

        let averageEdgeLength = graph.edges.count > 0 ? totalLength / Float(graph.edges.count) : 0

        // Calculate bounding box
        var minPos = SIMD3<Float>(repeating: .infinity)
        var maxPos = SIMD3<Float>(repeating: -.infinity)

        for node in graph.nodes.values {
            minPos = simd_min(minPos, node.position)
            maxPos = simd_max(maxPos, node.position)
        }

        let boundingBoxSize = length(maxPos - minPos)

        return LayoutStats(
            nodeCount: graph.nodes.count,
            edgeCount: graph.edges.count,
            averageEdgeLength: averageEdgeLength,
            boundingBoxSize: boundingBoxSize
        )
    }

    struct LayoutStats {
        let nodeCount: Int
        let edgeCount: Int
        let averageEdgeLength: Float
        let boundingBoxSize: Float
    }
}
