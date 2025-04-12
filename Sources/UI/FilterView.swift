import Models
import SwiftUI

struct FilterView: View {
    let data: Filter

    @Binding var isOn: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor

    private let shape = Capsule()

    var body: some View {
        let _ = Self._debugPrintChanges()
        Toggle(data.displayName, isOn: $isOn)
            .clipShape(shape)
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)
            .background(accentColor.opacity(0.08), in: shape)
    }
}

#if swift(>=6.0)
extension FilterView: @preconcurrency Equatable {
    static func == (lhs: FilterView, rhs: FilterView) -> Bool {
        lhs.data == rhs.data && lhs.isOn == rhs.isOn
    }
}
#else
extension FilterView: Equatable {
    static func == (lhs: FilterView, rhs: FilterView) -> Bool {
        lhs.data == rhs.data && lhs.isOn == rhs.isOn
    }
}
#endif

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false

    VStack {
        FilterView(
            data: "Some Filter",
            isOn: $isOn
        )
    }
}
