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

import SwiftUI
import VisualLogger

struct ContentView: View {
    @State
    private var showLogger = false

    @State
    private var errorCount = 0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")

            Toggle(
                "\(showLogger ? "Dismiss" : "Present") VisualLogger",
                isOn: $showLogger
            )
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)

            Button("Log Error", action: logError)

            Spacer()
        }
        .padding(30)
        .visualLoggerSheet(isPresented: $showLogger)
        .onChange(of: showLogger, perform: didShowLogger)
    }

    private func didShowLogger(_ newValue: Bool) {
        if newValue {
            log.info("VisualLogger presented")
        } else {
            log.info("VisualLogger dismissed")
        }
    }

    private func logError() {
        log.error("Error #\(errorCount) occurred", userInfo: [
            "code": 123,
            "domain": "https://example.com",
            "reason": "Something went wrong",
        ])
        errorCount += 1
    }
}

#Preview {
    ContentView()
}
