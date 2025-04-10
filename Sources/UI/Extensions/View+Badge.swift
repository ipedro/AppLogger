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

extension View {
    func badge(
        count: Int = 0,
        foregroundColor: Color = .white,
        backgroundColor: Color = .red
    ) -> some View {
        modifier(
            BadgeModifier(
                count: count,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor
            )
        )
    }
}

struct BadgeModifier: ViewModifier {
    var count: Int
    var foregroundColor: Color
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            if count != 0 {
                ZStack {
                    Text(count, format: .number)
                        .font(.caption2)
                        .foregroundStyle(foregroundColor)
                        .fixedSize()
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 1)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(Capsule().fill(backgroundColor))
                    
                }
                .transition(.scale.combined(with: .opacity))
                .frame(width: 0, height: 0)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(body: {
    @Previewable @State
    var count = 0
    
    Button("Test") {
        count = count == 0 ? 10 : 0
    }
    .badge(count: count)
    .animation(.interactiveSpring, value: count)
})
