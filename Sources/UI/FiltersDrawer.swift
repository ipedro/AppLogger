import Data
import Models
import SwiftUI

struct FiltersDrawer: View {
    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @Environment(\.spacing)
    private var spacing

    @State
    private var activeFilters: Set<LogFilter> = []

    @State
    private var categories: [LogFilter] = []

    @State
    private var sources: [LogFilter] = []

    var body: some View {
        let _ = Self._debugPrintChanges()
        VStack(spacing: spacing) {
            SearchBarView()
                .padding(.horizontal, spacing * 2)

            if !categories.isEmpty {
                FiltersRow(
                    title: "Categories",
                    selection: $activeFilters,
                    data: categories
                )
                .animation(.snappy, value: categories)
            }
            if !sources.isEmpty {
                FiltersRow(
                    title: "Sources",
                    selection: $activeFilters,
                    data: sources
                )
                .animation(.snappy, value: sources)
            }
        }
        .font(.footnote)
        .padding(.vertical, spacing)
        .background(.background)
        .safeAreaInset(
            edge: .bottom,
            spacing: .zero,
            content: Divider.init
        )
        .onReceive(viewModel.activeFiltersSubject) {
            activeFilters = $0
        }
        .onReceive(viewModel.categoriesSubject) {
            categories = $0
        }
        .onReceive(viewModel.sourcesSubject) {
            sources = $0
        }
        .onChange(of: activeFilters) {
            viewModel.activeFiltersSubject.send($0)
        }
    }
}

#Preview {
    FiltersDrawer()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: DataObserver(
                    allCategories: ["test", "test2"],
                    allSources: ["test"]
                ),
                dismissAction: {}
            )
        )
}
