//
//  AddSourceView.swift
//  Research Web Crawler
//
//  View for adding a new source
//

import SwiftUI

struct AddSourceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var graphManager: GraphManager

    @State private var selectedMethod: AddMethod = .manual

    enum AddMethod {
        case manual
        case url
        case pdf
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Method selector
                Picker("Add Method", selection: $selectedMethod) {
                    Label("Manual", systemImage: "pencil").tag(AddMethod.manual)
                    Label("From URL", systemImage: "link").tag(AddMethod.url)
                    Label("PDF", systemImage: "doc.fill").tag(AddMethod.pdf)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content based on selected method
                switch selectedMethod {
                case .manual:
                    AddSourceManualView()
                case .url:
                    AddSourceFromURLView()
                case .pdf:
                    AddSourcePDFView()
                }

                Spacer()
            }
            .navigationTitle("Add Source")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Manual Entry

struct AddSourceManualView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var graphManager: GraphManager

    @State private var title = ""
    @State private var authors = ""
    @State private var sourceType: SourceType = .article
    @State private var url = ""
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Title", text: $title)
                TextField("Authors (comma separated)", text: $authors)
                Picker("Type", selection: $sourceType) {
                    ForEach(SourceType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon).tag(type)
                    }
                }
            }

            Section("Optional") {
                TextField("URL", text: $url)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(5...10)
            }

            Section {
                Button("Add Source") {
                    addSource()
                }
                .disabled(title.isEmpty)
            }
        }
    }

    private func addSource() {
        guard let project = graphManager.currentProject else { return }

        let source = Source(
            title: title,
            type: sourceType,
            projectId: project.id,
            addedBy: "default-user"
        )

        source.authors = authors.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        source.url = url.isEmpty ? nil : url
        source.notes = notes.isEmpty ? nil : notes

        Task {
            await graphManager.addSource(source)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - From URL (Placeholder)

struct AddSourceFromURLView: View {
    @State private var url = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Enter URL", text: $url)
                .textFieldStyle(.roundedBorder)
                .padding()

            Text("URL scraping will be implemented in Epic 5")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

// MARK: - PDF Upload (Placeholder)

struct AddSourcePDFView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("PDF upload will be implemented in Epic 4")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    AddSourceView()
        .environmentObject(GraphManager(
            persistenceManager: PersistenceManager(
                modelContainer: try! ModelContainer(
                    for: Schema([Project.self, Source.self, Collection.self]),
                    configurations: []
                )
            )
        ))
}
