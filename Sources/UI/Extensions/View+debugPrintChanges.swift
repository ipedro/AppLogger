import SwiftUI

extension View {
    static func _debugPrintChanges() {
        #if DEBUG_VIEWS
        Self._printChanges()
        #endif
    }
}
