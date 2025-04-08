//
//  SpacingKey.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import protocol SwiftUICore.EnvironmentKey
import protocol SwiftUICore.View
import struct SwiftUICore.CGFloat
import struct SwiftUICore.EnvironmentValues

private struct SpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

extension EnvironmentValues {
    var spacing: CGFloat {
        get {
            self[SpacingKey.self]
        } set {
            self[SpacingKey.self] = newValue
        }
    }
}

extension View {
    func spacing(_ spacing: CGFloat) -> some View {
        environment(\.spacing, spacing)
    }
}
