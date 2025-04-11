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
import class Data.DataObserver
import struct Data.DynamicColorGenerator
import enum Models.Mock
import struct Models.Source

@available(iOS 16.0, *)
package struct LogEntriesNavigationStack: View {

    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    package init() {}
    
    package var body: some View {
        NavigationStack {
            LogEntriesNavigationContent()
        }
        .tint(accentColor)
        .colorScheme(preferredColorScheme ?? colorScheme)
        .activitySheet($viewModel.activityItem)
    }
}

@available(iOS 16.0, *)
#Preview {
    let allEntries = Mock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<Source>()
    
    let dataObserver = DataObserver(
        allCategories: Set(allEntries.map(\.category)).sorted(),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:], { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        })
    )
    
    LogEntriesNavigationStack()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(accentColor: .red))
}
