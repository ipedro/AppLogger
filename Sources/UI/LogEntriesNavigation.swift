import Data
import Models
import SwiftUI

package struct LogEntriesNavigation<Content>: View where Content: View {

    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    private let content: Content
    
    @available(iOS 16.0, *)
    package static func makeStack() -> Self where Content == NavigationStack<NavigationPath, LogEntriesList> {
        Self(content: NavigationStack(root: LogEntriesList.init))
    }

    package static func makeView() -> Self where Content == NavigationView<LogEntriesList> {
        Self(content: NavigationView(content: LogEntriesList.init))
    }
    
    package var body: some View {
        content
            .tint(accentColor)
            .colorScheme(preferredColorScheme ?? colorScheme)
            .activitySheet($viewModel.activityItem)
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
    
    LogEntriesNavigation.makeStack()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(accentColor: .red))
}
