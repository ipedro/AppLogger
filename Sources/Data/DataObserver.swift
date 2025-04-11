import Combine
import Models
import SwiftUI

package final class DataObserver: @unchecked Sendable {
    package init(
        allCategories: [LogEntry.Category] = [],
        allEntries: [LogEntry.ID] = [],
        allSources: [LogEntry.Source] = [],
        entryCategories: [LogEntry.ID : LogEntry.Category] = [:],
        entryContents: [LogEntry.ID : LogEntry.Content] = [:],
        entrySources: [LogEntry.ID : LogEntry.Source] = [:],
        entryUserInfos: [LogEntry.ID: LogEntry.UserInfo?] = [:],
        sourceColors: [LogEntry.Source.ID: DynamicColor] = [:]
    ) {
        self.allCategories = CurrentValueSubject(allCategories)
        self.allEntries = CurrentValueSubject(allEntries)
        self.allSources = CurrentValueSubject(allSources)
        self.entryCategories = entryCategories
        self.entryContents = entryContents
        self.entrySources = entrySources
        self.sourceColors = sourceColors
        
        for (id, userInfo) in entryUserInfos {
            guard let (keys, values) = userInfo?.denormalize(id: id) else {
                continue
            }
            entryUserInfoKeys[id] = keys
            for (key, value) in values {
                entryUserInfoValues[key] = value
            }
        }
    }
    
    /// A published array of log entry IDs from the data store.
    package let allEntries: CurrentValueSubject<[LogEntry.ID], Never>
    
    /// An array holding all log entry categories present in the store.
    package internal(set) var allCategories: CurrentValueSubject<[LogEntry.Category], Never>
    
    /// An array holding all log entry sources present in the store.
    package internal(set) var allSources: CurrentValueSubject<[LogEntry.Source], Never>
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package internal(set) var entryCategories: [LogEntry.ID: LogEntry.Category]
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package internal(set) var entryContents: [LogEntry.ID: LogEntry.Content]
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package internal(set) var entrySources: [LogEntry.ID: LogEntry.Source]
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    package internal(set) var entryUserInfoKeys = [LogEntry.ID: [LogEntry.UserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    package internal(set) var entryUserInfoValues = [LogEntry.UserInfoKey: String]()
    
    /// A dictionary mapping log source IDs to their corresponding color.
    package internal(set) var sourceColors = [LogEntry.Source.ID: DynamicColor]()
}
