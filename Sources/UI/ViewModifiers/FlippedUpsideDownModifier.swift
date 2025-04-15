import SwiftUI

extension View {
    func flippedUpsideDown(_ enabled: Bool = true) -> some View {
        modifier(FlippedUpsideDownModifier(enabled: enabled))
    }
}

struct FlippedUpsideDownModifier: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        content
            .rotationEffect(enabled ? .radians(Double.pi) : .zero)
            .scaleEffect(x: enabled ? -1 : 1, y: 1)
    }
}
