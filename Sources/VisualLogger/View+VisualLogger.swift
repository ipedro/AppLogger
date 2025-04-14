//  Copyright (c) 2025 Pedro Almeida
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

import Data
import SwiftUI
import UI

public extension View {
    /// Presents a visual logging interface modally using a sheet presentation.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that indicates whether the logger should be presented.
    ///   - configuration: The configuration object for customizing the appearance and behavior of the logger (default is `.init()`).
    ///   - onDismiss: An optional closure that is called when the logger is dismissed.
    ///
    /// - Returns: A view modified to present the visual logger.
    ///
    /// **Example:**
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showLogger = false
    ///
    ///     var body: some View {
    ///         Button("Show Logger") {
    ///             showLogger = true
    ///         }
    ///         .visualLogger(isPresented: $showLogger)
    ///     }
    /// }
    /// ```
    @available(iOS, introduced: 15.0, deprecated: 16.4, message: "Please use visualLoggerSheet(isPresented:configuration:onDismiss:)")
    func visualLogger(
        isPresented: Binding<Bool>,
        configuration: VisualLoggerConfiguration = .init(),
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            VisualLoggerPresentationModifier(
                isPresented: isPresented,
                configuration: configuration,
                onDismiss: onDismiss,
                sheetContent: VisualLoggerView.navigationView
            )
        )
    }

    /// Presents a visual logging interface modally using the new sheet presentation APIs.
    ///
    /// This method leverages enhanced sheet presentation features available in iOS 16.4 and later.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that indicates whether the logger should be presented.
    ///   - configuration: The configuration object for customizing the appearance and behavior of the logger (default is `.init()`).
    ///   - onDismiss: An optional closure that is called when the logger is dismissed.
    ///
    /// - Returns: A view modified to present the visual logger using a sheet.
    ///
    /// **Example:**
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var showLogger = false
    ///
    ///     var body: some View {
    ///         Button("Show Logger") {
    ///             showLogger = true
    ///         }
    ///         .visualLoggerSheet(isPresented: $showLogger)
    ///     }
    /// }
    /// ```
    @available(iOS 16.4, *)
    func visualLoggerSheet(
        isPresented: Binding<Bool>,
        configuration: VisualLoggerConfiguration = .init(),
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            VisualLoggerPresentationModifier(
                isPresented: isPresented,
                configuration: configuration,
                onDismiss: onDismiss,
                sheetContent: {
                    VisualLoggerView.navigationStack()
                        .presentationDetents([.large, .medium])
                        .presentationDragIndicator(.visible)
                        .presentationContentInteraction(.scrolls)
                        .presentationBackgroundInteraction(.enabled)
                }
            )
        )
    }
}

private struct VisualLoggerPresentationModifier<SheetContent: View>: ViewModifier {
    @Binding
    var isPresented: Bool

    var configuration: VisualLoggerConfiguration

    var onDismiss: (() -> Void)?

    @ViewBuilder
    let sheetContent: () -> SheetContent

    @State
    private var dataObserver: DataObserver?

    private var __isPresented: Binding<Bool> {
        Binding(
            get: { isPresented && dataObserver != nil },
            set: { isPresented = $0 }
        )
    }

    func body(content: Content) -> some View {
        content.task(id: isPresented) {
            if isPresented {
                dataObserver = await VisualLogger.current.makeDataObserver()
            } else {
                dataObserver = nil
            }
        }.sheet(isPresented: __isPresented, onDismiss: onDismiss) {
            if let dataObserver {
                sheetContent()
                    .configuration(configuration)
                    .environmentObject(
                        VisualLoggerViewModel(
                            dataObserver: dataObserver,
                            dismissAction: {
                                isPresented = false
                            }
                        )
                    )
            }
        }
    }
}
