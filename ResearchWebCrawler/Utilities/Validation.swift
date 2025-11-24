//
//  Validation.swift
//  Research Web Crawler
//
//  Data validation utilities
//

import Foundation

enum ValidationError: LocalizedError {
    case emptyTitle
    case titleTooLong(maxLength: Int)
    case invalidURL
    case invalidDOI
    case invalidISBN
    case tooManyAuthors(maxCount: Int)
    case tooManyTags(maxCount: Int)
    case tagTooLong(maxLength: Int)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Title cannot be empty"
        case .titleTooLong(let max):
            return "Title cannot exceed \(max) characters"
        case .invalidURL:
            return "Invalid URL format"
        case .invalidDOI:
            return "Invalid DOI format"
        case .invalidISBN:
            return "Invalid ISBN format"
        case .tooManyAuthors(let max):
            return "Cannot have more than \(max) authors"
        case .tooManyTags(let max):
            return "Cannot have more than \(max) tags"
        case .tagTooLong(let max):
            return "Tag cannot exceed \(max) characters"
        }
    }
}

// MARK: - Project Validation

extension Project {
    func validate() throws {
        // Name validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard name.count <= 200 else {
            throw ValidationError.titleTooLong(maxLength: 200)
        }

        // Counts should not be negative
        assert(sourceCount >= 0, "Source count cannot be negative")
        assert(connectionCount >= 0, "Connection count cannot be negative")
    }
}

// MARK: - Source Validation

extension Source {
    func validate() throws {
        // Title validation
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard title.count <= 500 else {
            throw ValidationError.titleTooLong(maxLength: 500)
        }

        // Authors validation
        guard authors.count <= 50 else {
            throw ValidationError.tooManyAuthors(maxCount: 50)
        }

        // Tags validation
        guard tags.count <= 50 else {
            throw ValidationError.tooManyTags(maxCount: 50)
        }

        for tag in tags {
            guard tag.count <= 30 else {
                throw ValidationError.tagTooLong(maxLength: 30)
            }
        }

        // URL validation (if present)
        if let urlString = url, !urlString.isEmpty {
            guard URL(string: urlString) != nil else {
                throw ValidationError.invalidURL
            }
        }

        // DOI validation (if present)
        if let doi = doi, !doi.isEmpty {
            try validateDOI(doi)
        }

        // ISBN validation (if present)
        if let isbn = isbn, !isbn.isEmpty {
            try validateISBN(isbn)
        }
    }

    private func validateDOI(_ doi: String) throws {
        // DOI format: 10.xxxx/xxxxx
        let doiPattern = #"^10\.\d{4,9}/[-._;()/:A-Z0-9]+$"#
        let regex = try? NSRegularExpression(pattern: doiPattern, options: .caseInsensitive)
        let range = NSRange(doi.startIndex..., in: doi)

        guard regex?.firstMatch(in: doi, range: range) != nil else {
            throw ValidationError.invalidDOI
        }
    }

    private func validateISBN(_ isbn: String) throws {
        // Remove hyphens and spaces
        let cleanedISBN = isbn.replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")

        // ISBN-10 or ISBN-13
        guard cleanedISBN.count == 10 || cleanedISBN.count == 13 else {
            throw ValidationError.invalidISBN
        }

        // Check if all characters are digits (except last char of ISBN-10 can be X)
        let allowedCharacters = CharacterSet.decimalDigits
        let isbnSet = CharacterSet(charactersIn: cleanedISBN.dropLast())

        guard isbnSet.isSubset(of: allowedCharacters) else {
            throw ValidationError.invalidISBN
        }

        // Last character can be X for ISBN-10
        if cleanedISBN.count == 10 {
            let lastChar = cleanedISBN.last!
            guard lastChar.isNumber || lastChar == "X" || lastChar == "x" else {
                throw ValidationError.invalidISBN
            }
        }
    }
}

// MARK: - Collection Validation

extension Collection {
    func validate() throws {
        // Name validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ValidationError.emptyTitle
        }

        guard name.count <= 100 else {
            throw ValidationError.titleTooLong(maxLength: 100)
        }
    }
}

// MARK: - Connection Validation

extension Connection {
    func validate() throws {
        // Ensure fromSourceId != toSourceId (no self-loops, unless explicitly allowed)
        // Note: We actually allow self-loops in the graph, so this is commented out
        // guard fromSourceId != toSourceId else {
        //     throw ValidationError.custom("Source cannot connect to itself")
        // }

        // Annotation length validation (if present)
        if let annotation = annotation {
            guard annotation.count <= 500 else {
                throw ValidationError.titleTooLong(maxLength: 500)
            }
        }
    }
}

// MARK: - Validation Utilities

struct Validator {
    /// Validates a URL string
    static func isValidURL(_ urlString: String) -> Bool {
        guard !urlString.isEmpty else { return true } // Empty is valid (optional field)

        guard let url = URL(string: urlString) else { return false }

        // Check for valid scheme
        guard let scheme = url.scheme?.lowercased() else { return false }
        return ["http", "https", "file"].contains(scheme)
    }

    /// Validates an email address
    static func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(email.startIndex..., in: email)
        return regex?.firstMatch(in: email, range: range) != nil
    }

    /// Sanitizes user input by trimming whitespace and limiting length
    static func sanitize(_ input: String, maxLength: Int = 1000) -> String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)

        if sanitized.count > maxLength {
            sanitized = String(sanitized.prefix(maxLength))
        }

        return sanitized
    }

    /// Removes potentially dangerous characters from input
    static func removeDangerousCharacters(_ input: String) -> String {
        // Remove control characters except newlines
        return input.filter { !$0.isControl || $0 == "\n" }
    }
}
