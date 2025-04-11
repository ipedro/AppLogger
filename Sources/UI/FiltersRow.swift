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
    
    @Binding
    var selection: Set<Filter>
    
    let data: [Filter]
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(data, id: \.self) { filter in
                        FilterView(
                            data: filter,
                            isOn: Binding {
                                selection.contains(filter)
                            } set: { active in
                                if active {
                                    selection.insert(filter)
                                } else {
                                    selection.remove(filter)
                                }
                            }
                        )
                    }
                } header: {
                    Text(title)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(
                            top: spacing,
                            leading: spacing * 2,
                            bottom: spacing,
                            trailing: spacing
                        ))
                        .background(.background)
                }
            }
            .padding(.trailing, spacing * 2)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var activeFilters: Set<Filter> = [
        "Filter 1"
    ]
    FiltersRow(
        title: "Filters",
        selection: $activeFilters,
        data: [
            "Filter 1",
            "Filter 2",
            "Filter 3"
        ]
    )
}
