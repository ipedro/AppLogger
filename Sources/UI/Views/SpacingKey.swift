import SwiftUI

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
