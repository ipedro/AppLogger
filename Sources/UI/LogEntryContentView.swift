//  Copyright (c) 2025 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI
import struct Models.Category
import struct Models.Content

struct LogEntryContentView: View {
    var category: Category
    var content: Content
    var tint: Color
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(content.message)
                .bold()
                .font(.callout)
                .minimumScaleFactor(0.85)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
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
                .background {
                    RoundedRectangle(cornerRadius: spacing * 2)
                        .fill(tint.opacity(0.1))
                }
            }
        }
    }
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: Content("content description", output: "Bla"),
        tint: .accentColor
    )
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: "content description",
        tint: .accentColor
    )
}
