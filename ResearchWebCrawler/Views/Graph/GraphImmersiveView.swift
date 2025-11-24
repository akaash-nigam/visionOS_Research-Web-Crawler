//
//  GraphImmersiveView.swift
//  Research Web Crawler
//
//  Immersive 3D graph visualization view
//

import SwiftUI
import RealityKit

struct GraphImmersiveView: View {
    @EnvironmentObject var graphManager: GraphManager
    @StateObject private var graphScene = GraphScene()
    @StateObject private var cameraController = CameraController()

    @State private var selectedNodeId: UUID?
    @State private var lastUpdateTime: Date?

    var body: some View {
        RealityView { content in
            // Add root entity to scene
            content.add(graphScene.rootEntity)

            // Connect camera controller to root entity
            cameraController.rootEntity = graphScene.rootEntity

            // Initial camera position
            cameraController.resetCamera()

            // Render initial graph
            renderGraph()

            print("✅ RealityKit 3D Graph Scene initialized")
        } update: { content in
            // Update scene when graph changes
            renderGraph()
        }
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    cameraController.handlePinchGesture(value.magnification)
                }
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Two-finger drag = pan, one-finger = rotate
                    // For now, treat all drags as rotate
                    cameraController.handleDragGesture(
                        value.translation,
                        type: .rotate
                    )
                }
        )
        .task {
            // Camera update loop
            await runUpdateLoop()
        }
        .onChange(of: graphManager.graph) { oldValue, newValue in
            // Re-render when graph changes
            renderGraph()
        }
    }

    // MARK: - Rendering

    private func renderGraph() {
        guard graphManager.sources.count > 0 else {
            print("⚠️ No sources to render")
            return
        }

        graphScene.renderGraph(graphManager.graph, sources: graphManager.sources)
    }

    // MARK: - Update Loop

    private func runUpdateLoop() async {
        while !Task.isCancelled {
            let currentTime = Date()

            if let lastTime = lastUpdateTime {
                let deltaTime = Float(currentTime.timeIntervalSince(lastTime))
                cameraController.update(deltaTime: deltaTime)
            }

            lastUpdateTime = currentTime

            // Target 60 FPS
            try? await Task.sleep(nanoseconds: 16_666_666) // ~60 FPS
        }
    }

    // MARK: - Interaction

    private func handleNodeTap(_ nodeId: UUID) {
        // Deselect previous node
        if let previousId = selectedNodeId {
            graphScene.graphRenderer?.deselectNode(previousId)
        }

        // Select new node
        selectedNodeId = nodeId
        graphScene.graphRenderer?.selectNode(nodeId)

        // Focus camera on node
        if let node = graphManager.graph.nodes[nodeId] {
            cameraController.focusOn(position: node.position, distance: 1.5)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    GraphImmersiveView()
        .environmentObject(GraphManager(
            persistenceManager: PersistenceManager(
                modelContainer: try! ModelContainer(
                    for: Schema([Project.self, Source.self, Collection.self]),
                    configurations: []
                )
            )
        ))
}
