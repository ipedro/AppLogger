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

struct DataStoreTests {
    let sut = DataStore()

    func makeLogEntry() -> LogEntry {
        LogEntry(
            category: .debug,
            source: "TestSource",
            content: "Test content",
            userInfo: ["key": "value"]
        )
    }

    @Test("Adding duplicate log entries should not create duplicates")
    func addLogEntry() async {
        // Given
        let logEntry = makeLogEntry()

        // When
        await sut.addLogEntry(logEntry)
        await sut.addLogEntry(logEntry)
        let observer = await sut.makeObserver()

        // Then
        #expect(observer.allEntries.value == [logEntry.id])
        #expect(observer.allCategories.value == [.debug])
        #expect(observer.allSources.value == ["TestSource"])
        #expect(observer.entryContents == [logEntry.id: logEntry.content])
        #expect(observer.entryCategories == [logEntry.id: logEntry.category])
        #expect(observer.entrySources.value[logEntry.id] == logEntry.source)
    }

    @Test("Adding multiple log entries with similar contents should work")
    func addMultipleLogEntry() async {
        // Given
        let observer = await sut.makeObserver()
        let logEntry1 = makeLogEntry()
        let logEntry2 = makeLogEntry()
        let logEntry3 = makeLogEntry()

        // When
        await sut.addLogEntry(logEntry1)
        await sut.addLogEntry(logEntry2)
        await sut.addLogEntry(logEntry3)

        // Then
        #expect(
            observer.allEntries.value == [
                logEntry3.id,
                logEntry2.id,
                logEntry1.id,
            ]
        )
        #expect(
            observer.allCategories.value == [.debug]
        )
        #expect(
            observer.allSources.value == ["TestSource"]
        )
        #expect(
            observer.entryContents == [
                logEntry3.id: logEntry3.content,
                logEntry2.id: logEntry2.content,
                logEntry1.id: logEntry1.content,
            ]
        )
        #expect(
            observer.entryCategories == [
                logEntry3.id: logEntry3.category,
                logEntry2.id: logEntry2.category,
                logEntry1.id: logEntry1.category,
            ]
        )
        #expect(
            observer.entrySources.value == [
                logEntry3.id: logEntry3.source,
                logEntry2.id: logEntry2.source,
                logEntry1.id: logEntry1.source,
            ]
        )
    }

    @Test("`Clear Logs` action is present when logs exist")
    func clearLogActionIsPresentOnlyWhenLogsExist() async {
        // Given
        let observer = await sut.makeObserver()
        let clearLogsAction = await sut.clearLogsAction
        #expect(observer.customActions.value.isEmpty)

        // When
        await sut.addLogEntry(makeLogEntry())

        // Then
        #expect(observer.customActions.value == [clearLogsAction])

        // When
        await sut.clearLogs()

        // Then
        #expect(observer.customActions.value.isEmpty)
    }

    @Test("Custom actions can be added and removed")
    func addAndRemoveCustomAction() async {
        // Given
        let observer = await sut.makeObserver()
        let customAction = VisualLoggerAction(title: "Test", handler: { _ in })

        // When
        await sut.addAction(customAction)

        // Then
        #expect(observer.customActions.value == [customAction])

        // When
        await sut.removeAction(customAction)

        // Then
        #expect(observer.customActions.value.isEmpty)
    }

    @Test("Clearing logs should remove all stored data")
    func clearLogs() async {
        // Given
        let observer = await sut.makeObserver()
        await sut.addLogEntry(makeLogEntry())

        // When
        await sut.clearLogs()

        // Then
        #expect(observer.allEntries.value.isEmpty)
        #expect(observer.allCategories.value.isEmpty)
        #expect(observer.allSources.value.isEmpty)
        #expect(observer.entryContents.isEmpty)
        #expect(observer.entryCategories.isEmpty)
        #expect(observer.entrySources.value.isEmpty)
    }

    @Test("Custom actions are preserved when logs are cleared")
    func clearLogsKeepCustomActions() async {
        // Given
        let observer = await sut.makeObserver()
        let customAction = VisualLoggerAction(title: "Test", handler: { _ in })
        let clearLogsAction = await sut.clearLogsAction

        // When
        await sut.addAction(customAction)
        await sut.addLogEntry(makeLogEntry())

        // Then
        #expect(observer.customActions.value == [clearLogsAction, customAction])

        // When
        await sut.clearLogs()

        // Then
        #expect(observer.customActions.value == [customAction])
    }

    @Test("`Clear Logs` action should remove all stored data")
    func clearLogsAction() async {
        // Given
        let observer = await sut.makeObserver()
        let clearLogsAction = await sut.clearLogsAction
        await sut.addLogEntry(makeLogEntry())

        // When
        #expect(observer.customActions.value == [clearLogsAction])
        await observer.customActions.value[0]()

        // Then
        #expect(observer.allEntries.value.isEmpty)
        #expect(observer.allCategories.value.isEmpty)
        #expect(observer.allSources.value.isEmpty)
        #expect(observer.entryContents.isEmpty)
        #expect(observer.entryCategories.isEmpty)
        #expect(observer.entrySources.value.isEmpty)
    }

    @Test("Source colors are generated for new sources")
    func testSourceColorGeneration() async throws {
        // Given
        let observer = await sut.makeObserver()
        let logEntry1 = makeLogEntry()
        let logEntry2 = makeLogEntry()
        let logEntry3 = LogEntry(
            category: .debug,
            source: "OtherSource",
            content: "Test content",
            userInfo: ["key": "value"]
        )

        // When
        await sut.addLogEntry(logEntry1)

        // Then
        let color1 = try #require(observer.sourceColors[logEntry1.source.id])
        #expect(observer.sourceColors == [logEntry1.source.id: color1])

        // When
        await sut.addLogEntry(logEntry2)

        // Then
        #expect(observer.sourceColors == [logEntry1.source.id: color1])

        // When
        await sut.addLogEntry(logEntry3)

        // Then
        let color2 = try #require(observer.sourceColors[logEntry3.source.id])
        #expect(observer.sourceColors == [
            logEntry1.source.id: color1,
            logEntry3.source.id: color2,
        ])
    }
}
