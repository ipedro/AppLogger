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
    private let data: [ColorScheme: Components]
    
    private init(_ value: [ColorScheme: Components]) {
        data = value
    }
    
    package func resolve(with colorScheme: ColorScheme) -> Color {
        data[colorScheme]?.color() ?? .secondary
    }
    
    package func description(with colorScheme: ColorScheme) -> String {
        data[colorScheme]!.description
    }
    
    struct Components: CustomStringConvertible {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
        
        var description: String {
            "H: \(hue)\nS: \(saturation)\nB: \(brightness)"
        }
        
        func color() -> Color {
            Color(
                uiColor: UIColor(
                    hue: hue,
                    saturation: saturation,
                    brightness: brightness,
                    alpha: 1
                )
            )
        }
    }
    
    package static func makeColors(count: Int = 10) -> [DynamicColor] {
        let start: CGFloat = .random(in: 0...0.3)
        let end: CGFloat = .random(in: 0.8...1.2)
        let strideLength = (end - start) / CGFloat(count)
        
        return stride(from: start, to: end + strideLength, by: strideLength)
            .suffix(count)
            .map { hue in
                let saturation = CGFloat.random(in: 0.2...0.8)
                let brightness = CGFloat.random(in: 0.4...0.8)
                
                return DynamicColor(
                    ColorScheme.allCases.reduce(into: [:]) { dict, colorScheme in
                        let components = switch colorScheme {
                        case .dark:
                            Components(
                                hue: hue,
                                saturation: max(0.4, saturation * 1.1),
                                brightness: max(0.6, brightness * 1.5)
                            )
                        default:
                            Components(
                                hue: hue,
                                saturation: saturation / brightness,
                                brightness: brightness
                            )
                        }
                        
                        dict[colorScheme] = components
                    }
                )
            }
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State
    var colors = DynamicColor.makeColors()
    
    VStack(spacing: 10) {
        ForEach(Array(colors.enumerated()), id: \.offset) { offset, color in
            HStack(spacing: .zero) {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    color.resolve(with: colorScheme).overlay {
                        Text(color.description(with: colorScheme))
                            .font(.caption2.monospaced().bold())
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                    }
                }
            }
        }
    }
    .safeAreaInset(edge: .bottom, spacing: 30, content: {
        Button("Generate Colors") {
            colors = DynamicColor.makeColors()
        }
        .buttonStyle(.borderedProminent)
    })
    .padding(15)
    .background(content: {
        HStack(spacing: .zero) {
            Rectangle().fill(Color.white.gradient)
            Rectangle().fill(Color.black.gradient)
        }
        .ignoresSafeArea(edges: .all)
    })
}
