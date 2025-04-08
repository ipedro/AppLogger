//
//  File.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI
import Models

struct AppLoggerView: View {
    
    @State
    var searchQuery: String = ""
    
    @State
    var showFilters = false
    
    @State
    var sorting: Sorting = .ascending
    
    @State
    private var activityItem: ActivityItem?
    
    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.configuration.navigationTitle)
    private var navigationTitle
    
    @Environment(\.configuration.emptyReasons)
    private var emptyReasons
    
    @Environment(\.spacing)
    private var spacing
    
    var bottomPadding: CGFloat = 0
    
    var entries: [ID]
    
    var categories: [Filter]
    
    var sources: [Filter]
    
    private var emptyReason: String {
        if searchQuery.isEmpty {
            emptyReasons.empty
        } else {
            "\(emptyReasons.searchResults) \"\(searchQuery)\""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                filtersDrawer
                
                ScrollView {
                    LazyVStack(spacing: .zero) {
                        ForEach(entries, id: \.self) { id in
                            EntryView(id: id)
                                .equatable()
                                .safeAreaInset(
                                    edge: .bottom,
                                    content: Divider.init
                                )
                        }
                    }
                    .background {
                        if entries.isEmpty {
                            Text(emptyReason)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                                .padding(.top, 200)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, bottomPadding)
                }
                .onDrag { info in
                    self.showFilters = info.predictedEndTranslation.height > 0
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
        .activitySheet($activityItem)
    }
    
    private var filtersDrawer: some View {
        VStack(spacing: .zero) {
            HStack {
                ActiveFiltersToggle(
                    isOn: $showFilters,
                    activeFilters: showFilters ? 3 : 0
                )
                .disabled(sources.isEmpty && categories.isEmpty)
                
                SearchBarView(searchQuery: $searchQuery)
                
                SortingButton(selection: $sorting)
                    .opacity(entries.isEmpty ? 0.5 : 1)
                    .disabled(entries.isEmpty)
            }
            .padding(.horizontal)
            if showFilters && !categories.isEmpty {
                FiltersView(title: "Categories", data: categories)
            }
            if showFilters && !sources.isEmpty {
                FiltersView(title: "Sources", data: sources)
            }
        }
        .safeAreaInset(edge: .bottom, content: Divider.init)
        .foregroundColor(.primary)
    }
    
    private var leadingNavigationBarItems: some View {
        ExportButton {
            self.activityItem = nil //dataStore.csvActivityItem()
            fatalError("implement")
        }
        .foregroundColor(.primary)
    }
    
    private var trailingNavigationBarItems: some View {
        DismissButton {
            fatalError("implement")
        }
    }
}

#Preview {
    AppLoggerView(
        searchQuery: "",
        entries: [],
        categories: ["Managers"],
        sources: ["Apple", "Google"]
    )
}
