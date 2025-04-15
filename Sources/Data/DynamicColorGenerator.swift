\ MIT License
\ 
\ Copyright (c) 2025 Pedro Almeida
\ 
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in all
\ copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.
import Models
import SwiftUI

package struct DynamicColorGenerator<Element> where Element: Identifiable {
    private var unassignedColors = [DynamicColor]()

    private(set) var assignedColors: [Element.ID: DynamicColor] = [:]

    package init() {}

    package mutating func color(for element: Element) -> DynamicColor {
        generateColorIfNeeded(for: element)
    }

    @discardableResult
    mutating func generateColorIfNeeded(for element: Element) -> DynamicColor {
        if let color = assignedColors[element.id] {
            return color
        }
        if unassignedColors.isEmpty {
            unassignedColors = DynamicColor.makeColors(count: .random(in: 4 ... 8)).shuffled()
        }

        let newColor = unassignedColors.removeFirst()
        assignedColors[element.id] = newColor
        return newColor
    }
}

private struct PreviewItem: Identifiable {
    let id: Int
}

@available(iOS 17, *)
#Preview {
    @Previewable @State
    var generator = DynamicColorGenerator<PreviewItem>()

    let items = (0 ..< 1000).map(PreviewItem.init(id:))

    ScrollView {
        LazyVStack(spacing: 10) {
            ForEach(items) { item in
                HStack(spacing: .zero) {
                    ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                        (generator.color(for: item)[colorScheme]?.color() ?? .secondary)
                            .frame(height: 80)
                            .overlay {
                                Text(generator.color(for: item).description(with: colorScheme))
                                    .font(.caption2.monospaced().bold())
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                            }
                    }
                }
            }
        }
        .padding(15)
    }
    .background(content: {
        HStack(spacing: .zero) {
            Rectangle().fill(Color.white.gradient)
            Rectangle().fill(Color.black.gradient)
        }
        .ignoresSafeArea(edges: .all)
    })
}
