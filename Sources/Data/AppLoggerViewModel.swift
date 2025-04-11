import Combine
import Foundation
import Models
import SwiftUI

package final class AppLoggerViewModel: ObservableObject {
    @Published
    package var searchQuery: String = ""
    
    @Published
    package var showFilters: Bool {
        willSet {
            UserDefaults.standard.showFilters = newValue
        }
    }
    
    @Published
    package var sorting: LogEntrySorting
    
    @Published
    package var activityItem: ActivityItem?
    
    @Published
    package var activeFilters: Set<Filter> = []
    
    package var activeScope: [String] {
        var scope = activeFilters.sorted()
        if !searchQuery.trimmed.isEmpty {
            scope.append(searchQuery.trimmed.filter)
        }
        return scope.map(\.displayName)
    }
    
    @Published
    package var sources: [Filter] = []
    
    @Published
    package var categories: [Filter] = []
    
    @Published
    package var entries: [LogEntryID] = []
    
    package let dismissAction: @MainActor () -> Void
    
    private let dataObserver: DataObserver
    
    private var cancellables = Set<AnyCancellable>()
    
    package init(
        dataObserver: DataObserver,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction
        self.sorting = UserDefaults.standard.sorting
        self.showFilters = UserDefaults.standard.showFilters
        
        setupListeners()
    }
    
    package func sourceColor(_ source: LogEntrySource, for colorScheme: ColorScheme) -> Color {
        dataObserver.sourceColors[source.id]?[colorScheme]?.color() ?? .secondary
    }
    
    package func entrySource(_ id: LogEntryID) -> LogEntrySource {
        dataObserver.entrySources[id]!
    }
    
    package func entryCategory(_ id: LogEntryID) -> LogEntryCategory {
        dataObserver.entryCategories[id]!
    }
    
    package func entryContent(_ id: LogEntryID) -> LogEntryContent {
        dataObserver.entryContents[id]!
    }
    
    package func entryUserInfoKeys(_ id: LogEntryID) -> [LogEntryUserInfoKey]? {
        dataObserver.entryUserInfoKeys[id]
    }
    
    package func entryUserInfoValue(_ id: LogEntryUserInfoKey) -> String {
        dataObserver.entryUserInfoValues[id]!
    }
    
    package func entryCreatedAt(_ id: LogEntryID) -> Date {
        id.createdAt
    }
    
}

private extension AppLoggerViewModel {
    func setupListeners() {
        Publishers.CombineLatest(
            dataObserver.allCategories.throttleOnMain(for: 0.15).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: RunLoop.main)
        .sink { [unowned self] sources, filters in
            self.categories = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            dataObserver.allSources.throttleOnMain(for: 0.15).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: RunLoop.main)
        .sink { [unowned self] sources, filters in
            self.sources = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest4(
            dataObserver.allEntries.throttleOnMain(for: 0.15),
            $searchQuery.debounceOnMain(for: 0.3).map(\.trimmed),
            $activeFilters,
            $sorting
        )
        .receive(on: RunLoop.main)
        .map { [unowned self] allEntries, query, filters, sort in
            UserDefaults.standard.sorting = sort

            var result = filterEntries(allEntries, with: filters)
            if !query.isEmpty {
                result = filterEntries(result, with: [query.filter])
            }
            result = sortEntries(result, by: sort)
            return result
        }
        .sink { [unowned self] newValue in
            entries = newValue
        }
        .store(in: &cancellables)
    }
    
    func sortEntries(_ entries: [LogEntryID], by sorting: LogEntrySorting) -> [LogEntryID] {
        switch sorting {
        case .ascending: entries
        case .descending: entries.reversed()
        }
    }
    
    func sortFilters(_ filters: Set<Filter>, by selection: Set<Filter>) -> [Filter] {
        return filters.sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs)
            let rhsActive = selection.contains(rhs)
            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
    
    func filterEntries(_ entries: [LogEntryID], with filters: Set<Filter>) -> [LogEntryID] {
        var result = entries
        
        if !filters.isEmpty {
            result = result.filter { id in
                return filterEntry(id, with: filters)
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
            let rawValue = integer(forKey: "AppLogger.sorting")
            return LogEntrySorting(rawValue: rawValue) ?? .descending
        }
        set {
            set(newValue.rawValue, forKey: "AppLogger.sorting")
        }
    }
    
    var showFilters: Bool {
        get {
            bool(forKey: "AppLogger.showFilters")
        }
        set {
            set(newValue, forKey: "AppLogger.showFilters")
        }
    }
}
