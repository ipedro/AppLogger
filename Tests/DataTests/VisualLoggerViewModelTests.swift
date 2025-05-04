
//  VisualLoggerViewModelTests.swift
//  swiftui-visual-logger
//
//  Created by Pedro Almeida on 05.05.25.
//

@testable import Data
@testable import Models
import Testing
import Combine
import Foundation

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
    func testEntryAccessors() {
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
    func testStopClearsState() {
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
    func testDismissAction() {
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

    @Test("changing entriesSortingSubject persists to UserDefaults")
    func testSortingPersistence() {
        // Given
        let sut = VisualLoggerViewModel(
            dataObserver: DataObserver(),
            dismissAction: {}
        )

        // When
        sut.entriesSortingSubject.value = .ascending

        // Then
        #expect(UserDefaults.standard.sorting == .ascending)
    }

    @Test("changing showFilterDrawerSubject persists to UserDefaults")
    func testShowFiltersPersistence() {
        // Given
        let sut = VisualLoggerViewModel(
            dataObserver: DataObserver(),
            dismissAction: {}
        )

        // When
        sut.showFilterDrawerSubject.value = true

        // Then
        #expect(UserDefaults.standard.showFilters)
    }

    @Test("customActionsSubject updates when DataObserver customActions changes")
    func testCustomActionsPropagation() {
        // Given
        let observer = DataObserver()
        let vm = VisualLoggerViewModel(dataObserver: observer, dismissAction: {})
        let action = VisualLoggerAction(title: "Action") { _ in }

        // When
        observer.customActions.send([action])

        // Then
        #expect(vm.customActionsSubject.value == [action])
    }
}
