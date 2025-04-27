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
package final class ConsolePipe {

    // MARK: - Private storage

    private lazy var inputPipe  = Pipe()
    private lazy var outputPipe = Pipe()

    /// Original file descriptors so we can restore them on teardown.
    private let originalStdout: Int32
    private let originalStderr: Int32

    // MARK: - Public API

    /// Creates a new console pipe and begins streaming immediately.
    package init?() {
        originalStdout = dup(STDOUT_FILENO)
        originalStderr = dup(STDERR_FILENO)

        guard originalStdout != -1, originalStderr != -1 else {
            return nil
        }
    }

    enum Error: Swift.Error {
        case failedToCaptureConsoleOutput
    }

    package func callAsFunction(handler: @escaping @Sendable (String) -> Void) throws {
#if !targetEnvironment(simulator)
        setvbuf(stdout, nil, _IONBF, 0)
#endif

        //from documentation
        //dup2() makes newfd (new file descriptor) be the copy of oldfd (old file descriptor), closing newfd first if necessary.

        //here we are copying the STDOUT file descriptor into our output pipe's file descriptor
        //this is so we can write the strings back to STDOUT, so it can show up on the xcode console
        guard
            dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor) != -1
        else {
            throw Error.failedToCaptureConsoleOutput
        }

        //In this case, the newFileDescriptor is the pipe's file descriptor and the old file descriptor is STDOUT_FILENO and STDERR_FILENO
        guard
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO) != -1,
            dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO) != -1
        else {
            throw Error.failedToCaptureConsoleOutput
        }

        inputPipe.fileHandleForReading.readabilityHandler = { [weak outputPipe] pipeReadHandle in
            do {
                let data = pipeReadHandle.availableData

                guard let str = String(data: data, encoding: .ascii) else {
                    return
                }

                if !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    handler(str)
                }

                //write the data back into the output pipe. the output pipe's write file descriptor points to STDOUT. this allows the logs to show up on the xcode console
                outputPipe?.fileHandleForWriting.write(data)
            }
        }

        print("Registered console logging pipe.")
    }

    deinit {
        // 1. Stop asynchronous callbacks.
        inputPipe.fileHandleForReading.readabilityHandler = nil

        // 2. Restore the original stdio so future sessions start clean.
        dup2(originalStdout, STDOUT_FILENO)
        dup2(originalStderr, STDERR_FILENO)
        close(originalStdout)
        close(originalStderr)

        // 3. Close our pipe ends.
        inputPipe.fileHandleForReading.closeFile()
        inputPipe.fileHandleForWriting.closeFile()
        outputPipe.fileHandleForWriting.closeFile()
    }
}
