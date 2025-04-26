//
//  ConsolePipe.swift
//  swiftui-visual-logger
//
//  Created by Pedro Almeida on 26.04.25.
//

import Foundation
import Combine

/// Redirects `stdout` and `stderr` into a Combine publisher.
/// The underlying pipes remain open for as long as the instance
/// is retained and are restored automatically on de‑initialisation.
final class ConsolePipe {

    // MARK: - Private storage

    private let inputPipe  = Pipe()
    private let outputPipe = Pipe()

    /// Original file descriptors so we can restore them later.
    private let originalStdout: Int32
    private let originalStderr: Int32

    // MARK: - Public API

    /// Notifications emitted whenever data is written to the console pipe.
    let publisher: AnyPublisher<String, Never>

    /// Creates a new console pipe and begins streaming immediately.
    /// Returns `nil` if any of the low‑level `dup`/`dup2` calls fail.
    init?() {
        // Preserve originals so we can restore them in `deinit`.
        originalStdout = dup(STDOUT_FILENO)
        originalStderr = dup(STDERR_FILENO)

        guard
            originalStdout != -1,
            originalStderr != -1
        else {
            return nil
        }

        // Mirror STDOUT back to the original console so we still see logs in Xcode.
        guard dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor) != -1 else {
            return nil
        }

        #if DEBUG && !targetEnvironment(simulator)
            // Disable buffering in debug so every line appears immediately.
            setvbuf(stdout, nil, _IONBF, 0)
        #endif

        // Redirect STDOUT and STDERR to the input pipe.
        guard
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO) != -1,
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO) != -1
        else {
            return nil
        }

        // Start listening.
        inputPipe.fileHandleForReading.readInBackgroundAndNotify(forModes: [.common])

        publisher = NotificationCenter.default.publisher(
            for: FileHandle.readCompletionNotification,
            object: inputPipe.fileHandleForReading
        )
        .compactMap {
            $0.userInfo?[NSFileHandleNotificationDataItem] as? Data
        }
        .compactMap {
            String(data: $0, encoding: .utf8)
        }
        .eraseToAnyPublisher()
    }

    deinit {
        // Restore the original file descriptors.
        dup2(originalStdout, STDOUT_FILENO)
        dup2(originalStderr, STDERR_FILENO)
        close(originalStdout)
        close(originalStderr)

        // Close our pipe ends.
        inputPipe.fileHandleForReading.closeFile()
        inputPipe.fileHandleForWriting.closeFile()
        outputPipe.fileHandleForWriting.closeFile()
    }
}
