//
//  ExportButton.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI

struct ExportButton: View {
    var action: () -> Void
    
    @Environment(\.appLoggerConfiguration.icons.export)
    private var icon
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon).font(.callout)
        }
    }
}

#Preview {
    ExportButton(action: {})
}
