//
//  CitationFormatterTests.swift
//  Research Web Crawler Tests
//
//  Unit tests for citation formatting
//

import XCTest
@testable import ResearchWebCrawler

final class CitationFormatterTests: XCTestCase {
    var testSource: Source!
    var testProject: Project!

    override func setUp() {
        testProject = Project(name: "Test Project", ownerId: "test")
        testSource = Source(
            title: "Understanding Swift Concurrency",
            type: .academicPaper,
            projectId: testProject.id,
            addedBy: "test"
        )
        testSource.authors = ["John Smith", "Jane Doe"]
        testSource.journal = "Journal of Programming Languages"
        testSource.volume = "45"
        testSource.issue = "3"
        testSource.pages = "123-145"
        testSource.doi = "10.1234/jpl.2023.001"
        testSource.publicationDate = createDate(year: 2023, month: 3, day: 15)
    }

    override func tearDown() {
        testSource = nil
        testProject = nil
    }

    // MARK: - APA Tests

    func testAPAFormatBasic() {
        let citation = CitationFormatter.format(testSource, style: .apa)

        XCTAssertTrue(citation.contains("Smith, J."))
        XCTAssertTrue(citation.contains("Doe, J."))
        XCTAssertTrue(citation.contains("(2023)"))
        XCTAssertTrue(citation.contains("Understanding Swift Concurrency"))
        XCTAssertTrue(citation.contains("*Journal of Programming Languages*"))
        XCTAssertTrue(citation.contains("*45*"))
        XCTAssertTrue(citation.contains("(3)"))
        XCTAssertTrue(citation.contains("123-145"))
        XCTAssertTrue(citation.contains("https://doi.org/10.1234/jpl.2023.001"))
    }

    func testAPASingleAuthor() {
        testSource.authors = ["John Smith"]

        let citation = CitationFormatter.format(testSource, style: .apa)

        XCTAssertTrue(citation.contains("Smith, J."))
        XCTAssertFalse(citation.contains("&"))
    }

    func testAPATwoAuthors() {
        testSource.authors = ["John Smith", "Jane Doe"]

        let citation = CitationFormatter.format(testSource, style: .apa)

        XCTAssertTrue(citation.contains("&"))
    }

    func testAPANoDate() {
        testSource.publicationDate = nil

        let citation = CitationFormatter.format(testSource, style: .apa)

        XCTAssertTrue(citation.contains("(n.d.)"))
    }

    func testAPABook() {
        testSource.sourceType = "book"
        testSource.publisher = "Academic Press"

        let citation = CitationFormatter.format(testSource, style: .apa)

        XCTAssertTrue(citation.contains("*Understanding Swift Concurrency*"))
        XCTAssertTrue(citation.contains("Academic Press"))
    }

    // MARK: - MLA Tests

    func testMLAFormatBasic() {
        let citation = CitationFormatter.format(testSource, style: .mla)

        XCTAssertTrue(citation.contains("Smith, J."))
        XCTAssertTrue(citation.contains("and"))
        XCTAssertTrue(citation.contains("\"Understanding Swift Concurrency.\""))
        XCTAssertTrue(citation.contains("*Journal of Programming Languages*"))
        XCTAssertTrue(citation.contains("vol. 45"))
        XCTAssertTrue(citation.contains("no. 3"))
        XCTAssertTrue(citation.contains("2023"))
        XCTAssertTrue(citation.contains("pp. 123-145"))
    }

    func testMLAThreeOrMoreAuthors() {
        testSource.authors = ["John Smith", "Jane Doe", "Bob Johnson"]

        let citation = CitationFormatter.format(testSource, style: .mla)

        XCTAssertTrue(citation.contains("et al"))
    }

    func testMLABook() {
        testSource.sourceType = "book"

        let citation = CitationFormatter.format(testSource, style: .mla)

        XCTAssertTrue(citation.contains("*Understanding Swift Concurrency*"))
        XCTAssertFalse(citation.contains("\""))
    }

    // MARK: - Chicago Tests

