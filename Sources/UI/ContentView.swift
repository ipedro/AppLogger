//
//  ContentView.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import SwiftUI
import struct Models.Category
import struct Models.Content

struct ContentView: View {
    var category: Category
    var content: Content
    var tint: Color
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        Text(content.description)
            .bold()
            .font(.callout)
            .minimumScaleFactor(0.85)
            .lineLimit(3)
            .padding(.horizontal, spacing * 2)
        
        if let message = content.output, !message.isEmpty {
            HStack(alignment: .top) {
                if let icon = category.emoji {
                    Text(String(icon))
                }
                
                LinkText(data: message)
            }
            .font(.footnote)
            .foregroundStyle(tint)
            .padding(spacing * 1.5)
            .background(tint.opacity(0.16))
            .cornerRadius(spacing * 1.8)
            .padding(.horizontal, spacing * 2)
            .padding(.vertical, spacing)
        }

    }
}

#Preview {
    ContentView(
        category: .alert,
        content: Content("content", output: "Bla", userInfo: [:]),
        tint: .accentColor
    )
}
