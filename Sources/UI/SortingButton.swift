//
//  SortingButton.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI
import enum Models.Sorting
import struct Models.Configuration

struct SortingButton: View {
    var options = Sorting.allCases
    
    @Binding
    var selection: Sorting
    
    @Environment(\.configuration.icons)
    private var icons
    
    var body: some View {
        Menu {
            ForEach(options, id: \.rawValue) { option in
                Button(
                    option.rawValue.localizedCapitalized + (option == selection ? " ✓" : ""),
                    systemImage: icon(option),
                    action: { selection = option }
                )
            }
        } label: {
            Image(systemName: icon).font(.title3)
        }
    }
    
    private var icon: String {
        icon(selection)
    }
    
    private func icon(_ sorting: Sorting) -> String {
        switch sorting {
        case .ascending: icons.sortAscending
        case .descending: icons.sortDescending
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var selection: Sorting = .ascending
    
    SortingButton(selection: $selection)
}
