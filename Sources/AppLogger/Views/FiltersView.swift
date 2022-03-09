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

import Foundation
import SwiftUI

struct FiltersView: View {
    var title: String
    private let spacing: CGFloat = 8

    @Binding var filters: [Filter]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: spacing) {
            Text("\(title) (\(filters.count))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, spacing * 2)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach($filters, id: \.query) {
                        FilterView(filter: $0)
                    }
                }
                .padding(.horizontal, spacing * 2)
                .padding(.vertical, spacing)
            }
        }
    }
}

// MARK: - Previews

struct FiltersViewPreviews: PreviewProvider {
    static var previews: some View {
        FiltersView(
            title: "Filters",
            filters: .constant([
                .init(query: "0", displayName: "Inactive Filter", isActive: false),
                .init(query: "1", displayName: "Active Filter", isActive: true),
                .init(query: "2", displayName: "Another Active Filter", isActive: true)
            ])
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
