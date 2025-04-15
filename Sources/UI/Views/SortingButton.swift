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

struct SortingButton: View {
    var options = LogEntrySorting.allCases

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @State
    private var selection: LogEntrySorting = UserDefaults.standard.sorting

    @Environment(\.configuration.icons)
    private var icons

    var body: some View {
        let _ = Self._debugPrintChanges()
        Picker(selection: $selection) {
            ForEach(options, id: \.rawValue) { option in
                Label(
                    option.description,
                    systemImage: icon(option)
                ).tag(option)
            }
        } label: {
            Label("Sorting", systemImage: icon)
        }
        .symbolRenderingMode(.hierarchical)
        .onReceive(viewModel.entriesSortingSubject) {
            selection = $0
        }
        .onChange(of: selection) {
            viewModel.entriesSortingSubject.send($0)
        }
    }

    private var icon: String {
        icon(selection)
    }

    private func icon(_ sorting: LogEntrySorting) -> String {
        switch sorting {
        case .ascending: icons.sortAscending
        case .descending: icons.sortDescending
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    SortingButton()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: DataObserver(),
                dismissAction: {}
            )
        )
}
