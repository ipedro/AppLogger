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
                    .foregroundColor(action.role == .destructive ? .red : nil)
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
