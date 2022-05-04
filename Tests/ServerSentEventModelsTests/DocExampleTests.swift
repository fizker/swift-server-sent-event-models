import XCTest
import ServerSentEventModels

extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: UInt64) async throws {
		try await sleep(milliseconds: seconds * 1000)
	}

	static func sleep(milliseconds: UInt64) async throws {
		try await sleep(microseconds: milliseconds * 1000)
	}

	static func sleep(microseconds: UInt64) async throws {
		try await Task.sleep(nanoseconds: microseconds * 1000)
	}
}

/// This test class includes the code shown in the DocC files. It tests that they work as the documentation claims.
final class DocExampleTests: XCTestCase {
	var client: Client!
	var messages: [MessageEvent] = []
	var logs: [String] = []
	var receivedMessages: [MessageEvent] = []
	var chatMessages: [String] = []
	var statuses: [String] = []

	override func setUp() async throws {
		logs = []
		chatMessages = []
		statuses = []
		receivedMessages = []
		messages = [
			.init(
				id: "1",
				eventType: "status",
				data: """
					{
						"room": "Friday Night Movies",
						"participants": [
							{ "id": "a", name: "Alpha" },
							{ "id": "b", name: "Beta" },
							{ "id": "c", name: "Gamma" }
						]
					}
					"""
			),
			.init(
				id: "2",
				eventType: "message",
				data: """
					{
						"from": "a",
						"message": "Hello world"
					}
					"""
			),
			.init(
				id: "3",
				eventType: "message",
				data: """
					{
						"from": "b",
						"message": "Hello Alpha, how are you?"
					}
					"""
			),
		]
	}

	func log(_ msg: String) {
		logs.append(msg)
	}

	func onStatusUpdated(_ value: String) {
		statuses.append(value)
	}

	func onNewChatMessage(_ value: String) {
		chatMessages.append(value)
	}

	func test__onNewClient__clientIsSet_allMessagesAreSent() async throws {
		let testClient = TestClient()
		Task {
			try await handleData(client: testClient)
		}

		try await onNewClient(testClient)

		try await Task.sleep(milliseconds: 1)

		XCTAssertTrue(client as? TestClient === testClient)
		XCTAssertEqual(receivedMessages, messages)
		XCTAssertEqual(statuses, [messages[0].data])
		XCTAssertEqual(chatMessages.count, 2)
		XCTAssertEqual(chatMessages, messages[1...].map(\.data))
	}

	func test__sendNewMessage__newMessageIsSent() async throws {
		let testClient = TestClient()
		client = testClient
		Task {
			try await handleData(client: testClient)
		}

		try await sendNewMessage(message: .init(id: "4", eventType: "message", data: "latest message"))

		try await Task.sleep(milliseconds: 1)

		XCTAssertEqual(chatMessages, [ "latest message" ])
	}

	func test__onReconnectingClient__messagesAfterIDIsSent() async throws {
		let testClient = TestClient()
		Task {
			try await handleData(client: testClient)
		}

		try await onReconnectingClient(testClient, lastEventID: "2")

		try await Task.sleep(milliseconds: 1)

		XCTAssertEqual(chatMessages, [ messages[2].data ])
	}
}

class TestClient: Client, HTTPClient {
	private var continuation: AsyncStream<String>.Continuation!
	private var stream: AsyncStream<String>!

	init() {
		stream = AsyncStream {
			self.continuation = $0
		}
	}

	var newlineSeparatedInput: AsyncStream<String> { stream }

	func writeLine(_ line: String) async throws {
		continuation.yield(line)
	}
}

// MARK: - Server code
extension DocExampleTests {
	func onNewClient(_ client: Client) async throws {
		self.client = client

		for message in messages {
			try await client.write(message)
		}
	}

	func sendNewMessage(message: MessageEvent) async throws {
		messages.append(message)
		try await client.write(message)
	}

	func onReconnectingClient(_ client: Client, lastEventID: String) async throws {
		let requestedMessages = messages.drop(while: { $0.id != lastEventID }).dropFirst()
		for message in requestedMessages {
			try await client.write(message)
		}
	}
}

protocol Client {
	/// Outputs the given line over HTTP.
	func writeLine(_ line: String) async throws
}

extension Client {
	/// Writes a message to the output.
	func write(_ message: MessageEvent) async throws {
		for line in message.asLines {
			try await writeLine(line.asString)
		}

		// An empty line ends the message event.
		try await writeLine("")
	}
}

// MARK: - Client code
extension DocExampleTests {
	func handleData(client: HTTPClient) async throws {
		for await message in client.messages {
			receivedMessages.append(message)
			switch message.eventType {
			case "error":
				log("error: \(message.data)")
			case "status":
				onStatusUpdated(message.data)
			case "message":
				onNewChatMessage(message.data)
			default:
				log("unknown message type: \(message.eventType ?? "")")
			}
		}
	}
}

protocol HTTPClient {
	var newlineSeparatedInput: AsyncStream<String> { get }
}

extension HTTPClient {
	private func parseLines(_ lines: [String], lastID: String?) -> MessageEvent {
		let maybeLines = lines.map(MessageLine.init(string:))
		let parsedLines = maybeLines.compactMap { $0 }
		guard
			// We check that no lines became nil
			maybeLines.count == parsedLines.count,
			let message = MessageEvent(lines: parsedLines, lastEventID: lastID)
		else {
			let errorMessage = MessageEvent(
				lastEventID: lastID,
				eventType: "error",
				data: """
					Maybe include some error data
					that can help diagnose
					or handle the error
					"""
			)
			return errorMessage
		}

		return message
	}

	var messages: AsyncStream<MessageEvent> {
		return AsyncStream { continuation in
			Task {
				var lastID: String?
				var lines: [String] = []
				for await line in newlineSeparatedInput {
					if line.isEmpty {
						let message = parseLines(lines, lastID: lastID)
						lines = []

						if let id = message.id {
							lastID = id
						}

						continuation.yield(message)
					} else {
						lines.append(line)
					}
				}
			}
		}
	}
}
