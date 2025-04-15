import SwiftUI

/// A type that defines the closure for an action handler.
public typealias VisualLoggerActionHandler = @MainActor (_ action: VisualLoggerAction) -> Void

/// A value that describes the purpose of an action.
public enum VisualLoggerActionRole {
    /// A role that indicates a regular action.
    case regular
    /// A role that indicates a destructive action.
    case destructive
}

/// A menu element that performs its action in a closure.
///
/// Create a `VisualLoggerAction` object when you want to customize the `VisualLogger` with a menu element that performs its action in a closure.
public struct VisualLoggerAction: Identifiable, Sendable {
    /// This action's identifier.
    public let id: String

    /// Short display title.
    public let title: String

    /// Image that can appear next to this action.
    package let image: Image?

    /// The role of the action which determines its styling.
    package let role: ButtonRole?

    /// This action's handler.
    private let handler: VisualLoggerActionHandler

    @MainActor
    package func execute() {
        handler(self)
    }

    /// Initializes a new `VisualLoggerAction` with an optional identifier, a title, a role, an optional image, and an action handler.
    ///
    /// If `id` is omitted, the title will be used as the identifier.
    ///
    /// - Parameters:
    ///   - id: An optional identifier for the action. If `nil`, the `title` is used as the identifier.
    ///   - title: A short display title for the action.
    ///   - role: The role for the action, which determines its styling. Defaults to `.regular`.
    ///   - image: An optional `Image` to display alongside the title.
    ///   - handler: A closure that defines the action to perform when this action is executed.
    ///
    /// **Example:**
    /// ```swift
    /// let action = VisualLoggerAction(title: "Refresh Logs", role: .regular, image: Image(systemName: "arrow.clockwise")) { action in
    ///     // Handle refresh action
    /// }
    /// ```
    public init(
        id: String? = nil,
        title: String,
        role: VisualLoggerActionRole = .regular,
        image: Image? = nil,
        handler: @escaping VisualLoggerActionHandler
    ) {
        self.id = id ?? title
        self.title = title
        self.image = image
        self.handler = handler
        self.role = {
            switch role {
            case .regular:
                return nil
            case .destructive:
                return .destructive
            }
        }()
    }

    /// Initializes a new `VisualLoggerAction` using a system image name.
    ///
    /// This initializer creates a new instance with an image generated from the provided system image name.
    /// If `id` is omitted, the `title` is used as the identifier.
    ///
    /// - Parameters:
    ///   - id: An optional identifier for the action. If `nil`, the `title` is used as the identifier.
    ///   - title: A short display title for the action.
    ///   - role: The role for the action, which determines its styling. Defaults to `.regular`.
    ///   - systemImage: A string representing the name of the system image to display.
    ///   - handler: A closure that defines the action to perform when this action is executed.
    ///
    /// **Example:**
    /// ```swift
    /// let action = VisualLoggerAction(title: "Delete", role: .destructive, systemImage: "trash") { action in
    ///     // Handle delete action
    /// }
    /// ```
    public init(
        id: String? = nil,
        title: String,
        role: VisualLoggerActionRole = .regular,
        systemImage: String,
        handler: @escaping VisualLoggerActionHandler
    ) {
        self.init(
            id: id,
            title: title,
            role: role,
            image: Image(systemName: systemImage),
            handler: handler
        )
    }

    /// Initializes a new `VisualLoggerAction` using a `UIImage`.
    ///
    /// This initializer allows the creation of an action with a `UIImage`. It converts the `UIImage` into a SwiftUI `Image` internally.
    /// If `id` is omitted, the `title` is used as the identifier.
    ///
    /// - Parameters:
    ///   - id: An optional identifier for the action. If `nil`, the `title` is used as the identifier.
    ///   - title: A short display title for the action.
    ///   - role: The role for the action, which determines its styling. Defaults to `.regular`.
    ///   - image: An optional `UIImage` to display alongside the title.
    ///   - handler: A closure that defines the action to perform when this action is executed.
    ///
    /// **Example:**
    /// ```swift
    /// let uiImage = UIImage(named: "customIcon")
    /// let action = VisualLoggerAction(title: "Custom Action", role: .regular, image: uiImage) { action in
    ///     // Handle custom action
    /// }
    /// ```
    @_disfavoredOverload
    public init(
        id: String? = nil,
        title: String,
        role: VisualLoggerActionRole = .regular,
        image: UIImage? = nil,
        handler: @escaping VisualLoggerActionHandler
    ) {
        self.init(
            id: id,
            title: title,
            role: role,
            image: {
                if let image {
                    Image(uiImage: image)
                } else {
                    nil
                }
            }(),
            handler: handler
        )
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
        lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
    }
}
