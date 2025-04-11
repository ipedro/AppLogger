public enum LogEntrySorting: Int, CustomStringConvertible, CaseIterable, Identifiable {
    case ascending, descending
    
    public var description: String {
        switch self {
        case .ascending:
            "New Logs Last"
        case .descending:
            "New Logs First"
        }
    }
    
    public var id: RawValue {
        rawValue
    }
    
    /// Toggle between sorting orders.
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}
