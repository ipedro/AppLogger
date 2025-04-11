import SwiftUI

extension View {
    static func _debugPrintChanges() {
        #if DEBUG_VIEWS
            _printChanges()
        #endif
    }
}
