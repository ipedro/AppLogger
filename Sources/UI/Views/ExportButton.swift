import SwiftUI

struct ExportButton: View {
    let action: () -> Void

    @Environment(\.configuration.icons.export)
    private var icon

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
    }
}

#Preview {
    ExportButton(action: {})
}
