import Data
import SwiftUI

struct SearchBarView: View {
    @FocusState
    private var focus

    @Environment(\.spacing)
    private var spacing

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @State
    private var searchQuery: String = ""

    var body: some View {
        let _ = Self._debugPrintChanges()
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
        .onTapGesture {
            focus = true
        }
        .onReceive(viewModel.searchQuerySubject) {
            searchQuery = $0
        }
        .onChange(of: searchQuery) {
            viewModel.searchQuerySubject.send($0.trimmed)
        }
        .animation(.interactiveSpring, value: showDismiss)
    }

    private var showDismiss: Bool {
        focus || !viewModel.searchQuerySubject.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func clearText() {
        viewModel.searchQuerySubject.value = String()
        focus.toggle()
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    SearchBarView()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: DataObserver(),
                dismissAction: {}
            )
        )
}
