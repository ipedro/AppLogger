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

import SwiftUI

package typealias Configuration = AppLoggerConfiguration

public struct AppLoggerConfiguration: Sendable {
    public var navigationTitle: String

    public var minimumSearchQueryLength: UInt

    public var colorScheme: ColorScheme?

    public var icons: Icons = .init()

    public var emptyReasons: EmptyReasons = .init()

    public var dateFormatter: DateFormatter

    public init(
        navigationTitle: String = "App Logs",
        minimumSearchQueryLength: UInt = 3,
        colorScheme: ColorScheme? = nil,
        icons: Icons = .init(),
        emptyReasons: EmptyReasons = .init(),
        dateFormatter: DateFormatter? = nil
    ) {
        self.navigationTitle = navigationTitle
        self.minimumSearchQueryLength = minimumSearchQueryLength
        self.colorScheme = colorScheme
        self.icons = icons
        self.emptyReasons = emptyReasons
        self.dateFormatter = dateFormatter ?? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd—HH-mm-ss"
            return dateFormatter
        }()
    }
}

public extension AppLoggerConfiguration {
    struct EmptyReasons: Sendable {
        public var searchResults: String
        public var empty: String
        
        public init(
            searchResults: String = "No results matching",
            empty: String = "No Entries Yet"
        ) {
            self.searchResults = searchResults
            self.empty = empty
        }
    }

    struct Icons: Sendable {
        public var export: String
        public var dismiss: String
        public var filtersOn: String
        public var filtersOff: String
        public var sorting: String
        public var sortAscending: String
        public var sortDescending: String
        
        public init(
            export: String = "square.and.arrow.up",
            dismiss: String = "xmark",
            filtersOn: String = "line.3.horizontal.decrease.circle.fill",
            filtersOff: String = "line.3.horizontal.decrease.circle",
            sorting: String = "arrow.up.arrow.down",
            sortAscending: String = "arrow.up",
            sortDescending: String = "arrow.down"
        ) {
            self.export = export
            self.dismiss = dismiss
            self.filtersOn = filtersOn
            self.filtersOff = filtersOff
            self.sorting = sorting
            self.sortAscending = sortAscending
            self.sortDescending = sortDescending
        }
    }
}

struct ConfigurationKey: EnvironmentKey {
    static let defaultValue: Configuration = .init()
}

package extension EnvironmentValues {
    var configuration: Configuration {
        get {
            self[ConfigurationKey.self]
        } set {
            self[ConfigurationKey.self] = newValue
        }
    }
}

package extension View {
    func configuration(_ configuration: Configuration) -> some View {
        environment(\.configuration, configuration)
    }
}
