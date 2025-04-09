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

package struct LogEntriesNavigationView: View {

    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.configuration.navigationTitle)
    private var navigationTitle
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    package init() {}
    
    package var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                FiltersDrawer()
                LogEntriesList()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .navigationBarItems(leading: leadingNavigationBarItems)
            .navigationBarItems(trailing: trailingNavigationBarItems)
            .endEditingOnDrag()
        }
        .preferredColorScheme(preferredColorScheme)
        .activitySheet($viewModel.activityItem)
    }
    
    private var leadingNavigationBarItems: some View {
        ExportButton {
            viewModel.activityItem = nil //dataStore.csvActivityItem()
            fatalError("implement")
        }
        .foregroundColor(.primary)
    }
    
    private var trailingNavigationBarItems: some View {
        DismissButton(action: viewModel.dismissAction)
    }
}

#Preview {
    let allEntries = Mock.allCases.map(\.rawValue)
    let dataObserver = DataObserver(
        allCategories: allEntries.map(\.category),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.reduce(into: [:], { $0[$1.id] = $1.category }),
        entryContents: allEntries.reduce(into: [:], { $0[$1.id] = $1.content }),
        entrySources: allEntries.reduce(into: [:], { $0[$1.id] = $1.source })
    )
    
    LogEntriesNavigationView()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .environmentObject(ColorStore<Source>())
        .environmentObject(dataObserver)
}
