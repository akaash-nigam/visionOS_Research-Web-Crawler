# Web Scraping & Content Extraction Architecture

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

This document details the architecture for web scraping and content extraction, including metadata extraction, PDF parsing, rate limiting, error handling, and ethical scraping practices.

## Scraping Architecture

### Content Processor Pipeline

```swift
final class ContentProcessor {
    let urlSession: URLSession
    let metadataExtractor: MetadataExtractor
    let pdfParser: PDFParser
    let cache: ContentCache

    func processURL(_ url: URL) async throws -> Source {
        // 1. Check cache
        if let cached = cache.get(url) {
            return cached
        }

        // 2. Determine content type
        let contentType = try await detectContentType(url)

        // 3. Extract based on type
        let source: Source
        switch contentType {
        case .html:
            source = try await scrapeWebPage(url)
        case .pdf:
            source = try await downloadAndParsePDF(url)
        default:
            throw ContentError.unsupportedType
        }

        // 4. Cache result
        cache.set(url, source: source)

        return source
    }
}
```

### Web Page Scraping

```swift
final class WebScraper {
    func scrape(_ url: URL) async throws -> ScrapedContent {
        // 1. Download HTML
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScrapingError.invalidEncoding
        }

        // 2. Parse with SwiftSoup
        let doc = try SwiftSoup.parse(html)

        // 3. Extract metadata (Open Graph, JSON-LD, meta tags)
        let metadata = try extractMetadata(from: doc, url: url)

        // 4. Extract main content (article text)
        let content = try extractMainContent(from: doc)

        // 5. Extract images
        let images = try extractImages(from: doc, baseURL: url)

        return ScrapedContent(
            url: url,
            title: metadata.title,
            authors: metadata.authors,
            publishDate: metadata.publishDate,
            publisher: metadata.publisher,
            content: content,
            images: images
        )
    }

    private func extractMetadata(from doc: Document, url: URL) throws -> Metadata {
        var metadata = Metadata()

        // Open Graph tags
        metadata.title = try? doc.select("meta[property=og:title]").first()?.attr("content")
        metadata.description = try? doc.select("meta[property=og:description]").first()?.attr("content")
        metadata.image = try? doc.select("meta[property=og:image]").first()?.attr("content")

        // Standard meta tags (fallback)
        if metadata.title == nil {
            metadata.title = try? doc.select("title").first()?.text()
        }

        // JSON-LD structured data
        if let jsonLD = try? doc.select("script[type='application/ld+json']").first()?.html() {
            parseJSONLD(jsonLD, into: &metadata)
        }

        // Academic-specific (for papers)
        metadata.doi = try? doc.select("meta[name=citation_doi]").first()?.attr("content")
        metadata.authors = try doc.select("meta[name=citation_author]")
            .array()
            .compactMap { try? $0.attr("content") }

        return metadata
    }

    private func extractMainContent(from doc: Document) throws -> String {
        // Try common content selectors
        let selectors = [
            "article",
            "[role=main]",
            ".article-content",
            ".post-content",
            "#content",
            ".entry-content"
        ]

        for selector in selectors {
            if let content = try? doc.select(selector).first()?.text(),
               !content.isEmpty {
                return cleanText(content)
            }
        }

        // Fallback: body text (may include noise)
        return try doc.select("body").text()
    }

    private func cleanText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

### PDF Parsing

```swift
final class PDFParser {
    func parse(_ pdfURL: URL) throws -> ParsedPDF {
        guard let document = PDFDocument(url: pdfURL) else {
            throw PDFError.cannotOpen
        }

        // 1. Extract metadata
        let metadata = extractPDFMetadata(document)

        // 2. Extract text
        var fullText = ""
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            if let pageText = page.string {
                fullText += pageText + "\n"
            }
        }

        // 3. Extract images (optional)
        let images = extractImages(from: document)

