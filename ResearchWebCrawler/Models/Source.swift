//
//  Source.swift
//  Research Web Crawler
//
//  Represents a research source (article, paper, book, etc.)
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Source {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Parent project ID
    var projectId: UUID

    /// Source title
    var title: String

    /// Authors
    var authors: [String]

    /// Publication date
    var publicationDate: Date?

    /// Source type
    var sourceType: String

    /// URL
    var url: String?

    /// DOI
    var doi: String?

    /// ISBN
    var isbn: String?

    /// Publisher
    var publisher: String?

    /// Journal name
    var journal: String?

    /// Volume
    var volume: String?

    /// Issue
    var issue: String?

    /// Pages
    var pages: String?

    /// Abstract
    var abstract: String?

    /// User notes
    var notes: String?

    /// Tags
    var tags: [String]

    /// Is favorite
    var isFavorite: Bool

    /// Creation date
    var created: Date

    /// Modification date
    var modified: Date

    /// Added by user ID
    var addedBy: String

    /// PDF file path
    var pdfFilePath: String?

    /// Number of connections
    var connectionCount: Int

    // MARK: - Initialization

    init(
        title: String,
        type: SourceType,
        projectId: UUID,
        addedBy: String
    ) {
        self.id = UUID()
        self.title = title
        self.sourceType = type.rawValue
        self.projectId = projectId
        self.addedBy = addedBy
        self.authors = []
        self.tags = []
        self.isFavorite = false
        self.created = Date()
        self.modified = Date()
        self.connectionCount = 0
    }

    // MARK: - Computed Properties

    var type: SourceType {
        get { SourceType(rawValue: sourceType) ?? .other }
        set { sourceType = newValue.rawValue }
    }

    // MARK: - Methods

    func updateModified() {
        self.modified = Date()
    }
}

// MARK: - Source Type

enum SourceType: String, Codable, CaseIterable {
    case article
    case academicPaper
    case book
    case bookChapter
    case news
    case blogPost
    case video
    case podcast
    case dataset
    case socialMedia
    case wikipedia
    case patent
    case thesis
    case presentation
    case note
    case other

    var displayName: String {
        switch self {
        case .article: return "Article"
        case .academicPaper: return "Academic Paper"
        case .book: return "Book"
        case .bookChapter: return "Book Chapter"
        case .news: return "News Article"
        case .blogPost: return "Blog Post"
        case .video: return "Video"
        case .podcast: return "Podcast"
        case .dataset: return "Dataset"
        case .socialMedia: return "Social Media"
        case .wikipedia: return "Wikipedia"
        case .patent: return "Patent"
        case .thesis: return "Thesis/Dissertation"
        case .presentation: return "Presentation"
        case .note: return "Note"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .academicPaper: return "graduationcap"
        case .book: return "book"
        case .bookChapter: return "book.pages"
        case .news: return "newspaper"
        case .blogPost: return "text.bubble"
        case .video: return "play.rectangle"
        case .podcast: return "mic"
        case .dataset: return "chart.bar"
        case .socialMedia: return "bubble.left.and.bubble.right"
        case .wikipedia: return "globe"
        case .patent: return "lightbulb"
        case .thesis: return "scroll"
        case .presentation: return "rectangle.on.rectangle"
        case .note: return "note.text"
        case .other: return "doc"
        }
    }

    var color: Color {
        switch self {
        case .article: return .blue
        case .academicPaper: return .purple
        case .book: return .brown
        case .bookChapter: return .orange
        case .news: return .red
        case .blogPost: return .cyan
        case .video: return .pink
        case .podcast: return .mint
        case .dataset: return .green
        case .socialMedia: return .indigo
        case .wikipedia: return .gray
        case .patent: return .yellow
        case .thesis: return .teal
        case .presentation: return .orange
        case .note: return .secondary
        case .other: return .gray
        }
    }
}
