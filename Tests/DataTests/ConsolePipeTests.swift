//
//  ConsolePipeTests.swift
//  swiftui-visual-logger
//
//  Created by Pedro Almeida on 05.05.25.
//

@testable import Data
@testable import Models
import Testing

struct ConsolePipeTests {
    let sut = ConsolePipe()!

    @Test("processChunk emits a single output on complete line")
    func testProcessChunkEmitsOnCompleteLine() async {
        let stream = AsyncStream<ConsoleOutput> { continuation in
            Task {
                await sut.processChunk("Hello, world!\n") { output in
                    continuation.yield(output)
                }
                continuation.finish()
            }
        }
        var count = 0
        for await _ in stream {
            count += 1
        }
        #expect(count == 1)
    }

    @Test("processChunk ignores incomplete lines without newline")
    func testProcessChunkIgnoresIncomplete() async {
        let stream = AsyncStream<ConsoleOutput> { continuation in
            Task {
                await sut.processChunk("No newline") {
                    continuation.yield($0)
                }
                continuation.finish()
            }
        }
        var count = 0
        for await _ in stream {
            count += 1
        }
        #expect(count == 0)
    }

    @Test("processChunk trims whitespace and ignores empty payloads")
    func testProcessChunkTrimsAndIgnoresEmpty() async {
        let stream = AsyncStream<ConsoleOutput> { continuation in
            Task {
                await sut.processChunk("   \n") {
                    continuation.yield($0)
                }
                continuation.finish()
            }
        }
        var count = 0
        for await _ in stream {
            count += 1
        }
        #expect(count == 0)
    }
}
