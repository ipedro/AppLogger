import SwiftUI

struct DismissButton: View {
    var action: () -> Void
    
    @Environment(\.configuration.icons.dismiss)
    private var icon
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
        }
        .tint(.secondary)
    }
}

#Preview {
    DismissButton(action: {})
}
