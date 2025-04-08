import class UIKit.UIActivity

/// Represents an activity for presenting an ActivityView (Share sheet) via the `activitySheet` modifier
package struct ActivityItem {
    package var items: [Any]
    package var activities: [UIActivity]

    /// The
    /// - Parameters:
    ///   - items: The items to share via a `UIActivityViewController`
    ///   - activities: Custom activities you want to include in the sheet
    package init(items: Any..., activities: [UIActivity] = []) {
        self.items = items
        self.activities = activities
    }
}
