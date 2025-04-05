import UIKit

/// Represents an activity for presenting an ActivityView (Share sheet) via the `activitySheet` modifier
struct ActivityItem {

    var items: [Any]
    var activities: [UIActivity]

    /// The
    /// - Parameters:
    ///   - items: The items to share via a `UIActivityViewController`
    ///   - activities: Custom activities you want to include in the sheet
    init(items: Any..., activities: [UIActivity] = []) {
        self.items = items
        self.activities = activities
    }
    
}
