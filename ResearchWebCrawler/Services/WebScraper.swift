//
//  WebScraper.swift
//  Research Web Crawler
//
//  Web scraping service for extracting content from URLs
//

import Foundation
import SwiftSoup

@MainActor
final class WebScraper {
    // MARK: - Properties

    private let session: URLSession
    private let rateLimiter: RateLimiter

    // MARK: - Initialization

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpAdditionalHeaders = [
            "User-Agent": "ResearchWebCrawler/1.0 (Academic Research Tool)"
        ]
        self.session = URLSession(configuration: config)
        self.rateLimiter = RateLimiter()
    }

    // MARK: - Public Methods

    /// Scrape a URL and extract metadata
    func scrape(url: String) async throws -> ScrapedContent {
        guard let url = URL(string: url) else {
            throw WebScraperError.invalidURL
        }

        // Check rate limiting
        try await rateLimiter.waitIfNeeded(for: url.host ?? "")

        // Fetch HTML
        let html = try await fetchHTML(from: url)

        // Parse with SwiftSoup
        let document = try SwiftSoup.parse(html)

        // Extract metadata
        let metadata = try extractMetadata(from: document, url: url)

        // Extract content
        let content = try extractContent(from: document)

        return ScrapedContent(
            url: url.absoluteString,
            title: metadata.title,
            authors: metadata.authors,
            description: metadata.description,
            content: content,
            publishDate: metadata.publishDate,
            metadata: metadata
        )
    }

    // MARK: - HTML Fetching

    private func fetchHTML(from url: URL) async throws -> String {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebScraperError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WebScraperError.httpError(statusCode: httpResponse.statusCode)
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw WebScraperError.encodingError
        }

        return html
    }

    // MARK: - Metadata Extraction

    private func extractMetadata(from document: Document, url: URL) throws -> WebMetadata {
        var metadata = WebMetadata()

        // Try Open Graph first
        if let ogTitle = try? document.select("meta[property=og:title]").first()?.attr("content"), !ogTitle.isEmpty {
            metadata.title = ogTitle
        }

        if let ogDescription = try? document.select("meta[property=og:description]").first()?.attr("content"), !ogDescription.isEmpty {
            metadata.description = ogDescription
        }

        if let ogImage = try? document.select("meta[property=og:image]").first()?.attr("content"), !ogImage.isEmpty {
            metadata.imageURL = ogImage
        }

        if let ogType = try? document.select("meta[property=og:type]").first()?.attr("content"), !ogType.isEmpty {
            metadata.type = ogType
        }

        // Fallback to standard meta tags
        if metadata.title == nil {
            if let title = try? document.title() {
                metadata.title = title
            }
        }

        if metadata.description == nil {
            if let description = try? document.select("meta[name=description]").first()?.attr("content"), !description.isEmpty {
                metadata.description = description
            }
        }

        // Extract author from meta tags
        if let author = try? document.select("meta[name=author]").first()?.attr("content"), !author.isEmpty {
            metadata.authors = [author]
        } else if let authors = try? document.select("meta[property=article:author]").array(), !authors.isEmpty {
            metadata.authors = authors.compactMap { try? $0.attr("content") }
        }

        // Extract publish date
        if let publishDate = try? document.select("meta[property=article:published_time]").first()?.attr("content"), !publishDate.isEmpty {
            metadata.publishDate = parseDate(publishDate)
        } else if let publishDate = try? document.select("meta[name=publish_date]").first()?.attr("content"), !publishDate.isEmpty {
            metadata.publishDate = parseDate(publishDate)
        }

        // Extract keywords
        if let keywords = try? document.select("meta[name=keywords]").first()?.attr("content"), !keywords.isEmpty {
            metadata.keywords = keywords.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        // Extract DOI if present
        if let doi = try? document.select("meta[name=citation_doi]").first()?.attr("content"), !doi.isEmpty {
            metadata.doi = doi
        } else if let doi = try? document.select("meta[name=DC.Identifier]").first()?.attr("content"), doi.hasPrefix("10.") {
            metadata.doi = doi
        }

        // Extract journal information for academic papers
        if let journal = try? document.select("meta[name=citation_journal_title]").first()?.attr("content"), !journal.isEmpty {
            metadata.journal = journal
        }

        return metadata
    }

    // MARK: - Content Extraction

    private func extractContent(from document: Document) throws -> String {
        // Remove scripts, styles, and nav elements
        try document.select("script, style, nav, header, footer, aside").remove()

        // Try to find main content
        var contentElements: [Element] = []

        // Try semantic HTML5 tags first
        if let main = try? document.select("main").first() {
            contentElements.append(main)
        } else if let article = try? document.select("article").first() {
            contentElements.append(article)
        } else if let content = try? document.select("div.content, div.article-content, div.post-content").first() {
            contentElements.append(content)
        } else {
            // Fallback: find paragraphs
            if let paragraphs = try? document.select("p") {
                contentElements = paragraphs.array()
            }
        }

        // Extract text from elements
        let text = contentElements.compactMap { element in
            try? element.text()
        }.joined(separator: "\n\n")

        // Clean up whitespace
        let cleaned = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return cleaned
    }

    // MARK: - Date Parsing

    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            ISO8601DateFormatter(),
        ]

        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        // Try standard date formatter with common formats
        let dateFormatter = DateFormatter()
        let formats = [
            "yyyy-MM-dd",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "MMM dd, yyyy",
            "MMMM dd, yyyy"
        ]

        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }
}

// MARK: - Models

struct ScrapedContent {
    let url: String
    let title: String?
    let authors: [String]
    let description: String?
    let content: String
    let publishDate: Date?
    let metadata: WebMetadata
}

struct WebMetadata {
    var title: String?
    var description: String?
    var authors: [String] = []
    var publishDate: Date?
    var imageURL: String?
    var type: String?
    var keywords: [String] = []
    var doi: String?
    var journal: String?
}

// MARK: - Rate Limiter

actor RateLimiter {
    private var lastRequestTimes: [String: Date] = [:]
    private let minimumDelay: TimeInterval = 1.0 // 1 second between requests to same domain

    func waitIfNeeded(for host: String) async throws {
        if let lastTime = lastRequestTimes[host] {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minimumDelay {
                let waitTime = minimumDelay - elapsed
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }

        lastRequestTimes[host] = Date()
    }
}

// MARK: - Errors

enum WebScraperError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case encodingError
    case parsingError
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .encodingError:
            return "Failed to decode response"
        case .parsingError:
            return "Failed to parse HTML"
        case .rateLimited:
            return "Rate limited. Please try again later."
        }
    }
}
