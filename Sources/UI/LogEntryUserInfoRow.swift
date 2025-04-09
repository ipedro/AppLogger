//  Copyright (c) 2022 Pedro Almeida
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

struct LogEntryUserInfoRow: View {
    let key: String
    let value: String
    let tint: Color?
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            keyText
            Spacer(minLength: spacing)
            valueText
        }
        .padding(spacing)
    }

    private var valueText: some View {
        LinkText(data: value, alignment: .trailing)
            .foregroundColor(tint)
            .font(.system(.caption, design: .monospaced))
    }

    private var keyText: some View {
        Text("\(key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .textSelection(.enabled)
            .isHidden(key.isEmpty)
    }
}

private extension View {
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            EmptyView()
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        LogEntryUserInfoRow(
            key: "Key",
            value: "I'm a value",
            tint: .blue
        )
        
        Divider()
        
        LogEntryUserInfoRow(
            key: "",
            value: "String interpolations are string literals that evaluate any included expressions and convert the results to string form. String interpolations give you an easy way to build a string from multiple pieces. Wrap each expression in a string interpolation in parentheses, prefixed by a backslash.",
            tint: .blue
        )
    }
}
