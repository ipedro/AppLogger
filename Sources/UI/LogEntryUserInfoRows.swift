import Data
import Models
import SwiftUI

struct LogEntryUserInfoRows: View {
    var ids: [LogEntryUserInfoKey]

    @Environment(\.spacing)
    private var spacing
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    var body: some View {
        let _ = Self._debugPrintChanges()
        LazyVStack(alignment: .leading, spacing: .zero) {
            ForEach(Array(ids.enumerated()), id: \.element) { offset, id in
                LogEntryUserInfoRow(
                    key: id.key,
                    value: viewModel.entryUserInfoValue(id)
                )
                .background(backgroundColor(for: offset))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: spacing * 1.5))
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if index.isMultiple(of: 2) {
            Color(uiColor: .systemGray5)
        } else if colorScheme == .dark {
            Color(uiColor: .systemGray4)
        } else {
            Color(uiColor: .systemGray6)
        }
    }
}

#Preview {
    let entry = LogEntryMock.socialLogin.entry()
    
    ScrollView {
        LogEntryUserInfoRows(
            ids: entry.userInfo?.storage.map {
                LogEntryUserInfoKey(id: entry.id, key: $0.key)
            } ?? []
        )
        .padding()
    }
    .environmentObject(
        AppLoggerViewModel(
            dataObserver: DataObserver(
                entryUserInfos: [entry.id: entry.userInfo]
            ),
            dismissAction: {}
        )
    )
}
