# Citation & Bibliography Engine Design

## Document Info
- **Version**: 1.0
- **Last Updated**: 2025-11-24
- **Status**: Draft

## Overview

Design for citation formatting and bibliography generation, supporting multiple citation styles (APA, MLA, Chicago, etc.) and export formats (BibTeX, RIS, Word).

## Citation Engine Architecture

### Core Components

```swift
final class CitationEngine {
    let styleManager: CitationStyleManager
    let formatter: CitationFormatter
    let exporter: BibliographyExporter
    let duplicateDetector: DuplicateDetector

    func formatCitation(_ source: Source, style: CitationStyle) -> String {
        let template = styleManager.getTemplate(for: style, type: source.type)
        return formatter.format(source, using: template)
    }

    func generateBibliography(_ sources: [Source], style: CitationStyle,
                              sortBy: SortOrder = .author) -> String {
        let sorted = sortSources(sources, by: sortBy)
        return sorted.map { formatCitation($0, style: style) }.joined(separator: "\n\n")
    }
}
```

### Citation Styles

#### APA 7th Edition

```swift
struct APAFormatter {
    func format(_ source: Source) -> String {
        switch source.type {
        case .academicPaper, .article:
            return formatJournalArticle(source)
        case .book:
            return formatBook(source)
        case .bookChapter:
            return formatBookChapter(source)
        case .website:
            return formatWebsite(source)
        default:
            return formatGeneric(source)
        }
    }

    private func formatJournalArticle(_ source: Source) -> String {
        // Authors (Year). Title. Journal, Volume(Issue), pages. DOI

        let authors = formatAuthors(source.authors)
        let year = source.publicationDate?.year ?? "n.d."
        let title = source.title.capitalizingFirstLetter()
        let journal = source.journal ?? ""
        let volume = source.volume ?? ""
        let issue = source.issue.map { "(\($0))" } ?? ""
        let pages = source.pages ?? ""
        let doi = source.doi.map { "https://doi.org/\($0)" } ?? source.url?.absoluteString ?? ""

        return "\(authors) (\(year)). \(title). \(journal), \(volume)\(issue), \(pages). \(doi)"
    }

    private func formatBook(_ source: Source) -> String {
        // Authors (Year). Title (Edition). Publisher.

        let authors = formatAuthors(source.authors)
        let year = source.publicationDate?.year ?? "n.d."
        let title = source.title.italicized()
        let publisher = source.publisher ?? ""

        return "\(authors) (\(year)). \(title). \(publisher)."
    }

    private func formatAuthors(_ authors: [String], apaStyle: Bool = true) -> String {
        guard !authors.isEmpty else { return "" }

        if authors.count == 1 {
            return formatAuthorName(authors[0])
        } else if authors.count == 2 {
            return "\(formatAuthorName(authors[0])) & \(formatAuthorName(authors[1]))"
        } else if authors.count <= 20 {
            let formatted = authors.prefix(authors.count - 1).map { formatAuthorName($0) }
            return formatted.joined(separator: ", ") + ", & \(formatAuthorName(authors.last!))"
        } else {
            // 21+ authors: list first 19, then "...", then last
            let first19 = authors.prefix(19).map { formatAuthorName($0) }
            return first19.joined(separator: ", ") + ", ... \(formatAuthorName(authors.last!))"
        }
    }

    private func formatAuthorName(_ name: String) -> String {
        // Convert "John Smith" to "Smith, J."
        let components = name.components(separatedBy: " ")
        guard components.count >= 2 else { return name }

        let lastName = components.last!
        let firstInitial = String(components.first!.prefix(1))

        return "\(lastName), \(firstInitial)."
    }
}
```

#### MLA 9th Edition

