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

import class Combine.CurrentValueSubject
import protocol SwiftUI.ObservableObject
import struct Models.Category
import struct Models.Content
import struct Models.ID
import struct Models.Source

package final class DataObserver: ObservableObject, @unchecked Sendable {
    package init(
        allCategories: [Category] = [],
        allEntries: [ID] = [],
        allSources: [Source] = [],
        entryCategories: [ID : Category] = [:],
        entryContents: [ID : Content] = [:],
        entrySources: [ID : Source] = [:]
    ) {
        self.allCategories = CurrentValueSubject(allCategories)
        self.allEntries = CurrentValueSubject(allEntries)
        self.allSources = CurrentValueSubject(allSources)
        self.entryCategories = entryCategories
        self.entryContents = entryContents
        self.entrySources = entrySources
    }
    
    /// A published array of log entry IDs from the data store.
    package let allEntries: CurrentValueSubject<[ID], Never>
    
    /// An array holding all log entry categories present in the store.
    package internal(set) var allCategories: CurrentValueSubject<[Category], Never>
    
    /// An array holding all log entry sources present in the store.
    package internal(set) var allSources: CurrentValueSubject<[Source], Never>
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package internal(set) var entryCategories: [ID: Category]
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package internal(set) var entryContents: [ID: Content]
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package internal(set) var entrySources: [ID: Source]
}
