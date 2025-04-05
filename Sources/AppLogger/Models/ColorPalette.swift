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
import UIKit

enum ColorPalette {

    struct DynamicColor: Hashable {
        private let colors: [ColorScheme: UIColor]

        init(_ colors: [ColorScheme: UIColor]) {
            self.colors = colors
        }

        func with(_ colorScheme: ColorScheme) -> UIColor? {
            colors[colorScheme]
        }
    }

    static var allColors: [DynamicColor] {
        stride(from: 0, to: 1, by: 0.1).map { hue in

            let saturation = CGFloat.random(in: 0.2...0.5)

            let brightness = CGFloat.random(in: 0.4...0.6)

            return DynamicColor(ColorScheme.allCases.reduce(into: [:]) { partialResult, colorScheme in
                partialResult[colorScheme] = UIColor(
                    hue: hue + .random(in: 0...0.1),
                    saturation: colorScheme == .dark ? saturation : saturation + 0.4,
                    brightness: colorScheme == .dark ? brightness + 0.3 : brightness,
                    alpha: 1
                )
            })
        }
    }
}

struct ColorPalettePreviews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            Group {
                VStack() {
                    ForEach(ColorPalette.allColors, id: \.self) { color in
                        Rectangle()
                            .foregroundColor(Color(color.with(colorScheme) ?? .clear))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .previewLayout(.sizeThatFits)
            .colorScheme(colorScheme)
        }
    }
}
