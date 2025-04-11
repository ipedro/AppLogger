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
import class Data.AppLoggerViewModel
import class Data.DataObserver
import enum Models.Mock
import struct Models.UserInfoKey

struct LogEntryUserInfoRows: View {
    var ids: [UserInfoKey]

    @Environment(\.spacing)
    private var spacing
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ForEach(Array(ids.enumerated()), id: \.offset) { offset, id in
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
    let entry = Mock.socialLogin.entry()
    
    ScrollView {
        LogEntryUserInfoRows(
            ids: entry.userInfo?.storage.map {
                UserInfoKey(id: entry.id, key: $0.key)
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
