//
//  SourceSearchView.swift
//  Research Web Crawler
//
//  Advanced search and filtering for sources
//

import SwiftUI

struct SourceSearchView: View {
    @EnvironmentObject var graphManager: GraphManager
    @Environment(\.dismiss) var dismiss

    // Search state
    @State private var searchText = ""
    @State private var selectedType: SourceType?
    @State private var showFavoritesOnly = false
    @State private var selectedTags: Set<String> = []
    @State private var sortOrder: SortOrder = .dateAddedDescending

    // Date filters
    @State private var useAddedDateFilter = false
    @State private var addedAfterDate = Date().addingTimeInterval(-30*24*60*60) // 30 days ago
    @State private var addedBeforeDate = Date()

    @State private var usePublicationDateFilter = false
    @State private var publicationAfterDate = Date().addingTimeInterval(-365*24*60*60) // 1 year ago
    @State private var publicationBeforeDate = Date()

    // Advanced filters
    @State private var hasURL = false
    @State private var hasDOI = false
    @State private var hasAbstract = false
    @State private var hasLocalFile = false
    @State private var minConnectionCount = 0

    // Results
    var filteredSources: [Source] {
        var sources = graphManager.sources

        // Text search
        if !searchText.isEmpty {
            sources = sources.filter { source in
                source.title.localizedCaseInsensitiveContains(searchText) ||
                source.authors.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                source.abstract?.localizedCaseInsensitiveContains(searchText) == true ||
                source.notes?.localizedCaseInsensitiveContains(searchText) == true ||
                source.journal?.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        // Type filter
        if let type = selectedType {
            sources = sources.filter { $0.type == type }
        }

        // Favorites filter
        if showFavoritesOnly {
            sources = sources.filter { $0.isFavorite }
        }

        // Tags filter
        if !selectedTags.isEmpty {
            sources = sources.filter { source in
                !Set(source.tags).isDisjoint(with: selectedTags)
            }
        }

        // Date filters
        if useAddedDateFilter {
            sources = sources.filter { source in
                source.added >= addedAfterDate && source.added <= addedBeforeDate
            }
        }

        if usePublicationDateFilter {
            sources = sources.filter { source in
                guard let pubDate = source.publicationDate else { return false }
                return pubDate >= publicationAfterDate && pubDate <= publicationBeforeDate
            }
        }

        // Advanced filters
        if hasURL {
            sources = sources.filter { $0.url != nil && !$0.url!.isEmpty }
        }

        if hasDOI {
            sources = sources.filter { $0.doi != nil && !$0.doi!.isEmpty }
        }

        if hasAbstract {
            sources = sources.filter { $0.abstract != nil && !$0.abstract!.isEmpty }
        }

        if hasLocalFile {
            sources = sources.filter { $0.localFilePath != nil }
        }

        if minConnectionCount > 0 {
            sources = sources.filter { $0.connectionCount >= minConnectionCount }
        }

        // Sort
        return sortOrder.sort(sources)
    }

    // Available tags
    var availableTags: Set<String> {
        var tags = Set<String>()
        for source in graphManager.sources {
            tags.formUnion(source.tags)
        }
        return tags
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField("Search sources...", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Type filter
                        Menu {
                            Button("All Types") {
                                selectedType = nil
                            }
                            ForEach(SourceType.allCases, id: \.self) { type in
                                Button(action: { selectedType = type }) {
                                    Label(type.displayName, systemImage: type.icon)
                                }
                            }
                        } label: {
                            FilterChip(
                                title: selectedType?.displayName ?? "All Types",
                                isActive: selectedType != nil
                            )
                        }

                        // Favorites filter
                        Button(action: { showFavoritesOnly.toggle() }) {
                            FilterChip(
                                title: "Favorites",
                                icon: "star.fill",
                                isActive: showFavoritesOnly
                            )
                        }

                        // More filters button
                        NavigationLink(destination: AdvancedFiltersView(
                            useAddedDateFilter: $useAddedDateFilter,
                            addedAfterDate: $addedAfterDate,
                            addedBeforeDate: $addedBeforeDate,
                            usePublicationDateFilter: $usePublicationDateFilter,
                            publicationAfterDate: $publicationAfterDate,
                            publicationBeforeDate: $publicationBeforeDate,
                            hasURL: $hasURL,
                            hasDOI: $hasDOI,
                            hasAbstract: $hasAbstract,
                            hasLocalFile: $hasLocalFile,
                            minConnectionCount: $minConnectionCount,
                            selectedTags: $selectedTags,
                            availableTags: availableTags
                        )) {
                            FilterChip(
                                title: "More Filters",
                                icon: "slider.horizontal.3",
                                isActive: hasActiveAdvancedFilters
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(.regularMaterial)

                // Sort picker
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.displayName).tag(order)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Divider()

                // Results
                if filteredSources.isEmpty {
                    ContentUnavailableView {
                        Label("No Sources Found", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try adjusting your search criteria")
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredSources) { source in
                                SourceRow(source: source)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                // Results count
                Text("\(filteredSources.count) of \(graphManager.sources.count) sources")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
            }
            .navigationTitle("Search Sources")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Clear Filters") {
                        clearAllFilters()
                    }
                    .disabled(!hasAnyFilters)
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var hasActiveAdvancedFilters: Bool {
        useAddedDateFilter || usePublicationDateFilter ||
        hasURL || hasDOI || hasAbstract || hasLocalFile ||
        minConnectionCount > 0 || !selectedTags.isEmpty
    }

    private var hasAnyFilters: Bool {
        !searchText.isEmpty || selectedType != nil ||
        showFavoritesOnly || hasActiveAdvancedFilters
    }

    // MARK: - Actions

    private func clearAllFilters() {
        searchText = ""
        selectedType = nil
        showFavoritesOnly = false
        selectedTags.removeAll()
        useAddedDateFilter = false
        usePublicationDateFilter = false
        hasURL = false
        hasDOI = false
        hasAbstract = false
        hasLocalFile = false
        minConnectionCount = 0
        sortOrder = .dateAddedDescending
    }

    // MARK: - Sort Order

    enum SortOrder: String, CaseIterable {
        case dateAddedAscending
        case dateAddedDescending
        case titleAscending
        case titleDescending
        case connectionCountDescending
        case publicationDateDescending

        var displayName: String {
            switch self {
            case .dateAddedAscending: return "Oldest First"
            case .dateAddedDescending: return "Newest First"
            case .titleAscending: return "Title A-Z"
            case .titleDescending: return "Title Z-A"
            case .connectionCountDescending: return "Most Connected"
            case .publicationDateDescending: return "Publication Date"
            }
        }

        func sort(_ sources: [Source]) -> [Source] {
            switch self {
            case .dateAddedAscending:
                return sources.sorted { $0.added < $1.added }
            case .dateAddedDescending:
                return sources.sorted { $0.added > $1.added }
            case .titleAscending:
                return sources.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
            case .titleDescending:
                return sources.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
            case .connectionCountDescending:
                return sources.sorted { $0.connectionCount > $1.connectionCount }
            case .publicationDateDescending:
                return sources.sorted { source1, source2 in
                    guard let date1 = source1.publicationDate,
                          let date2 = source2.publicationDate else {
                        return source1.publicationDate != nil
                    }
                    return date1 > date2
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    var icon: String?
    var isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(title)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Color.accentColor : Color.secondary.opacity(0.2))
        .foregroundStyle(isActive ? .white : .primary)
        .clipShape(Capsule())
    }
}

// MARK: - Source Row

struct SourceRow: View {
    let source: Source

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: source.type.icon)
                .font(.title3)
                .foregroundStyle(source.type.color)
                .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(source.title)
                    .font(.headline)

                // Authors
                if !source.authors.isEmpty {
                    Text(source.authors.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Metadata
                HStack(spacing: 8) {
                    if source.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }

                    if source.connectionCount > 0 {
                        Label("\(source.connectionCount)", systemImage: "link")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if source.localFilePath != nil {
                        Image(systemName: "doc.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }

                    if let journal = source.journal {
                        Text(journal)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Advanced Filters View

struct AdvancedFiltersView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var useAddedDateFilter: Bool
    @Binding var addedAfterDate: Date
    @Binding var addedBeforeDate: Date

    @Binding var usePublicationDateFilter: Bool
    @Binding var publicationAfterDate: Date
    @Binding var publicationBeforeDate: Date

    @Binding var hasURL: Bool
    @Binding var hasDOI: Bool
    @Binding var hasAbstract: Bool
    @Binding var hasLocalFile: Bool
    @Binding var minConnectionCount: Int

    @Binding var selectedTags: Set<String>
    let availableTags: Set<String>

    var body: some View {
        Form {
            // Date filters
            Section("Date Filters") {
                Toggle("Filter by Date Added", isOn: $useAddedDateFilter)

                if useAddedDateFilter {
                    DatePicker("After", selection: $addedAfterDate, displayedComponents: [.date])
                    DatePicker("Before", selection: $addedBeforeDate, displayedComponents: [.date])
                }

                Toggle("Filter by Publication Date", isOn: $usePublicationDateFilter)

                if usePublicationDateFilter {
                    DatePicker("After", selection: $publicationAfterDate, displayedComponents: [.date])
                    DatePicker("Before", selection: $publicationBeforeDate, displayedComponents: [.date])
                }
            }

            // Content filters
            Section("Content Filters") {
                Toggle("Has URL", isOn: $hasURL)
                Toggle("Has DOI", isOn: $hasDOI)
                Toggle("Has Abstract", isOn: $hasAbstract)
                Toggle("Has Local File (PDF)", isOn: $hasLocalFile)
            }

            // Connection filter
            Section("Connection Filter") {
                Stepper("Minimum Connections: \(minConnectionCount)", value: $minConnectionCount, in: 0...20)
            }

            // Tags filter
            if !availableTags.isEmpty {
                Section("Filter by Tags") {
                    ForEach(Array(availableTags).sorted(), id: \.self) { tag in
                        Toggle(tag, isOn: Binding(
                            get: { selectedTags.contains(tag) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTags.insert(tag)
                                } else {
                                    selectedTags.remove(tag)
                                }
                            }
                        ))
                    }
                }
            }
        }
        .navigationTitle("Advanced Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    SourceSearchView()
        .environmentObject(GraphManager(
            persistenceManager: PersistenceManager(
                modelContainer: try! ModelContainer(
                    for: Schema([Project.self, Source.self, Collection.self]),
                    configurations: []
                )
            )
        ))
}
