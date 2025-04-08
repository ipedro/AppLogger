//
//  ActiveFiltersToggle.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI

struct ActiveFiltersToggle: View {
    @Binding
    var isOn: Bool
    var activeFilters: Int = 0

    @Environment(\.appLoggerConfiguration.icons)
    private var icons
    
    var body: some View {
        Button {
            withAnimation(.bouncy) {
                isOn.toggle()
            }
        } label: {
            Image(systemName: isOn ? icons.filtersOn : icons.filtersOff)
                .badge(count: activeFilters)
                .font(.title3)
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false
    
    ActiveFiltersToggle(isOn: $isOn, activeFilters: isOn ? 3 : 0)
}
