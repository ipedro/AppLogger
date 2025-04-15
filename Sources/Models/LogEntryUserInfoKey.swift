/// A composite key for identifying specific pieces of user info within a log entry.
///
/// This type combines a log entry's ID with a specific key string to create
/// a unique identifier for each piece of metadata.
package struct LogEntryUserInfoKey: Hashable, Sendable {
    package let entryID: LogEntryID
    package let key: String

    package init(id: LogEntryID, key: String) {
        entryID = id
        self.key = key
    }
}
