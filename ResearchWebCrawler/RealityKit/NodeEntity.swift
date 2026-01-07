//
//  NodeEntity.swift
//  Research Web Crawler
//
//  3D entity representing a source node
//

import RealityKit
import SwiftUI

final class NodeEntity: Entity, HasModel, HasCollision {
    // MARK: - Properties

    let sourceId: UUID
    let sourceType: SourceType
    var nodeSize: Float
    var nodeColor: UIColor
    private var isHighlighted: Bool = false
    private var isSelected: Bool = false

    // MARK: - Initialization

    init(
        sourceId: UUID,
        type: SourceType,
        position: SIMD3<Float>,
        size: Float = 0.05,
        color: UIColor
    ) {
        self.sourceId = sourceId
        self.sourceType = type
        self.nodeSize = size
        self.nodeColor = color

        super.init()

        self.name = "Node_\(sourceId.uuidString.prefix(8))"
        self.position = position

        setupGeometry()
        setupCollision()
        setupPhysics()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Setup

    private func setupGeometry() {
        // Create sphere mesh
        let mesh = MeshResource.generateSphere(radius: nodeSize)

        // Create material with color
        var material = SimpleMaterial()
        material.color = .init(tint: nodeColor)
        material.metallic = .float(0.2)
        material.roughness = .float(0.3)

        // Add model component
        self.components.set(ModelComponent(
            mesh: mesh,
            materials: [material]
        ))
    }

    private func setupCollision() {
        // Add collision for tap detection
        let shape = ShapeResource.generateSphere(radius: nodeSize * 1.2)
        self.components.set(CollisionComponent(
            shapes: [shape],
            mode: .trigger,
            filter: .default
        ))
    }

    private func setupPhysics() {
        // Add input target for gestures
        self.components.set(InputTargetComponent())
    }

    // MARK: - Visual Updates

    func setHighlighted(_ highlighted: Bool) {
        isHighlighted = highlighted
        updateVisuals()
    }

    func setSelected(_ selected: Bool) {
        isSelected = selected
        updateVisuals()
    }

    private func updateVisuals() {
        var material = SimpleMaterial()

        if isSelected {
            // Selected: brighter, outlined
            material.color = .init(tint: nodeColor.withAlphaComponent(1.0))
            material.metallic = .float(0.5)
            material.roughness = .float(0.1)

            // Add glow effect
            // Note: RealityKit doesn't have built-in glow, so we'll make it brighter
            let brighterColor = nodeColor.lighter()
            material.color = .init(tint: brighterColor)

        } else if isHighlighted {
            // Highlighted: slightly brighter
            material.color = .init(tint: nodeColor.withAlphaComponent(0.9))
            material.metallic = .float(0.3)
            material.roughness = .float(0.2)

        } else {
            // Normal state
            material.color = .init(tint: nodeColor.withAlphaComponent(0.8))
            material.metallic = .float(0.2)
            material.roughness = .float(0.3)
        }

        // Update model component
        if let modelComponent = self.components[ModelComponent.self] {
            self.components.set(ModelComponent(
                mesh: modelComponent.mesh,
                materials: [material]
            ))
        }
    }

    func updateSize(_ newSize: Float) {
        self.nodeSize = newSize
        setupGeometry()
        setupCollision()
    }

    func updateColor(_ newColor: UIColor) {
        self.nodeColor = newColor
        updateVisuals()
    }

    // MARK: - Animation

    func animateAppearance() {
        // Start small
        self.scale = [0.01, 0.01, 0.01]

        // Animate to full size
        var transform = self.transform
        transform.scale = [1, 1, 1]

        self.move(
            to: transform,
            relativeTo: self.parent,
            duration: 0.3,
            timingFunction: .easeOut
        )
    }

    func animatePulse() {
        // Pulse animation for selection
        var enlargeTransform = self.transform
        enlargeTransform.scale = [1.2, 1.2, 1.2]

        var normalTransform = self.transform
        normalTransform.scale = [1, 1, 1]

        // Enlarge
        self.move(
            to: enlargeTransform,
            relativeTo: self.parent,
            duration: 0.15,
            timingFunction: .easeOut
        )

        // Return to normal (would need completion handler in real implementation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.move(
                to: normalTransform,
                relativeTo: self.parent,
                duration: 0.15,
                timingFunction: .easeIn
            )
        }
    }
}

// MARK: - UIColor Extensions

extension UIColor {
    func lighter(by percentage: CGFloat = 0.3) -> UIColor {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 0.3) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return UIColor(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            alpha: alpha
        )
    }
}
