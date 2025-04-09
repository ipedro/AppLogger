////  Copyright (c) 2022 Pedro Almeida
////
////  Permission is hereby granted, free of charge, to any person obtaining a copy
////  of this software and associated documentation files (the "Software"), to deal
////  in the Software without restriction, including without limitation the rights
////  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
////  copies of the Software, and to permit persons to whom the Software is
////  furnished to do so, subject to the following conditions:
////
////  The above copyright notice and this permission notice shall be included in all
////  copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
////  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
////  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
////  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
////  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
////  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
////  SOFTWARE.
//
//import Foundation
//
//public struct AppLoggerCSV: CustomStringConvertible {
//    var entries: [LogEntry]
//
//    public var description: String {
//        var array = [String]()
//        var maxDictLength = 0
//
//        for entry in entries {
//            maxDictLength = max(maxDictLength, entry.userInfo.keys.count)
//            array.append(entry.csv())
//        }
//
//        array.insert(LogEntry.csvHeader(with: maxDictLength), at: 0)
//        return array.joined(separator: "\n")
//    }
//
//    public var data: Data? {
//        description.data(using: .utf8)
//    }
//
//    public func write(to url: URL) throws {
//        try data?.write(to: url, options: .atomic)
//    }
//}
//
//// MARK: - Private Helpers
//
//private extension LogEntry {
//    nonisolated(unsafe) static let dateFormatter = ISO8601DateFormatter()
//
//    static func csvHeader(with parametersCount: Int) -> String {
//        var array = [
//            "Timestamp",
//            "Category",
//            "Source",
//            "Message"
//        ]
//
//        (0 ..< parametersCount).forEach { _ in
//            array.append("Parameter")
//            array.append("Value")
//        }
//
//        return array.csv()
//    }
//
//    func csv() -> String {
//        var array = [
//            Self.dateFormatter.string(from: createdAt),
//            category.description,
//            source.description,
//            content.message
//        ]
//
//        for (key, value) in content.userInfo {
//            array.append(key)
//            array.append(value)
//        }
//
//        return array.csv()
//    }
//}
//
//private extension Array where Element == String {
//    func csv() -> String {
//        joined(separator: ",")
//    }
//}
