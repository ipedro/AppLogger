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

struct AppLoggerView: View {
    @EnvironmentObject var viewModel: ViewModel
    let dismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var activityItem: ActivityItem?
    @State private var animate: Bool = false
    @State private var showFilters: Bool = true

    private var icons: AppLoggerConfiguration.Icons {
        viewModel.configuration.icons
    }

    private var exportButton: some View {
        Button {
            self.activityItem = viewModel.csvActivityItem()
        } label: {
            Image(systemName: viewModel.configuration.icons.export)
                .font(.callout)
        }
    }

    private var filtersButton: some View {
        Button {
            self.showFilters.toggle()
        } label: {
            Image(systemName: showFilters ? icons.filtersOn : icons.filtersOff)
                .font(.callout)
                .badge(count: viewModel.dataSource.activeFilters)
        }
    }

    private var sortingButton: some View {
        Menu {
            Text("Sort")
            ForEach(DataSource.Sorting.allCases, id: \.self) { sorting in
                Button {
                    self.viewModel.dataSource.rowsSorting = sorting
                } label: {
                    if self.viewModel.dataSource.rowsSorting == sorting {
                        Text("\(sorting.description) ✓")
                    }
                    else {
                        Text(sorting.description)
                    }
                }
            }
        } label: {
            Image(systemName: icons.sorting)
                .font(.footnote)
                .rotationEffect(.degrees(self.viewModel.dataSource.rowsSorting == .ascending ? 0 : 180))
        }
    }

    private var dismissButton: some View {
        Button(action: dismiss) {
            Image(systemName: icons.dismiss)
                .foregroundColor(.secondary)
                .font(.caption2.weight(.heavy))
                .padding(7)
                .background(Color(.mediumBackground))
                .cornerRadius(24)
        }
    }

    private var filtersStack: some View {
        VStack {
            FiltersView(
                title: "Categories",
                filters: $viewModel.dataSource.categories
            )

            if !viewModel.dataSource.sources.isEmpty {
                FiltersView(
                    title: "Sources",
                    filters: $viewModel.dataSource.sources
                )
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                SearchBarView(
                    searchQuery: $viewModel.dataSource.searchQuery
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
                        entries: viewModel.dataSource.rows,
                        emptyReason: viewModel.emptyReason
                    )
                    .padding(.bottom, viewModel.bottomPadding)
                }
                .onDrag { info in
                    self.showFilters = info.predictedEndTranslation.height > 0
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.configuration.navigationTitle)
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
            .animation(.easeInOut(duration: 0.35), value: viewModel.dataSource)
            .animation(.easeInOut(duration: 0.35), value: showFilters)
            .endEditingOnDrag()
        }
        .preferredColorScheme(viewModel.configuration.colorScheme)
        .onAppear {
            self.animate = true
        }
        .activitySheet($activityItem)
    }
}

final class AppLoggerView_Previews: PreviewProvider, ObservableObject {
    private static var randomInterval: TimeInterval { .random(in: 1...10) }

    private static var needsSetup = true

    private static var timer = Timer(timeInterval: randomInterval, repeats: true) { _ in
        guard let randomEntry = AppLoggerEntryMock.allCases.randomElement() else { return }
        AppLogger.sharedInstance.addLogEntry(
            .init(
                category: randomEntry.category,
                source: randomEntry.source,
                content: randomEntry.content
            )
        )
    }

    static var previews: some View {
        if Self.needsSetup {
            Self.needsSetup = false
            RunLoop.current.add(timer, forMode: .common)
        }

        let colorScheme: ColorScheme = .allCases.randomElement() ?? .light

        return Group {
            AppLoggerView(
                dismiss: {}
            )
            .environmentObject({ () -> ViewModel in
                let viewModel = ViewModel(
                    configuration: .init(
                        navigationTitle: String(describing: colorScheme),
                        colorScheme: colorScheme
                    )
                )
                AppLoggerEntryMock.allCases.forEach {
                    viewModel.addLogEntry($0)
                }
                return viewModel
            }())

            PresentingView(
                configuration: .init(
                    navigationTitle: "Entries every \(NumberFormatter().string(for: randomInterval)!)s",
                    colorScheme: colorScheme
                )
            )
        }
    }
}

private struct PresentingView: View {
    @State private var isPresenting = true
    var configuration: AppLoggerConfiguration
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
            configuration: configuration
        ) {
            self.isPresenting = false
        }
    }
}
