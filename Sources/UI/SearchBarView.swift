import SwiftUI

struct SearchBarView: View {
    @Binding
    var searchQuery: String
    
    @FocusState
    private var focus
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .accessibilityHidden(true)

                TextField(
                    "Search logs",
                    text: $searchQuery
                )
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundColor(.primary)
                .focused($focus)

                if showDismiss {
                    DismissButton(action: clearText).transition(
                        .scale.combined(with: .opacity)
                    )
                }
            }
            .padding(spacing)
            .foregroundColor(.secondary)
            .background(Color.secondaryBackground)
            .clipShape(Capsule())
        }
        .animation(.interactiveSpring, value: showDismiss)
    }
    
    private var showDismiss: Bool {
        focus || !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func clearText() {
        searchQuery = String()
        focus.toggle()
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var query: String = "Query"
    SearchBarView(searchQuery: $query)
}
