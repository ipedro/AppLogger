import Data
import Models
import SwiftUI

struct LogEntryView: View {
    let id: LogEntryID

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.spacing)
    private var spacing

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    var body: some View {
        let _ = Self._debugPrintChanges()
        let category = viewModel.entryCategory(id)
        let content = viewModel.entryContent(id)
        let createdAt = viewModel.entryCreatedAt(id)
        let source = viewModel.entrySource(id)
        let tint = viewModel.sourceColor(source, for: colorScheme)
        let userInfo = viewModel.entryUserInfoKeys(id)

        VStack(alignment: .leading, spacing: spacing) {
            LogEntryHeaderView(
                source: source,
                category: category.description,
                createdAt: createdAt
            )

            LogEntryContentView(
                category: category,
                content: content
            )

            if let userInfo {
                LogEntryUserInfoView(
                    ids: userInfo
                )
            }
        }
        .tint(tint)
        .padding(spacing * 2)
        .background(.background)
    }
}

#if DEBUG
    extension LogEntryView {
        init(mock: LogEntryMock) {
            let entry = mock.entry()
            id = entry.id
        }
    }
#endif

#Preview {
    let entry = LogEntryMock.socialLogin.entry()

    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                VisualLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
}

#Preview {
    let entry = LogEntryMock.googleAnalytics.entry()

    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                VisualLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
    .background(.red)
}
