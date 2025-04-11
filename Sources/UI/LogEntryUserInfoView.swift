import Data
import Models
import SwiftUI

struct LogEntryUserInfoView: View {
    let ids: [LogEntryUserInfoKey]

    @Environment(\.spacing)
    private var spacing

    var body: some View {
        let _ = Self._debugPrintChanges()
        LazyVStack(spacing: .zero) {
            ForEach(Array(ids.enumerated()), id: \.element) { @Sendable offset, id in
                LogEntryUserInfoRow(offset: offset, id: id)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: spacing * 1.5))
    }
}
