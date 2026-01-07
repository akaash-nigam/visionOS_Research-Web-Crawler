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

    // Basic info
    @State private var title = ""
    @State private var authors = ""
    @State private var sourceType: SourceType = .article
    @State private var url = ""

    // Publication details
    @State private var doi = ""
    @State private var isbn = ""
    @State private var journal = ""
    @State private var volume = ""
    @State private var issue = ""
    @State private var pages = ""
    @State private var publisher = ""
    @State private var publicationDate = Date()
    @State private var usePublicationDate = false

    // Additional metadata
    @State private var abstract = ""
    @State private var notes = ""
    @State private var tags = ""
    @State private var isFavorite = false

    // Validation
    @State private var validationError: String?
    @State private var showingError = false

    var body: some View {
        Form {
            // Basic Information
            Section("Basic Information") {
                TextField("Title *", text: $title)
                    .autocorrectionDisabled()

                TextField("Authors (comma separated)", text: $authors)
                    .autocorrectionDisabled()

                Picker("Type", selection: $sourceType) {
                    ForEach(SourceType.allCases, id: \.self) { type in
                        Label(type.displayName, systemImage: type.icon).tag(type)
                    }
                }
            }

            // Publication Details
            if sourceType == .academicPaper || sourceType == .article {
                Section("Publication Details") {
                    TextField("DOI (e.g., 10.1234/example)", text: $doi)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    TextField("Journal", text: $journal)

                    HStack {
                        TextField("Volume", text: $volume)
                            .frame(maxWidth: .infinity)
                        TextField("Issue", text: $issue)
                            .frame(maxWidth: .infinity)
                    }

                    TextField("Pages (e.g., 123-145)", text: $pages)
                }
            }

            if sourceType == .book || sourceType == .bookChapter {
                Section("Book Information") {
                    TextField("ISBN", text: $isbn)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    TextField("Publisher", text: $publisher)
                }
            }

            // Dates
            Section("Dates") {
                Toggle("Specify Publication Date", isOn: $usePublicationDate)

                if usePublicationDate {
                    DatePicker("Publication Date", selection: $publicationDate, displayedComponents: [.date])
                }
            }

            // Content
            Section("Content") {
                TextField("URL", text: $url)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)

                TextField("Abstract", text: $abstract, axis: .vertical)
                    .lineLimit(5...10)

                TextField("Personal Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }

            // Tags and Categories
            Section("Organization") {
                TextField("Tags (comma separated)", text: $tags)
                    .autocorrectionDisabled()

                Toggle("Mark as Favorite", isOn: $isFavorite)
            }

            // Actions
            Section {
                Button("Add Source") {
                    validateAndAddSource()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Validation error
            if let error = validationError {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .alert("Validation Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationError ?? "Unknown error")
        }
    }

    private func validateAndAddSource() {
        guard let project = graphManager.currentProject else { return }

        // Create source
        let source = Source(
            title: title.trimmingCharacters(in: .whitespaces),
            type: sourceType,
            projectId: project.id,
            addedBy: "default-user"
        )

        // Set authors
        if !authors.isEmpty {
            source.authors = authors.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        // Set publication details
        if !doi.isEmpty {
            source.doi = doi.trimmingCharacters(in: .whitespaces)
        }
        if !isbn.isEmpty {
            source.isbn = isbn.trimmingCharacters(in: .whitespaces)
        }
        if !journal.isEmpty {
            source.journal = journal.trimmingCharacters(in: .whitespaces)
        }
        if !volume.isEmpty {
            source.volume = volume.trimmingCharacters(in: .whitespaces)
        }
        if !issue.isEmpty {
            source.issue = issue.trimmingCharacters(in: .whitespaces)
        }
        if !pages.isEmpty {
            source.pages = pages.trimmingCharacters(in: .whitespaces)
        }
        if !publisher.isEmpty {
            source.publisher = publisher.trimmingCharacters(in: .whitespaces)
        }
        if usePublicationDate {
            source.publicationDate = publicationDate
        }

        // Set content
        if !url.isEmpty {
            source.url = url.trimmingCharacters(in: .whitespaces)
        }
        if !abstract.isEmpty {
            source.abstract = abstract.trimmingCharacters(in: .whitespaces)
        }
        if !notes.isEmpty {
            source.notes = notes.trimmingCharacters(in: .whitespaces)
        }

        // Set tags
        if !tags.isEmpty {
            source.tags = tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        source.isFavorite = isFavorite

        // Validate
        do {
            try source.validate()

            // Add to graph
            Task {
                await graphManager.addSource(source)
                await MainActor.run {
                    dismiss()
                }
            }
        } catch {
            validationError = error.localizedDescription
            showingError = true
        }
    }
}

// MARK: - From URL

struct AddSourceFromURLView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var graphManager: GraphManager

    @State private var url = ""
    @State private var isLoading = false
    @State private var scrapedContent: ScrapedContent?
    @State private var error: String?

    // Editable fields after scraping
    @State private var title = ""
    @State private var authors = ""
    @State private var sourceType: SourceType = .article
    @State private var description = ""
    @State private var tags = ""

    private let webScraper = WebScraper()

    var body: some View {
        Form {
            // URL Input
            Section("URL") {
                HStack {
                    TextField("https://example.com/article", text: $url)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                    }
                }

                Button(action: scrapeURL) {
                    Label("Fetch Metadata", systemImage: "arrow.down.circle")
                }
                .disabled(url.isEmpty || isLoading)
            }

            // Error display
            if let error = error {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            // Scraped metadata
            if let scraped = scrapedContent {
                Section("Extracted Information") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()

                    TextField("Authors (comma separated)", text: $authors)
                        .autocorrectionDisabled()

                    Picker("Type", selection: $sourceType) {
                        ForEach(SourceType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }

                    if let description = scraped.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }

                    if !scraped.content.isEmpty {
                        DisclosureGroup("Content Preview") {
                            Text(String(scraped.content.prefix(500)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Organization") {
                    TextField("Tags (comma separated)", text: $tags)
                        .autocorrectionDisabled()
                }

                Section {
                    Button("Add Source") {
                        addSource()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func scrapeURL() {
        isLoading = true
        error = nil

        Task {
            do {
                let scraped = try await webScraper.scrape(url: url)
                await MainActor.run {
                    self.scrapedContent = scraped

                    // Populate fields
                    self.title = scraped.title ?? ""
                    self.authors = scraped.authors.joined(separator: ", ")
                    self.description = scraped.description ?? ""

                    // Auto-detect type
                    if let type = scraped.metadata.type {
                        if type.contains("article") {
                            self.sourceType = scraped.metadata.journal != nil ? .academicPaper : .article
                        } else if type.contains("video") {
                            self.sourceType = .video
                        }
                    }

                    // Add keywords as tags
                    if !scraped.metadata.keywords.isEmpty {
                        self.tags = scraped.metadata.keywords.joined(separator: ", ")
                    }

                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func addSource() {
        guard let project = graphManager.currentProject,
              let scraped = scrapedContent else { return }

        let source = Source(
            title: title.trimmingCharacters(in: .whitespaces),
            type: sourceType,
            projectId: project.id,
            addedBy: "default-user"
        )

        // Set authors
        if !authors.isEmpty {
            source.authors = authors.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        // Set URL and metadata
        source.url = url
        source.abstract = scraped.description
        source.doi = scraped.metadata.doi
        source.journal = scraped.metadata.journal

        if let publishDate = scraped.publishDate {
            source.publicationDate = publishDate
        }

        // Set tags
        if !tags.isEmpty {
            source.tags = tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        // Add to graph
        Task {
            await graphManager.addSource(source)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - PDF Upload

struct AddSourcePDFView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var graphManager: GraphManager

    @State private var isImporting = false
    @State private var selectedPDFURL: URL?
    @State private var pdfData: Data?

    // Extracted metadata
    @State private var extractedTitle: String?
    @State private var extractedAuthors: [String] = []

    // Manual fields
    @State private var title = ""
    @State private var authors = ""
    @State private var sourceType: SourceType = .academicPaper
    @State private var doi = ""
    @State private var abstract = ""
    @State private var notes = ""
    @State private var tags = ""

    @State private var validationError: String?
    @State private var showingError = false

    var body: some View {
        Form {
            // PDF Selection
            Section("PDF File") {
                if let url = selectedPDFURL {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(url.lastPathComponent)
                                .font(.body)
                            Text("PDF selected")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Change") {
                            isImporting = true
                        }
                    }
                } else {
                    Button(action: { isImporting = true }) {
                        Label("Select PDF File", systemImage: "doc.badge.plus")
                    }
                }
            }

            if selectedPDFURL != nil {
                // Basic metadata
                Section("Metadata") {
                    TextField("Title", text: $title)
                        .autocorrectionDisabled()

                    TextField("Authors (comma separated)", text: $authors)
                        .autocorrectionDisabled()

                    Picker("Type", selection: $sourceType) {
                        Text("Academic Paper").tag(SourceType.academicPaper)
                        Text("Book").tag(SourceType.book)
                        Text("Book Chapter").tag(SourceType.bookChapter)
                        Text("Article").tag(SourceType.article)
                        Text("Other").tag(SourceType.other)
                    }
                }

                // Additional metadata
                Section("Publication Details") {
                    TextField("DOI (optional)", text: $doi)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    TextField("Abstract (optional)", text: $abstract, axis: .vertical)
                        .lineLimit(5...10)
                }

                // Organization
                Section("Organization") {
                    TextField("Tags (comma separated)", text: $tags)
                        .autocorrectionDisabled()

                    TextField("Personal Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }

                // Actions
                Section {
                    Button("Add Source with PDF") {
                        validateAndAddSource()
                    }
                    .disabled(title.isEmpty || selectedPDFURL == nil)
                }

                // Validation error
                if let error = validationError {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handlePDFSelection(result)
        }
        .alert("Validation Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationError ?? "Unknown error")
        }
    }

    private func handlePDFSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // Store URL
            selectedPDFURL = url

            // Try to read PDF data
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }

                if let data = try? Data(contentsOf: url) {
                    pdfData = data
                    extractMetadata(from: data, filename: url.lastPathComponent)
                }
            }

        case .failure(let error):
            validationError = "Failed to select PDF: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func extractMetadata(from data: Data, filename: String) {
        // Basic extraction from filename
        // More sophisticated extraction would use PDFKit
        let nameWithoutExtension = filename.replacingOccurrences(of: ".pdf", with: "")

        // Use filename as initial title if empty
        if title.isEmpty {
            title = nameWithoutExtension
        }

        // TODO: Use PDFKit to extract actual metadata from PDF
        // This is a simplified version
        extractedTitle = nameWithoutExtension
    }

    private func validateAndAddSource() {
        guard let project = graphManager.currentProject else { return }
        guard let pdfURL = selectedPDFURL else { return }

        // Create source
        let source = Source(
            title: title.trimmingCharacters(in: .whitespaces),
            type: sourceType,
            projectId: project.id,
            addedBy: "default-user"
        )

        // Set authors
        if !authors.isEmpty {
            source.authors = authors.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        // Set publication details
        if !doi.isEmpty {
            source.doi = doi.trimmingCharacters(in: .whitespaces)
        }
        if !abstract.isEmpty {
            source.abstract = abstract.trimmingCharacters(in: .whitespaces)
        }
        if !notes.isEmpty {
            source.notes = notes.trimmingCharacters(in: .whitespaces)
        }

        // Set tags
        if !tags.isEmpty {
            source.tags = tags.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }

        // Set PDF file path
        // In real implementation, copy PDF to app's documents directory
        source.localFilePath = pdfURL.path

        // Validate
        do {
            try source.validate()

            // Add to graph
            Task {
                await graphManager.addSource(source)
                await MainActor.run {
                    dismiss()
                }
            }
        } catch {
            validationError = error.localizedDescription
            showingError = true
        }
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
