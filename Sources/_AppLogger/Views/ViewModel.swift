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
//import Combine
//import UIKit
//import SwiftUI
//
//final class ViewModel: ObservableObject {
//    @Published var configuration: AppLoggerConfiguration
//
//    @Published var bottomPadding: CGFloat = .zero
//
//    @Published var dataStore: DataStore = .init()
//
//    init(configuration: AppLoggerConfiguration = .init()) {
//        self.configuration = configuration
//    }
//
//    func addLogEntry(_ loggerEntry: LogEntry) {
//        dataStore.addLogEntry(loggerEntry)
//    }
//
//    var emptyReason: String {
//        if dataStore.search.isActive {
//            return "\(configuration.emptyReasons.searchResults) \"\(dataStore.search.displayName)\""
//        }
//        return configuration.emptyReasons.default
//    }
//
//    func setCompactPresentation(_ isCompact: Bool, in window: UIWindow) {
//        if isCompact {
//            bottomPadding = window.bounds.height / 2
//        } else {
//            bottomPadding = window.safeAreaInsets.bottom
//        }
//    }
//
//    // MARK: - CSV
//
//    func csv() -> AppLoggerCSV {
//        AppLoggerCSV(entries: dataStore.rows)
//    }
//
//    func csvActivityItem() -> ActivityItem? {
//        let csv = csv()
//        guard let cacheFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
//            return nil
//        }
//        do {
//            let fileURL = cacheFolderURL.appendingPathComponent(csvFileName())
//            try csv.write(to: fileURL)
//            return ActivityItem(items: fileURL)
//        } catch {
//            assertionFailure(error.localizedDescription)
//            return nil
//        }
//    }
//
//    private func csvFileName() -> String {
//        var components = [String]()
//        if let bundleIdentifier = Bundle.main.bundleIdentifier {
//            components.append(bundleIdentifier)
//        }
//        components.append(configuration.dateFormatter.string(from: Date()))
//
//        if dataStore.search.isActive {
//            components.append("search:\(dataStore.searchQuery)")
//        }
//
//        let activeFilters = dataStore.categories.filter(\.isActive)
//        if !activeFilters.isEmpty {
//            components.append("filters:\(activeFilters.map(\.query).joined(separator: ","))")
//        }
//
//        return components.joined(separator: "—").appending(".csv")
//    }
//}
