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
import struct Models.Filter

struct FiltersRow: View {
    var title: String
    
    let data: [Filter]
    
    @Environment(\.spacing)
    private var spacing
    
    @State
    private var activeFilters: Set<Filter.ID> = []
    
    private var sortedData: [Filter] {
        data.sorted { lhs, rhs in
            if activeFilters.contains(lhs.id) && !activeFilters.contains(rhs.id) {
                return true
            }
            if activeFilters.contains(rhs.id) && !activeFilters.contains(lhs.id) {
                return false
            }
            return lhs.query < rhs.query
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("\(title) (\(data.count))")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, spacing * 2)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach(sortedData) { filter in
                        FilterView(
                            isOn: Binding {
                                activeFilters.contains(filter.id)
                            } set: { active in
                                if active {
                                    activeFilters.insert(filter.id)
                                } else {
                                    activeFilters.remove(filter.id)
                                }
                            },
                            data: filter
                        )
                    }
                }
                .animation(.default, value: activeFilters)
                .padding(.horizontal, spacing * 2)
            }
            .padding(.vertical, spacing)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    FiltersRow(
        title: "Filters",
        data: [
            "Filter 1",
            "Filter 2",
            "Filter 3"
        ]
    )
}
