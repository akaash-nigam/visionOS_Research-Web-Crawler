//
//  CameraController.swift
//  Research Web Crawler
//
//  Controls camera movement and interaction in 3D graph space
//

import RealityKit
import SwiftUI

@MainActor
final class CameraController: ObservableObject {
    // MARK: - Properties

    weak var rootEntity: Entity?

    @Published var cameraDistance: Float = 2.0
    @Published var cameraRotation: SIMD2<Float> = .zero // yaw, pitch
    @Published var cameraOffset: SIMD3<Float> = .zero

    // Constraints
    private let minDistance: Float = 0.5
    private let maxDistance: Float = 10.0
    private let minPitch: Float = -.pi / 3  // -60 degrees
    private let maxPitch: Float = .pi / 3   // +60 degrees

    // Smooth interpolation
    private var targetDistance: Float = 2.0
    private var targetRotation: SIMD2<Float> = .zero
    private var targetOffset: SIMD3<Float> = .zero

    private let smoothingFactor: Float = 0.15

    // MARK: - Initialization

    init(rootEntity: Entity? = nil) {
        self.rootEntity = rootEntity
        resetCamera()
    }

    // MARK: - Camera Control

    func resetCamera() {
        targetDistance = 2.0
        targetRotation = .zero
        targetOffset = .zero

        cameraDistance = targetDistance
        cameraRotation = targetRotation
        cameraOffset = targetOffset

        updateCameraPosition()
    }

    func zoom(delta: Float) {
        targetDistance += delta
        targetDistance = clamp(targetDistance, min: minDistance, max: maxDistance)
    }

    func pan(delta: SIMD2<Float>) {
        // Convert 2D pan to 3D offset based on current rotation
        let yaw = targetRotation.x

        // Calculate right and up vectors based on rotation
        let right = SIMD3<Float>(cos(yaw), 0, sin(yaw))
        let up = SIMD3<Float>(0, 1, 0)

        targetOffset += right * delta.x * 0.01
        targetOffset += up * delta.y * 0.01

        // Constrain offset to reasonable bounds
        targetOffset.x = clamp(targetOffset.x, min: -5, max: 5)
        targetOffset.y = clamp(targetOffset.y, min: -5, max: 5)
        targetOffset.z = clamp(targetOffset.z, min: -5, max: 5)
    }

    func rotate(delta: SIMD2<Float>) {
        targetRotation.x += delta.x * 0.01  // yaw
        targetRotation.y += delta.y * 0.01  // pitch

        // Normalize yaw to [-π, π]
        while targetRotation.x > .pi {
            targetRotation.x -= 2 * .pi
        }
        while targetRotation.x < -.pi {
            targetRotation.x += 2 * .pi
        }

        // Clamp pitch
        targetRotation.y = clamp(targetRotation.y, min: minPitch, max: maxPitch)
    }

    func focusOn(position: SIMD3<Float>, distance: Float = 2.0) {
        targetOffset = -position
        targetDistance = distance
        targetRotation = .zero
    }

    // MARK: - Update Loop

    func update(deltaTime: Float) {
        // Smooth interpolation
        cameraDistance = lerp(cameraDistance, targetDistance, smoothingFactor)
        cameraRotation.x = lerpAngle(cameraRotation.x, targetRotation.x, smoothingFactor)
        cameraRotation.y = lerp(cameraRotation.y, targetRotation.y, smoothingFactor)
        cameraOffset = lerp(cameraOffset, targetOffset, smoothingFactor)

        updateCameraPosition()
    }

    private func updateCameraPosition() {
        guard let rootEntity = rootEntity else { return }

        // Calculate camera position based on spherical coordinates
        let yaw = cameraRotation.x
        let pitch = cameraRotation.y

        // Spherical to Cartesian conversion
        let x = cameraDistance * cos(pitch) * sin(yaw)
        let y = cameraDistance * sin(pitch)
        let z = cameraDistance * cos(pitch) * cos(yaw)

        let cameraPos = SIMD3<Float>(x, y, z) + cameraOffset

        // Update root entity position
        rootEntity.position = -cameraPos + [0, 1.5, -2]

        // Calculate look-at rotation (camera looks at origin + offset)
        let lookAtTarget = cameraOffset
        let direction = normalize(lookAtTarget - cameraPos)

        // Convert direction to quaternion
        let yawRot = atan2(direction.x, direction.z)
        let pitchRot = asin(direction.y)

        rootEntity.orientation = simd_quatf(
            angle: yawRot,
            axis: SIMD3<Float>(0, 1, 0)
        ) * simd_quatf(
            angle: -pitchRot,
            axis: SIMD3<Float>(1, 0, 0)
        )
    }

    // MARK: - Gesture Handlers

    func handlePinchGesture(_ magnification: CGFloat) {
        let zoomDelta = Float(magnification - 1.0) * -0.5
        zoom(delta: zoomDelta)
    }

    func handleDragGesture(_ translation: CGSize, type: DragType) {
        let delta = SIMD2<Float>(Float(translation.width), Float(translation.height))

        switch type {
        case .pan:
            pan(delta: delta)
        case .rotate:
            rotate(delta: delta)
        }
    }

    enum DragType {
        case pan
        case rotate
    }

    // MARK: - Utilities

    private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + (b - a) * t
    }

    private func lerp(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ t: Float) -> SIMD3<Float> {
        return a + (b - a) * t
    }

    private func lerpAngle(_ a: Float, _ b: Float, _ t: Float) -> Float {
        // Handle angle wrapping
        var delta = b - a
        while delta > .pi { delta -= 2 * .pi }
        while delta < -.pi { delta += 2 * .pi }
        return a + delta * t
    }

    private func clamp(_ value: Float, min: Float, max: Float) -> Float {
        return Swift.min(Swift.max(value, min), max)
    }

    // MARK: - Camera State

    func getCameraState() -> CameraState {
        return CameraState(
            distance: cameraDistance,
            rotation: cameraRotation,
            offset: cameraOffset
        )
    }

    func setCameraState(_ state: CameraState, animated: Bool = true) {
        if animated {
            targetDistance = state.distance
            targetRotation = state.rotation
            targetOffset = state.offset
        } else {
            cameraDistance = state.distance
            cameraRotation = state.rotation
            cameraOffset = state.offset
            targetDistance = state.distance
            targetRotation = state.rotation
            targetOffset = state.offset
            updateCameraPosition()
        }
    }

    struct CameraState: Codable {
        let distance: Float
        let rotation: SIMD2<Float>
        let offset: SIMD3<Float>
    }
}
