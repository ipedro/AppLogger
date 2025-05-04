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
