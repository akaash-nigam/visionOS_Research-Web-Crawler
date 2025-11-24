//
//  SourceDetailView.swift
//  Research Web Crawler
//
//  Detailed view of a source
//

import SwiftUI

struct SourceDetailView: View {
    let source: Source

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                Text(source.title)
                    .font(.title)
                    .fontWeight(.bold)

                // Metadata
                VStack(alignment: .leading, spacing: 12) {
                    if !source.authors.isEmpty {
                        MetadataRow(
                            icon: "person.2",
                            title: "Authors",
                            value: source.authors.joined(separator: ", ")
                        )
                    }

                    if let date = source.publicationDate {
                        MetadataRow(
                            icon: "calendar",
                            title: "Published",
                            value: date.formatted(date: .long, time: .omitted)
                        )
                    }

                    MetadataRow(
                        icon: "doc.text",
                        title: "Type",
                        value: source.type.displayName
                    )

                    if let url = source.url {
                        MetadataRow(
                            icon: "link",
                            title: "URL",
                            value: url
                        )
                    }

                    if let doi = source.doi {
                        MetadataRow(
                            icon: "number",
                            title: "DOI",
                            value: doi
                        )
                    }
                }

                // Abstract
                if let abstract = source.abstract {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Abstract")
                            .font(.headline)

                        Text(abstract)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                // Notes
                if let notes = source.notes {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)

                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MetadataRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SourceDetailView(
            source: Source(
                title: "Sample Research Paper",
                type: .academicPaper,
                projectId: UUID(),
                addedBy: "test"
            )
        )
    }
}
