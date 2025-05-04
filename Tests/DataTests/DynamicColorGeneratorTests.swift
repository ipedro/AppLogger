@testable import Data
@testable import Models
import Testing

struct DynamicColorGeneratorTests {
    struct Item: Identifiable {
        let id: Int
    }

    @Test("color(for:) returns the same color for the same element")
    func testColorConsistency() {
        // Given
        var sut = DynamicColorGenerator<Item>()
        let item = Item(id: 1)

        // When
        let firstColor = sut.color(for: item)
        let secondColor = sut.color(for: item)

        // Then
        #expect(firstColor == secondColor)
        #expect(sut.assignedColors[item.id] == firstColor)
    }

    @Test("generateColorIfNeeded assigns unique colors for different elements")
    func testUniqueColorsForDifferentElements() {
        // Given
        var sut = DynamicColorGenerator<Item>()
        let item1 = Item(id: 1)
        let item2 = Item(id: 2)

        // When
        let color1 = sut.generateColorIfNeeded(for: item1)
        let color2 = sut.generateColorIfNeeded(for: item2)

        // Then
        #expect(color1 != color2)
        #expect(sut.assignedColors.count == 2)
        #expect(sut.assignedColors[item1.id] == color1)
        #expect(sut.assignedColors[item2.id] == color2)
    }

    @Test("repopulates colors when unassigned colors are exhausted")
    func testRepopulationWhenExhausted() {
        // Given
        var sut = DynamicColorGenerator<Item>()
        let maxCount = 8

        // When
        let newItem = Item(id: maxCount)
        let newColor = sut.generateColorIfNeeded(for: newItem)

        for id in 0..<maxCount {
            _ = sut.generateColorIfNeeded(for: Item(id: id))
        }

        // Then
        #expect(sut.assignedColors.count == maxCount + 1)
        #expect(sut.assignedColors[newItem.id] == newColor)
    }
}
