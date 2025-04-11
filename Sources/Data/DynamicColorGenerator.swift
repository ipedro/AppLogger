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
