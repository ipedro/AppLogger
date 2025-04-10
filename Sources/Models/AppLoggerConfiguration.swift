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
    public var accentColor: Color
    public var colorScheme: ColorScheme?
    public var emptyReasons: EmptyReasons = .init()
    public var icons: Icons = .init()
    public var navigationTitle: String

    public init(
        accentColor: Color = .secondary,
        colorScheme: ColorScheme? = nil,
        emptyReasons: EmptyReasons = .init(),
        icons: Icons = .init(),
        navigationTitle: String = "Logs"
    ) {
        self.accentColor = accentColor
        self.colorScheme = colorScheme
        self.emptyReasons = emptyReasons
        self.icons = icons
        self.navigationTitle = navigationTitle
    }
}

public extension AppLoggerConfiguration {
    struct EmptyReasons: Sendable {
        public var empty: String
        public var searchResults: String
        
        public init(
            empty: String = "No Entries Yet",
            searchResults: String = "No results matching"
        ) {
            self.empty = empty
            self.searchResults = searchResults
        }
    }

    struct Icons: Sendable {
        public var dismiss: String
        public var export: String
        public var filtersOff: String
        public var filtersOn: String
        public var sortAscending: String
        public var sortDescending: String
        
        public init(
            dismiss: String = "xmark.circle.fill",
            export: String = "square.and.arrow.up",
            filtersOff: String = "line.3.horizontal.decrease.circle",
            filtersOn: String = "line.3.horizontal.decrease.circle.fill",
            sortAscending: String = "text.line.last.and.arrowtriangle.forward", //"arrowtriangle.up",
            sortDescending: String = "text.line.first.and.arrowtriangle.forward" // "arrowtriangle.down"
        ) {
            self.dismiss = dismiss
            self.export = export
            self.filtersOff = filtersOff
            self.filtersOn = filtersOn
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
