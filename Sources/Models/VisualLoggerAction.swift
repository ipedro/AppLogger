//
//  VisualLoggerAction.swift
//  swiftui-visual-logger
//
//  Created by Pedro Almeida on 12.04.25.
//

import SwiftUI

@available(iOS 13.0, *)
public struct VisualLoggerAction: Identifiable, Sendable {
    /// A type that defines the closure for an action handler.
    public typealias ActionHandler = @MainActor (_ action: VisualLoggerAction) -> Void

    /// This action's identifier.
    public let id: String

    /// Short display title.
    package let title: String

    /// Image that can appear next to this action.
    package let image: Image?

    /// This action's handler
    private let handler: ActionHandler

    @MainActor
    package func execute() {
        handler(self)
    }
    
    public init(
        id: String? = nil,
        title: String,
        image: Image? = nil,
        handler: @escaping ActionHandler
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
        handler: @escaping ActionHandler
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
