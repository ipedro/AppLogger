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
import struct Models.Category
import struct Models.Content
import struct Models.DynamicColor
import struct Models.ID
import struct Models.Source
import struct Models.UserInfoKey

struct LogEntryView: View {
    let id: ID
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.spacing)
    private var spacing
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel

    var body: some View {
        let source = viewModel.entrySource(id)
        let category = viewModel.entryCategory(id)
        let createdAt = viewModel.entryCreatedAt(id)
        let content = viewModel.entryContent(id)
        let userInfo = viewModel.entryUserInfoKeys(id)
        let tint = viewModel.sourceColor(source, for: colorScheme)
        
        VStack(alignment: .leading, spacing: spacing) {
            LogEntryHeaderView(
                tint: tint,
                source: source,
                category: category.description,
                createdAt: createdAt
            )
            .padding(.trailing, spacing * 2)
            
            LogEntryContentView(
                category: category,
                content: content,
                tint: tint
            )
            .padding(.horizontal, spacing * 2)
            
            if let userInfo {
                LogEntryUserInfoRows(
                    ids: userInfo,
                    tint: tint
                )
                .padding(EdgeInsets(
                    top: spacing,
                    leading: spacing * 2,
                    bottom: .zero,
                    trailing: spacing * 2
                ))
            }
        }
        .padding(EdgeInsets(
            top: spacing * 2,
            leading: spacing,
            bottom: spacing * 2,
            trailing: .zero
        ))
        .background(.background)
    }
}

#if DEBUG
extension LogEntryView {
    init(mock: Mock) {
        let entry = mock.entry()
        self.id = entry.id
    }
}
#endif

#Preview {
    let entry = Mock.socialLogin.entry()
    
    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                AppLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
}

#Preview {
    let entry = Mock.googleAnalytics.entry()
    
    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                AppLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
    .background(.red)
}
