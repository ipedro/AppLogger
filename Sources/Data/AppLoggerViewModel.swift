//  Copyright (c) 2025 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import class Combine.AnyCancellable
import class Foundation.DispatchQueue
import enum Combine.Publishers
import enum Models.Sorting
import protocol Combine.ObservableObject
import protocol Combine.Publisher
import protocol Models.Filterable
import struct Combine.Published
import struct Models.ActivityItem
import struct Models.Category
import struct Models.Content
import struct Models.Filter
import struct Models.ID
import struct Models.Source

package final class AppLoggerViewModel: ObservableObject {
    @Published
    package var searchQuery: String = ""
    
    @Published
    package var showFilters = false
    
    @Published
    package var sorting: Sorting = .descending
    
    @Published
    package var activityItem: ActivityItem?
    
    @Published
    package var activeFilters: Set<Filter> = []
    
    package var activeScope: String {
        var scope = activeFilters.sorted()
        if !searchQuery.trimmed.isEmpty {
            scope.append(searchQuery.trimmed.filter)
        }
        return scope.map(\.displayName).joined(separator: ", ")
    }
    
    @Published
    package var sources: [Filter] = []
    
    @Published
    package var categories: [Filter] = []
    
    @Published
    package var entries: [ID] = []
    
    package let dismissAction: @MainActor () -> Void
    
    private let dataObserver: DataObserver
    
    private var cancellables = Set<AnyCancellable>()
    
    package init(
        dataObserver: DataObserver,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction
        
        setupListeners()
    }
}

private extension AppLoggerViewModel {
    func setupListeners() {
        dataObserver.allCategories
            .debounceOnMain(for: 0.1)
            .map { Set($0.map(\.filter)) }
            .sink { [unowned self] newValue in
                categories = sortFilters(newValue, by: activeFilters)
            }
            .store(in: &cancellables)
        
        dataObserver.allSources
            .debounceOnMain(for: 0.1)
            .map { Set($0.map(\.filter)) }
            .sink { [unowned self] newValue in
                sources = sortFilters(newValue, by: activeFilters)
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
            let filtered = filterEntries(allEntries, filters: filters, query: query)
            return sortEntries(filtered, by: sort)
        }
        .sink { [unowned self] newValue in
            entries = newValue
        }
        .store(in: &cancellables)
    }
    
    func sortEntries(_ entries: [ID], by sorting: Sorting) -> [ID] {
        switch sorting {
        case .ascending: entries
        case .descending: entries.reversed()
        }
    }
    
    func sortFilters(_ filters: Set<Filter>, by selection: Set<Filter>) -> [Filter] {
        filters.sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs)
            let rhsActive = selection.contains(rhs)
            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
    
    func filterEntries(_ entries: [ID], filters: Set<Filter>, query: String) -> [ID] {
        var result = entries
        
        if !filters.isEmpty {
            result = result.filter { id in
                return filterEntry(id, with: filters)
            }
        }
        
        if !query.isEmpty {
            let search = query.filter
            result = result.filter { id in
                return filterEntry(id, with: [search])
            }
        }
        
        return result
    }
    
    func filterEntry(_ id: ID, with filters: Set<Filter>) -> Bool {
        var source: Source {
            dataObserver.entrySources[id]!
        }
        
        var category: Category {
            dataObserver.entryCategories[id]!
        }
        
        var content: Content {
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
