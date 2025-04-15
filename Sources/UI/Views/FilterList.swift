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


import Combine
import Data
import Models
import SwiftUI

struct FilterList: View {
    let title: String

    let keyPath: KeyPath<VisualLoggerViewModel, CurrentValueSubject<[LogFilter], Never>>

    @State
    private var selection = Set<LogFilter>()

    @State
    private var data = [LogFilter]()

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @Environment(\.spacing)
    private var spacing

    var body: some View {
        let _ = Self._debugPrintChanges()
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing, pinnedViews: .sectionHeaders) {
                    Section(content: filters, header: header)
                }
                .padding(.trailing, spacing * 2)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .animation(.snappy, value: data)
        .onReceive(viewModel.activeFiltersSubject) {
            selection = $0
        }
        .onChange(of: selection) {
            viewModel.activeFiltersSubject.send($0)
        }
        .onReceive(viewModel[keyPath: keyPath]) {
            data = $0
        }
    }

    private func filters() -> some View {
        ForEach(data, id: \.self) { /*@Sendable*/ filter in
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
    }

    private func header() -> some View {
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

// @available(iOS 17.0, *)
// #Preview {
//    @Previewable @State
//    var activeFilters: Set<LogFilter> = [
//        "Filter 1",
//    ]
//    FilterList(
//        title: "Filters",
//        selection: $activeFilters,
//        data: [
//            "Filter 1",
//            "Filter 2",
//            "Filter 3",
//        ]
//    )
// }
