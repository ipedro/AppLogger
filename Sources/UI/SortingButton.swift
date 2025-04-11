import Data
import Models
import SwiftUI

struct SortingButton: View {
    var options = LogEntrySorting.allCases

    @EnvironmentObject
    private var viewModel: AppLoggerViewModel

    @State
    private var selection: LogEntrySorting = .ascending

    @Environment(\.configuration.icons)
    private var icons

    var body: some View {
        let _ = Self._debugPrintChanges()
        Menu {
            Picker("Sorting", selection: $selection) {
                ForEach(options, id: \.rawValue) { option in
                    Label(option.description, systemImage: icon(option)).tag(option)
                }
            }
        } label: {
            Image(systemName: icon)
        }
        .symbolRenderingMode(.hierarchical)
        .onReceive(viewModel.entriesSortingSubject) {
            selection = $0
        }
        .onChange(of: selection) {
            viewModel.entriesSortingSubject.send($0)
        }
    }

    private var icon: String {
        icon(selection)
    }

    private func icon(_ sorting: LogEntrySorting) -> String {
        switch sorting {
        case .ascending: icons.sortAscending
        case .descending: icons.sortDescending
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    SortingButton()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: DataObserver(),
                dismissAction: {}
            )
        )
}
