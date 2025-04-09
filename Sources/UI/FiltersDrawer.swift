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
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                FiltersDrawerToggle(
                    isOn: $viewModel.showFilters,
                    activeFilters: viewModel.activeFilters.count
                )
                .disabled(viewModel.sources.isEmpty && viewModel.categories.isEmpty)
                
                SearchBarView(searchQuery: $viewModel.searchQuery)
                
                SortingButton(selection: $viewModel.sorting)
                    .opacity(viewModel.entries.isEmpty ? 0.5 : 1)
                    .disabled(viewModel.entries.isEmpty)
            }
            .padding(.horizontal)
            
            if viewModel.showFilters && !viewModel.categories.isEmpty {
                FiltersRow(
                    title: "Categories",
                    selection: $viewModel.activeFilters,
                    data: viewModel.categories
                )
            }
            if viewModel.showFilters && !viewModel.sources.isEmpty {
                FiltersRow(
                    title: "Sources",
                    selection: $viewModel.activeFilters,
                    data: viewModel.sources
                )
            }
        }
        .safeAreaInset(edge: .bottom, content: Divider.init)
        .foregroundColor(.primary)
    }
}

#Preview {
    FiltersDrawer()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: DataObserver(),
                dismissAction: {}
            )
        )
}
