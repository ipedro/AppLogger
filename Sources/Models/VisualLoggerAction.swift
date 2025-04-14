import SwiftUI

/// A type that defines the closure for an action handler.
public typealias VisualLoggerActionHandler = @MainActor (_ action: VisualLoggerAction) -> Void

/// A menu element that performs its action in a closure.
///
/// Create a ``VisualLoggerAction`` object when you want to customize the `VisualLogger` with a menu element that performs its action in a closure.
public struct VisualLoggerAction: Identifiable, Sendable {
    /// This action's identifier.
    public let id: String

    /// Short display title.
    public let title: String

    /// Image that can appear next to this action.
    package let image: Image?

    /// This action's handler
    private let handler: VisualLoggerActionHandler

    @MainActor
    package func execute() {
        handler(self)
    }

    public init(
        id: String? = nil,
        title: String,
        image: Image? = nil,
        handler: @escaping VisualLoggerActionHandler
    ) {
        self.id = id ?? title
        self.title = title
        self.image = image
        self.handler = handler
    }

    @_disfavoredOverload
    public init(
        id: String? = nil,
        title: String,
        image: UIImage? = nil,
        handler: @escaping VisualLoggerActionHandler
    ) {
        self.id = id ?? title
        self.title = title
        self.image = if let image {
            Image(uiImage: image)
        } else {
            nil
        }
        self.handler = handler
    }
}

extension VisualLoggerAction: Equatable {
    public static func == (lhs: VisualLoggerAction, rhs: VisualLoggerAction) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.image == rhs.image
    }
}

extension VisualLoggerAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension VisualLoggerAction: Comparable {
    public static func < (lhs: VisualLoggerAction, rhs: VisualLoggerAction) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
