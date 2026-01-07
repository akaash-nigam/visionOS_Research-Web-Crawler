//
//  CitationFormatter.swift
//  Research Web Crawler
//
//  Citation formatting in APA, MLA, and Chicago styles
//

import Foundation

struct CitationFormatter {
    // MARK: - Citation Styles

    enum Style: String, CaseIterable {
        case apa = "APA (7th Edition)"
        case mla = "MLA (9th Edition)"
        case chicago = "Chicago (17th Edition)"

        var id: String { rawValue }
    }

    // MARK: - Format Citation

    static func format(_ source: Source, style: Style) -> String {
        switch style {
        case .apa:
            return formatAPA(source)
        case .mla:
            return formatMLA(source)
        case .chicago:
            return formatChicago(source)
        }
    }

    // MARK: - APA Format (7th Edition)

    private static func formatAPA(_ source: Source) -> String {
        var citation = ""

        // Authors
        if !source.authors.isEmpty {
            citation += formatAPAAuthors(source.authors)
            citation += ". "
        }

        // Year
        if let date = source.publicationDate {
            let year = Calendar.current.component(.year, from: date)
            citation += "(\(year)). "
        } else {
            citation += "(n.d.). "
        }

        // Title
        switch source.type {
        case .book, .bookChapter:
            citation += "*\(source.title)*"
        case .academicPaper, .article:
            citation += source.title
        default:
            citation += source.title
        }
        citation += ". "

        // Publication details
        switch source.type {
        case .academicPaper, .article:
            if let journal = source.journal {
                citation += "*\(journal)*"
                if let volume = source.volume {
                    citation += ", *\(volume)*"
                }
                if let issue = source.issue {
                    citation += "(\(issue))"
                }
                if let pages = source.pages {
                    citation += ", \(pages)"
                }
                citation += ". "
            }

        case .book:
            if let publisher = source.publisher {
                citation += "\(publisher). "
            }

        case .bookChapter:
            if let publisher = source.publisher {
                citation += "In *\(publisher)*. "
            }

        default:
            break
        }

        // DOI or URL
        if let doi = source.doi {
            citation += "https://doi.org/\(doi)"
        } else if let url = source.url {
            citation += url
        }

        return citation
    }

    private static func formatAPAAuthors(_ authors: [String]) -> String {
        if authors.isEmpty { return "" }

        if authors.count == 1 {
            return formatAuthorLastFirst(authors[0])
        } else if authors.count == 2 {
            return "\(formatAuthorLastFirst(authors[0])), & \(formatAuthorLastFirst(authors[1]))"
        } else {
            let formatted = authors.prefix(20).map { formatAuthorLastFirst($0) }
            return formatted.joined(separator: ", ")
        }
    }

    // MARK: - MLA Format (9th Edition)

    private static func formatMLA(_ source: Source) -> String {
        var citation = ""

        // Authors
        if !source.authors.isEmpty {
            if source.authors.count == 1 {
                citation += formatAuthorLastFirst(source.authors[0])
            } else if source.authors.count == 2 {
                citation += "\(formatAuthorLastFirst(source.authors[0])), and \(source.authors[1])"
            } else {
                citation += "\(formatAuthorLastFirst(source.authors[0])), et al"
            }
            citation += ". "
        }

        // Title
        switch source.type {
        case .book:
            citation += "*\(source.title)*"
        case .academicPaper, .article:
            citation += "\"\(source.title).\""
        default:
            citation += "\"\(source.title).\""
        }
        citation += " "

        // Container/Publication
        if let journal = source.journal {
            citation += "*\(journal)*, "
            if let volume = source.volume {
                citation += "vol. \(volume), "
            }
            if let issue = source.issue {
                citation += "no. \(issue), "
            }
        }

        // Date
        if let date = source.publicationDate {
            let year = Calendar.current.component(.year, from: date)
            citation += "\(year), "
        }

        // Pages
        if let pages = source.pages {
            citation += "pp. \(pages). "
        }

        // DOI or URL
        if let doi = source.doi {
            citation += "https://doi.org/\(doi)."
        } else if let url = source.url {
            citation += url + "."
        }

        return citation
    }

    // MARK: - Chicago Format (17th Edition)

    private static func formatChicago(_ source: Source) -> String {
        var citation = ""

        // Authors
        if !source.authors.isEmpty {
            citation += formatChicagoAuthors(source.authors)
            citation += ". "
        }

        // Title
        switch source.type {
        case .book:
            citation += "*\(source.title)*"
        case .academicPaper, .article:
            citation += "\"\(source.title).\""
        default:
            citation += "\"\(source.title).\""
        }
        citation += " "

        // Publication details
        if let journal = source.journal {
            citation += "*\(journal)* "
            if let volume = source.volume {
                citation += "\(volume), "
            }
            if let issue = source.issue {
                citation += "no. \(issue) "
            }
        }

        // Date
        if let date = source.publicationDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            citation += "(\(formatter.string(from: date))): "
        }

