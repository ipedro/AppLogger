// MIT License
// 
// Copyright (c) 2025 Pedro Almeida
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Models

/// An actor that handles asynchronous storage and management of log entries.
/// It indexes log entries by their unique IDs and tracks associated metadata such as categories, sources, and content.
package actor DataStore {
    package init() {}

    private weak var observer: DataObserver?

    private var sourceColorGenerator = DynamicColorGenerator<LogEntrySource>()

    /// An array holding all custom actions.
    private var customActions = Set<VisualLoggerAction>()

    /// An array holding all log entry IDs.
    private var allEntries = Set<LogEntryID>()

    /// An array holding all log entry categories present in the store.
    private var allCategories = Set<LogEntryCategory>()

    /// An array holding all log entry sources present in the store.
    private var allSources = Set<LogEntrySource>()

    /// A dictionary mapping log entry IDs to their corresponding category.
    private var entryCategories = [LogEntryID: LogEntryCategory]()

    /// A dictionary mapping log entry IDs to their corresponding content.
    private var entryContents = [LogEntryID: LogEntryContent]()

    /// A dictionary mapping log entry IDs to their corresponding source.
    private var entrySources = [LogEntryID: LogEntrySource]()

    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    private var entryUserInfoKeys = [LogEntryID: [LogEntryUserInfoKey]]()

    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    private var entryUserInfoValues = [LogEntryUserInfoKey: String]()

    package func makeObserver() -> DataObserver {
        let observer = DataObserver()
        self.observer = observer
        defer {
            updateObserver()
        }
        return observer
    }

    package func addAction(_ action: VisualLoggerAction) {
        customActions.insert(action)
        updateObserver()
    }

    package func removeAction(_ action: VisualLoggerAction) {
        customActions.remove(action)
        updateObserver()
    }

    private lazy var clearLogsAction = VisualLoggerAction(
        id: "\(VisualLoggerAction.internalNamespace).clear_logs",
        title: "Clear logs",
        role: .destructive,
        systemImage: "trash"
    ) { [unowned self] _ in
        Task {
            await clearLogs()
        }
    }

    private func clearLogs() {
        defer {
            updateObserver()
        }
        allCategories.removeAll()
        allEntries.removeAll()
        allSources.removeAll()
        customActions.remove(clearLogsAction)
        entryCategories.removeAll()
        entryContents.removeAll()
        entrySources.removeAll()
        entryUserInfoKeys.removeAll()
        entryUserInfoValues.removeAll()
    }

    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    package func addLogEntry(_ logEntry: LogEntry) {
        let id = logEntry.id

        // O(1) lookup for duplicates.
        guard allEntries.insert(id).inserted else {
            return
        }

        customActions.insert(clearLogsAction)

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
    }

    private func updateObserver() {
        guard let observer else {
            return
        }

        observer.updateValues(
            allCategories: allCategories.sorted(),
            allEntries: allEntries.sorted(),
            allSources: allSources.sorted(),
            customActions: customActions.sorted(),
            entryCategories: entryCategories,
            entryContents: entryContents,
            entrySources: entrySources,
            entryUserInfoKeys: entryUserInfoKeys,
            entryUserInfoValues: entryUserInfoValues,
            sourceColors: sourceColorGenerator.assignedColors
        )
    }
}

extension LogEntryUserInfo {
    func denormalize(id logID: LogEntryID) -> (keys: [LogEntryUserInfoKey], values: [LogEntryUserInfoKey: String]) {
        var keys = [LogEntryUserInfoKey]()
        var values = [LogEntryUserInfoKey: String]()

        for (key, value) in storage {
            let infoID = LogEntryUserInfoKey(id: logID, key: key)
            keys.append(infoID)
            values[infoID] = value
        }

        return (keys, values)
    }
}
