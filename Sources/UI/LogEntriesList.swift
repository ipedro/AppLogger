//  Copyright (c) 2025 Pedro Almeida
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
import class Data.ColorStore
import class Data.DataObserver
import enum Models.Mock
import struct Models.Source

struct LogEntriesList: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.configuration.emptyReasons)
    private var emptyReasons
    
    private var emptyReason: String {
        if viewModel.searchQuery.isEmpty {
            emptyReasons.empty
        } else {
            "\(emptyReasons.searchResults) \"\(viewModel.searchQuery)\""
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero) {
                ForEach(viewModel.entries, id: \.self) { id in
                    LogEntryView(id: id).safeAreaInset(
                        edge: .bottom,
                        content: Divider.init
                    )
                    .transition(
                        .move(edge: viewModel.sorting == .ascending ? .bottom : .top)
                    )
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.entries)
            .background {
                if viewModel.entries.isEmpty {
                    Text(emptyReason)
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .padding(.top, 200)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

#Preview {
    let allEntries = Mock.allCases.map(\.rawValue)
    let dataObserver = DataObserver(
        allEntries: allEntries.map(\.id),
        entryCategories: allEntries.reduce(into: [:], { $0[$1.id] = $1.category }),
        entryContents: allEntries.reduce(into: [:], { $0[$1.id] = $1.content }),
        entrySources: allEntries.reduce(into: [:], { $0[$1.id] = $1.source })
    )
    
    LogEntriesList()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: {}
            )
        )
        .environmentObject(ColorStore<Source>())
        .environmentObject(dataObserver)
}
