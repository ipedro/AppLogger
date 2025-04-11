import SwiftUI

struct FiltersDrawerToggle: View {
    @Binding
    var isOn: Bool
    var activeFilters: Int = 0

    @Environment(\.configuration.icons)
    private var icons
    
    var body: some View {
        Button {
            withAnimation(.snappy) {
                isOn.toggle()
            }
        } label: {
            Image(systemName: isOn ? icons.filtersOn : icons.filtersOff)
                .badge(count: activeFilters)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false
    
    FiltersDrawerToggle(
        isOn: $isOn,
        activeFilters: isOn ? 3 : 0
    )
}
