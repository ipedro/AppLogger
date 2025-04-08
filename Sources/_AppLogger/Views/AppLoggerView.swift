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
import Models

struct AppLoggerView: View {
    @Environment(\.appLoggerConfiguration)
    private var config
    
    @State private var activityItem: ActivityItem?
    @State private var animate: Bool = false
    @State private var showFilters: Bool = true

    private var searchQueryBinding: Binding<String> {
        Binding(
            get: { dataStore.searchQuerySubject.value },
            set: { dataStore.searchQuerySubject.send($0) }
        )
    }
    
    private var categoriesBinding: Binding<[Filter]> {
        Binding(
            get: { dataStore.categoriesSubject.value },
            set: { newCategories in dataStore.updateCategories(newCategories) }
        )
    }
    
    private var sourcesBinding: Binding<[Filter]> {
        Binding(
            get: { sources },
            set: { _ in }
        )
    }
    
    private var activeFilters: Int {
        dataStore.categoriesSubject.value.filter { $0.isActive }.count
    }
    
    init(config: AppLoggerConfiguration) {
        self.config = config
    }
    
    private var exportButton: some View {
        ExportButton {
            self.activityItem = dataStore.csvActivityItem()
        }
    }
    
    private var filtersButton: some View {
        FilterToggle(isOn: $showFilters, activeFilters: activeFilters)
    }
    
    private var sortingButton: some View {
        SortingButton(selection: <#T##Sorting#>)
    }
    
    private var dismissButton: some View {
        DismissButton {
            fatalError("implement")
        }
    }
    
    private var filtersStack: some View {
        VStack {
            FiltersView(
                title: "Categories",
                data: categoriesBinding
            )
            
            if !sources.isEmpty {
                FiltersView(
                    title: "Sources",
                    filters: sourcesBinding
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                SearchBarView(
                    searchQuery: searchQueryBinding
                )
                .padding(.vertical, 10)
                
                Divider()
                
                if showFilters {
                    filtersStack
                        .padding(.vertical, 10)
                    
                    Divider()
                }
                
                ScrollView {
                    EntriesView(
                        entries: rows,
                        emptyReason: emptyReason
                    )
                    .padding(.bottom, bottomPadding)
                }
                .onDrag { info in
                    self.showFilters = info.predictedEndTranslation.height > 0
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(config.navigationTitle)
            .navigationBarItems(
                leading: HStack(spacing: .zero) {
                    filtersButton
                    sortingButton
                    Spacer(minLength: 12)
                    exportButton
                }
                    .foregroundColor(Color(.label))
            )
            .navigationBarItems(trailing: dismissButton)
            .animation(.easeInOut(duration: 0.35), value: rows)
            .animation(.easeInOut(duration: 0.35), value: showFilters)
            .onReceive(dataStore.searchPublisher) { search in
                if search.isActive {
                    emptyReason = "\(config.emptyReasons.searchResults) \"\(search.displayName)\""
                } else {
                    emptyReason = config.emptyReasons.default
                }
            }
            .onReceive(dataStore.rowsPublisher) { newRows in
                rows = newRows
            }
            .onReceive(dataStore.sourcesPublisher) { newSources in
                sources = newSources
            }
            .endEditingOnDrag()
        }
        .preferredColorScheme(config.colorScheme)
        .onAppear {
            self.animate = true
        }
        .activitySheet($activityItem)
    }
}

final class AppLoggerView_Previews: PreviewProvider {
    static var previews: some View {
        let config = AppLoggerConfiguration(
            navigationTitle: "Preview Title",
            colorScheme: .light
        )
        return AppLoggerView(config: config)
    }
}

private struct PresentingView: View {
    @State private var isPresenting = true
    var config: AppLoggerConfiguration
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Present") { isPresenting.toggle() }
                    Spacer()
                }
                Spacer()
            }
        }
        .navigationTitle("Some View")
        .appLogger(
            isPresented: $isPresenting,
            config: config
        ) {
            self.isPresenting = false
        }
    }
}
