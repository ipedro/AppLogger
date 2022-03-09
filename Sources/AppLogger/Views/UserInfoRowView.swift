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

import Foundation
import SwiftUI

struct UserInfoRowView: View {
    let key: String
    let value: String
    let valueColor: Color?
    let formattedValue: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if key.isEmpty {
                valueText
                Spacer()
            } else {
                keyText
                Spacer(minLength: 8)
                valueText
            }
        }
    }

    private var valueText: some View {
        LinkText(formattedValue, alignment: .trailing)
            .foregroundColor(valueColor)
            .font(.system(.caption, design: .monospaced))
            .safeTextSelection()
    }

    private var keyText: some View {
        Text("\(key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .safeTextSelection()
    }
}

// MARK: - Previews

struct UserInfoRowViewPreviews: PreviewProvider {
    static var previews: some View {
        UserInfoRowView(
            key: "Key",
            value: "Value",
            valueColor: .blue,
            formattedValue: "I'm a value"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
