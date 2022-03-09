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

struct UserInfoView: View {
    let items: [String: String]
    var valueColor: Color? = .secondary

    private func format(value: String) -> String? {
        let string = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return string.isEmpty ? .none : string
    }

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: .zero) {
                let items = items.filter({ format(value: $0.value) != nil }).sorted(by: <)

                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    if let formattedValue = format(value: item.value) {
                        UserInfoRowView(
                            key: item.key,
                            value: item.value,
                            valueColor: valueColor,
                            formattedValue: formattedValue
                        )
                            .padding(8)
                            .background(
                                Color(index.isMultiple(of: 2) ? .softBackground : .clear)
                            )
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct PreviewsUserInfoViewPreviews: PreviewProvider {
    static var previews: some View {
        UserInfoView(
            items: [
                "environment": "dev",
                "event": "open screen",
            ],
            valueColor: .blue
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
