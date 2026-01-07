//
//  ResearchWebCrawlerApp.swift
//  Research Web Crawler
//
//  Created by Claude
//  Copyright © 2025 Research Web Crawler. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct ResearchWebCrawlerApp: App {
    // MARK: - Properties

    /// SwiftData model container for persistence
    var modelContainer: ModelContainer

    /// Shared persistence manager
    let persistenceManager: PersistenceManager

    /// Graph manager for handling graph operations
    let graphManager: GraphManager

    // MARK: - Initialization

    init() {
        // Initialize SwiftData model container
        do {
            let schema = Schema([
                Project.self,
                Source.self,
                Collection.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            persistenceManager = PersistenceManager(modelContainer: modelContainer)
            graphManager = GraphManager(persistenceManager: persistenceManager)

            print("✅ App initialized successfully")
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Scene

    var body: some Scene {
        // Main window group
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(graphManager)
                .environmentObject(persistenceManager)
        }

        // Immersive space for 3D graph visualization
        ImmersiveSpace(id: "GraphSpace") {
            GraphImmersiveView()
                .environmentObject(graphManager)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
