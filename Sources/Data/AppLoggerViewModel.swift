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
    package var sorting: Sorting = .ascending
    
    @Published
    package var activityItem: ActivityItem?
    
    @Published
    package var activeFilters: Set<Filter> = []
    
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
            $searchQuery.debounce(for: 0.3, scheduler: DispatchQueue.main),
            $activeFilters,
            $sorting
        )
        .receive(on: DispatchQueue.main)
        .map { [unowned self] allEntries, query, filters, sort in
            var allFilters = filters
            
            if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                allFilters.insert(query.filter)
            }
            
            if allFilters.isEmpty {
                return sortEntries(allEntries, by: sort)
            }
            
            let filtered = allEntries.filter { id in
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
                
                for filter in allFilters {
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
            
            return sortEntries(filtered, by: sort)
        }
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
    
    private func sortFilters(_ filters: [Filter], by selection: Set<Filter>) -> [Filter] {
        filters.sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs)
            let rhsActive = selection.contains(rhs)
            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
}
