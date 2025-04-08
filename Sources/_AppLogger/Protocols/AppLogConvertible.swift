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

public enum AppLogConversionResult {
    case message(String)
    case userInfo([String: String])
}

public protocol AppLogConvertible {
    static func convert(_ object: Any?) -> AppLogConversionResult
    static func convert(toString object: Any?) -> String
    static func convert(toDictionary object: Any?) -> [String: String]
}

public extension AppLogConvertible {

    func convert(_ object: Any?) -> AppLogConversionResult { Self.convert(object) }

    func convert(toString object: Any?) -> String { Self.convert(toString: object) }

    func convert(toDictionary object: Any?) -> [String: String] { Self.convert(toDictionary: object) }

    static func convert(_ object: Any?) -> AppLogConversionResult {
        guard let object = object else { return .message("") }
        if Mirror(reflecting: object).children.isEmpty {
            return .message(convert(toString: object))
        } else {
            return .userInfo(convert(toDictionary: object))
        }
    }

    static func convert(toString object: Any?) -> String {
        switch object {
        case .none:
            return String()
        case let string as String where ["", "nil", "[]", "{}", "[:]"].contains(string):
            return "(empty)"
        case let string as String:
            return string
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
