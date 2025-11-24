//
//  SourceListView.swift
//  Research Web Crawler
//
//  List view of all sources
//

import SwiftUI

struct SourceListView: View {
    @EnvironmentObject var graphManager: GraphManager
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(filteredSources) { source in
                NavigationLink {
                    SourceDetailView(source: source)
                } label: {
                    SourceListRow(source: source)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search sources")
        .navigationTitle("All Sources")
    }

    private var filteredSources: [Source] {
        if searchText.isEmpty {
            return graphManager.sources
        } else {
            return graphManager.sources.filter { source in
                source.title.localizedCaseInsensitiveContains(searchText) ||
                source.authors.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

struct SourceListRow: View {
    let source: Source

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: source.type.icon)
                    .foregroundStyle(source.type.color)

                Text(source.title)
                    .font(.headline)
                    .lineLimit(2)
            }

            if !source.authors.isEmpty {
                Text(source.authors.prefix(3).joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if let date = source.publicationDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SourceListView()
            .environmentObject(GraphManager(
                persistenceManager: PersistenceManager(
                    modelContainer: try! ModelContainer(
                        for: Schema([Project.self, Source.self, Collection.self]),
                        configurations: []
                    )
                )
            ))
    }
}
