//
//  DataStoreObserver.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import class Combine.PassthroughSubject
import class Combine.AnyCancellable
import protocol SwiftUI.ObservableObject
import struct Models.Category
import struct Models.ID
import struct Models.Source
import struct Models.Content

package final class DataStoreObserver: ObservableObject {
    /// A published array of log entry IDs from the data store.
    package let allEntries = PassthroughSubject<[ID], Never>()
    
    package init(
        allCategories: [Category] = [],
        allSources: [Source] = [],
        entryCategories: [ID : Category] = [:],
        entryContents: [ID : Content] = [:],
        entrySources: [ID : Source] = [:]
    ) {
        self.allCategories = allCategories
        self.allSources = allSources
        self.entryCategories = entryCategories
        self.entryContents = entryContents
        self.entrySources = entrySources
    }
    
    /// An array holding all log entry categories present in the store.
    package internal(set) var allCategories: [Category]
    
    /// An array holding all log entry sources present in the store.
    package internal(set) var allSources: [Source]
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package internal(set) var entryCategories: [ID: Category]
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package internal(set) var entryContents: [ID: Content]
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package internal(set) var entrySources: [ID: Source]
}
