import Foundation
import Models

package extension UserDefaults {
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
