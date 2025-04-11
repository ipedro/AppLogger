import Models
import SwiftUI

struct SortingButton: View {
    var options = LogEntry.Sorting.allCases
    
    @Binding
    var selection: LogEntry.Sorting
    
    @Environment(\.configuration.icons)
    private var icons
    
    var body: some View {
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
    }
    
    private var icon: String {
        icon(selection)
    }
    
    private func icon(_ sorting: LogEntry.Sorting) -> String {
        switch sorting {
        case .ascending: icons.sortAscending
        case .descending: icons.sortDescending
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var selection: LogEntry.Sorting = .ascending
    
    SortingButton(selection: $selection)
}
