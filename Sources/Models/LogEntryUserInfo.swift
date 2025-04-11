public struct LogEntryUserInfo: Sendable {
    package let storage: [(key: String, value: String)]
    
    /// Creates a `UserInfo` instance from a given string.
    public init(_ string: String) {
        storage = [(String(), string.trimmingCharacters(in: .whitespacesAndNewlines))]
    }
    
    /// Creates a `UserInfo` instance from a dictionary of `[String: String]`.
    public init(_ dictionary: [String: String]) {
        storage = dictionary.sorted(by: <)
    }
    
    /// Initializes a `UserInfo` instance from a generic dictionary.
    ///
    /// The keys in the given dictionary are converted to strings using `String(describing:)`,
    /// and the values are converted to strings using the `convert(toString:)` helper method.
    /// The resulting dictionary is used to instantiate the `.dictionary` case.
    ///
    /// - Parameter dictionary: A dictionary with keys conforming to `Hashable` and values of any type.
    public init<Key, Value>(_ dictionary: [Key: Value]) where Key: Hashable {
        storage = dictionary.reduce(into: [String: String]()) { partialResult, element in
            partialResult[String(describing: element.key)] = Self.convert(toString: element.value)
        }
        .sorted(by: <)
    }
    
    private static let emptyValue = "–"
    
    
    /// Attempts to initialize a `UserInfo` instance from any type of object.
    ///
    /// This initializer supports conversion from dictionaries, arrays, and strings.
    /// For dictionaries and arrays, it converts the value to a `[String: String]` representation.
    /// For strings, it trims whitespace and uses the result for the `.message` case.
    /// For other object types, reflection is used to decide between `.message` and `.dictionary`.
    ///
    /// - Parameter value: The object to convert into a `UserInfo` instance.
    public init?(_ value: Any? = nil) {
        guard let value = value else { return nil }
        
        if let dict = value as? [String: Any] {
            storage = Self.convert(toDictionary: dict).sorted(by: <)
        }
        else if let array = value as? [Any] {
            storage = Self.convert(toDictionary: array).sorted(by: <)
        }
        else if let str = value as? String {
            let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
            storage = [("", (trimmed.isEmpty || ["nil", "[]", "{ }", "[:]"].contains(str) ? Self.emptyValue : trimmed))]
        }
        else {
            let mirror = Mirror(reflecting: value)
            
            if mirror.children.isEmpty {
                storage = [("", String(describing: value))]
            } else if let dict = Self.convert(toDictionary: value) {
                storage = dict.sorted(by: <)
            } else {
                return nil
            }
        }
    }
    
    private static func convert(toString object: Any?) -> String {
        switch object {
        case .none:
            return emptyValue
        case let string as String where ["", "nil", "[]", "{}", "[:]"].contains(string):
            return emptyValue
        case let string as String:
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        case let .some(object):
            return String(describing: object)
        }
    }
    
    private static func convert(toDictionary object: Any?) -> [String: String]? {
        switch object {
        case let dictionary as [String: Any]:
            convert(toDictionary: dictionary)
            
        case let array as [Any]:
            convert(toDictionary: array)
            
        case let object?:
            Mirror(reflecting: object).children.reduce(into: [:]) { dict, child in
                guard let label = child.label else { return }
                dict[String(describing: label)] = convert(toString: child.value)
            }
        case .none:
            nil
        }
    }
    
    private static func convert(toDictionary dict: [String: Any]) -> [String: String] {
        dict.reduce([String: String]()) { partialResult, element in
            var dict = partialResult
            dict[element.key] = convert(toString: element.value)
            return dict
        }
    }
    
    private static func convert(toDictionary array: [Any]) -> [String: String] {
        array.enumerated().reduce([String: String]()) { partialResult, item in
            var dict = partialResult
            dict[String(item.offset)] = convert(toString: item.element)
            return dict
        }
    }
}

extension LogEntryUserInfo: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntryUserInfo: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(
            elements.reduce(into: [:]) { partialResult, element in
                partialResult[element.0] = element.1
            }
        )
    }
}

extension LogEntryUserInfo: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(
            Self.convert(toDictionary: elements)
        )
    }
}
