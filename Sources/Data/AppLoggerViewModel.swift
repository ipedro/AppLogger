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
    package var sorting: LogEntry.Sorting
    
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
    package var entries: [LogEntry.ID] = []
    
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
    
    package func sourceColor(_ source: LogEntry.Source, for colorScheme: ColorScheme) -> Color {
        dataObserver.sourceColors[source.id]?[colorScheme]?.color() ?? .secondary
    }
    
    package func entrySource(_ id: LogEntry.ID) -> LogEntry.Source {
        dataObserver.entrySources[id]!
    }
    
    package func entryCategory(_ id: LogEntry.ID) -> LogEntry.Category {
        dataObserver.entryCategories[id]!
    }
    
    package func entryContent(_ id: LogEntry.ID) -> LogEntry.Content {
        dataObserver.entryContents[id]!
    }
    
    package func entryUserInfoKeys(_ id: LogEntry.ID) -> [LogEntry.UserInfoKey]? {
        dataObserver.entryUserInfoKeys[id]
    }
    
    package func entryUserInfoValue(_ id: LogEntry.UserInfoKey) -> String {
        dataObserver.entryUserInfoValues[id]!
    }
    
    package func entryCreatedAt(_ id: LogEntry.ID) -> Date {
        id.createdAt
    }
    
}

private extension AppLoggerViewModel {
    func setupListeners() {
        Publishers.CombineLatest(
            dataObserver.allCategories.debounceOnMain(for: 0.1).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] sources, filters in
            self.categories = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            dataObserver.allSources.debounceOnMain(for: 0.1).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] sources, filters in
            self.sources = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        
        Publishers.CombineLatest4(
            dataObserver.allEntries.debounceOnMain(for: 0.2),
            $searchQuery.debounceOnMain(for: 0.3).map(\.trimmed),
            $activeFilters,
            $sorting
        )
        .receive(on: DispatchQueue.main)
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
    
    func sortEntries(_ entries: [LogEntry.ID], by sorting: LogEntry.Sorting) -> [LogEntry.ID] {
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
    
    func filterEntries(_ entries: [LogEntry.ID], with filters: Set<Filter>) -> [LogEntry.ID] {
        var result = entries
        
        if !filters.isEmpty {
            result = result.filter { id in
                return filterEntry(id, with: filters)
            }
        }
        
        return result
    }
    
    func filterEntry(_ id: LogEntry.ID, with filters: Set<Filter>) -> Bool {
        var source: LogEntry.Source {
            dataObserver.entrySources[id]!
        }
        
        var category: LogEntry.Category {
            dataObserver.entryCategories[id]!
        }
        
        var content: LogEntry.Content {
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
        for dueTime: DispatchQueue.SchedulerTimeType.Stride,
        options: DispatchQueue.SchedulerOptions? = nil
    ) -> Publishers.Debounce<Self, DispatchQueue> {
        debounce(for: dueTime, scheduler: DispatchQueue.main, options: options)
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension UserDefaults {
    var sorting: LogEntry.Sorting {
        get {
            let rawValue = integer(forKey: "AppLogger.sorting")
            return LogEntry.Sorting(rawValue: rawValue) ?? .descending
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
