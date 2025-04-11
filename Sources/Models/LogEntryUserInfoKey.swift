package struct LogEntryUserInfoKey: Hashable, Sendable {
    package let entryID: LogEntryID
    package let key: String
    
    package init(id: LogEntryID, key: String) {
        self.entryID = id
        self.key = key
    }
}