        // Pages
        if let pages = source.pages {
            citation += "\(pages). "
        }

        // DOI or URL
        if let doi = source.doi {
            citation += "https://doi.org/\(doi)."
        } else if let url = source.url {
            citation += url + "."
        }

        return citation
    }

    private static func formatChicagoAuthors(_ authors: [String]) -> String {
        if authors.isEmpty { return "" }

        if authors.count == 1 {
            return formatAuthorLastFirst(authors[0])
        } else if authors.count == 2 {
            return "\(formatAuthorLastFirst(authors[0])), and \(authors[1])"
        } else if authors.count == 3 {
            return "\(formatAuthorLastFirst(authors[0])), \(authors[1]), and \(authors[2])"
        } else {
            return "\(formatAuthorLastFirst(authors[0])) et al."
        }
    }

    // MARK: - Helper Methods

    private static func formatAuthorLastFirst(_ name: String) -> String {
        let components = name.split(separator: " ")
        guard components.count >= 2 else { return name }

        let lastName = components.last!
        let firstNames = components.dropLast().joined(separator: " ")

        // Format: Last, F.
        let initials = firstNames.split(separator: " ")
            .map { String($0.prefix(1)) + "." }
            .joined(separator: " ")

        return "\(lastName), \(initials)"
    }

    // MARK: - Bibliography Generation

    static func generateBibliography(
        sources: [Source],
        style: Style,
        sortByAuthor: Bool = true
    ) -> String {
        var sorted = sources

        if sortByAuthor {
            sorted.sort { source1, source2 in
                let author1 = source1.authors.first ?? source1.title
                let author2 = source2.authors.first ?? source2.title
                return author1.localizedCompare(author2) == .orderedAscending
            }
        }

        let citations = sorted.map { format($0, style: style) }
        return citations.joined(separator: "\n\n")
    }

    // MARK: - Export Formats

    static func exportToPlainText(
        sources: [Source],
        style: Style,
        includeNotes: Bool = false
    ) -> String {
        var output = "Bibliography - \(style.rawValue)\n"
        output += String(repeating: "=", count: 50)
        output += "\n\n"

        output += generateBibliography(sources: sources, style: style)

        if includeNotes {
            output += "\n\n"
            output += String(repeating: "=", count: 50)
            output += "\nNotes\n"
            output += String(repeating: "=", count: 50)
            output += "\n\n"

            for source in sources {
                if let notes = source.notes, !notes.isEmpty {
                    output += "\(source.title)\n"
                    output += "---\n"
                    output += "\(notes)\n\n"
                }
            }
        }

        return output
    }

    static func exportToBibTeX(_ sources: [Source]) -> String {
        var output = ""

        for source in sources {
            let key = generateBibTeXKey(source)

            switch source.type {
            case .academicPaper:
                output += "@article{\(key),\n"
            case .book:
                output += "@book{\(key),\n"
            case .bookChapter:
                output += "@inbook{\(key),\n"
            default:
                output += "@misc{\(key),\n"
            }

            output += "  title = {\(source.title)},\n"

            if !source.authors.isEmpty {
                output += "  author = {\(source.authors.joined(separator: " and "))},\n"
            }

            if let date = source.publicationDate {
                let year = Calendar.current.component(.year, from: date)
                output += "  year = {\(year)},\n"
            }

            if let journal = source.journal {
                output += "  journal = {\(journal)},\n"
            }

            if let volume = source.volume {
                output += "  volume = {\(volume)},\n"
            }

            if let pages = source.pages {
                output += "  pages = {\(pages)},\n"
            }

            if let doi = source.doi {
                output += "  doi = {\(doi)},\n"
            }

            if let url = source.url {
                output += "  url = {\(url)},\n"
            }

            output += "}\n\n"
        }

        return output
    }

    private static func generateBibTeXKey(_ source: Source) -> String {
        let author = source.authors.first?.split(separator: " ").last.map(String.init) ?? "Unknown"
        let year = source.publicationDate.map { Calendar.current.component(.year, from: $0) } ?? 0
        let titleWord = source.title.split(separator: " ").first.map(String.init) ?? "Title"

        return "\(author)\(year)\(titleWord)".replacingOccurrences(of: " ", with: "")
    }
}
