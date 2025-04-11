import Models
import SwiftUI

struct LogEntryHeaderView: View {
    let source: LogEntry.Source
    let category: String
    let createdAt: Date
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack(spacing: spacing / 2) {
            Text(category)
                .foregroundStyle(.primary)
            
            Image(systemName: "chevron.forward")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            
            LogEntrySourceView(data: source)
                .foregroundStyle(.tint)
            
            Spacer()
            
            Text(createdAt, style: .time)
        }
        .foregroundStyle(.secondary)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.tint)
                .frame(width: spacing * 0.75)
                .offset(x: -spacing * 1.25)
        }
        .font(.footnote)
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    LogEntryHeaderView(
        source: "Source",
        category: "Category",
        createdAt: Date()
    )
    .padding()
}
