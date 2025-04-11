import Data
import Models
import SwiftUI

@available(iOS 16.0, *)
package extension AppLoggerView where Content == NavigationStack<NavigationPath, LogEntriesList> {
    static func navigationStack() -> Self {
        Self(content: NavigationStack(root: LogEntriesList.init))
    }
}

package extension AppLoggerView where Content == NavigationView<LogEntriesList> {
    static func navigationView() -> Self {
        Self(content: NavigationView(content: LogEntriesList.init))
    }
}

package struct AppLoggerView<Content>: View where Content: View {

    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    private let content: Content
    
    package var body: some View {
        let _ = Self._debugPrintChanges()
        content
            .tint(accentColor)
            .colorScheme(preferredColorScheme ?? colorScheme)
    }
}

@available(iOS 16.0, *)
#Preview {
    let allEntries = LogEntryMock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<LogEntrySource>()
    
    let dataObserver = DataObserver(
        allCategories: Set(allEntries.map(\.category)).sorted(),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:], { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        })
    )
    
    AppLoggerView.navigationStack()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(accentColor: .red))
}
