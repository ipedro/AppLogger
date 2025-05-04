// MIT License
//
// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@testable import Data
@testable import Models
import Testing

struct DynamicColorGeneratorTests {
    struct Item: Identifiable {
        let id: Int
    }

    @Test("color(for:) returns the same color for the same element")
    func colorConsistency() {
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
    func uniqueColorsForDifferentElements() {
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
    func repopulationWhenExhausted() {
        // Given
        var sut = DynamicColorGenerator<Item>()
        let maxCount = 8

        // When
        let newItem = Item(id: maxCount)
        let newColor = sut.generateColorIfNeeded(for: newItem)

        for id in 0 ..< maxCount {
            _ = sut.generateColorIfNeeded(for: Item(id: id))
        }

        // Then
        #expect(sut.assignedColors.count == maxCount + 1)
        #expect(sut.assignedColors[newItem.id] == newColor)
    }
}
