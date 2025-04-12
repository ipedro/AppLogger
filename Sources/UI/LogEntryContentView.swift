import Models
import SwiftUI

struct LogEntryContentView: View {
    let category: LogEntryCategory
    let content: LogEntryContent

    @Environment(\.spacing)
    private var spacing

    var body: some View {
        let _ = Self._debugPrintChanges()
        VStack(alignment: .leading, spacing: spacing) {
            Text(content.function)
                .font(.callout.bold())
                .minimumScaleFactor(0.85)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            if let message = content.message, !message.isEmpty {
                HStack(alignment: .top, spacing: spacing) {
                    if let icon = category.emoji {
                        Text(String(icon))
                    }

                    LinkText(data: message)
                }
                .font(.footnote)
                .foregroundStyle(.tint)
                .padding(spacing)
                .background(
                    .tint.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: spacing * 1.5)
                )
            }
        }
    }
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: LogEntryContent(
            function: "content description",
            message: "Bla"
        )
    )
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: "content description"
    )
}
