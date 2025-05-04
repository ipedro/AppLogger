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

import Combine
@testable import Data
import Foundation
@testable import Models
import Testing

@MainActor
struct VisualLoggerViewModelTests {
    @Test("sourceColor returns provided color or secondary when absent")
    func sourceColor() {
        // Given
        let source = LogEntrySource("TestSource")
        let color = DynamicColor.makeColors(count: 1).first!
        let dataObserver = DataObserver(sourceColors: [source.id: color])
        let sut = VisualLoggerViewModel(dataObserver: dataObserver, dismissAction: {})

        // Then
        let expected = color[.light]?.color() ?? .secondary
        #expect(sut.sourceColor(source, for: .light) == expected)
    }

    @Test func noSourceColor() async throws {
        // Given
        let dataObserver = DataObserver()
        let sut = VisualLoggerViewModel(dataObserver: dataObserver, dismissAction: {})
        let source = LogEntrySource("TestSource")

        // When
        #expect(sut.sourceColor(source, for: .dark) == .secondary)
    }

    @Test("entry accessors return underlying observer values")
    func entryAccessors() {
        // Given
        let date = Date()
        let id = LogEntryID(date: date)
        let source = LogEntrySource("Src")
        let category = LogEntryCategory("Cat")
        let content: LogEntryContent = "Content"
        let userInfo: LogEntryUserInfo = ["key": "value"]
        let expectedKey = LogEntryUserInfoKey(id: id, key: "key")

        let observer = DataObserver(
            entryCategories: [id: category],
            entryContents: [id: content],
            entrySources: [id: source],
            entryUserInfos: [id: userInfo]
        )
        let sut = VisualLoggerViewModel(
            dataObserver: observer,
            dismissAction: {}
        )

        // Then
        #expect(sut.entrySource(id) == source)
        #expect(sut.entryCategory(id) == category)
        #expect(sut.entryContent(id) == content)
        #expect(sut.entryUserInfoKeys(id) == [expectedKey])
        #expect(sut.entryUserInfoValue(expectedKey) == "value")
        #expect(sut.entryCreatedAt(id) == date)
    }

    @Test("`stop()` clears state subjects")
    func stopClearsState() {
        // Given
        let observer = DataObserver()
        let action = VisualLoggerAction(title: "Test") { _ in }
        let sut = VisualLoggerViewModel(dataObserver: observer, dismissAction: {})
        sut.activeFilterScopeSubject.value = ["scope"]
        sut.activeFiltersSubject.value = [LogFilter(.all, query: "", displayName: "")]
        sut.categoryFiltersSubject.value = [LogFilter(.all, query: "", displayName: "")]
        sut.currentEntriesSubject.value = [LogEntryID(date: Date())]
        sut.customActionsSubject.value = [action]
        sut.searchQuerySubject.value = "query"
        sut.sourceFiltersSubject.value = [LogFilter(.all, query: "", displayName: "")]

        // When
        sut.stop()

        // Then
        #expect(sut.activeFilterScopeSubject.value.isEmpty)
        #expect(sut.activeFiltersSubject.value.isEmpty)
        #expect(sut.categoryFiltersSubject.value.isEmpty)
        #expect(sut.currentEntriesSubject.value.isEmpty)
        #expect(sut.customActionsSubject.value.isEmpty)
        #expect(sut.searchQuerySubject.value.isEmpty)
        #expect(sut.sourceFiltersSubject.value.isEmpty)
    }

    @Test("dismissAction is called when invoked")
    func dismissAction() {
        // Given
        var called = false
        let sut = VisualLoggerViewModel(
            dataObserver: DataObserver(),
            dismissAction: {
                called = true
            }
        )

        // When
        sut.dismissAction()

        // Then
        #expect(called)
    }
}
