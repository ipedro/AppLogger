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

import struct Models.Category
import struct Models.Content
import struct Models.ID
import struct Models.LogEntry
import struct Models.Source
import struct Models.UserInfo
import struct Models.UserInfoKey

/// An actor that handles asynchronous storage and management of log entries.
/// It indexes log entries by their unique IDs and tracks associated metadata such as categories, sources, and content.
package actor DataStore {
    package init() {}
    
    /// A reactive subject that holds an array of log entry IDs.
    package private(set) var allEntries = Set<ID>()
    
    /// An array holding all log entry categories present in the store.
    package private(set) var allCategories = Set<Category>()
    
    /// An array holding all log entry sources present in the store.
    package private(set) var allSources = Set<Source>()
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package private(set) var entryCategories = [ID: Category]()
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package private(set) var entryContents = [ID: Content]()
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package private(set) var entrySources = [ID: Source]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    package private(set) var entryUserInfoKeys = [ID: [UserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    package private(set) var entryUserInfoValues = [UserInfoKey: String]()
    
    weak private var observer: DataObserver?
    
    package func makeObserver() -> DataObserver {
        let observer = DataObserver()
        self.observer = observer
        defer {
            updateObserver()
        }
        return observer
    }
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    /// - Returns: A Boolean indicating whether the log entry was successfully
    /// added. Returns false if the log entry's ID already exists.
    @discardableResult
    package func addLogEntry(_ logEntry: LogEntry) -> Bool {
        let id = logEntry.id
        
        // O(1) lookup for duplicates.
        guard allEntries.insert(id).inserted else {
            return false
        }
        
        defer {
            updateObserver()
        }
        
        allCategories.insert(logEntry.category)
        allSources.insert(logEntry.source)
        
        entryCategories[id] = logEntry.category
        entryContents[id] = logEntry.content
        entrySources[id] = logEntry.source
        
        if let userInfo = logEntry.userInfo {
            let (keys, values) = userInfo.denormalize(id: id)
            entryUserInfoKeys[id] = keys
            for (key, value) in values {
                entryUserInfoValues[key] = value
            }
        }
        
        return true
    }
    
    private func updateObserver() {
        guard let observer else {
            return
        }
        
        defer {
            // push update to subscribers as last step
            observer.allEntries.send(allEntries.sorted())
            observer.allSources.send(allSources.sorted())
            observer.allCategories.send(allCategories.sorted())
        }
        
        observer.entryCategories = entryCategories
        observer.entryContents = entryContents
        observer.entrySources = entrySources
        observer.entryUserInfoKeys = entryUserInfoKeys
        observer.entryUserInfoValues = entryUserInfoValues
    }
}

extension UserInfo {
    func denormalize(id logID: ID) -> (keys: [UserInfoKey], values: [UserInfoKey: String]) {
        var keys = [UserInfoKey]()
        var values = [UserInfoKey: String]()
        
        for (key, value) in storage {
            let infoID = UserInfoKey(id: logID, key: key)
            keys.append(infoID)
            values[infoID] = value
        }
        
        return (keys, values)
    }
}
