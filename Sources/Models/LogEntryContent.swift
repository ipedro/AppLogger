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

package typealias Content = LogEntry.Content

public extension LogEntry {
    struct Content: Sendable {
        public var description: String
        public var output: String?
        public var userInfo: [String: String]
        
        public init(
            _ content: String,
            output: String? = .none,
            userInfo: [String: String] = [:]
        ) {
            self.description = content
            self.output = output
            self.userInfo = userInfo.reduce(into: [:]) { partialResult, row in
                partialResult[row.key] = row.value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        @_disfavoredOverload
        public init(
            _ description: String,
            output: String? = .none,
            userInfo: Any? = nil
        ) {
            self.description = description
            self.output = output
            
            switch Self.convert(userInfo) {
            case let .message(message) where output == .none:
                self.output = message.trimmingCharacters(in: .whitespacesAndNewlines)
                self.userInfo = [:]
            case let .message(message):
                self.userInfo = ["": message.trimmingCharacters(in: .whitespacesAndNewlines)]
            case let .dictionary(dictionary):
                self.userInfo = dictionary
            }
        }
        
        
        enum UserInfo {
            case message(String)
            case dictionary([String: String])
        }
        
        static func convert(_ object: Any?) -> UserInfo {
            guard let object = object else { return .message("") }
            if Mirror(reflecting: object).children.isEmpty {
                return .message(convert(toString: object))
            } else {
                return .dictionary(convert(toDictionary: object))
            }
        }
        
        static func convert(toString object: Any?) -> String {
            switch object {
            case .none:
                return String()
            case let string as String where ["", "nil", "[]", "{}", "[:]"].contains(string):
                return "(empty)"
            case let string as String:
                return string.trimmingCharacters(in: .whitespacesAndNewlines)
            case let .some(object):
                return String(describing: object)
            }
        }
        
        static func convert(toDictionary object: Any?) -> [String: String] {
            switch object {
            case let dictionary as [AnyHashable: Any]:
                return dictionary.reduce([String: String]()) { partialResult, element in
                    var dict = partialResult
                    dict[String(describing: element.key.base)] = convert(toString: element.value)
                    return dict
                }
                
            case let array as [Any]:
                return array.enumerated().reduce([String: String]()) { partialResult, item in
                    var dict = partialResult
                    dict["item \(item.offset)"] = convert(toString: item.element)
                    return dict
                }
                
            case let object?:
                return Mirror(reflecting: object)
                    .children
                    .reduce(into: [String: String]()) { partialResult, element in
                        guard let label = element.label else { return }
                        partialResult[String(describing: label)] = convert(toString: element.value)
                    }
            case .none:
                return [:]
            }
        }
    }
}

extension LogEntry.Content: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntry.Content: Filterable {
    package func matches(_ filter: Filter) -> Bool {
        if description.localizedCaseInsensitiveContains(filter.query) { return true }
        if output?.localizedCaseInsensitiveContains(filter.query) == true { return true }
        if userInfo.keys.joined().localizedCaseInsensitiveContains(filter.query) { return true }
        if userInfo.values.joined().localizedCaseInsensitiveContains(filter.query) { return true }
        return false
    }
}
