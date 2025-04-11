//  Copyright (c) 2025 Pedro Almeida
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
import class Data.AppLoggerViewModel
import class Data.DataObserver

struct FiltersDrawer: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        VStack(spacing: spacing) {
            SearchBarView(searchQuery: $viewModel.searchQuery)
                .padding(.horizontal, spacing * 2)
            
            if !viewModel.categories.isEmpty {
                FiltersRow(
                    title: "Categories",
                    selection: $viewModel.activeFilters,
                    data: viewModel.categories
                )
                .animation(.snappy, value: viewModel.categories)
            }
            if !viewModel.sources.isEmpty {
                FiltersRow(
                    title: "Sources",
                    selection: $viewModel.activeFilters,
                    data: viewModel.sources
                )
                .animation(.snappy, value: viewModel.sources)
            }
        }
        .font(.footnote)
        .padding(.vertical, spacing)
        .background(.background)
        .safeAreaInset(edge: .bottom, spacing: .zero, content: Divider.init)
    }
}

#Preview {
    FiltersDrawer()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: DataObserver(
//                    allCategories: ["test"],
//                    allSources: ["test"]
                ),
                dismissAction: {
                }
            )
        )
}
