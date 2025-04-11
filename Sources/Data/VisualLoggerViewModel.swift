import Combine
import Foundation
import Models
import SwiftUI

@MainActor
package final class VisualLoggerViewModel: ObservableObject {
    package let dismissAction: @MainActor () -> Void

    package let dataObserver: DataObserver

    private var cancellables = Set<AnyCancellable>()

    // Subjects

    package let searchQuerySubject = CurrentValueSubject<String, Never>("")

    package let showFilterDrawerSubject = CurrentValueSubject<Bool, Never>(UserDefaults.standard.showFilters)

    package let entriesSortingSubject = CurrentValueSubject<LogEntrySorting, Never>(UserDefaults.standard.sorting)

    package let activeFiltersSubject = CurrentValueSubject<Set<Filter>, Never>([])

    package var sourcesSubject = CurrentValueSubject<[Filter], Never>([])

    package var categoriesSubject = CurrentValueSubject<[Filter], Never>([])

    package var entriesSubject = CurrentValueSubject<[LogEntryID], Never>([])

    package var activeFilterScopeSubject = CurrentValueSubject<[String], Never>([])

    package init(dataObserver: DataObserver, dismissAction: @escaping @MainActor () -> Void) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction

        setupPublishers()
    }
}

package extension VisualLoggerViewModel {
    func sourceColor(_ source: LogEntrySource, for colorScheme: ColorScheme) -> Color {
        dataObserver.sourceColors[source.id]?[colorScheme]?.color() ?? .secondary
    }

    func entrySource(_ id: LogEntryID) -> LogEntrySource {
        dataObserver.entrySources[id]!
    }

    func entryCategory(_ id: LogEntryID) -> LogEntryCategory {
        dataObserver.entryCategories[id]!
    }

    func entryContent(_ id: LogEntryID) -> LogEntryContent {
        dataObserver.entryContents[id]!
    }

    func entryUserInfoKeys(_ id: LogEntryID) -> [LogEntryUserInfoKey]? {
        dataObserver.entryUserInfoKeys[id]
    }

    func entryUserInfoValue(_ id: LogEntryUserInfoKey) -> String {
        dataObserver.entryUserInfoValues[id, default: "–"]
    }

    func entryCreatedAt(_ id: LogEntryID) -> Date {
        id.createdAt
    }
}

private extension VisualLoggerViewModel {
    func setupPublishers() {
        // Categories pipeline
        Publishers.CombineLatest(
            dataObserver.allCategories.throttleOnMain(for: 0.15),
            activeFiltersSubject
        )
        .map { allCategories, activeFilters in
            Set(allCategories.map(\.filter)).sort(by: activeFilters)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            categoriesSubject.send($0)
        }
        .store(in: &cancellables)

        // Sources pipeline
        Publishers.CombineLatest(
            dataObserver.allSources.throttleOnMain(for: 0.15),
            activeFiltersSubject
        )
        .map { allSources, activeFilters in
            Set(allSources.map(\.filter)).sort(by: activeFilters)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            sourcesSubject.send($0)
        }
        .store(in: &cancellables)

        // Active Filter Scope pipeline
        Publishers.CombineLatest(
            activeFiltersSubject,
            searchQuerySubject
        )
        .map { filter, query in
            var scope = filter.sorted()
            let trimmedQuery = query.trimmed
            if !trimmedQuery.isEmpty {
                scope.append(trimmedQuery.filter)
            }
            return scope.map(\.displayName)
        }
        .sink { [unowned self] in
            activeFilterScopeSubject.send($0)
        }
        .store(in: &cancellables)

        // Entries pipeline
        Publishers.CombineLatest4(
            dataObserver.allEntries.throttleOnMain(for: 0.15),
            searchQuerySubject.debounceOnMain(for: 0.3).map(\.trimmed),
            activeFiltersSubject,
            entriesSortingSubject
        )
        .receive(on: RunLoop.main)
        .map { [unowned self] entries, query, filters, sorting in
            UserDefaults.standard.sorting = sorting
            var result = filterEntries(entries, with: filters)
            if !query.isEmpty {
                result = filterEntries(result, with: [query.filter])
            }
            return result.sort(by: sorting)
        }
        .sink { [unowned self] in
            entriesSubject.send($0)
        }
        .store(in: &cancellables)

        // Persisting showFilters to UserDefaults
        showFilterDrawerSubject
            .sink {
                UserDefaults.standard.showFilters = $0
            }
            .store(in: &cancellables)
    }
}

private extension VisualLoggerViewModel {
    func filterEntries(_ entries: [LogEntryID], with filters: Set<Filter>) -> [LogEntryID] {
        var result = entries

        if !filters.isEmpty {
            result = result.filter { id in
                filterEntry(id, with: filters)
            }
        }

        return result
    }

    func filterEntry(_ id: LogEntryID, with filters: Set<Filter>) -> Bool {
        var source: LogEntrySource {
            dataObserver.entrySources[id]!
        }

        var category: LogEntryCategory {
            dataObserver.entryCategories[id]!
        }

        var content: LogEntryContent {
            dataObserver.entryContents[id]!
        }

        var userInfo: Set<String> {
            let keys = dataObserver.entryUserInfoKeys[id, default: []]
            var userInfo = Set(keys.map(\.key))
            for key in keys {
                if let value = dataObserver.entryUserInfoValues[key] {
                    userInfo.insert(value)
                }
            }
            return userInfo
        }

        for filter in filters {
            if filter.kind.contains(.source) {
                if source.matches(filter) { return true }
            }
            if filter.kind.contains(.category) {
                if category.matches(filter) { return true }
            }
            if filter.kind.contains(.content) {
                if content.matches(filter) { return true }
            }
            if filter.kind.contains(.userInfo) {
                if userInfo.contains(where: { $0.matches(filter) }) { return true }
            }
        }

        return false
    }
}

private extension Publisher {
    func debounceOnMain(
        for dueTime: RunLoop.SchedulerTimeType.Stride,
        options: RunLoop.SchedulerOptions? = nil
    ) -> Publishers.Debounce<Self, RunLoop> {
        debounce(for: dueTime, scheduler: RunLoop.main, options: options)
    }

    func throttleOnMain(
        for dueTime: RunLoop.SchedulerTimeType.Stride,
        latest: Bool = true
    ) -> Publishers.Throttle<Self, RunLoop> {
        throttle(for: dueTime, scheduler: RunLoop.main, latest: latest)
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension UserDefaults {
    var sorting: LogEntrySorting {
        get {
            let rawValue = integer(forKey: "VisualLogger.sorting")
            return LogEntrySorting(rawValue: rawValue) ?? .descending
        }
        set {
            set(newValue.rawValue, forKey: "VisualLogger.sorting")
        }
    }

    var showFilters: Bool {
        get {
            bool(forKey: "VisualLogger.showFilters")
        }
        set {
            set(newValue, forKey: "VisualLogger.showFilters")
        }
    }
}
