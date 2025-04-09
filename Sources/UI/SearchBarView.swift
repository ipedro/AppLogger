//  Copyright (c) 2022 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
                .foregroundColor(.primary)
                .focused($focus)

                if showClearTextButton {
                    Button(action: clearText) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(spacing)
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: spacing))
        }
        .animation(.interactiveSpring, value: showClearTextButton)
        .padding(.vertical, spacing)
    }
    
    private var showClearTextButton: Bool {
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
    SearchBarView(searchQuery: $query).padding()
}
