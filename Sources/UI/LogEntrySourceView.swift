import Models
import SwiftUI

struct LogEntrySourceView: View {
    let data: LogEntry.Source

    private var label: String {
        switch data.info {
        case let .sdk(version):
            "\(data) (\(version))"
        case let .file(lineNumber):
            "\(data).swift:\(lineNumber)"
        case let .error(code):
            "\(data) (Code \(code))"
        case .none:
            data.description
        }
    }
    
    var body: some View {
        Text(label)
    }
}

#Preview {
    VStack {
        LogEntrySourceView(
            data: LogEntry.Source("📄", "File.swift", .file(line: 12))
        )
        
        LogEntrySourceView(
            data: LogEntry.Source("MySDK", .sdk(version: "1.2.3"))
        )
        
        LogEntrySourceView(
            data: "Some source"
        )
        
        LogEntrySourceView(data: LogEntry.Source(CustomSource()))
    }
}

private struct CustomSource: LogEntrySource {
    var logEntryEmoji: Character? { "👌" }
}
