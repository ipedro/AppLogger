import SwiftUI
import Models

struct FiltersRow: View {
    var title: String
    
    @Binding
    var selection: Set<Filter>
    
    let data: [Filter]
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        let _ = Self._debugPrintChanges()
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(data, id: \.self) { filter in
                        FilterView(
                            data: filter,
                            isOn: Binding {
                                selection.contains(filter)
                            } set: { active in
                                if active {
                                    selection.insert(filter)
                                } else {
                                    selection.remove(filter)
                                }
                            }
                        )
                        .equatable()
                    }
                } header: {
                    Text(title)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(
                            top: spacing,
                            leading: spacing * 2,
                            bottom: spacing,
                            trailing: spacing
                        ))
                        .background(.background)
                }
            }
            .padding(.trailing, spacing * 2)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var activeFilters: Set<Filter> = [
        "Filter 1"
    ]
    FiltersRow(
        title: "Filters",
        selection: $activeFilters,
        data: [
            "Filter 1",
            "Filter 2",
            "Filter 3"
        ]
    )
}
