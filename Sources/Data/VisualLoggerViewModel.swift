import Combine
import Foundation
import Models
import SwiftUI

package final class VisualLoggerViewModel: ObservableObject {
    package typealias DismissAction = @MainActor () -> Void

    package let dismissAction: DismissAction

    package let dataObserver: DataObserver

    private var cancellables = Set<AnyCancellable>()

    // Subjects

    package let activeFilterScopeSubject = CurrentValueSubject<[String], Never>([])

    package let activeFiltersSubject = CurrentValueSubject<Set<LogFilter>, Never>([])

    package let categoryFiltersSubject = CurrentValueSubject<[LogFilter], Never>([])

    package let currentEntriesSubject = CurrentValueSubject<[LogEntryID], Never>([])

    package let customActionsSubject = CurrentValueSubject<[VisualLoggerAction], Never>([])

    package let entriesSortingSubject = CurrentValueSubject<LogEntrySorting, Never>(UserDefaults.standard.sorting)

    package let searchQuerySubject = CurrentValueSubject<String, Never>("")

    package let showFilterDrawerSubject = CurrentValueSubject<Bool, Never>(UserDefaults.standard.showFilters)

    package let sourceFiltersSubject = CurrentValueSubject<[LogFilter], Never>([])

    package init(dataObserver: DataObserver, dismissAction: @escaping DismissAction) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction
        setupPublishers()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        debugPrint(#function, "VisualLoggerViewModel released")
    }
}

package extension VisualLoggerViewModel {
    func sourceColor(_ source: LogEntrySource, for colorScheme: ColorScheme) -> Color {
        dataObserver.sourceColors[source.id]?[colorScheme]?.color() ?? .secondary
    }

    func entrySource(_ id: LogEntryID) -> LogEntrySource? {
        dataObserver.entrySources.value[id]
    }

    func entryCategory(_ id: LogEntryID) -> LogEntryCategory? {
        dataObserver.entryCategories[id]
    }

    func entryContent(_ id: LogEntryID) -> LogEntryContent? {
        dataObserver.entryContents[id]
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
        let backgroundQueue = DispatchQueue.global()

        // Category Filters pipeline
        setupCategoryFiltersSubject(backgroundQueue)

        // Source Filters pipeline
        setupSourceFiltersSubject(backgroundQueue)

        // Active Filter Scope pipeline
        setupActiveFilterScopeSubject(backgroundQueue)

        // Entries pipeline
        setupCurrentEntriesSubject(backgroundQueue)

        // Custom actions
        setupCustomActionsSubject()

        // Persisting entries sorting to UserDefaults
        setupEntriesSortingSubject()

        // Persisting showFilters to UserDefaults
        setupShowFilterDrawerSubject()
    }

    func setupCategoryFiltersSubject(_ queue: DispatchQueue) {
        Publishers.CombineLatest(
            dataObserver.allCategories,
            activeFiltersSubject
        )
        .throttle(for: 0.15, scheduler: queue, latest: true)
        .map { allCategories, activeFilters in
            Set(allCategories.map(\.filter)).sort(by: activeFilters)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            categoryFiltersSubject.send($0)
        }
        .store(in: &cancellables)
    }

    func setupSourceFiltersSubject(_ queue: DispatchQueue) {
        Publishers.CombineLatest3(
            activeFiltersSubject,
            currentEntriesSubject,
            dataObserver.entrySources
        )
        .throttle(for: 0.15, scheduler: queue, latest: true)
        .map { activeFilters, entries, sources in
            var sources = entries.reduce(into: Set<LogFilter>()) { set, entry in
                if let source = sources[entry]?.filter {
                    set.insert(source)
                }
            }
            sources.formUnion(activeFilters.filter { $0.kind == .source })
            return sources.sort(by: activeFilters)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            sourceFiltersSubject.send($0)
        }
        .store(in: &cancellables)
    }

    func setupActiveFilterScopeSubject(_ queue: DispatchQueue) {
        Publishers.CombineLatest(
            activeFiltersSubject,
            searchQuerySubject
        )
        .receive(on: queue)
        .map { filter, query in
            var scope = filter.sorted()
            if !query.isEmpty {
                scope.append(query.filter)
            }
            return scope.map(\.displayName)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            activeFilterScopeSubject.send($0)
        }
        .store(in: &cancellables)
    }

    func setupCurrentEntriesSubject(_ queue: DispatchQueue) {
        Publishers.CombineLatest4(
            dataObserver.allEntries,
            searchQuerySubject.debounceOnMain(),
            activeFiltersSubject,
            entriesSortingSubject
        )
        .throttleOnMain()
        .map { [unowned self] entries, query, filters, sorting in
            (
                entries,
                dataObserver.entrySources.value,
                dataObserver.entryCategories,
                dataObserver.entryContents,
                dataObserver.entryUserInfoKeys,
                dataObserver.entryUserInfoValues,
                query,
                filters,
                sorting
            )
        }
        .receive(on: queue)
        .map { allIds, sources, categories, contents, userInfoKeys, userInfoValues, query, filters, sorting in
            let categoryFilters = filters.filter { $0.kind == .category }
            let sourceFilters = filters.filter { $0.kind == .source }

            var filtered = allIds

            filtered = categoryFilters.filterEntries(
                ids: filtered,
                sources: sources,
                categories: categories,
                contents: contents,
                userInfoKeys: userInfoKeys,
                userInfoValues: userInfoValues
            )
            filtered = sourceFilters.filterEntries(
                ids: filtered,
                sources: sources,
                categories: categories,
                contents: contents,
                userInfoKeys: userInfoKeys,
                userInfoValues: userInfoValues
            )
            if !query.isEmpty {
                filtered = [query.filter].filterEntries(
                    ids: filtered,
                    sources: sources,
                    categories: categories,
                    contents: contents,
                    userInfoKeys: userInfoKeys,
                    userInfoValues: userInfoValues
                )
            }
            return filtered.sort(by: sorting)
        }
        .receive(on: RunLoop.main)
        .sink { [unowned self] in
            currentEntriesSubject.send($0)
        }
        .store(in: &cancellables)
    }

    func setupCustomActionsSubject() {
        dataObserver.customActions
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                customActionsSubject.send($0)
            }
            .store(in: &cancellables)
    }

    func setupEntriesSortingSubject() {
        entriesSortingSubject
            .receive(on: RunLoop.main)
            .sink {
                UserDefaults.standard.sorting = $0
            }
            .store(in: &cancellables)
    }

    func setupShowFilterDrawerSubject() {
        showFilterDrawerSubject
            .receive(on: RunLoop.main)
            .sink {
                UserDefaults.standard.showFilters = $0
            }
            .store(in: &cancellables)
    }
}

