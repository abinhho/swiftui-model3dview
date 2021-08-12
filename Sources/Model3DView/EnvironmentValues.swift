/*
 * EnvironmentValues.swift
 * Created by Freek Zijlmans on 08-08-2021.
 */

import SwiftUI

// MARK: - Environment keys.
struct CameraEnvironmentKey: EnvironmentKey {
	static var defaultValue: Camera = PerspectiveCamera()
}

struct IBLEnvironmentKey: EnvironmentKey {
	static var defaultValue: URL? = nil
}

struct SkyboxEnvironmentKey: EnvironmentKey {
	static var defaultValue: URL? = nil
}

// MARK: - Environment values.
extension EnvironmentValues {
	var camera: Camera {
		get { self[CameraEnvironmentKey.self] }
		set { self[CameraEnvironmentKey.self] = newValue }
	}
	
	var ibl: URL? {
		get { self[IBLEnvironmentKey.self] }
		set { self[IBLEnvironmentKey.self] = newValue }
	}
	
	var skybox: URL? {
		get { self[SkyboxEnvironmentKey.self] }
		set { self[SkyboxEnvironmentKey.self] = newValue }
	}
}