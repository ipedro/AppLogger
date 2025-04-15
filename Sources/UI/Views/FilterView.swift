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
import Models
import SwiftUI

struct FilterView: View {
    let data: LogFilter

    @Binding var isOn: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.tintColor)
    private var tintColor

    private let shape = Capsule()

    private var backgroundColor: Color {
        (tintColor ?? .accentColor).opacity(0.08)
    }

    var body: some View {
        let _ = Self._debugPrintChanges()
        Toggle(data.displayName, isOn: $isOn)
            .clipShape(shape)
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)
            .background(backgroundColor, in: shape)
    }
}

#if swift(>=6.0)
    extension FilterView: @preconcurrency Equatable {
        static func == (lhs: FilterView, rhs: FilterView) -> Bool {
            lhs.data == rhs.data && lhs.isOn == rhs.isOn
        }
    }
#else
    extension FilterView: Equatable {
        static func == (lhs: FilterView, rhs: FilterView) -> Bool {
            lhs.data == rhs.data && lhs.isOn == rhs.isOn
        }
    }
#endif

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false

    VStack {
        FilterView(
            data: "Some Filter",
            isOn: $isOn
        )
    }
}
