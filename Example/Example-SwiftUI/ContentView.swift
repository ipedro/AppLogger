//
//  ContentView.swift
//  Example-SwiftUI
//
//  Created by Pedro Almeida on 14.04.25.
//

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
                "Present VisualLogger",
                isOn: $showLogger
            )
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)

            Button("Log Error") {
                log.error("Error #\(errorCount) occurred", userInfo: [
                    "code": 123,
                    "domain": "example.com",
                    "reason": "Something went wrong",
                ])
                errorCount += 1
            }

            Spacer()
        }
        .padding(30)
        .visualLoggerSheet(isPresented: $showLogger)
        .onChange(of: showLogger) { newValue in
            if newValue {
                log.info("VisualLogger presented")
            } else {
                log.info("VisualLogger dismissed")
            }
        }
    }
}

#Preview {
    ContentView()
}
