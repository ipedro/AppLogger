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

import Data
import Models
import SwiftUI

package struct LogEntriesList: View {
    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @Environment(\.configuration)
    private var configuration

    @Environment(\.spacing)
    private var spacing

    @State
    private var entries: [LogEntryID] = []

    @State
    private var searchQuery = ""

    @State
    private var showFilters: Bool = UserDefaults.standard.showFilters

    @State
    private var activeFilterScope: [String] = []

    @State
    private var sorting: LogEntrySorting = UserDefaults.standard.sorting

    private var flipped: Bool {
        sorting == .ascending
    }

    package var body: some View {
        let _ = Self._debugPrintChanges()
        let data = entries
        ScrollView {
            LazyVStack(spacing: .zero, pinnedViews: [.sectionHeaders, .sectionFooters]) {
                Section {
                    ForEach(data, id: \.self) { @MainActor @Sendable id in
                        LogEntryView(id: id).flippedUpsideDown(flipped)

                        if id != data.last {
                            Divider()
                        }
                    }
                    .animation(.default, value: data)
                } header: {
                    if !flipped {
                        filtersDrawer()
                    }
                } footer: {
                    if flipped {
                        filtersDrawer()
                    }
                }
            }
        }
        .clipped()
        .flippedUpsideDown(flipped)
        .interactiveDismissDisabled(flipped)
        .background {
            if data.isEmpty {
                Text(emptyReason)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(flipped ? .bottom : .top, showFilters ? 150 : 0)
            }
        }
        .animation(.snappy, value: showFilters)
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
        .onReceive(viewModel.entriesSortingSubject) {
            sorting = $0
        }
        .onReceive(viewModel.currentEntriesSubject) {
            entries = $0
        }
        .onReceive(viewModel.showFilterDrawerSubject) {
            showFilters = $0
        }
        .onChange(of: showFilters) {
            viewModel.showFilterDrawerSubject.send($0)
        }
        .onReceive(viewModel.searchQuerySubject) {
            searchQuery = $0
        }
        .onReceive(viewModel.activeFilterScopeSubject) {
            activeFilterScope = $0
        }
    }

    private func filtersDrawer() -> some View {
        FiltersDrawer()
            .compositingGroup()
            .opacity(showFilters ? 1 : 0)
            .frame(height: showFilters ? nil : spacing, alignment: .top)
            .clipped()
            .flippedUpsideDown(flipped)
    }

    private var emptyReason: String {
        if activeFilterScope.isEmpty {
            configuration.emptyReasons.empty
        } else {
            configuration.emptyReasons.searchResults + ":\n\n\(activeFilterScope.joined(separator: ", "))"
        }
    }

    private func leadingNavigationBarItems() -> some View {
        HStack {
            FiltersDrawerToggle(
                isOn: $showFilters,
                activeFilters: activeFilterScope.count
            )

            ActionsMenu()
                .tint(nil)
        }
    }

    private func trailingNavigationBarItems() -> some View {
        DismissButton(action: viewModel.dismissAction)
            .font(.title2)
    }
}

#Preview {
    let allEntries = LogEntryMock.allCases.map { $0.entry() }

    var colorGenerator = DynamicColorGenerator<LogEntrySource>()

    let dataObserver = DataObserver(
        allCategories: allEntries.map(\.category),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:]) { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        }
    )

    let viewModel = VisualLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: {}
    )

    LogEntriesList()
        .environmentObject(viewModel)
        .onAppear {
            viewModel.showFilterDrawerSubject.value = true
        }
}
