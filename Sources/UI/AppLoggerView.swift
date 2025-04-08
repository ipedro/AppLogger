//
//  AppLoggerView.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI
import Models
import class Data.DataObserver

package final class AppLoggerViewModel: ObservableObject {
    @Published
    var searchQuery: String = ""
    
    @Published
    var showFilters = false
    
    @Published
    var sorting: Sorting = .ascending
    
    @Published
    var activityItem: ActivityItem?
    
    @Published
    var activeFilters: [Filter.ID] = []
    
    @Published
    var sources: [Filter] = []
    
    @Published
    var categories: [Filter] = []
    
    @Published
    var entries: [ID] = []
    
    private let dataObserver: DataObserver
    
    let dismissAction: @MainActor () -> Void
    
    package init(
        dataObserver: DataObserver,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction
    }
}

package struct AppLoggerView: View {
    
//    @State
//    var searchQuery: String = ""
//    
//    @State
//    var showFilters = false
//    
//    @State
//    var sorting: Sorting = .ascending
//    
//    @State
//    private var activityItem: ActivityItem?
    
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
    
//    var entries: [ID] { [] }
//    
//    var categories: [Filter] { [] }
//    
//    var sources: [Filter] { [] }
    
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
                            EntryView(id: id)
                                .equatable()
                                .safeAreaInset(
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
