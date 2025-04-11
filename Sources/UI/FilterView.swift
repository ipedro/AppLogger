import SwiftUI
import Models

struct FilterView: View {
    let data: Filter
    @Binding var isOn: Bool
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.configuration.accentColor)
    private var accentColor
    
    private let shape = Capsule()
    
    var body: some View {
        Toggle(data.displayName, isOn: $isOn)
            .clipShape(shape)
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)
            .background(accentColor.opacity(0.08), in: shape)
    }
}

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