        return ParsedPDF(
            metadata: metadata,
            text: fullText,
            images: images,
            pageCount: document.pageCount
        )
    }

    private func extractPDFMetadata(_ document: PDFDocument) -> Metadata {
        var metadata = Metadata()

        // PDF metadata dictionary
        let attributes = document.documentAttributes

        metadata.title = attributes?[PDFDocumentAttribute.titleAttribute] as? String
        metadata.authors = (attributes?[PDFDocumentAttribute.authorAttribute] as? String)?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        metadata.creationDate = attributes?[PDFDocumentAttribute.creationDateAttribute] as? Date

        // Try to extract DOI from text
        if let firstPage = document.page(at: 0)?.string {
            metadata.doi = extractDOI(from: firstPage)
        }

        return metadata
    }

    private func extractDOI(from text: String) -> String? {
        let pattern = #"10\.\d{4,9}/[-._;()/:A-Z0-9]+"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..., in: text)

        if let match = regex?.firstMatch(in: text, range: range) {
            return String(text[Range(match.range, in: text)!])
        }
        return nil
    }
}
```

### Metadata Extraction

#### DOI Lookup (CrossRef API)

```swift
final class DOIResolver {
    let baseURL = "https://api.crossref.org/works/"

    func resolve(_ doi: String) async throws -> Source {
        let url = URL(string: baseURL + doi)!
        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(CrossRefResponse.self, from: data)
        let work = response.message

        return Source(
            title: work.title.first ?? "",
            type: .academicPaper,
            projectId: UUID(), // Set later
            addedBy: ""
        ).apply {
            $0.authors = work.author.map { "\($0.given ?? "") \($0.family)" }
            $0.doi = doi
            $0.journal = work.containerTitle?.first
            $0.publicationDate = parseDate(work.published)
            $0.url = URL(string: "https://doi.org/\(doi)")
        }
    }

    struct CrossRefResponse: Codable {
        let message: Work

        struct Work: Codable {
            let title: [String]
            let author: [Author]
            let containerTitle: [String]?
            let published: PublishedDate?

            struct Author: Codable {
                let given: String?
                let family: String
            }

            struct PublishedDate: Codable {
                let dateParts: [[Int]]
            }
        }
    }
}
```

#### ISBN Lookup (Google Books API)

```swift
final class ISBNResolver {
    let apiKey: String
    let baseURL = "https://www.googleapis.com/books/v1/volumes"

    func resolve(_ isbn: String) async throws -> Source {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: "isbn:\(isbn)"),
            URLQueryItem(name: "key", value: apiKey)
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

        guard let book = response.items?.first else {
            throw MetadataError.notFound
        }

        return Source(
            title: book.volumeInfo.title,
            type: .book,
            projectId: UUID(),
            addedBy: ""
        ).apply {
            $0.authors = book.volumeInfo.authors ?? []
            $0.isbn = isbn
            $0.publisher = book.volumeInfo.publisher
            $0.publicationDate = parseDate(book.volumeInfo.publishedDate)
            $0.abstract = book.volumeInfo.description
        }
    }
}
```

## Rate Limiting & Politeness

### Rate Limiter

```swift
final class RateLimiter {
    private var lastRequest: [String: Date] = [:]
    private let minInterval: TimeInterval = 1.0 // 1 second between requests

