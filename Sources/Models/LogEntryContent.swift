public extension LogEntry {
    struct Content: Sendable {
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
}

extension LogEntry.Content: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(function: value)
    }
}

extension LogEntry.Content: Filterable {
    package static var filterQuery: KeyPath<LogEntry.Content, String> {
        \.function
    }
    
    package static var filterableOptional: KeyPath<LogEntry.Content, String?> {
        \.message
    }
}
