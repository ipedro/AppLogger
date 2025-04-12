import Data
import Models
import SwiftUI

struct FiltersDrawer: View {
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        let _ = Self._debugPrintChanges()
        VStack(spacing: spacing) {
            SearchBarView()
                .padding(.horizontal, spacing * 2)

            FilterList(
                title: "Categories",
                keyPath: \.categoryFiltersSubject
            )
            
            FilterList(
                title: "Sources",
                keyPath: \.sourceFiltersSubject
            )
        }
        .font(.footnote)
        .padding(.vertical, spacing)
        .background(.background)
        .safeAreaInset(
            edge: .bottom,
            spacing: .zero,
            content: Divider.init
        )
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
