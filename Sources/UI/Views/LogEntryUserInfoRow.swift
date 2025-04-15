import Data
import Models
import SwiftUI

struct LogEntryUserInfoRow: View {
    let offset: Int
    let id: LogEntryUserInfoKey

    @Environment(\.spacing)
    private var spacing

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    var body: some View {
        let _ = Self._debugPrintChanges()
        HStack(alignment: .top, spacing: spacing) {
            if !id.key.isEmpty {
                keyText
                Spacer(minLength: spacing)
            }
            valueText
        }
        .padding(spacing)
        .background(backgroundColor)
    }

    private var backgroundColor: Color {
        if offset.isMultiple(of: 2) {
            Color(uiColor: .systemGray5)
        } else if colorScheme == .dark {
            Color(uiColor: .systemGray4)
        } else {
            Color(uiColor: .systemGray6)
        }
    }

    private var valueString: String {
        viewModel.entryUserInfoValue(id)
    }

    private var valueText: some View {
        LinkText(data: valueString, alignment: .trailing)
            .foregroundStyle(.tint)
            .font(.system(.caption, design: .monospaced))
    }

    private var keyText: some View {
        Text("\(id.key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .textSelection(.enabled)
    }
}
