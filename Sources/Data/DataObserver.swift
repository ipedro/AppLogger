//
//  DataObserver.swift
//  AppLogger
//
//  Created by Pedro Almeida on 08.04.25.
//

import class Combine.CurrentValueSubject
import protocol SwiftUI.ObservableObject
import struct Models.Category
import struct Models.Content
import struct Models.ID
import struct Models.Source

package final class DataObserver: ObservableObject, @unchecked Sendable {
    package init() {}
    
    /// A published array of log entry IDs from the data store.
    package let allEntries = CurrentValueSubject<[ID], Never>([])
    
    /// An array holding all log entry categories present in the store.
    package internal(set) var allCategories = CurrentValueSubject<[Category], Never>([])
    
    /// An array holding all log entry sources present in the store.
    package internal(set) var allSources = CurrentValueSubject<[Source], Never>([])
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package internal(set) var entryCategories = [ID: Category]()
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package internal(set) var entryContents = [ID: Content]()
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package internal(set) var entrySources = [ID: Source]()
}
