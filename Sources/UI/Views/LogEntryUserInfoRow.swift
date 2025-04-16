// MIT License
//
// Copyright (c) 2025 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Data
import Models
import SwiftUI

struct LogEntryUserInfoRow: View {
    let offset: Int
    let id: LogEntryUserInfoKey
    let last: Bool

    @Environment(\.spacing)
    private var spacing

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject
    private var viewModel: VisualLoggerViewModel

    var body: some View {
        let _ = Self._debugPrintChanges()
        HStack(alignment: .top, spacing: spacing) {
            if !id.key.isEmpty {
                keyText
                Spacer(minLength: spacing)
            }
            valueText
        }
        .padding(spacing)
        .background(
            backgroundColor,
            in: BackgroundShape(
                radius: cornerRadius,
                corners: roundedCorners
            )
        )
    }

    private var cornerRadius: CGFloat {
        if offset == 0, last {
            spacing
        } else {
            spacing * 1.5
        }
    }

    private var roundedCorners: UIRectCorner {
        var roundedCorners = UIRectCorner()
        if offset == 0 {
            roundedCorners.insert([.topLeft, .topRight])
        }
        if last {
            roundedCorners.insert([.bottomLeft, .bottomRight])
        }
        return roundedCorners
    }

    private var backgroundColor: Color {
        if offset.isMultiple(of: 2) {
            Color(uiColor: .systemGray5)
        } else if colorScheme == .dark {
            Color(uiColor: .systemGray4)
        } else {
            Color(uiColor: .systemGray6)
        }
    }

    private var valueString: String {
        viewModel.entryUserInfoValue(id)
    }

    private var valueText: some View {
        LinkText(data: valueString, alignment: .trailing)
            .foregroundStyle(.tint)
            .font(.system(.caption, design: .monospaced))
    }

    private var keyText: some View {
        Text("\(id.key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .textSelection(.enabled)
    }
}

private struct BackgroundShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(
                    width: radius,
                    height: radius
                )
            ).cgPath
        )
    }
}
