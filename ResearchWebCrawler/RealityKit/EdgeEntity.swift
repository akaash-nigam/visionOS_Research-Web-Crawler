//
//  EdgeEntity.swift
//  Research Web Crawler
//
//  3D entity representing a connection edge between nodes
//

import RealityKit
import SwiftUI

final class EdgeEntity: Entity, HasModel {
    // MARK: - Properties

    let connectionId: UUID
    let connection: Connection
    weak var fromNode: NodeEntity?
    weak var toNode: NodeEntity?

    private var lineWidth: Float
    private var lineColor: UIColor

    // MARK: - Initialization

    init(
        connection: Connection,
        fromNode: NodeEntity,
        toNode: NodeEntity,
        width: Float = 0.005
    ) {
        self.connectionId = connection.id
        self.connection = connection
        self.fromNode = fromNode
        self.toNode = toNode
        self.lineWidth = width * connection.strength.multiplier
        self.lineColor = connection.type.uiColor

        super.init()

        self.name = "Edge_\(connection.id.uuidString.prefix(8))"

        updateGeometry()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Geometry Updates

    func updateGeometry() {
        guard let fromNode = fromNode,
              let toNode = toNode else { return }

        let fromPos = fromNode.position(relativeTo: self.parent)
        let toPos = toNode.position(relativeTo: self.parent)

        // Calculate midpoint
        let midpoint = (fromPos + toPos) / 2
        self.position = midpoint

        // Calculate distance
        let direction = toPos - fromPos
        let distance = length(direction)

        guard distance > 0.001 else { return }

        // Create cylinder mesh
        let mesh = MeshResource.generateCylinder(
            height: distance,
            radius: lineWidth
        )

        // Create material with connection type color
        var material = SimpleMaterial()
        material.color = .init(tint: lineColor)
        material.metallic = .float(0.1)
        material.roughness = .float(0.4)

        // Apply bidirectional style if needed
        if connection.bidirectional {
            // Make line slightly thicker and more saturated
            material.color = .init(tint: lineColor.withAlphaComponent(0.9))
        } else {
            material.color = .init(tint: lineColor.withAlphaComponent(0.7))
        }

        // Set model component
        self.components.set(ModelComponent(
            mesh: mesh,
            materials: [material]
        ))

        // Orient cylinder to point from source to target
        orientLine(from: fromPos, to: toPos)
    }

    private func orientLine(from: SIMD3<Float>, to: SIMD3<Float>) {
        let direction = to - from
        let distance = length(direction)

        guard distance > 0.001 else { return }

        let normalizedDir = normalize(direction)

        // Cylinder default is along Y axis
        let up = SIMD3<Float>(0, 1, 0)

        // Calculate rotation to align cylinder with direction
        if abs(dot(normalizedDir, up)) < 0.999 {
            let axis = cross(up, normalizedDir)
            let angle = acos(dot(up, normalizedDir))
            self.orientation = simd_quatf(angle: angle, axis: normalize(axis))
        } else if dot(normalizedDir, up) < 0 {
            // If pointing down, rotate 180 degrees
            self.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
        }
    }

    // MARK: - Visual Updates

    func updateColor(_ newColor: UIColor) {
        self.lineColor = newColor
        updateGeometry()
    }

    func updateWidth(_ newWidth: Float) {
        self.lineWidth = newWidth
        updateGeometry()
    }

    func setHighlighted(_ highlighted: Bool) {
        var material = SimpleMaterial()

        if highlighted {
            // Brighter and thicker when highlighted
            material.color = .init(tint: lineColor.withAlphaComponent(1.0))
            material.metallic = .float(0.3)
            material.roughness = .float(0.2)

            // Temporarily increase width
            let highlightedWidth = lineWidth * 1.5

            guard let fromNode = fromNode,
                  let toNode = toNode else { return }

            let fromPos = fromNode.position(relativeTo: self.parent)
            let toPos = toNode.position(relativeTo: self.parent)
            let distance = length(toPos - fromPos)

            let mesh = MeshResource.generateCylinder(
                height: distance,
                radius: highlightedWidth
            )

            self.components.set(ModelComponent(
                mesh: mesh,
                materials: [material]
            ))
        } else {
            // Normal state
            updateGeometry()
        }
    }

    // MARK: - Animation

    func animateAppearance() {
        // Start with zero scale on XZ plane (keep Y for length)
        self.scale = [0.01, 1.0, 0.01]

        // Animate to full size
        var transform = self.transform
        transform.scale = [1, 1, 1]

        self.move(
            to: transform,
            relativeTo: self.parent,
            duration: 0.4,
            timingFunction: .easeOut
        )
    }

    func animatePulse() {
        // Pulse animation for selection
        var enlargeTransform = self.transform
        enlargeTransform.scale = [1.5, 1.0, 1.5] // XZ only

        var normalTransform = self.transform
        normalTransform.scale = [1, 1, 1]

        // Enlarge
        self.move(
            to: enlargeTransform,
            relativeTo: self.parent,
            duration: 0.2,
            timingFunction: .easeOut
        )

        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.move(
                to: normalTransform,
                relativeTo: self.parent,
                duration: 0.2,
                timingFunction: .easeIn
            )
        }
    }
}

// MARK: - Connection Extensions

extension Connection {
    var uiColor: UIColor {
        type.uiColor
    }
}

extension ConnectionType {
    var uiColor: UIColor {
        switch self {
        case .cites:
            return UIColor.systemBlue
        case .supports:
            return UIColor.systemGreen
        case .contradicts:
            return UIColor.systemRed
        case .related:
            return UIColor.systemGray
        case .derivedFrom:
            return UIColor.systemPurple
        case .mentions:
            return UIColor.systemOrange
        case .builds:
            return UIColor.systemTeal
        case .critiques:
            return UIColor.systemPink
        }
    }
}

extension ConnectionStrength {
    var multiplier: Float {
        switch self {
        case .weak:
            return 0.7
        case .moderate:
            return 1.0
        case .strong:
            return 1.3
        }
    }
}