    func waitIfNeeded(for domain: String) async {
        if let last = lastRequest[domain] {
            let elapsed = Date().timeIntervalSince(last)
            if elapsed < minInterval {
                let delay = minInterval - elapsed
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        lastRequest[domain] = Date()
    }
}

// Usage
await rateLimiter.waitIfNeeded(for: url.host ?? "")
let content = try await scraper.scrape(url)
```

### Robots.txt Compliance

```swift
final class RobotsChecker {
    private var cache: [String: RobotsTxt] = [:]

    func isAllowed(_ url: URL) async -> Bool {
        guard let host = url.host else { return false }

        // Check cache
        if let robots = cache[host] {
            return robots.isAllowed(path: url.path)
        }

        // Fetch robots.txt
        let robotsURL = URL(string: "https://\(host)/robots.txt")!
        guard let content = try? await fetchRobotsTxt(robotsURL) else {
            return true // Allow if robots.txt not found
        }

        let robots = parseRobotsTxt(content)
        cache[host] = robots

        return robots.isAllowed(path: url.path)
    }

    private func parseRobotsTxt(_ content: String) -> RobotsTxt {
        // Parse robots.txt format
        // Implement user-agent matching, disallow/allow rules
        return RobotsTxt(content: content)
    }
}
```

## Caching Strategy

### Content Cache

```swift
final class ContentCache {
    private let cacheDirectory: URL
    private let ttl: TimeInterval = 7 * 24 * 3600 // 7 days

    func get(_ url: URL) -> Source? {
        let key = url.absoluteString.hash
        let cacheFile = cacheDirectory.appendingPathComponent("\(key).json")

        guard FileManager.default.fileExists(atPath: cacheFile.path),
              let data = try? Data(contentsOf: cacheFile),
              let cached = try? JSONDecoder().decode(CachedSource.self, from: data),
              Date().timeIntervalSince(cached.timestamp) < ttl else {
            return nil
        }

        return cached.source
    }

    func set(_ url: URL, source: Source) {
        let key = url.absoluteString.hash
        let cacheFile = cacheDirectory.appendingPathComponent("\(key).json")

        let cached = CachedSource(source: source, url: url, timestamp: Date())
        if let data = try? JSONEncoder().encode(cached) {
            try? data.write(to: cacheFile)
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory,
                                                  withIntermediateDirectories: true)
    }
}
```

## Error Handling

### Retry Logic

```swift
func fetchWithRetry<T>(_ operation: @escaping () async throws -> T,
                       maxAttempts: Int = 3) async throws -> T {
    var lastError: Error?

    for attempt in 1...maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxAttempts {
                let delay = TimeInterval(attempt * 2) // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    throw lastError!
}

// Usage
let content = try await fetchWithRetry {
    try await scraper.scrape(url)
}
```

### Error Types

```swift
enum ScrapingError: Error {
    case networkError(Error)
    case invalidURL
    case invalidEncoding
    case contentNotFound
    case rateLimitExceeded
    case blocked
    case timeout

    var userMessage: String {
        switch self {
        case .networkError:
            return "Network connection failed. Check your internet."
        case .invalidURL:
            return "Invalid URL format."
        case .contentNotFound:
            return "Could not extract content from this page."
        case .rateLimitExceeded:
            return "Too many requests. Please wait."
        case .blocked:
            return "This site blocks automated access."
        case .timeout:
            return "Request timed out. Try again."
        default:
            return "An error occurred while fetching content."
        }
    }
}
```

## Testing

### Mock Scraper

```swift
final class MockWebScraper: WebScraper {
    var mockResponses: [URL: ScrapedContent] = [:]

    override func scrape(_ url: URL) async throws -> ScrapedContent {
        if let mock = mockResponses[url] {
            return mock
        }
        throw ScrapingError.contentNotFound
    }
}

// Test
func testWebScraping() async throws {
    let scraper = MockWebScraper()
    scraper.mockResponses[testURL] = ScrapedContent(
        url: testURL,
        title: "Test Article",
        content: "Test content"
    )

    let result = try await scraper.scrape(testURL)
    XCTAssertEqual(result.title, "Test Article")
}
```

## Performance Optimization

### Parallel Processing

```swift
func processMultipleURLs(_ urls: [URL]) async throws -> [Source] {
    try await withThrowingTaskGroup(of: Source.self) { group in
        for url in urls {
            group.addTask {
                await self.rateLimiter.waitIfNeeded(for: url.host ?? "")
                return try await self.processURL(url)
            }
        }

        var sources: [Source] = []
        for try await source in group {
            sources.append(source)
        }
        return sources
    }
}
```

## References

- [SwiftSoup Documentation](https://github.com/scinfu/SwiftSoup)
- [CrossRef API](https://www.crossref.org/documentation/retrieve-metadata/)
- [Google Books API](https://developers.google.com/books)
- [Robots.txt Specification](https://www.robotstxt.org/)
