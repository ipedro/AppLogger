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

struct DataObserverTests {
    @Test("default init yields empty state")
    func emptyInitializer() {
        // Given
        let sut = DataObserver()

        // Then
        #expect(sut.allCategories.value.isEmpty)
        #expect(sut.allEntries.value.isEmpty)
        #expect(sut.allSources.value.isEmpty)
        #expect(sut.customActions.value.isEmpty)
        #expect(sut.entrySources.value.isEmpty)
        #expect(sut.entryCategories.isEmpty)
        #expect(sut.entryContents.isEmpty)
        #expect(sut.entryUserInfoKeys.isEmpty)
        #expect(sut.entryUserInfoValues.isEmpty)
        #expect(sut.sourceColors.isEmpty)
    }

    @Test("init with data denormalizes info keys and values")
    func initializer() {
        // Given
        let entry = LogEntryMock.googleAnalytics.entry()
        let sut = DataObserver(
            allCategories: [entry.category],
            allEntries: [entry.id],
            allSources: [entry.source],
            customActions: [],
            entryCategories: [entry.id: entry.category],
            entryContents: [entry.id: entry.content],
            entrySources: [entry.id: entry.source],
            entryUserInfos: [entry.id: entry.userInfo]
        )

        // Then
        #expect(sut.allCategories.value == [entry.category])
        #expect(sut.allEntries.value == [entry.id])
        #expect(sut.allSources.value == [entry.source])
        #expect(sut.customActions.value.isEmpty)
        #expect(sut.entrySources.value == [entry.id: entry.source])
        #expect(sut.entryCategories == [entry.id: entry.category])
        #expect(sut.entryContents == [entry.id: entry.content])
        #expect(
            sut.entryUserInfoKeys == [
                entry.id: [
                    .init(id: entry.id, key: "customerID"),
                    .init(id: entry.id, key: "screen"),
                ],
            ]
        )
        #expect(
            sut.entryUserInfoValues == [
                .init(id: entry.id, key: "customerID"): "1234567890",
                .init(id: entry.id, key: "screen"): "Home",
            ]
        )
    }

    @Test("updateValues updates internal state and publishes new values")
    func updateValues() {
        // Given
        let sut = DataObserver()
        let entry = LogEntry(
            category: .debug,
            source: "Source",
            content: "Content",
            userInfo: ["k": "v"]
        )
        let id = entry.id
        let source = entry.source
        let action = VisualLoggerAction(title: "Action") { _ in }
        let categories = [entry.category]
        let entries = [id]
        let sources = [source]
        let entryCategories = [id: entry.category]
        let entryContents = [id: entry.content]
        let entrySourcesDict = [id: source]
        let userInfoKey = LogEntryUserInfoKey(id: id, key: "k")
        let entryUserInfoKeys = [id: [userInfoKey]]
        let entryUserInfoValues = [userInfoKey: "v"]
        let color = DynamicColor.makeColors(count: 1).first!
        let sourceColorsDict = [source.id: color]

        sut.updateValues(
            allCategories: categories,
            allEntries: entries,
            allSources: sources,
            customActions: [action],
            entryCategories: entryCategories,
            entryContents: entryContents,
            entrySources: entrySourcesDict,
            entryUserInfoKeys: entryUserInfoKeys,
            entryUserInfoValues: entryUserInfoValues,
            sourceColors: sourceColorsDict
        )

        // Then
        #expect(sut.allCategories.value == categories)
        #expect(sut.allEntries.value == entries)
        #expect(sut.allSources.value == sources)
        #expect(sut.customActions.value == [action])
        #expect(sut.entrySources.value == entrySourcesDict)
        #expect(sut.entryCategories == entryCategories)
        #expect(sut.entryContents == entryContents)
        #expect(sut.entryUserInfoKeys == entryUserInfoKeys)
        #expect(sut.entryUserInfoValues == entryUserInfoValues)
        #expect(sut.sourceColors == sourceColorsDict)
    }
}
