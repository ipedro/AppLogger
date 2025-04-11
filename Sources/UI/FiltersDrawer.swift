import SwiftUI
import class Data.AppLoggerViewModel
import class Data.DataObserver

struct FiltersDrawer: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        VStack(spacing: spacing) {
            SearchBarView(searchQuery: $viewModel.searchQuery)
                .padding(.horizontal, spacing * 2)
            
            if !viewModel.categories.isEmpty {
                FiltersRow(
                    title: "Categories",
                    selection: $viewModel.activeFilters,
                    data: viewModel.categories
                )
                .animation(.snappy, value: viewModel.categories)
            }
            if !viewModel.sources.isEmpty {
                FiltersRow(
                    title: "Sources",
                    selection: $viewModel.activeFilters,
                    data: viewModel.sources
                )
                .animation(.snappy, value: viewModel.sources)
            }
        }
        .font(.footnote)
        .padding(.vertical, spacing)
        .background(.background)
        .safeAreaInset(edge: .bottom, spacing: .zero, content: Divider.init)
    }
}

#Preview {
    FiltersDrawer()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: DataObserver(
//                    allCategories: ["test"],
//                    allSources: ["test"]
                ),
                dismissAction: {
                }
            )
        )
}
