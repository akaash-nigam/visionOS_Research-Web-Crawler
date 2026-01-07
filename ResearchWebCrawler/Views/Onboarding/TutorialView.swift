//
//  TutorialView.swift
//  Research Web Crawler
//
//  Interactive tutorial for new users
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    private let steps: [TutorialStep] = [
        TutorialStep(
            title: "Create Your First Project",
            description: "Start by creating a project to organize your research. Think of projects as collections of related sources.",
            icon: "folder.badge.plus",
            color: .blue,
            actionTitle: "I'll try it!",
            demoView: AnyView(ProjectCreationDemo())
        ),
        TutorialStep(
            title: "Add Sources",
            description: "Add research sources by entering them manually, importing PDFs, or scraping URLs. We'll automatically extract metadata.",
            icon: "doc.badge.plus",
            color: .green,
            actionTitle: "Show me how",
            demoView: AnyView(SourceAdditionDemo())
        ),
        TutorialStep(
            title: "Visualize in 3D",
            description: "See your research come to life in 3D space. Each source becomes a node, and references become connections.",
            icon: "cube.transparent",
            color: .purple,
            actionTitle: "Explore",
            demoView: AnyView(GraphVisualizationDemo())
        ),
        TutorialStep(
            title: "Connect Sources",
            description: "Create relationships between sources by tapping to select and dragging to connect. Build your knowledge graph.",
            icon: "link.badge.plus",
            color: .orange,
            actionTitle: "Let's connect",
            demoView: AnyView(ConnectionCreationDemo())
        ),
        TutorialStep(
            title: "Generate Citations",
            description: "Need a bibliography? Select sources and generate perfect citations in APA, MLA, or Chicago format.",
            icon: "doc.richtext",
            color: .indigo,
            actionTitle: "Try it out",
            demoView: AnyView(CitationGenerationDemo())
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [steps[currentStep].color.opacity(0.2), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep ? steps[currentStep].color : Color.gray.opacity(0.3))
                            .frame(width: index == currentStep ? 40 : 20, height: 4)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)

                // Tutorial content
                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        TutorialStepView(step: step, isLast: index == steps.count - 1) {
                            if index < steps.count - 1 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                completeTutorial()
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation
                HStack {
                    if currentStep > 0 {
                        Button {
                            withAnimation {
                                currentStep -= 1
                            }
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    Button {
                        completeTutorial()
                    } label: {
                        Text("Skip Tutorial")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
                .padding(40)
            }
        }
    }

    private func completeTutorial() {
        FirstRunManager.shared.markTutorialComplete()
        dismiss()
    }
}

// MARK: - Tutorial Step View

struct TutorialStepView: View {
    let step: TutorialStep
    let isLast: Bool
    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer().frame(height: 20)

                // Icon
                ZStack {
                    Circle()
                        .fill(step.color.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: step.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(step.color)
                }

                // Title and description
                VStack(spacing: 12) {
                    Text(step.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(step.description)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Demo view
                step.demoView
                    .frame(height: 300)
                    .padding(.horizontal, 40)

                // Action button
                Button(action: onNext) {
                    Text(isLast ? "Get Started" : step.actionTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

// MARK: - Tutorial Step Model

struct TutorialStep {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let actionTitle: String
    let demoView: AnyView
}

// MARK: - Demo Views

struct ProjectCreationDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "folder.badge.plus")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)

                        Text("My Research Project")
                            .font(.headline)

                        Text("Tap '+' to create a new project")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
        }
    }
}

struct SourceAdditionDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                DemoCard(icon: "pencil", title: "Manual", color: .blue)
                DemoCard(icon: "link", title: "URL", color: .green)
                DemoCard(icon: "doc", title: "PDF", color: .orange)
            }
        }
    }
}

struct GraphVisualizationDemo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)

            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(.green)
                        .frame(width: 40, height: 40)
                }

                HStack(spacing: 20) {
                    Circle()
                        .fill(.purple)
                        .frame(width: 40, height: 40)
                    Circle()
                        .fill(.orange)
                        .frame(width: 40, height: 40)
                }

                Text("Your sources in 3D space")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ConnectionCreationDemo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)

            HStack(spacing: 40) {
                Circle()
                    .fill(.blue)
                    .frame(width: 50, height: 50)

                Image(systemName: "arrow.right")
                    .font(.title)
                    .foregroundStyle(.secondary)

                Circle()
                    .fill(.green)
                    .frame(width: 50, height: 50)
            }

            VStack {
                Spacer()
                Text("Drag from one node to another")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}

struct CitationGenerationDemo: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay {
                VStack(alignment: .leading, spacing: 12) {
                    Text("APA Style:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Smith, J. (2023). Understanding Swift...")
                        .font(.footnote)
                        .lineLimit(2)

                    Divider()

                    Button {} label: {
                        Label("Generate Bibliography", systemImage: "doc.richtext")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(20)
            }
    }
}

struct DemoCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TutorialView()
}
