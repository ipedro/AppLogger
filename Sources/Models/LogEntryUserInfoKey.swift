package extension LogEntry {
    struct UserInfoKey: Hashable, Sendable {
        package let entryID: ID
        package let key: String
        
        package init(id: ID, key: String) {
            self.entryID = id
            self.key = key
        }
    }
}
