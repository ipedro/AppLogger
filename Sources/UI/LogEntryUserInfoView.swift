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
import struct Models.UserInfo

struct LogEntryUserInfoView: View {
    var data: UserInfo
    var tint: Color? = .secondary

    @Environment(\.spacing)
    private var spacing
    
    private var rows: [(key: String, value: String)] {
        switch data.storage {
            case let .dictionary(dictionary):
                dictionary.sorted(by: <)
            case let .message(message):
                [("", message)]
        }
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: .zero) {
            let rows = rows
            
            ForEach(Array(zip(rows.indices, rows)), id: \.0) { offset, item in
                LogEntryUserInfoRow(
                    key: item.key,
                    value: item.value,
                    tint: tint
                )
                .padding(spacing)
                .background(Color(backgroundColor(for: offset)))
                .cornerRadius(spacing)
            }
        }
        .padding(.horizontal, spacing * 2)
        .padding(.top, spacing)
    }
    
    private func backgroundColor(for index: Int) -> UIColor {
        index.isMultiple(of: 2) ? .systemGroupedBackground : .secondarySystemGroupedBackground
    }
}

#Preview {
    LogEntryUserInfoView(
        data: [
            "environment": "dev",
            "event": "open screen",
            "": "Hey test",
        ],
        tint: .blue
    )
}

#Preview {
    LogEntryUserInfoView(
        data: [
            "dev",
            "open screen",
            "Hey test",
        ],
        tint: .blue
    )
}

#Preview {
    LogEntryUserInfoView(
        data: "Hey test",
        tint: .blue
    )
}
