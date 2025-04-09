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
import enum Models.SourceInfo

struct LogEntrySourceView: View {
    let name: String
    let data: SourceInfo?

    private var label: String {
        switch data {
        case let .sdk(version):
            "\(name) (\(version))"
        case let .swift(lineNumber):
            "\(name).swift:\(lineNumber)"
        case let .error(code):
            "\(name) Code: \(code)"
        case .none:
            name
        }
    }
    
    var body: some View {
        Text(label).font(.footnote)
    }
}

#Preview {
    VStack {
        LogEntrySourceView(
            name: "File",
            data: .swift(lineNumber: 12)
        )
        
        LogEntrySourceView(
            name: "MySDK",
            data: .sdk(version: "1.2.3")
        )
        
        LogEntrySourceView(
            name: "Something else",
            data: .none
        )
        
        LogEntrySourceView(
            name: "Some Error",
            data: .error(code: 15)
        )
    }
}
