//  Copyright (c) 2022 Pedro Almeida
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

import Foundation

struct DataSource: Hashable {
    static var empty = DataSource()

    enum Sorting: CaseIterable, Hashable, CustomStringConvertible {
        case ascending, descending

        var description: String {
            switch self {
            case .ascending:
                return "Oldest first"
            case .descending:
                return "Newest first"
            }
        }

        mutating func toggle() {
            switch self {
            case .ascending:
                self = .descending
            case .descending:
                self = .ascending
            }
        }
    }

    var rowsSorting: Sorting = .descending {
        didSet {
            guard oldValue != rowsSorting else { return }
            reloadRows()
        }
    }

    let minimumSearchQueryLength: UInt = 3

    var activeFilters: Int {
        allFilters.filter(\.isActive).count
    }

    var search: Filter {
        let searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return Filter(
            query: searchQuery,
            displayName: searchQuery,
            isActive: searchQuery.count >= minimumSearchQueryLength
        )
    }

    var searchQuery: String = "" {
        didSet {
            reloadSources()
            reloadRows()
        }
    }

    var categories: [Filter] = [] {
        didSet {
            let sorted = categories.sorted(by: <)
            if categories != sorted {
                categories = sorted
            }
            reloadSources()
            //reloadRows()
        }
    }

    var sources: [Filter] = [] {
        didSet {
            let sorted = sources.sorted(by: <)
            if sources != sorted {
                sources = sorted
            }
            reloadRows()
        }
    }

    private var sortedRows: [LogEntry] {
        switch rowsSorting {
        case .ascending:
            return rows.sorted(by: <)
        case .descending:
            return rows.sorted(by: >)
        }
    }

    var rows: [LogEntry] = [] {
        didSet {
            let sorted = sortedRows
            if rows != sorted {
                rows = sorted
            }
        }
    }

    private var allEntries: [LogEntry] = []

    mutating func addLogEntry(_ loggerEntry: LogEntry) {
        allEntries.insert(loggerEntry, at: .zero)

        if !categories.map(\.query).contains(loggerEntry.category.debugName) {
            categories.append(
                .init(
                    query: loggerEntry.category.debugName,
                    displayName: loggerEntry.category.displayName
                )
            )
        }
    }
}

private extension Array where Element == Filter {
    var areInactive: Bool {
        filter(\.isActive).isEmpty
    }
}

private extension DataSource {
    var scope: [Filter] { [search] + categories }

    var allFilters: [Filter] { scope + sources }

    mutating func reloadSources() {
        sources = calculateSources(in: scope)
    }

    mutating func reloadRows() {
        let allRowsInScope = calculateRows(in: scope)

        guard !sources.areInactive else {
            rows = allRowsInScope
            return
        }

        var filteredRows = Set<LogEntry>()

        sources.forEach { filteredRows.formUnion($0.filter(allRowsInScope)) }

        switch rowsSorting {
        case .ascending:
            rows = filteredRows.sorted(by: <)
        case .descending:
            rows = filteredRows.sorted(by: >)
        }
    }

    func calculateRows(in scope: [Filter]) -> [LogEntry] {
        if scope.areInactive { return allEntries }
        var rows = Set<LogEntry>()

        scope.forEach { rows.formUnion($0.filter(allEntries)) }

        return Array(rows)
    }

    func calculateSources(in scope: [Filter]) -> [Filter] {
        var updatedSources = Set<Filter>()

        var entries = Set<LogEntry>()

        if scope.areInactive {
            entries.formUnion(allEntries)
        } else {
            scope.forEach { entries.formUnion($0.filter(allEntries)) }
        }

        entries.forEach {
            let query = $0.source.debugName
            let displayName = $0.source.displayName

            updatedSources.insert(
                .init(
                    query: query,
                    displayName: displayName,
                    isActive: {
                        if let index = allFilters.map(\.query).firstIndex(of: query) {
                            return allFilters[index].isActive
                        }
                        return false
                    }()
                )
            )
        }

        return updatedSources.sorted(by: <)
    }
}
