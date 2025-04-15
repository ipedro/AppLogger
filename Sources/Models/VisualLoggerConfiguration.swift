// MIT License
// 
// Copyright (c) 2025 Pedro Almeida
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import SwiftUI

/// A configuration structure for customizing the appearance and behavior of the app's logging interface.
///
/// This struct allows you to define properties such as tint colors, color schemes, empty reason messages, icons, and navigation titles.
public struct VisualLoggerConfiguration: Sendable {
    /// The tint color used throughout the logging interface.
    public var tintColor: Color?

    /// The color scheme for the interface, or `nil` to use the system default.
    public var colorScheme: ColorScheme?

    /// Messages to display when the log is empty or search results return no matches.
    public var emptyReasons: EmptyReasons = .init()

    /// The icons used throughout the logging interface.
    public var icons: Icons = .init()

    /// The title displayed in the navigation bar of the logging interface.
    public var navigationTitle: String

    /// Initializes a new configuration with default values for each property.
    ///
    /// - Parameters:
    ///   - tintColor: The tint color for the interface.
    ///   - colorScheme: The color scheme to use.
    ///   - emptyReasons: Custom messages for empty states.
    ///   - icons: Custom icons for actions.
    ///   - navigationTitle: The title for the navigation bar.
    public init(
        tintColor: Color? = nil,
        colorScheme: ColorScheme? = nil,
        emptyReasons: EmptyReasons = .init(),
        icons: Icons = .init(),
        navigationTitle: String = "Logs"
    ) {
        self.tintColor = tintColor
        self.colorScheme = colorScheme
        self.emptyReasons = emptyReasons
        self.icons = icons
        self.navigationTitle = navigationTitle
    }
}

public extension VisualLoggerConfiguration {
    /// Structure defining custom messages for empty states in the logging interface.
    struct EmptyReasons: Sendable {
        /// The message displayed when there are no log entries.
        public var empty: String

        /// The message displayed when a search returns no matching results.
        public var searchResults: String

        /// Initializes custom messages for empty states.
        ///
        /// - Parameters:
        ///   - empty: Message for an empty log (default is "No Entries Yet").
        ///   - searchResults: Message for no matching search results (default is "No results matching").
        public init(
            empty: String = "No Entries Yet",
            searchResults: String = "No results matching"
        ) {
            self.empty = empty
            self.searchResults = searchResults
        }
    }

    /// Structure defining custom icons used in the logging interface.
    struct Icons: Sendable {
        /// The icon for dismissing the log interface.
        public var dismiss: String

        /// The icon for exporting log entries.
        public var export: String

        /// The icon for turning filters off.
        public var filtersOff: String

        /// The icon for turning filters on.
        public var filtersOn: String

        /// The icon for sorting in ascending order.
        public var sortAscending: String

        /// The icon for sorting in descending order.
        public var sortDescending: String

        /// Initializes custom icons for actions.
        ///
        /// - Parameters:
        ///   - dismiss: Icon for dismiss action.
        ///   - export: Icon for export action.
        ///   - filtersOff: Icon for turning filters off.
        ///   - filtersOn: Icon for turning filters on.
        ///   - sortAscending: Icon for sorting in ascending order.
        ///   - sortDescending: Icon for sorting in descending order.
        public init(
            dismiss: String = "xmark.circle.fill",
            export: String = "square.and.arrow.up",
            filtersOff: String = "line.3.horizontal.decrease.circle",
            filtersOn: String = "line.3.horizontal.decrease.circle.fill",
            sortAscending: String = "text.append",
            sortDescending: String = "text.insert"
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
    static let defaultValue: VisualLoggerConfiguration = .init()
}

package extension EnvironmentValues {
    var configuration: VisualLoggerConfiguration {
        get { self[ConfigurationKey.self] }
        set { self[ConfigurationKey.self] = newValue }
    }
}

package extension View {
    /// Applies a configuration to a SwiftUI view hierarchy.
    func configuration(_ configuration: VisualLoggerConfiguration) -> some View {
        environment(\.configuration, configuration)
    }
}
