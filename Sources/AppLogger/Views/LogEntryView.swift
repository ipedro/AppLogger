//  Copyright (c) 2022 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
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

struct LogEntryView: View {
    @Environment(\.colorScheme) private var colorScheme

    var viewModel: LogEntryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: viewModel.spacing) {
            TitleView(
                badgeColor: viewModel.badgeColor(colorScheme),
                title: viewModel.title,
                createdAt: viewModel.createdAt,
                spacing: viewModel.spacing
            )
                .font(.footnote)
                .padding(.vertical, .zero)
                .padding(.trailing, viewModel.spacing * 2)

            SourceView(
                name: viewModel.sourceName,
                info: viewModel.sourceInfo
            )
                .font(.footnote)
                .padding(.horizontal, viewModel.spacing * 2)
                .foregroundColor(viewModel.badgeColor(colorScheme))

            Text(viewModel.content)
                .bold()
                .font(.callout)
                .minimumScaleFactor(0.85)
                .lineLimit(3)
                .padding(.horizontal, viewModel.spacing * 2)

            if let message = viewModel.message, !message.isEmpty {
                HStack(alignment: .top) {
                    if let icon = viewModel.icon {
                        Text(icon)
                    }

                    LinkText(message)
                }
                    .font(.footnote)
                    .foregroundColor(viewModel.badgeColor(colorScheme))
                    .padding( viewModel.spacing * 1.5)
                    .background(viewModel.messageBackgroundColor(colorScheme))
                    .cornerRadius(viewModel.spacing * 1.8)
                    .padding(.horizontal, viewModel.spacing * 2)
                    .padding(.vertical, viewModel.spacing)
            }

            UserInfoView(
                items: viewModel.userInfo,
                valueColor: viewModel.badgeColor(colorScheme)
            )
                .padding(.horizontal, viewModel.spacing * 2)
                .padding(.top, viewModel.spacing)
        }
        .padding([.leading, .top, .bottom])
    }
}

// MARK: - Previews

struct LogEntryViewPreviews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            Group {
                LogEntryView(
                    viewModel: .init(logEntry: AppLoggerEntryMock.logger)
                )

                LogEntryView(
                    viewModel: .init(logEntry: AppLoggerEntryMock.socialLogin)
                )

                LogEntryView(
                    viewModel: .init(logEntry: AppLoggerEntryMock.error)
                )

                LogEntryView(
                    viewModel: .init(logEntry: AppLoggerEntryMock.analytics)
                )
            }
            .background(Color(.systemBackground))
            .colorScheme(colorScheme)
        }
        .previewLayout(.sizeThatFits)
    }
}
