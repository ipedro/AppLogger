import Testing
@testable import Data
@testable import Models

struct DataStoreTests {
    var dataStore: DataStore

    init() async throws {
        dataStore = DataStore()
    }

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
        await dataStore.addLogEntry(logEntry)
        await dataStore.addLogEntry(logEntry)
        let observer = await dataStore.makeObserver()

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
        let observer = await dataStore.makeObserver()
        let logEntry1 = makeLogEntry()
        let logEntry2 = makeLogEntry()
        let logEntry3 = makeLogEntry()

        // When
        await dataStore.addLogEntry(logEntry1)
        await dataStore.addLogEntry(logEntry2)
        await dataStore.addLogEntry(logEntry3)

        // Then
        #expect(
            observer.allEntries.value == [
                logEntry3.id,
                logEntry2.id,
                logEntry1.id
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
        let observer = await dataStore.makeObserver()
        let clearLogsAction = await dataStore.clearLogsAction
        #expect(observer.customActions.value.isEmpty)

        // When
        await dataStore.addLogEntry(makeLogEntry())

        // Then
        #expect(observer.customActions.value == [clearLogsAction])

        // When
        await dataStore.clearLogs()

        // Then
        #expect(observer.customActions.value.isEmpty)
    }

    @Test("Custom actions can be added and removed")
    func addAndRemoveCustomAction() async {
        // Given
        let observer = await dataStore.makeObserver()
        let customAction = VisualLoggerAction(title: "Test", handler: { _ in })

        // When
        await dataStore.addAction(customAction)

        // Then
        #expect(observer.customActions.value == [customAction])

        // When
        await dataStore.removeAction(customAction)

        // Then
        #expect(observer.customActions.value.isEmpty)
    }

    @Test("Clearing logs should remove all stored data")
    func clearLogs() async {
        // Given
        let observer = await dataStore.makeObserver()
        await dataStore.addLogEntry(makeLogEntry())

        // When
        await dataStore.clearLogs()

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
        let observer = await dataStore.makeObserver()
        let customAction = VisualLoggerAction(title: "Test", handler: { _ in })
        let clearLogsAction = await dataStore.clearLogsAction

        // When
        await dataStore.addAction(customAction)
        await dataStore.addLogEntry(makeLogEntry())

        // Then
        #expect(observer.customActions.value == [clearLogsAction, customAction])

        // When
        await dataStore.clearLogs()

        // Then
        #expect(observer.customActions.value == [customAction])
    }

    @Test("`Clear Logs` action should remove all stored data")
    func clearLogsAction() async {
        // Given
        let observer = await dataStore.makeObserver()
        let clearLogsAction = await dataStore.clearLogsAction
        await dataStore.addLogEntry(makeLogEntry())

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
        let observer = await dataStore.makeObserver()
        let logEntry1 = makeLogEntry()
        let logEntry2 = makeLogEntry()
        let logEntry3 = LogEntry(
            category: .debug,
            source: "OtherSource",
            content: "Test content",
            userInfo: ["key": "value"]
        )

        // When
        await dataStore.addLogEntry(logEntry1)

        // Then
        let color = try #require(observer.sourceColors[logEntry1.source.id])

        // When
        await dataStore.addLogEntry(logEntry2)

        // Then
        #expect(observer.allEntries.value.count == 2)
        #expect(observer.sourceColors == [logEntry1.source.id: color])

        // When
        await dataStore.addLogEntry(logEntry3)

        // Then
        #expect(observer.allEntries.value.count == 3)
        #expect(observer.sourceColors.values.count == 2)
        #expect(observer.sourceColors[logEntry1.source.id] == color)
        #expect(observer.sourceColors[logEntry2.source.id] == color)
        #expect(observer.sourceColors[logEntry3.source.id] != color)
    }
}
