//
//  DismissButton.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI

struct DismissButton: View {
    var action: () -> Void
    
    @Environment(\.appLoggerConfiguration.icons.dismiss)
    private var icon
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.footnote.bold())
                .padding(7)
                .background {
                    Circle().fill(Color.primary.opacity(0.1))
                }
        }
    }
}

#Preview {
    DismissButton(action: {})
}
