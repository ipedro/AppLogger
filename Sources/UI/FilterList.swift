import Combine
import Data
import Models
import SwiftUI

struct FilterList: View {
    let title: String

    let keyPath: KeyPath<VisualLoggerViewModel, CurrentValueSubject<[LogFilter], Never>>

    @State
    private var selection = Set<LogFilter>()

    @State
    private var filters = [LogFilter]()
    
    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        let _ = Self._debugPrintChanges()
        VStack {
            if !filters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(
                        spacing: spacing,
                        pinnedViews: .sectionHeaders,
                        content: content
                    )
                    .padding(.trailing, spacing * 2)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .animation(.snappy, value: filters)
        .onReceive(viewModel.activeFiltersSubject) {
            selection = $0
        }
        .onChange(of: selection) {
            viewModel.activeFiltersSubject.send($0)
        }
        .onReceive(viewModel[keyPath: keyPath]) {
            filters = $0
        }
    }
    
    private func content() -> some View {
        Section {
            ForEach(filters, id: \.self) { /*@Sendable*/ filter in
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
}

//@available(iOS 17.0, *)
//#Preview {
//    @Previewable @State
//    var activeFilters: Set<LogFilter> = [
//        "Filter 1",
//    ]
//    FilterList(
//        title: "Filters",
//        selection: $activeFilters,
//        data: [
//            "Filter 1",
//            "Filter 2",
//            "Filter 3",
//        ]
//    )
//}
