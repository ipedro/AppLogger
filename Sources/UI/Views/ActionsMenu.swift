// MIT License

Copyright(c) 2025 Pedro Almeida

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
    in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

    import Data
import Models
import SwiftUI

struct ActionsMenu: View {
    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    @State
    private var customActions: [VisualLoggerAction] = []

    var body: some View {
        let _ = Self._debugPrintChanges()

        Menu {
            SortingButton()

            Divider()

            ForEach(customActions) { action in
                Button(role: action.role, action: action.execute) {
                    Label {
                        Text(action.title)
                    } icon: {
                        action.image
                    }
                }
                if action.id.starts(with: VisualLoggerAction.internalNamespace) {
                    Divider()
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .onReceive(viewModel.customActionsSubject) {
            customActions = $0
        }
    }
}

#Preview {
    ActionsMenu()
        .environmentObject(
            VisualLoggerViewModel(
                dataObserver: DataObserver(
                    customActions: [
                        VisualLoggerAction(
                            title: "Action",
                            systemImage: "plus.circle",
                            handler: {
                                _ in print("Action executed")
                            }
                        ),
                        VisualLoggerAction(
                            title: "Destructive Action",
                            role: .destructive,
                            systemImage: "trash",
                            handler: {
                                _ in print("Action executed")
                            }
                        ),
                    ]
                ),
                dismissAction: {}
            )
        )
}
