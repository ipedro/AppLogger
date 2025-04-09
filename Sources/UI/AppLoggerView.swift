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

package struct AppLoggerView: View {
    
    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.configuration.navigationTitle)
    private var navigationTitle
    
    @Environment(\.configuration.emptyReasons)
    private var emptyReasons
    
    @Environment(\.spacing)
    private var spacing
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    package init() {}
    
    private var emptyReason: String {
        if viewModel.searchQuery.isEmpty {
            emptyReasons.empty
        } else {
            "\(emptyReasons.searchResults) \"\(viewModel.searchQuery)\""
        }
    }
    
    package var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                filtersDrawer
                
                ScrollView {
                    LazyVStack(spacing: .zero) {
                        ForEach(viewModel.entries, id: \.self) { id in
                            LogEntryView(id: id).safeAreaInset(
                                edge: .bottom,
                                content: Divider.init
                            )
                        }
                    }
                    .background {
                        if viewModel.entries.isEmpty {
                            Text(emptyReason)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                                .padding(.top, 200)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .onDrag { info in
                    viewModel.showFilters = info.predictedEndTranslation.height > 0
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .navigationBarItems(leading: leadingNavigationBarItems)
            .navigationBarItems(trailing: trailingNavigationBarItems)
//            .animation(.easeInOut(duration: 0.35), value: rows)
            .endEditingOnDrag()
        }
        .preferredColorScheme(preferredColorScheme)
        .activitySheet($viewModel.activityItem)
    }
    
    private var filtersDrawer: some View {
        VStack(spacing: .zero) {
            HStack {
                ActiveFiltersToggle(
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
                FiltersView(title: "Categories", data: viewModel.categories)
            }
            if viewModel.showFilters && !viewModel.sources.isEmpty {
                FiltersView(title: "Sources", data: viewModel.sources)
            }
        }
        .safeAreaInset(edge: .bottom, content: Divider.init)
        .foregroundColor(.primary)
    }
    
    private var leadingNavigationBarItems: some View {
        ExportButton {
            viewModel.activityItem = nil //dataStore.csvActivityItem()
            fatalError("implement")
        }
        .foregroundColor(.primary)
    }
    
    private var trailingNavigationBarItems: some View {
        DismissButton(action: viewModel.dismissAction)
    }
}

//#Preview {
//    AppLoggerView(
//        searchQuery: "",
//        entries: [],
//        categories: ["Managers"],
//        sources: ["Apple", "Google"]
//    )
//}
