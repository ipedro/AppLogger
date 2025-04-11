import SwiftUI

struct LogEntryUserInfoRow: View {
    let key: String
    let value: String
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        let _ = Self._debugPrintChanges()
        HStack(alignment: .top, spacing: spacing) {
            keyText
            Spacer(minLength: spacing)
            valueText
        }
        .padding(spacing)
    }

    private var valueText: some View {
        LinkText(data: value, alignment: .trailing)
            .foregroundStyle(.tint)
            .font(.system(.caption, design: .monospaced))
    }

    private var keyText: some View {
        Text("\(key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .textSelection(.enabled)
            .isHidden(key.isEmpty)
    }
}

private extension View {
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            EmptyView()
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        LogEntryUserInfoRow(
            key: "Key",
            value: "I'm a value"
        )
        
        Divider()
        
        LogEntryUserInfoRow(
            key: "",
            value: "String interpolations are string literals that evaluate any included expressions and convert the results to string form. String interpolations give you an easy way to build a string from multiple pieces. Wrap each expression in a string interpolation in parentheses, prefixed by a backslash."
        )
    }
}
