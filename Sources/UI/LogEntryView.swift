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
import class Data.ColorStore
import class Data.DataObserver
import enum Models.Mock
import struct Models.Category
import struct Models.Content
import struct Models.ID
import struct Models.Source
import struct Models.UserInfoKey

struct LogEntryView: View {
    let id: ID
    
    private var source: Source { data.entrySources[id]! }
    
    private var category: Category { data.entryCategories[id]! }
    
    private var content: Content { data.entryContents[id]! }
    
    private var userInfo: [UserInfoKey]? { data.entryUserInfoKeys[id] }
    
    private var createdAt: Date { id.createdAt }
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.spacing)
    private var spacing
    
    @EnvironmentObject
    private var colorStore: ColorStore<Source>
    
    @EnvironmentObject
    private var data: DataObserver

    var body: some View {
        let tint = colorStore
            .color(for: source)
            .resolve(with: colorScheme)
        
        VStack(alignment: .leading, spacing: spacing) {
            LogEntryTitleView(
                tint: tint,
                title: category.description,
                createdAt: createdAt
            )
            
            LogEntrySourceView(
                name: source.description,
                data: source.debugInfo
            )
            .foregroundStyle(tint)
            
            LogEntryContentView(
                category: category,
                content: content,
                tint: tint
            )
            
            if let userInfo {
                LogEntryUserInfoRows(
                    ids: userInfo,
                    tint: tint
                )
            }
        }
        .padding([.leading, .top, .bottom])
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
            .environmentObject(ColorStore<Source>())
            .environmentObject(DataObserver(
                entryCategories: [entry.id: entry.category],
                entryContents: [entry.id: entry.content],
                entrySources: [entry.id: entry.source],
                entryUserInfos: [entry.id: entry.userInfo]
            ))
    }
}
#Preview {
    let entry = Mock.googleAnalytics.entry()
    
    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(ColorStore<Source>())
            .environmentObject(DataObserver(
                entryCategories: [entry.id: entry.category],
                entryContents: [entry.id: entry.content],
                entrySources: [entry.id: entry.source],
                entryUserInfos: [entry.id: entry.userInfo]
            ))
    }
    .background(.red)
}
