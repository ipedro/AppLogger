//
//  LogEntryViewModel.swift
//  AppLogger
//
//  Created by Pedro Almeida on 05.04.25.
//

import SwiftUI

struct LogEntryViewModel: Hashable {
    private var logEntry: LogEntry

    var spacing: CGFloat

    var title: String { logEntry.category.displayName }

    var content: String { logEntry.content.description }

    var icon: String? { logEntry.category.emojiString }

    var createdAt: Date { logEntry.createdAt }

    var sourceName: String { logEntry.source.displayName }

    var sourceInfo: AppLoggerSourceInfo? { logEntry.source.debugInfo }

    var message: String? { logEntry.content.output }

    var userInfo: [String: String] { logEntry.content.userInfo }

    func badgeColor(_ colorScheme: ColorScheme) -> Color { Color(debugColor(colorScheme)) }

    func messageBackgroundColor(_ colorScheme: ColorScheme) -> Color { Color(debugColor(colorScheme).withAlphaComponent(0.16)) }


    init(spacing: CGFloat = 8, logEntry: LogEntry) {
        self.spacing = spacing
        self.logEntry = logEntry
    }

    private func debugColor(_ colorScheme: ColorScheme) -> UIColor {
        if let sourceColor = logEntry.source.debugColor { return sourceColor }
        if let randomColor = randomColor()?.with(colorScheme) { return randomColor }
        return .secondaryLabel
    }

    private static var sourceColors = [String: ColorPalette.DynamicColor]()

    private static var availableColors: [ColorPalette.DynamicColor] = []

    private func randomColor() -> ColorPalette.DynamicColor? {
        if Self.availableColors.isEmpty {
            Self.availableColors = ColorPalette.allColors.shuffled()
        }
        let color = Self.sourceColors[logEntry.source.debugName] ?? Self.availableColors.removeFirst()
        Self.sourceColors[logEntry.source.debugName] = color
        return color
    }

}
