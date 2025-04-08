//
//  LogEntrySorting.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

package typealias Sorting = LogEntry.Sorting

public extension LogEntry {
    enum Sorting: String, CaseIterable, Identifiable {
        case ascending, descending
        
        public var id: RawValue {
            rawValue
        }
        
        /// Toggle between sorting orders.
        mutating func toggle() {
            self = self == .ascending ? .descending : .ascending
        }
    }
}