    func testChicagoFormatBasic() {
        let citation = CitationFormatter.format(testSource, style: .chicago)

        XCTAssertTrue(citation.contains("Smith, J."))
        XCTAssertTrue(citation.contains("\"Understanding Swift Concurrency.\""))
        XCTAssertTrue(citation.contains("*Journal of Programming Languages*"))
        XCTAssertTrue(citation.contains("45"))
        XCTAssertTrue(citation.contains("no. 3"))
        XCTAssertTrue(citation.contains("123-145"))
    }

    func testChicagoEtAl() {
        testSource.authors = ["John Smith", "Jane Doe", "Bob Johnson", "Alice Brown"]

        let citation = CitationFormatter.format(testSource, style: .chicago)

        XCTAssertTrue(citation.contains("et al."))
    }

    // MARK: - Bibliography Tests

    func testBibliographyGeneration() {
        let source2 = Source(
            title: "Advanced Topics in Programming",
            type: .book,
            projectId: testProject.id,
            addedBy: "test"
        )
        source2.authors = ["Alice Brown"]
        source2.publicationDate = createDate(year: 2022, month: 1, day: 1)

        let bibliography = CitationFormatter.generateBibliography(
            sources: [testSource, source2],
            style: .apa,
            sortByAuthor: true
        )

        // Should be sorted alphabetically
        let lines = bibliography.components(separatedBy: "\n\n")
        XCTAssertEqual(lines.count, 2)

        // Alice Brown should come before John Smith
        XCTAssertTrue(lines[0].contains("Brown"))
        XCTAssertTrue(lines[1].contains("Smith"))
    }

    // MARK: - Export Tests

    func testExportToPlainText() {
        let export = CitationFormatter.exportToPlainText(
            sources: [testSource],
            style: .apa,
            includeNotes: false
        )

        XCTAssertTrue(export.contains("Bibliography - APA"))
        XCTAssertTrue(export.contains("Understanding Swift Concurrency"))
    }

    func testExportWithNotes() {
        testSource.notes = "This is an important paper about concurrency."

        let export = CitationFormatter.exportToPlainText(
            sources: [testSource],
            style: .apa,
            includeNotes: true
        )

        XCTAssertTrue(export.contains("Notes"))
        XCTAssertTrue(export.contains("This is an important paper"))
    }

    func testExportToBibTeX() {
        let bibtex = CitationFormatter.exportToBibTeX([testSource])

        XCTAssertTrue(bibtex.contains("@article{"))
        XCTAssertTrue(bibtex.contains("title = {Understanding Swift Concurrency}"))
        XCTAssertTrue(bibtex.contains("author = {John Smith and Jane Doe}"))
        XCTAssertTrue(bibtex.contains("year = {2023}"))
        XCTAssertTrue(bibtex.contains("journal = {Journal of Programming Languages}"))
        XCTAssertTrue(bibtex.contains("volume = {45}"))
        XCTAssertTrue(bibtex.contains("pages = {123-145}"))
        XCTAssertTrue(bibtex.contains("doi = {10.1234/jpl.2023.001}"))
    }

    func testBibTeXBookEntry() {
        testSource.sourceType = "book"
        testSource.publisher = "Academic Press"

        let bibtex = CitationFormatter.exportToBibTeX([testSource])

        XCTAssertTrue(bibtex.contains("@book{"))
    }

    // MARK: - Edge Cases

    func testEmptyAuthors() {
        testSource.authors = []

        let citation = CitationFormatter.format(testSource, style: .apa)

        // Should not crash, should just skip authors section
        XCTAssertTrue(citation.contains("Understanding Swift Concurrency"))
    }

    func testMissingMetadata() {
        testSource.journal = nil
        testSource.volume = nil
        testSource.issue = nil
        testSource.pages = nil
        testSource.doi = nil

        let citation = CitationFormatter.format(testSource, style: .apa)

        // Should still format basic info
        XCTAssertTrue(citation.contains("Smith, J."))
        XCTAssertTrue(citation.contains("(2023)"))
        XCTAssertTrue(citation.contains("Understanding Swift Concurrency"))
    }

    // MARK: - Helper

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}
