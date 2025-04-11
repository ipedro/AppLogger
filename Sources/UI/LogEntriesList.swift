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
import struct Data.DynamicColorGenerator
import enum Models.Mock
import struct Models.Source

package struct LogEntriesList: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.configuration)
    private var configuration
    
    package var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(viewModel.entries, id: \.self) { id in
                        LogEntryView(id: id)
                        
                        if id != viewModel.entries.last {
                            Divider()
                        }
                    }
                } header: {
                    if viewModel.showFilters {
                        FiltersDrawer().transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                    }
                }
            }
            .padding(.bottom, 50)
            .animation(.snappy, value: viewModel.entries)
        }
        .clipped()
        .ignoresSafeArea(.container, edges: .bottom)
        .background {
            if viewModel.entries.isEmpty {
                Text(emptyReason)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.top, viewModel.showFilters ? 150 : 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(configuration.navigationTitle)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: leadingNavigationBarItems
            )
            ToolbarItem(
                placement: .topBarTrailing,
                content: trailingNavigationBarItems
            )
        }
    }
    
    private var emptyReason: String {
        if viewModel.searchQuery.isEmpty {
            configuration.emptyReasons.empty
        } else {
            "\(configuration.emptyReasons.searchResults):\n\n\(viewModel.activeScope.joined(separator: ", "))"
        }
    }
    
    private func leadingNavigationBarItems() -> some View {
        HStack {
            FiltersDrawerToggle(
                isOn: $viewModel.showFilters,
                activeFilters: viewModel.activeScope.count
            )
            
            SortingButton(selection: $viewModel.sorting)
                .disabled(viewModel.entries.isEmpty)
        }
    }
    
    private func trailingNavigationBarItems() -> some View {
        DismissButton(action: viewModel.dismissAction)
            .font(.title2)
    }
}

#Preview {
    let allEntries = Mock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<Source>()
    
    let dataObserver = DataObserver(
        allEntries: allEntries.map(\.id),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:], { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        })
    )
    
    let viewModel = AppLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: {}
    )
    
    LogEntriesList()
        .environmentObject(viewModel)
        .onAppear {
            viewModel.showFilters = true
        }
}
