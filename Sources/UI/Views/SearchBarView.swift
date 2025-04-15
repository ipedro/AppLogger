// MIT License
// 
// Copyright (c) 2025 Pedro Almeida
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
        focus || !searchQuery.isEmpty
    }

    private func clearText() {
        searchQuery = String()
        focus = false
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
