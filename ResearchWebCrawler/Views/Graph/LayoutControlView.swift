//
//  LayoutControlView.swift
//  Research Web Crawler
//
//  UI controls for graph layout operations
//

import SwiftUI

struct LayoutControlView: View {
    @EnvironmentObject var graphManager: GraphManager
    @StateObject private var layoutManager: LayoutManager

    @State private var selectedPreset: LayoutPreset = .default
    @State private var selectedInitialLayout: InitialLayout = .spherical
    @State private var showingParameters: Bool = false
    @State private var animateLayout: Bool = true

    // Custom parameters
    @State private var optimalDistance: Float = 1.0
    @State private var attractionStrength: Float = 1.0
    @State private var centeringForce: Float = 0.01

    init(layoutManager: LayoutManager) {
        _layoutManager = StateObject(wrappedValue: layoutManager)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Graph Layout")
                    .font(.headline)

                Spacer()

                if layoutManager.isLayoutRunning {
                    ProgressView(value: layoutManager.layoutProgress)
                        .progressViewStyle(.linear)
                        .frame(width: 100)

                    Text("\(layoutManager.currentIteration)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Quick layouts
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Layouts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    QuickLayoutButton(
                        title: "Circular",
                        icon: "circle",
                        action: { layoutManager.applyCircularLayout() }
                    )

                    QuickLayoutButton(
                        title: "Grid",
                        icon: "square.grid.3x3",
                        action: { layoutManager.applyGridLayout() }
                    )

                    QuickLayoutButton(
                        title: "Sphere",
                        icon: "sphere",
                        action: { layoutManager.applySphericalLayout() }
                    )

                    QuickLayoutButton(
                        title: "Random",
                        icon: "shuffle",
                        action: { layoutManager.randomizeLayout() }
                    )
                }
            }

            Divider()

            // Force-directed layout
            VStack(alignment: .leading, spacing: 12) {
                Text("Force-Directed Layout")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Preset selection
                Picker("Preset", selection: $selectedPreset) {
                    Text("Default").tag(LayoutPreset.default)
                    Text("Tight").tag(LayoutPreset.tight)
                    Text("Loose").tag(LayoutPreset.loose)
                    Text("Fast").tag(LayoutPreset.fast)
                    Text("Slow").tag(LayoutPreset.slow)
                }
                .pickerStyle(.segmented)

                // Initial layout
                Picker("Initial Layout", selection: $selectedInitialLayout) {
                    Text("Spherical").tag(InitialLayout.spherical)
                    Text("Circular").tag(InitialLayout.circular)
                    Text("Grid").tag(InitialLayout.grid)
                    Text("Random").tag(InitialLayout.random)
                    Text("Current").tag(InitialLayout.current)
                }

                // Animate toggle
                Toggle("Animate Layout", isOn: $animateLayout)

                // Apply button
                Button(action: applyForceDirectedLayout) {
                    if layoutManager.isLayoutRunning {
                        Label("Running...", systemImage: "stop.circle")
                    } else {
                        Label("Apply Layout", systemImage: "play.circle")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(graphManager.sources.isEmpty || layoutManager.isLayoutRunning)

                // Parameters button
                Button(action: { showingParameters.toggle() }) {
                    Label("Advanced Parameters", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Layout stats
            LayoutStatsView(layoutManager: layoutManager)
        }
        .padding()
        .frame(maxWidth: 400)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $showingParameters) {
            LayoutParametersSheet(
                optimalDistance: $optimalDistance,
                attractionStrength: $attractionStrength,
                centeringForce: $centeringForce,
                layoutManager: layoutManager
            )
        }
    }

    // MARK: - Actions

    private func applyForceDirectedLayout() {
        Task {
            await layoutManager.applyForceDirectedLayout(
                preset: selectedPreset,
                initialLayout: selectedInitialLayout,
                animated: animateLayout
            )
        }
    }

    // MARK: - Enums

    enum LayoutPreset: String, CaseIterable {
        case `default` = "Default"
        case tight = "Tight"
        case loose = "Loose"
        case fast = "Fast"
        case slow = "Slow"

        var managerPreset: LayoutManager.LayoutPreset {
            switch self {
            case .default: return .default
            case .tight: return .tight
            case .loose: return .loose
            case .fast: return .fast
            case .slow: return .slow
            }
        }
    }

    enum InitialLayout: String, CaseIterable {
        case spherical = "Spherical"
        case circular = "Circular"
        case grid = "Grid"
        case random = "Random"
        case current = "Current"

        var managerLayout: LayoutManager.InitialLayout {
            switch self {
            case .spherical: return .spherical
            case .circular: return .circular
            case .grid: return .grid
            case .random: return .random
            case .current: return .current
            }
        }
    }
}

// MARK: - Quick Layout Button

struct QuickLayoutButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Layout Stats View

struct LayoutStatsView: View {
    @ObservedObject var layoutManager: LayoutManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Layout Statistics")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            let stats = layoutManager.getLayoutStats()

            HStack {
                StatItem(label: "Nodes", value: "\(stats.nodeCount)")
                Spacer()
                StatItem(label: "Edges", value: "\(stats.edgeCount)")
            }

            HStack {
                StatItem(
                    label: "Avg Edge Length",
                    value: String(format: "%.2f", stats.averageEdgeLength)
                )
                Spacer()
                StatItem(
                    label: "Bounding Box",
                    value: String(format: "%.2f", stats.boundingBoxSize)
                )
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Parameters Sheet

struct LayoutParametersSheet: View {
    @Binding var optimalDistance: Float
    @Binding var attractionStrength: Float
    @Binding var centeringForce: Float

    @ObservedObject var layoutManager: LayoutManager

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Force Parameters") {
                    VStack(alignment: .leading) {
                        Text("Optimal Distance: \(String(format: "%.2f", optimalDistance))")
                        Slider(value: $optimalDistance, in: 0.5...3.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Attraction Strength: \(String(format: "%.2f", attractionStrength))")
                        Slider(value: $attractionStrength, in: 0.1...2.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Centering Force: \(String(format: "%.3f", centeringForce))")
                        Slider(value: $centeringForce, in: 0.0...0.1, step: 0.001)
                    }
                }

                Section {
                    Button("Apply Custom Parameters") {
                        applyCustomParameters()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Layout Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func applyCustomParameters() {
        let customParams = ForceDirectedLayout.LayoutParameters(
            optimalDistance: optimalDistance,
            attractionStrength: attractionStrength,
            centeringForce: centeringForce
        )

        Task {
            await layoutManager.applyForceDirectedLayout(
                preset: .custom(customParams),
                initialLayout: .current,
                animated: true
            )
        }
    }
}

#Preview {
    let graphManager = GraphManager(
        persistenceManager: PersistenceManager(
            modelContainer: try! ModelContainer(
                for: Schema([Project.self, Source.self, Collection.self]),
                configurations: []
            )
        )
    )

    let layoutManager = LayoutManager(graphManager: graphManager)

    return LayoutControlView(layoutManager: layoutManager)
        .environmentObject(graphManager)
}
