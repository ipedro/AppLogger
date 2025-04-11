import Data
import Models
import SwiftUI

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
    let allEntries = LogEntryMock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<LogEntrySource>()
    
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
