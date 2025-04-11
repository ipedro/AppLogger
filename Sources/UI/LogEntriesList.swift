import Data
import Models
import SwiftUI

package struct LogEntriesList: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.configuration)
    private var configuration
    
    @State
    private var entries: [LogEntryID] = []
    
    @State
    private var searchQuery = ""
    
    @State
    private var showFilters: Bool = false
    
    @State
    private var activeFilterScope: [String] = []
    
    package var body: some View {
        let _ = Self._debugPrintChanges()
        ScrollView {
            LazyVStack(spacing: .zero, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(entries, id: \.self) { id in
                        LogEntryView(id: id)
                        
                        if id != entries.last {
                            Divider()
                        }
                    }
                } header: {
                    if showFilters {
                        FiltersDrawer().transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                    }
                }
            }
            .padding(.bottom, 50)
            .animation(.snappy, value: entries)
        }
        .clipped()
        .ignoresSafeArea(.container, edges: .bottom)
        .background {
            if entries.isEmpty {
                Text(emptyReason)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.top, showFilters ? 150 : 0)
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
        .onReceive(viewModel.entriesSubject) {
            entries = $0
        }
        .onReceive(viewModel.showFilterDrawerSubject) {
            showFilters = $0
        }
        .onReceive(viewModel.searchQuerySubject) {
            searchQuery = $0
        }
        .onReceive(viewModel.activeFilterScopeSubject) {
            activeFilterScope = $0
        }
    }
    
    private var emptyReason: String {
        if searchQuery.isEmpty {
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
            
            SortingButton()
                .disabled(entries.isEmpty)
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
            viewModel.showFilterDrawerSubject.value = true
        }
}
