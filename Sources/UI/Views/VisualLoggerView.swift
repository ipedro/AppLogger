// MIT License
//
// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Data
import Models
import SwiftUI

@available(iOS 16.0, *)
package extension VisualLoggerView where Content == NavigationStack<NavigationPath, LogEntriesList> {
    static func navigationStack() -> Self {
        Self(content: NavigationStack(root: LogEntriesList.init))
    }
}

package extension VisualLoggerView where Content == NavigationView<LogEntriesList> {
    static func navigationView() -> Self {
        Self(content: NavigationView(content: LogEntriesList.init))
    }
}

package struct VisualLoggerView<Content>: View where Content: View {
    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme

    @Environment(\.colorScheme)
    private var currentColorScheme

    @Environment(\.configuration.tintColor)
    private var tintColor

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    private let content: Content

    package var body: some View {
        let _ = Self._debugPrintChanges()
        content
            .tint(tintColor)
            .colorScheme(preferredColorScheme ?? currentColorScheme)
            .onDisappear {
                // There is a bug with the SwiftUI environment that can hold on
                // to the view model if the search bar has come into focus
                // during the logger presentation, so cancelling observers
                // manually to be safe.
                //
                // The zombie view model gets released when the search bar comes
                // into focus again.
                viewModel.stop()
            }
    }
}

@available(iOS 16.0, *)
#Preview {
    let allEntries = LogEntryMock.allCases.map { $0.entry() }

    var colorGenerator = DynamicColorGenerator<LogEntrySource>()

    let dataObserver = DataObserver(
        allCategories: Set(allEntries.map(\.category)).sorted(),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        customActions: [
            VisualLoggerAction(
                title: "Action",
                image: nil,
                handler: { _ in print("Action executed")
                }
            ),
        ],
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:]) { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        }
    )

    VisualLoggerView.navigationStack()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(tintColor: .red))
}
