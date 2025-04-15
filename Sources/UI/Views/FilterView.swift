import Models
import SwiftUI

struct FilterView: View {
    let data: LogFilter

    @Binding var isOn: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.tintColor)
    private var tintColor

    private let shape = Capsule()

    private var backgroundColor: Color {
        (tintColor ?? .accentColor).opacity(0.08)
    }

    var body: some View {
        let _ = Self._debugPrintChanges()
        Toggle(data.displayName, isOn: $isOn)
            .clipShape(shape)
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)
            .background(backgroundColor, in: shape)
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