```swift
struct MLAFormatter {
    func format(_ source: Source) -> String {
        switch source.type {
        case .academicPaper, .article:
            return formatArticle(source)
        case .book:
            return formatBook(source)
        case .website:
            return formatWebsite(source)
        default:
            return formatGeneric(source)
        }
    }

    private func formatArticle(_ source: Source) -> String {
        // Authors. "Title." Journal, vol. X, no. Y, Year, pp. A-B.

        let authors = formatAuthors(source.authors)
        let title = "\"\(source.title)\""
        let journal = source.journal ?? ""
        let volume = source.volume.map { "vol. \($0)" } ?? ""
        let issue = source.issue.map { "no. \($0)" } ?? ""
        let year = source.publicationDate?.year ?? ""
        let pages = source.pages.map { "pp. \($0)" } ?? ""

        let parts = [authors, title, journal, volume, issue, year, pages]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        return parts + "."
    }

    private func formatAuthors(_ authors: [String]) -> String {
        guard !authors.isEmpty else { return "" }

        if authors.count == 1 {
            return formatAuthorName(authors[0])
        } else if authors.count == 2 {
            return "\(formatAuthorName(authors[0])) and \(formatAuthorName(authors[1], reverse: false))"
        } else {
            return "\(formatAuthorName(authors[0])), et al"
        }
    }

    private func formatAuthorName(_ name: String, reverse: Bool = true) -> String {
        let components = name.components(separatedBy: " ")
        guard components.count >= 2 else { return name }

        if reverse {
            let lastName = components.last!
            let firstName = components.dropLast().joined(separator: " ")
            return "\(lastName), \(firstName)"
        } else {
            return name
        }
    }
}
```

#### Chicago 17th Edition

```swift
struct ChicagoFormatter {
    func format(_ source: Source, notes: Bool = false) -> String {
        // Chicago has two systems: Notes-Bibliography and Author-Date
        if notes {
            return formatNotesBibliography(source)
        } else {
            return formatAuthorDate(source)
        }
    }

    private func formatNotesBibliography(_ source: Source) -> String {
        // Authors. Title. Publisher, Year.

        let authors = formatAuthors(source.authors)
        let title = source.title.italicized()
        let publisher = source.publisher ?? ""
        let year = source.publicationDate?.year ?? ""

        return "\(authors). \(title). \(publisher), \(year)."
    }

    private func formatAuthors(_ authors: [String]) -> String {
        // Similar to MLA but different punctuation
        guard !authors.isEmpty else { return "" }

        if authors.count == 1 {
            return authors[0]
        } else if authors.count <= 3 {
            return authors.dropLast().joined(separator: ", ") + ", and \(authors.last!)"
        } else {
            return "\(authors[0]) et al."
        }
    }
}
```

### Citation Style Language (CSL) Support

For comprehensive style support, implement CSL processor:

```swift
final class CSLProcessor {
    func loadStyle(_ styleName: String) throws -> CSLStyle {
        // Load CSL file (XML) from bundle
        guard let url = Bundle.main.url(forResource: styleName, withExtension: "csl") else {
            throw CitationError.styleNotFound
        }

        let data = try Data(contentsOf: url)
        return try CSLParser().parse(data)
    }

    func format(_ source: Source, using style: CSLStyle) -> String {
        // Process CSL template
        // Replace variables with source data
        return processTemplate(style.bibliography, data: source)
    }

    struct CSLStyle {
        let id: String
        let title: String
        let bibliography: CSLTemplate
        let citation: CSLTemplate
    }

    struct CSLTemplate {
        let layout: String
        let variables: [String: CSLVariable]
    }
}
```

## Bibliography Export

### Export Formats

#### BibTeX

