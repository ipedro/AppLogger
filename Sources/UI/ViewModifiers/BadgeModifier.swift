import SwiftUI

extension View {
    func badge(
        count: Int = 0,
        foregroundColor: Color = .white,
        backgroundColor: Color = .red
    ) -> some View {
        modifier(
            BadgeModifier(
                count: count,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor
            )
        )
    }
}

struct BadgeModifier: ViewModifier {
    var count: Int
    var foregroundColor: Color
    var backgroundColor: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            if count != 0 {
                ZStack {
                    Text(count, format: .number)
                        .font(.caption2)
                        .foregroundStyle(foregroundColor)
                        .fixedSize()
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 1)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(backgroundColor, in: Capsule())
                }
                .transition(.scale.combined(with: .opacity))
                .frame(width: 0, height: 0)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(body: {
    @Previewable @State
    var count = 0

    Button("Test") {
        count = count == 0 ? 10 : 0
    }
    .badge(count: count)
    .animation(.interactiveSpring, value: count)
})
