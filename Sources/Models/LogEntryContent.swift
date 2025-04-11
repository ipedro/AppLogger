public struct LogEntryContent: Sendable {
    public let function: String
    public let message: String?
    
    public init(
        function: String,
        message: String? = .none
    ) {
        self.function = function
        self.message = message
    }
}

extension LogEntryContent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(function: value)
    }
}

extension LogEntryContent: Filterable {
    package static var filterQuery: KeyPath<LogEntryContent, String> {
        \.function
    }
    
    package static var filterableOptional: KeyPath<LogEntryContent, String?> {
        \.message
    }
}
