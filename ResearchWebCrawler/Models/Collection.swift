//
//  Collection.swift
//  Research Web Crawler
//
//  Represents a user-defined collection of sources
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Collection {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Parent project ID
    var projectId: UUID

    /// Collection name
    var name: String

    /// Description
    var collectionDescription: String?

    /// Color (stored as hex string)
    var colorHex: String

    /// Icon name
    var iconName: String?

    /// Creation date
    var created: Date

    /// Modification date
    var modified: Date

    /// Source IDs in this collection
    var sourceIds: [UUID]

    // MARK: - Initialization

    init(
        name: String,
        projectId: UUID,
        color: Color = .blue
    ) {
        self.id = UUID()
        self.name = name
        self.projectId = projectId
        self.colorHex = color.toHex()
        self.created = Date()
        self.modified = Date()
        self.sourceIds = []
    }

    // MARK: - Computed Properties

    var color: Color {
        get { Color(hex: colorHex) ?? .blue }
        set { colorHex = newValue.toHex() }
    }

    // MARK: - Methods

    func addSource(_ sourceId: UUID) {
        guard !sourceIds.contains(sourceId) else { return }
        sourceIds.append(sourceId)
        modified = Date()
    }

    func removeSource(_ sourceId: UUID) {
        sourceIds.removeAll { $0 == sourceId }
        modified = Date()
    }

    func contains(_ sourceId: UUID) -> Bool {
        sourceIds.contains(sourceId)
    }
}

// MARK: - Color Extensions

extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components,
              components.count >= 3 else {
            return "#0000FF" // Default blue
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }

    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
