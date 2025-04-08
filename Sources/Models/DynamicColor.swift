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

package struct DynamicColor: Sendable {
    private let data: [ColorScheme: Color]
    
    fileprivate init(_ value: [ColorScheme: Color]) {
        data = value
    }
    
    package func resolve(with colorScheme: ColorScheme) -> Color {
        data[colorScheme, default: .secondary]
    }
    
    package static func makeColors(count: Int = 15) -> [DynamicColor] {
        stride(from: 0, to: 1, by: 1 / CGFloat(count)).map { hue in
            let saturation = CGFloat.random(in: 0.2...0.7)
            let brightness = CGFloat.random(in: 0.4...0.7)
            
            return DynamicColor(ColorScheme.allCases.reduce(into: [:]) { partialResult, colorScheme in
                let uiColor = UIColor(
                    hue: hue + .random(in: 0...0.1),
                    saturation: colorScheme == .dark ? saturation : saturation + 0.4,
                    brightness: colorScheme == .dark ? brightness + 0.3 : brightness,
                    alpha: 1
                )
                
                partialResult[colorScheme] = Color(uiColor: uiColor)
            })
        }
    }
}

#Preview {
    VStack {
        let colors = DynamicColor.makeColors()
        
        ForEach(Array(zip(colors.indices, colors)), id: \.0) { _, color in
            color.resolve(with: .light)
        }
    }
}
