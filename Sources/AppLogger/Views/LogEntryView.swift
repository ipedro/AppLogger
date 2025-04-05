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

import SwiftUI

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

#Preview {
    LogEntryView(
        viewModel: .init(logEntry: AppLoggerEntryMock.logger)
    )
}

#Preview {
    LogEntryView(
        viewModel: .init(logEntry: AppLoggerEntryMock.socialLogin)
    )
}

#Preview {
    LogEntryView(
        viewModel: .init(logEntry: AppLoggerEntryMock.error)
    )
}

#Preview {
    LogEntryView(
        viewModel: .init(logEntry: AppLoggerEntryMock.analytics)
    )
}
