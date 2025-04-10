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
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.configuration.navigationTitle)
    private var navigationTitle
    
    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    package init() {}
    
    package var body: some View {
        NavigationView {
            LogEntriesList()
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(navigationTitle)
                .toolbar {
                    ToolbarItem(
                        placement: .topBarLeading,
                        content: leadingNavigationBarItems
                    )
                    ToolbarItem(
                        placement: .topBarTrailing,
                        content: trailingNavigationBarItems
                    )
                }
        }
        .tint(accentColor)
        .colorScheme(preferredColorScheme ?? colorScheme)
        .activitySheet($viewModel.activityItem)
    }
    
    private func leadingNavigationBarItems() -> some View {
        HStack {
            FiltersDrawerToggle(
                isOn: $viewModel.showFilters,
                activeFilters: viewModel.activeScope.count
            )
            
            SortingButton(selection: $viewModel.sorting)
                .disabled(viewModel.entries.isEmpty)
        }
    }
    
    private func trailingNavigationBarItems() -> some View {
        DismissButton(action: viewModel.dismissAction)
    }
}

#Preview {
    let allEntries = Mock.allCases.map { $0.entry() }
    
    let dataObserver = DataObserver(
        allCategories: Set(allEntries.map(\.category)).sorted(),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo)
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
        .configuration(.init(accentColor: .red))
}
