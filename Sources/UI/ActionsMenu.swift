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
                Button(action: action.execute) {
                    Label {
                        Text(action.title)
                    } icon: {
                        action.image
                    }
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
                            image: nil,
                            handler: {
                                _ in print("Action executed")
                            }
                        ),
                        VisualLoggerAction(
                            title: "Action 2",
                            image: nil,
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
