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

struct SourceView: View {
    let name: String
    let info: AppLoggerSourceInfo?

    var body: some View {
        switch info {
        case let .sdk(version):
            return Text("\(name.titleCase()) (\(version))")
        case let .swift(lineNumber):
            return Text("\(name).swift:\(lineNumber)")
        case let .error(code):
            return Text("\(name) Code: \(code)")
        case .none:
            return Text(name)
        }
    }
}

private extension String {
    func titleCase() -> String {
        return self
            .replacingOccurrences(
                of: "([A-Z])",
                with: " $1",
                options: .regularExpression,
                range: range(of: self)
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}

#Preview {
    SourceView(
        name: "File",
        info: .swift(lineNumber: 12)
    )
}

#Preview {
    SourceView(
        name: "MySDK",
        info: .sdk(version: "1.2.3")
    )
}

#Preview {
    SourceView(
        name: "Something else",
        info: .none
    )
}
#Preview {
    SourceView(
        name: "Error",
        info: .error(code: 15)
    )
}