private extension Collection where Element == LogFilter {
    func filterEntries(
        ids: [LogEntryID],
        sources: [LogEntryID: LogEntrySource],
        categories: [LogEntryID: LogEntryCategory],
        contents: [LogEntryID: LogEntryContent],
        userInfoKeys: [LogEntryID: [LogEntryUserInfoKey]],
        userInfoValues: [LogEntryUserInfoKey: String]
    ) -> [LogEntryID] {
        guard !isEmpty else {
            return ids
        }

        let result = ids.filter { id in
            func userInfo() -> Set<String> {
                let keys = userInfoKeys[id, default: []]
                var userInfo = Set(keys.map(\.key))
                for key in keys {
                    if let value = userInfoValues[key] {
                        userInfo.insert(value)
                    }
                }
                return userInfo
            }
            return filterEntry(
                source: sources[id]!,
                category: categories[id]!,
                content: contents[id]!,
                userInfo: userInfo()
            )
        }

        return result
    }

    func filterEntry(
        source: @autoclosure () -> LogEntrySource,
        category: @autoclosure () -> LogEntryCategory,
        content: @autoclosure () -> LogEntryContent,
        userInfo: @autoclosure () -> Set<String>
    ) -> Bool {
        for filter in self {
            if filter.kind.contains(.source) {
                if source().matches(filter) { return true }
            }
            if filter.kind.contains(.category) {
                if category().matches(filter) { return true }
            }
            if filter.kind.contains(.content) {
                if content().matches(filter) { return true }
            }
            if filter.kind.contains(.userInfo) {
                if userInfo().contains(where: { $0.matches(filter) }) { return true }
            }
        }

        return false
    }
}

private extension Publisher {
    func debounceOnMain(
        for dueTime: RunLoop.SchedulerTimeType.Stride = 0.3,
        options: RunLoop.SchedulerOptions? = nil
    ) -> Publishers.Debounce<Self, RunLoop> {
        debounce(for: dueTime, scheduler: RunLoop.main, options: options)
    }

    func throttleOnMain(
        for dueTime: RunLoop.SchedulerTimeType.Stride = 0.15,
        latest: Bool = true
    ) -> Publishers.Throttle<Self, RunLoop> {
        throttle(for: dueTime, scheduler: RunLoop.main, latest: latest)
    }
}

private extension UserDefaults {
    var sorting: LogEntrySorting {
        get {
            guard
                let rawValue = string(forKey: "VisualLogger.sorting"),
                let sorting = LogEntrySorting(rawValue: rawValue)
            else {
                return .defaultValue
            }

            return sorting
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
