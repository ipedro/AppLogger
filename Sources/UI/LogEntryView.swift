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
import enum Models.Mock
import struct Models.Category
import struct Models.Content
import struct Models.Source
import struct Models.ID
import class Data.ColorStore
import class Data.DataObserver

struct LogEntryView: View {
    let id: ID
    
    private var source: Source { data.entrySources[id]! }
    
    private var category: Category { data.entryCategories[id]! }
    
    private var content: Content { data.entryContents[id]! }
    
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
            
            if !content.userInfo.isEmpty {
                LogEntryUserInfoView(
                    data: content.userInfo,
                    tint: tint
                )
            }
        }
        .padding([.leading, .top, .bottom])
    }
}

#if DEBUG
extension LogEntryView {
    init(mock: Mock) {
        let entry = mock.rawValue
        self.id = entry.id
    }
}
#endif

#Preview {
    let allEntries = Mock.allCases.map(\.rawValue)
    
    ScrollView {
        LazyVStack(spacing: 0) {
            ForEach(0..<10) { _ in
                ForEach(allEntries.shuffled()) { entry in
                    LogEntryView(id: entry.id).safeAreaInset(
                        edge: .bottom,
                        content: Divider.init
                    )
                }
            }
        }
    }
    .environmentObject(ColorStore<Source>())
    .environmentObject(DataObserver(
        entryCategories: allEntries.reduce(into: [:], { $0[$1.id] = $1.category }),
        entryContents: allEntries.reduce(into: [:], { $0[$1.id] = $1.content }),
        entrySources: allEntries.reduce(into: [:], { $0[$1.id] = $1.source })
    ))
}
