/*
 * Cameras.swift
 * Created by Freek (github.com/frzi) on 08-08-2021.
 */

import SwiftUI
import simd

// MARK: - Camera protocol
/// Protocol for `Model3DView` cameras.
public protocol Camera {
	var position: Vector3 { get set }
	var rotation: Euler { get set }
	var isRotating: Bool { get set }
	func projectionMatrix(viewport: CGSize) -> Matrix4x4
}

extension Camera {
	/// Adjust the camera to orient towards `center`.
	public mutating func lookAt(center: Vector3, up: Vector3 = [0, 1, 0]) {
		let m = Matrix4x4.lookAt(eye: position, target: center, up: up)
		let mat3 = Matrix3x3(
			[m.columns.0.x, m.columns.0.y, m.columns.0.z],
			[m.columns.1.x, m.columns.1.y, m.columns.1.z],
			[m.columns.2.x, m.columns.2.y, m.columns.2.z]
		)
		rotation = Euler(Quaternion(mat3))
	}
	
	/// Return a copy of the camera oriented towards `center`.
	public func lookingAt(center: Vector3, up: Vector3 = [0, 1, 0]) -> Self {
		var copy = self
		copy.lookAt(center: center, up: up)
		return copy
	}
}

// MARK: - Camera view modifier
/// An animatable modifier that helps animate properties of a `Camera`.
private struct CameraModifier<C: Camera>: AnimatableModifier {
	var camera: C

	var animatableData: AnimatablePair<Vector3, Euler> {
		get {
			.init(camera.position, camera.rotation)
		}
		set {
			camera.position = newValue.first
			camera.rotation = newValue.second
		}
	}

	func body(content: Content) -> some View {
		content.environment(\.camera, camera)
	}
}

extension View {
	/// Sets the default camera.
	public func camera<C: Camera>(_ camera: C) -> some View {
		modifier(CameraModifier(camera: camera))
	}
}

// MARK: - Camera types
/// Camera with orthographic projection.
public struct OrthographicCamera: Camera, Equatable {
	public var position: Vector3
	public var rotation: Euler
	public var near: Float
	public var far: Float
	public var scale: Float

	public var isRotating: Bool = false
	
	public init(
		position: Vector3 = [0, 0, 2],
		rotation: Euler = Euler(),
		near: Float = 0.1,
		far: Float = 100,
		scale: Float = 1
	) {
		self.position = position
		self.rotation = rotation
		self.near = near
		self.far = far
		self.scale = scale
	}
	
	public func projectionMatrix(viewport size: CGSize) -> Matrix4x4 {
		let aspect = Float(size.width / size.height) * scale
		return .orthographic(left: -aspect, right: aspect, bottom: -scale, top: scale, near: near, far: far)
	}
}

/// Camera with perspective projection.
public struct PerspectiveCamera: Camera, Equatable {
	public var position: Vector3
	public var rotation: Euler
	public var fov: Angle
	public var near: Float
	public var far: Float

	public var isRotating: Bool = false
	
	public init(
		position: Vector3 = [0, 0, 2],
		rotation: Euler = Euler(),
		fov: Angle = .degrees(60),
		near: Float = 0.1,
		far: Float = 100
	) {
		self.position = position
		self.rotation = rotation
		self.fov = fov
		self.near = near
		self.far = far
	}
	
	public func projectionMatrix(viewport size: CGSize) -> Matrix4x4 {
		let aspect = Float(size.width / size.height)
		return .perspective(fov: Float(fov.radians), aspect: aspect, near: near, far: far)
	}
}

