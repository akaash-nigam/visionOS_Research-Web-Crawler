//
//  ContentView.swift
//  Research Web Crawler
//
//  Main content view that serves as the app's entry point
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Environment

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var graphManager: GraphManager

    // MARK: - State

    @State private var showingOnboarding = true
    @State private var isGraphSpaceOpen = false
    @State private var showingSettings = false
    @State private var showingAddSource = false

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack {
                if !hasCompletedOnboarding && showingOnboarding {
                    // Show onboarding for first-time users
                    WelcomeView(
                        onComplete: {
                            hasCompletedOnboarding = true
                            showingOnboarding = false
                        },
                        onSkip: {
                            hasCompletedOnboarding = true
                            showingOnboarding = false
                        }
                    )
                } else {
                    // Main app interface
                    mainContent
                }
            }
            .navigationTitle("Research Web Crawler")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSource = true
                    } label: {
                        Label("Add Source", systemImage: "plus.circle.fill")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddSource) {
                AddSourceView()
                    .environmentObject(graphManager)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Your Research Graph")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let project = graphManager.currentProject {
                    Text("\(project.sourceCount) sources • \(project.connectionCount) connections")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No project loaded")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)

            Spacer()

            // Main action button
            Button {
                Task {
                    await toggleGraphSpace()
                }
            } label: {
                Label(
                    isGraphSpaceOpen ? "Close 3D Graph" : "Open 3D Graph",
                    systemImage: isGraphSpaceOpen ? "cube.fill" : "cube"
                )
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            .disabled(graphManager.sources.isEmpty)

            if graphManager.sources.isEmpty {
                Text("Add sources to view your graph")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Source list
            SourceListPreview()
                .environmentObject(graphManager)
        }
        .padding()
    }

    // MARK: - Methods

    private func toggleGraphSpace() async {
        if isGraphSpaceOpen {
            await dismissImmersiveSpace()
            isGraphSpaceOpen = false
        } else {
            switch await openImmersiveSpace(id: "GraphSpace") {
            case .opened:
                isGraphSpaceOpen = true
            case .error:
                print("❌ Failed to open immersive space")
            case .userCancelled:
                print("⚠️ User cancelled opening immersive space")
            @unknown default:
                break
            }
        }
    }
}

// MARK: - Source List Preview

struct SourceListPreview: View {
    @EnvironmentObject var graphManager: GraphManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Sources")
                    .font(.headline)
                Spacer()
                NavigationLink("View All") {
                    SourceListView()
                }
                .font(.subheadline)
            }

            if graphManager.sources.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("No sources yet")
                        .font(.title3)
                        .fontWeight(.medium)

                    Text("Add your first source to start building your research graph")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(graphManager.sources.prefix(5)), id: \.id) { source in
                            SourceRowView(source: source)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Source Row View

struct SourceRowView: View {
    let source: Source

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: source.type.icon)
                .font(.title3)
                .foregroundStyle(source.type.color)
                .frame(width: 32)

            // Source info
            VStack(alignment: .leading, spacing: 4) {
                Text(source.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if !source.authors.isEmpty {
                    Text(source.authors.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Navigation arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(GraphManager(
            persistenceManager: PersistenceManager(
                modelContainer: try! ModelContainer(
                    for: Schema([Project.self, Source.self, Collection.self]),
                    configurations: []
                )
            )
        ))
}
