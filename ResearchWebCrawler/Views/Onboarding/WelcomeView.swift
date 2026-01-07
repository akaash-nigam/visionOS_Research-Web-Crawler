//
//  WelcomeView.swift
//  Research Web Crawler
//
//  Epic 8: Onboarding & Tutorial
//  Welcome screen for first-time users
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showingTutorial = false

    private let features: [WelcomeFeature] = [
        WelcomeFeature(
            icon: "cube.transparent",
            title: "3D Knowledge Graphs",
            description: "Visualize your research in immersive 3D space. See connections and relationships like never before.",
            color: .blue
        ),
        WelcomeFeature(
            icon: "sparkles",
            title: "Smart Web Scraping",
            description: "Automatically extract metadata from papers, books, and articles. Save hours of manual data entry.",
            color: .purple
        ),
        WelcomeFeature(
            icon: "doc.richtext",
            title: "Perfect Citations",
            description: "Generate APA, MLA, Chicago citations instantly. Export bibliographies in multiple formats.",
            color: .green
        ),
        WelcomeFeature(
            icon: "link",
            title: "Track Relationships",
            description: "Connect sources and visualize how research builds upon previous work. Discover hidden patterns.",
            color: .orange
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 140, height: 140)

                        Image(systemName: "cube.transparent")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    Text("Research Web Crawler")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Transform Your Research with Spatial Computing")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                TabView(selection: $currentPage) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureCard(feature: feature)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 280)
                .padding(.horizontal, 40)

                VStack(spacing: 16) {
                    Button {
                        showingTutorial = true
                    } label: {
                        Text("Start Tutorial")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)

                    Button {
                        FirstRunManager.shared.markWelcomeComplete()
                        dismiss()
                    } label: {
                        Text("Skip for Now")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingTutorial) {
            TutorialView()
        }
    }
}

struct FeatureCard: View {
    let feature: WelcomeFeature

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: feature.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(feature.color)
            }

            VStack(spacing: 8) {
                Text(feature.title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(feature.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WelcomeFeature {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
