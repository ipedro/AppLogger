import Data
import Models
import SwiftUI

@available(iOS 16.0, *)
package extension VisualLoggerView where Content == NavigationStack<NavigationPath, LogEntriesList> {
    static func navigationStack() -> Self {
        Self(content: NavigationStack(root: LogEntriesList.init))
    }
}

package extension VisualLoggerView where Content == NavigationView<LogEntriesList> {
    static func navigationView() -> Self {
        Self(content: NavigationView(content: LogEntriesList.init))
    }
}

package struct VisualLoggerView<Content>: View where Content: View {
    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme

    @Environment(\.colorScheme)
    private var currentColorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    private let content: Content

    package var body: some View {
        let _ = Self._debugPrintChanges()
        content
            .tint(accentColor)
            .colorScheme(preferredColorScheme ?? currentColorScheme)
            .onDisappear {
                // There is a bug with the SwiftUI environment that can hold on
                // to the view model if there is a search query, so cancelling
                // observers manually to be safe.
                //
                // The zombie view model gets released when the search bar comes
                // into focus again.
                viewModel.cancelObservers()
            }
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
        customActions: [
            VisualLoggerAction(
                title: "Action",
                image: nil,
                handler: { _ in print("Action executed")
                }
            ),
        ],
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:]) { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        }
    )

    VisualLoggerView.navigationStack()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(accentColor: .red))
}
