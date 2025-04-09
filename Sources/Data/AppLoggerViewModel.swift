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
import protocol Models.Filterable
import struct Combine.Published
import struct Models.ActivityItem
import struct Models.Filter
import struct Models.ID

package final class AppLoggerViewModel: ObservableObject {
    @Published
    package var searchQuery: String = ""
    
    @Published
    package var showFilters = false
    
    @Published
    package var sorting: Sorting = .ascending {
        willSet {
            entries = entries.reversed()
        }
    }
    
    @Published
    package var activityItem: ActivityItem?
    
    @Published
    package var activeFilters: Set<Filter.ID> = [] {
        willSet {
            sources = sortFilters(sources, by: newValue)
            categories = sortFilters(categories, by: newValue)
        }
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
    
    private func setupListeners() {
        dataObserver.allSources
            .debounce(for: 0.1, scheduler: DispatchQueue.global())
            .map { $0.map(\.filter) }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] newValue in
                sources = sortFilters(newValue, by: activeFilters)
            }
            .store(in: &cancellables)
        
        dataObserver.allCategories
            .debounce(for: 0.1, scheduler: DispatchQueue.global())
            .map { $0.map(\.filter) }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] newValue in
                categories = sortFilters(newValue, by: activeFilters)
            }
            .store(in: &cancellables)
        
        // New pipeline to filter and sort entries based on search and active filters
        Publishers.CombineLatest4(
            dataObserver.allEntries.debounce(for: 0.2, scheduler: DispatchQueue.main),
            $searchQuery,
            $activeFilters,
            $sorting
        )
        .receive(on: DispatchQueue.main)
        .map { [unowned self] allEntries, query, filterIDs, sort in
            var allFilters = Set(filterIDs.map({ Filter(query: $0) }))
            
            if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                allFilters.insert(Filter(query: query))
            }
            
            if allFilters.isEmpty {
                return allEntries
            }
            
            let filtered = allEntries.filter { id in
                let content = dataObserver.entryContents[id]!
                let source = dataObserver.entrySources[id]!
                let category = dataObserver.entryCategories[id]!
                let userInfo = dataObserver.entryUserInfoValues.keys.map(\.key) + dataObserver.entryUserInfoValues.values
                
                for filter in allFilters {
                    if content.matches(filter) { return true }
                    if source.matches(filter) { return true }
                    if category.matches(filter) { return true }
                    if userInfo.contains(where: { $0.matches(filter) }) { return true }
                }
                
                return false
            }
            
            return sortEntries(filtered, by: sort)
        }
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] newValue in
            entries = newValue
        }
        .store(in: &cancellables)
    }
    
    private func sortEntries(_ entries: [ID], by sorting: Sorting) -> [ID] {
        switch sorting {
        case .ascending: entries
        case .descending: entries.reversed()
        }
    }
    
    private func sortFilters(_ filters: [Filter], by selection: Set<Filter.ID>) -> [Filter] {
        filters.sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs.id)
            let rhsActive = selection.contains(rhs.id)
            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
}

extension String: Filterable {
    package static var filterable: KeyPath<String, String> {
        \.self
    }
}
