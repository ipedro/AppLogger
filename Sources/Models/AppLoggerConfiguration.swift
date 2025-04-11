import SwiftUI

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
    static let defaultValue: AppLoggerConfiguration = .init()
}

package extension EnvironmentValues {
    var configuration: AppLoggerConfiguration {
        get {
            self[ConfigurationKey.self]
        } set {
            self[ConfigurationKey.self] = newValue
        }
    }
}

package extension View {
    func configuration(_ configuration: AppLoggerConfiguration) -> some View {
        environment(\.configuration, configuration)
    }
}
