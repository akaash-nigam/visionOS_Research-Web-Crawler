//
//  BibliographyView.swift
//  Research Web Crawler
//
//  View for generating and exporting bibliographies
//

import SwiftUI

struct BibliographyView: View {
    @EnvironmentObject var graphManager: GraphManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedStyle: CitationFormatter.Style = .apa
    @State private var selectedSources: Set<UUID> = []
    @State private var showingExportSheet = false
    @State private var exportFormat: ExportFormat = .plainText
    @State private var includeNotes = false
    @State private var generatedBibliography = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Style selector
                Picker("Citation Style", selection: $selectedStyle) {
                    ForEach(CitationFormatter.Style.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Source selection
                List(selection: $selectedSources) {
                    Section("Select Sources") {
                        ForEach(graphManager.sources) { source in
                            HStack {
                                Image(systemName: selectedSources.contains(source.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedSources.contains(source.id) ? .blue : .secondary)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(source.title)
                                        .font(.body)

                                    if !source.authors.isEmpty {
                                        Text(source.authors.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(source.id)
                            }
                        }
                    }
                }

                // Actions
                VStack(spacing: 12) {
                    HStack {
                        Button(action: selectAll) {
                            Label("Select All", systemImage: "checkmark.circle")
                        }

                        Button(action: deselectAll) {
                            Label("Deselect All", systemImage: "circle")
                        }
                    }
                    .buttonStyle(.bordered)

                    HStack(spacing: 12) {
                        Button(action: generateBibliography) {
                            Label("Generate Bibliography", systemImage: "doc.text")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedSources.isEmpty)

                        Button(action: { showingExportSheet = true }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .disabled(generatedBibliography.isEmpty)
                    }
                }
                .padding()
                .background(.regularMaterial)
            }
            .navigationTitle("Bibliography")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportSheet(
                    bibliography: generatedBibliography,
                    format: $exportFormat,
                    includeNotes: $includeNotes,
                    sources: selectedSourcesList
                )
            }
            .sheet(item: $previewBibliography) { bibliography in
                BibliographyPreviewView(bibliography: bibliography.text)
            }
        }
    }

    @State private var previewBibliography: PreviewBibliography?

    struct PreviewBibliography: Identifiable {
        let id = UUID()
        let text: String
    }

    private var selectedSourcesList: [Source] {
        graphManager.sources.filter { selectedSources.contains($0.id) }
    }

    private func toggleSelection(_ id: UUID) {
        if selectedSources.contains(id) {
            selectedSources.remove(id)
        } else {
            selectedSources.insert(id)
        }
    }

    private func selectAll() {
        selectedSources = Set(graphManager.sources.map { $0.id })
    }

    private func deselectAll() {
        selectedSources.removeAll()
    }

    private func generateBibliography() {
        let sources = selectedSourcesList
        generatedBibliography = CitationFormatter.generateBibliography(
            sources: sources,
            style: selectedStyle
        )

        // Show preview
        previewBibliography = PreviewBibliography(text: generatedBibliography)
    }

    enum ExportFormat: String, CaseIterable {
        case plainText = "Plain Text"
        case bibtex = "BibTeX"

        var id: String { rawValue }
    }
}

// MARK: - Bibliography Preview

struct BibliographyPreviewView: View {
    let bibliography: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(bibliography)
                    .font(.system(.body, design: .serif))
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("Bibliography Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: copyToClipboard) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }

    private func copyToClipboard() {
        #if os(iOS) || os(visionOS)
        UIPasteboard.general.string = bibliography
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(bibliography, forType: .string)
        #endif
    }
}

// MARK: - Export Sheet

struct ExportSheet: View {
    let bibliography: String
    @Binding var format: BibliographyView.ExportFormat
    @Binding var includeNotes: Bool
    let sources: [Source]

    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $format) {
                        ForEach(BibliographyView.ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if format == .plainText {
                    Section {
                        Toggle("Include Personal Notes", isOn: $includeNotes)
                    }
                }

                Section("Preview") {
                    Text(exportContent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(10)
                }

                Section {
                    Button(action: exportBibliography) {
                        Label("Export Bibliography", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Export Bibliography")
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

    private var exportContent: String {
        switch format {
        case .plainText:
            return CitationFormatter.exportToPlainText(
                sources: sources,
                style: .apa, // Use selected style from parent
                includeNotes: includeNotes
            )
        case .bibtex:
            return CitationFormatter.exportToBibTeX(sources)
        }
    }

    private func exportBibliography() {
        // Copy to clipboard
        #if os(iOS) || os(visionOS)
        UIPasteboard.general.string = exportContent
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(exportContent, forType: .string)
        #endif

        dismiss()
    }
}

#Preview {
    BibliographyView()
        .environmentObject(GraphManager(
            persistenceManager: PersistenceManager(
                modelContainer: try! ModelContainer(
                    for: Schema([Project.self, Source.self, Collection.self]),
                    configurations: []
                )
            )
        ))
}
