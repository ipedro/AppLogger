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

struct TitleView: View {
    let tint: Color
    let title: String
    let createdAt: Date
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack(spacing: spacing) {
            Circle().fill(tint).frame(width: spacing, height: spacing)
            Text(title).textSelection(.enabled)
            Spacer()
            Text(createdAt, style: .time).foregroundStyle(.secondary)
        }
        .font(.footnote)
        .padding(.vertical, .zero)
        .padding(.trailing, spacing * 2)
    }
}

#Preview {
    TitleView(
        tint: .pink,
        title: "Category",
        createdAt: Date()
    )
}
