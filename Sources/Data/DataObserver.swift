import Combine
import Models
import SwiftUI

package final class DataObserver: @unchecked Sendable {
    package init(
        allCategories: [LogEntryCategory] = [],
        allEntries: [LogEntryID] = [],
        allSources: [LogEntrySource] = [],
        entryCategories: [LogEntryID : LogEntryCategory] = [:],
        entryContents: [LogEntryID : LogEntryContent] = [:],
        entrySources: [LogEntryID : LogEntrySource] = [:],
        entryUserInfos: [LogEntryID: LogEntryUserInfo?] = [:],
        sourceColors: [LogEntrySource.ID: DynamicColor] = [:],
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
    let allEntries: CurrentValueSubject<[LogEntryID], Never>
    
    /// An array holding all log entry categories present in the store.
    let allCategories: CurrentValueSubject<[LogEntryCategory], Never>
    
    /// An array holding all log entry sources present in the store.
    let allSources: CurrentValueSubject<[LogEntrySource], Never>
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    private(set) var entryCategories: [LogEntryID: LogEntryCategory]
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    private(set) var entryContents: [LogEntryID: LogEntryContent]
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    private(set) var entrySources: [LogEntryID: LogEntrySource]
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    private(set) var entryUserInfoKeys = [LogEntryID: [LogEntryUserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    private(set) var entryUserInfoValues = [LogEntryUserInfoKey: String]()
    
    /// A dictionary mapping log source IDs to their corresponding color.
    private(set) var sourceColors = [LogEntrySource.ID: DynamicColor]()
    
    func updateValues(
        allCategories: [LogEntryCategory],
        allEntries: [LogEntryID],
        allSources: [LogEntrySource],
        entryCategories: [LogEntryID: LogEntryCategory],
        entryContents: [LogEntryID: LogEntryContent],
        entrySources: [LogEntryID: LogEntrySource],
        entryUserInfoKeys: [LogEntryID: [LogEntryUserInfoKey]],
        entryUserInfoValues: [LogEntryUserInfoKey: String],
        sourceColors: [LogEntrySource.ID: DynamicColor]
    ) {
        defer {
            // push update to subscribers as last step
            self.allEntries.send(allEntries)
            self.allSources.send(allSources)
            self.allCategories.send(allCategories)
        }
        
        self.entryCategories = entryCategories
        self.entryContents = entryContents
        self.entrySources = entrySources
        self.entryUserInfoKeys = entryUserInfoKeys
        self.entryUserInfoValues = entryUserInfoValues
        self.sourceColors = sourceColors
    }
}