```swift
struct BibTeXExporter {
    func export(_ sources: [Source]) -> String {
        sources.map { exportEntry($0) }.joined(separator: "\n\n")
    }

    private func exportEntry(_ source: Source) -> String {
        let entryType = mapToBibTeXType(source.type)
        let key = generateCiteKey(source)

        var fields: [String] = []

        if !source.authors.isEmpty {
            fields.append("  author = {\(source.authors.joined(separator: " and "))}")
        }

        fields.append("  title = {{\(source.title)}}")

        if let year = source.publicationDate?.year {
            fields.append("  year = {\(year)}")
        }

        if let journal = source.journal {
            fields.append("  journal = {\(journal)}")
        }

        if let volume = source.volume {
            fields.append("  volume = {\(volume)}")
        }

        if let pages = source.pages {
            fields.append("  pages = {\(pages)}")
        }

        if let doi = source.doi {
            fields.append("  doi = {\(doi)}")
        }

        return """
        @\(entryType){\(key),
        \(fields.joined(separator: ",\n"))
        }
        """
    }

    private func mapToBibTeXType(_ type: SourceType) -> String {
        switch type {
        case .academicPaper: return "article"
        case .book: return "book"
        case .bookChapter: return "inbook"
        case .thesis: return "phdthesis"
        default: return "misc"
        }
    }

    private func generateCiteKey(_ source: Source) -> String {
        let author = source.authors.first?.components(separatedBy: " ").last ?? "Unknown"
        let year = source.publicationDate?.year ?? 0
        return "\(author.lowercased())\(year)"
    }
}
```

#### RIS (Research Information Systems)

```swift
struct RISExporter {
    func export(_ sources: [Source]) -> String {
        sources.map { exportEntry($0) }.joined(separator: "\n\n")
    }

    private func exportEntry(_ source: Source) -> String {
        var lines: [String] = []

        // Type
        lines.append("TY  - \(mapToRISType(source.type))")

        // Authors
        for author in source.authors {
            lines.append("AU  - \(author)")
        }

        // Title
        lines.append("TI  - \(source.title)")

        // Publication year
        if let year = source.publicationDate?.year {
            lines.append("PY  - \(year)")
        }

        // Journal
        if let journal = source.journal {
            lines.append("JO  - \(journal)")
        }

        // Volume
        if let volume = source.volume {
            lines.append("VL  - \(volume)")
        }

        // Issue
        if let issue = source.issue {
            lines.append("IS  - \(issue)")
        }

        // Pages
        if let pages = source.pages {
            lines.append("SP  - \(pages.components(separatedBy: "-").first ?? "")")
            if pages.contains("-") {
                lines.append("EP  - \(pages.components(separatedBy: "-").last ?? "")")
            }
        }

        // DOI
        if let doi = source.doi {
            lines.append("DO  - \(doi)")
        }

        // URL
        if let url = source.url {
            lines.append("UR  - \(url.absoluteString)")
        }

        // End of record
        lines.append("ER  -")

        return lines.joined(separator: "\n")
    }

    private func mapToRISType(_ type: SourceType) -> String {
        switch type {
        case .academicPaper: return "JOUR"
        case .book: return "BOOK"
        case .bookChapter: return "CHAP"
        case .thesis: return "THES"
        case .website: return "ELEC"
        default: return "GEN"
        }
    }
}
```

#### Word Document (.docx)

```swift
import UniformTypeIdentifiers

final class WordExporter {
    func export(_ sources: [Source], style: CitationStyle) throws -> URL {
        let bibliography = CitationEngine.shared.generateBibliography(sources, style: style)

        // Create simple Word document
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Bibliography</title>
        </head>
        <body>
            <h1>Bibliography</h1>
            <div style="margin-left: 0.5in; text-indent: -0.5in;">
                \(bibliography.replacingOccurrences(of: "\n\n", with: "</p><p>"))
            </div>
        </body>
        </html>
        """

        // Convert HTML to Word (using NSAttributedString)
        guard let data = html.data(using: .utf8) else {
            throw ExportError.conversionFailed
        }

        let attributedString = try NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )

        let docxData = try attributedString.data(
            from: NSRange(location: 0, length: attributedString.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.docx]
        )

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("bibliography.docx")
        try docxData.write(to: tempURL)

        return tempURL
    }
}
```

