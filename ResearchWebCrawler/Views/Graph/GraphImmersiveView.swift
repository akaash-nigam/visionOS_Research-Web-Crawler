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

    var body: some View {
        RealityView { content in
            // RealityKit scene will be implemented in Epic 2
            // For now, just create a simple placeholder

            // Add ambient light
            let lightEntity = Entity()
            var light = PointLightComponent(
                color: .white,
                intensity: 1000,
                attenuationRadius: 10
            )
            lightEntity.components.set(light)
            lightEntity.position = [0, 2, 0]
            content.add(lightEntity)

            // Add placeholder sphere
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = [0, 1.5, -1]
            content.add(entity)

            print("✅ RealityKit scene initialized (placeholder)")
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
