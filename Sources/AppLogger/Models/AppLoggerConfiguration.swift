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

public struct AppLoggerConfiguration: Hashable {
    public var navigationTitle: String

    public var minimumSearchQueryLength: UInt

    public var colorScheme: ColorScheme?

    public var icons: Icons = .init()

    public var emptyReasons: EmptyReasons = .init()

    public var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd—HH-mm-ss"
        return dateFormatter
    }()

    public init(
        navigationTitle: String = "Application Logs",
        colorScheme: ColorScheme? = .none,
        minimumSearchQueryLength: UInt = 3
    ) {
        self.navigationTitle = navigationTitle
        self.minimumSearchQueryLength = minimumSearchQueryLength
        self.colorScheme = colorScheme
    }
}

public extension AppLoggerConfiguration {
    struct EmptyReasons: Hashable {
        public var searchResults = "No results matching"
        public var `default` = "No Entries Yet"
    }

    struct Icons: Hashable {
        public var export = "square.and.arrow.up"
        public var dismiss = "xmark"
        public var filtersOn = "line.3.horizontal.decrease.circle.fill"
        public var filtersOff = "line.3.horizontal.decrease.circle"
        public var sorting = "arrow.up.arrow.down"
    }
}
