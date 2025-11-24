//
//  WebScraperTests.swift
//  Research Web Crawler Tests
//
//  Unit tests for web scraping functionality
//

import XCTest
@testable import ResearchWebCrawler

@MainActor
final class WebScraperTests: XCTestCase {
    var webScraper: WebScraper!

    override func setUp() async throws {
        webScraper = WebScraper()
    }

    override func tearDown() async throws {
        webScraper = nil
    }

    // MARK: - Initialization Tests

    func testWebScraperInitialization() {
        XCTAssertNotNil(webScraper)
    }

    // MARK: - Metadata Extraction Tests
    // Note: These tests require network access and live URLs
    // Should be run manually or in CI with network access

    func testExtractOpenGraphMetadata() async throws {
        // This would test against a real URL
        // Example: let content = try await webScraper.scrape(url: "https://example.com/article")
        // XCTAssertNotNil(content.title)

        // For now, we'll skip this in unit tests
        throw XCTSkip("Requires network access")
    }

    func testExtractAcademicMetadata() async throws {
        throw XCTSkip("Requires network access to academic site")
    }

    // MARK: - Error Handling Tests

    func testInvalidURL() async {
        do {
            _ = try await webScraper.scrape(url: "not-a-valid-url")
            XCTFail("Should throw invalid URL error")
        } catch let error as WebScraperError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Wrong error type")
        }
    }

    func testEmptyURL() async {
        do {
            _ = try await webScraper.scrape(url: "")
            XCTFail("Should throw invalid URL error")
        } catch let error as WebScraperError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Wrong error type")
        }
    }

    // MARK: - Rate Limiter Tests

    func testRateLimiterWaits() async {
        let rateLimiter = RateLimiter()

        let startTime = Date()

        // First request
        try? await rateLimiter.waitIfNeeded(for: "example.com")

        // Second request (should wait)
        try? await rateLimiter.waitIfNeeded(for: "example.com")

        let elapsed = Date().timeIntervalSince(startTime)

        // Should have waited at least 1 second
        XCTAssertGreaterThanOrEqual(elapsed, 1.0)
    }

    func testRateLimiterDifferentDomains() async {
        let rateLimiter = RateLimiter()

        let startTime = Date()

        // Different domains should not wait
        try? await rateLimiter.waitIfNeeded(for: "example1.com")
        try? await rateLimiter.waitIfNeeded(for: "example2.com")

        let elapsed = Date().timeIntervalSince(startTime)

        // Should be nearly instant (< 0.1s)
        XCTAssertLessThan(elapsed, 0.1)
    }

    // MARK: - Content Extraction Tests
    // These would test HTML parsing logic

    func testHTMLParsingBasic() {
        // Would test SwiftSoup parsing
        // Example HTML snippet tests
        XCTAssertTrue(true) // Placeholder
    }
}

// MARK: - Integration Tests

extension WebScraperTests {
    // Integration test with real URLs (run manually)
    func testScrapeWikipediaArticle() async throws {
        throw XCTSkip("Integration test - requires network")

        // let content = try await webScraper.scrape(url: "https://en.wikipedia.org/wiki/Swift_(programming_language)")
        // XCTAssertFalse(content.title?.isEmpty ?? true)
        // XCTAssertFalse(content.content.isEmpty)
    }

    func testScrapeArXivPaper() async throws {
        throw XCTSkip("Integration test - requires network")

        // Test scraping academic paper from arXiv
        // Should extract DOI, authors, abstract
    }
}
