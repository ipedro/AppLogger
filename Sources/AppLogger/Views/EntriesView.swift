//  Copyright (c) 2022 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI

struct EntriesView: View {
    var entries: [LogEntry]
    var emptyReason: String

    var body: some View {
        LazyVStack {
            ForEach(entries, id: \.self) {
                Divider()
                    .opacity(0.5)
                LogEntryView(viewModel: .init(logEntry: $0))
            }
        }
        .background {
            if entries.isEmpty {
                Text(emptyReason)
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .padding(.top, 50)
            }
        }
    }
}

#Preview {
    EntriesView(
        entries: [
            AppLoggerEntryMock.socialLogin,
            AppLoggerEntryMock.analytics
        ],
        emptyReason: "No data"
    )
}