## Duplicate Detection

```swift
final class DuplicateDetector {
    func findDuplicates(in sources: [Source]) -> [(Source, Source)] {
        var duplicates: [(Source, Source)] = []

        for i in 0..<sources.count {
            for j in (i+1)..<sources.count {
                if areDuplicates(sources[i], sources[j]) {
                    duplicates.append((sources[i], sources[j]))
                }
            }
        }

        return duplicates
    }

    func areDuplicates(_ s1: Source, _ s2: Source) -> Bool {
        // 1. Exact DOI match
        if let doi1 = s1.doi, let doi2 = s2.doi, !doi1.isEmpty, doi1 == doi2 {
            return true
        }

        // 2. Exact ISBN match
        if let isbn1 = s1.isbn, let isbn2 = s2.isbn, !isbn1.isEmpty, isbn1 == isbn2 {
            return true
        }

        // 3. Fuzzy title + author match
        let titleSimilarity = s1.title.similarity(to: s2.title)
        let authorMatch = !Set(s1.authors).isDisjoint(with: s2.authors)

        if titleSimilarity > 0.9 && authorMatch {
            return true
        }

        // 4. Same URL
        if let url1 = s1.url, let url2 = s2.url, url1 == url2 {
            return true
        }

        return false
    }
}

extension String {
    func similarity(to other: String) -> Double {
        // Levenshtein distance-based similarity
        let distance = levenshteinDistance(to: other)
        let maxLength = max(self.count, other.count)
        return 1.0 - Double(distance) / Double(maxLength)
    }

    func levenshteinDistance(to other: String) -> Int {
        let m = self.count
        let n = other.count
        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = self[self.index(self.startIndex, offsetBy: i - 1)] ==
                           other[other.index(other.startIndex, offsetBy: j - 1)] ? 0 : 1

                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        return matrix[m][n]
    }
}
```

## Testing

```swift
class CitationFormatterTests: XCTestCase {
    func testAPAJournalArticle() {
        let source = Source(
            title: "Climate Change Impacts",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )
        source.authors = ["John Smith", "Jane Doe"]
        source.publicationDate = Date(year: 2023)
        source.journal = "Nature"
        source.volume = "45"
        source.issue = "2"
        source.pages = "123-145"
        source.doi = "10.1038/nature12345"

        let citation = APAFormatter().format(source)

        XCTAssertEqual(
            citation,
            "Smith, J. & Doe, J. (2023). Climate change impacts. Nature, 45(2), 123-145. https://doi.org/10.1038/nature12345"
        )
    }

    func testBibTeXExport() {
        let source = Source(
            title: "Test Article",
            type: .academicPaper,
            projectId: UUID(),
            addedBy: "test"
        )
        source.authors = ["John Smith"]
        source.publicationDate = Date(year: 2023)

        let bibtex = BibTeXExporter().export([source])

        XCTAssertTrue(bibtex.contains("@article{smith2023"))
        XCTAssertTrue(bibtex.contains("author = {John Smith}"))
    }

    func testDuplicateDetection() {
        let s1 = Source(title: "Climate Change", type: .article, projectId: UUID(), addedBy: "test")
        s1.doi = "10.1234/test"

        let s2 = Source(title: "Climate Change Effects", type: .article, projectId: UUID(), addedBy: "test")
        s2.doi = "10.1234/test"

        XCTAssertTrue(DuplicateDetector().areDuplicates(s1, s2))
    }
}
```

## References

- [APA Style Guide](https://apastyle.apa.org/)
- [MLA Handbook](https://style.mla.org/)
- [Chicago Manual of Style](https://www.chicagomanualofstyle.org/)
- [Citation Style Language](https://citationstyles.org/)
- [BibTeX Format](http://www.bibtex.org/Format/)
- [RIS Format Specification](https://en.wikipedia.org/wiki/RIS_(file_format))
