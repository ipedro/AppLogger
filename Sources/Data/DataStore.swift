import Models

/// An actor that handles asynchronous storage and management of log entries.
/// It indexes log entries by their unique IDs and tracks associated metadata such as categories, sources, and content.
package actor DataStore {
    package init() {}
    
    weak private var observer: DataObserver?
    
    private var sourceColorGenerator = DynamicColorGenerator<LogEntry.Source>()
    
    /// A reactive subject that holds an array of log entry IDs.
    private var allEntries = Set<LogEntry.ID>()
    
    /// An array holding all log entry categories present in the store.
    private var allCategories = Set<LogEntry.Category>()
    
    /// An array holding all log entry sources present in the store.
    private var allSources = Set<LogEntry.Source>()
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    private var entryCategories = [LogEntry.ID: LogEntry.Category]()
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    private var entryContents = [LogEntry.ID: LogEntry.Content]()
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    private var entrySources = [LogEntry.ID: LogEntry.Source]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    private var entryUserInfoKeys = [LogEntry.ID: [LogEntry.UserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    private var entryUserInfoValues = [LogEntry.UserInfoKey: String]()
    
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
        
        sourceColorGenerator.generateColorIfNeeded(for: logEntry.source)
        
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
        observer.sourceColors = sourceColorGenerator.assignedColors
    }
}

extension LogEntry.UserInfo {
    func denormalize(id logID: LogEntry.ID) -> (keys: [LogEntry.UserInfoKey], values: [LogEntry.UserInfoKey: String]) {
        var keys = [LogEntry.UserInfoKey]()
        var values = [LogEntry.UserInfoKey: String]()
        
        for (key, value) in storage {
            let infoID = LogEntry.UserInfoKey(id: logID, key: key)
            keys.append(infoID)
            values[infoID] = value
        }
        
        return (keys, values)
    }
}
