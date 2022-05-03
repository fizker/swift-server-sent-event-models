import XCTest
import ServerSentEventModels

final class MessageLineTests: XCTestCase {
	func test__initWithString__validInputs__returnsExpected() throws {
		let tests: [(description: String, input: String, expected: MessageLine)] = [
			("Event without surrounding spaces", "event:some event", .event("some event")),
			("Event with single leading space on value", "event: some event", .event("some event")),
			("Event with trailing space on value", "event: some event ", .event("some event ")),
			("Event with two leading spaces on value", "event:  some event", .event(" some event")),

			("Data without surrounding spaces", "data:some event", .data("some event")),
			("Data with single leading space on value", "data: some event", .data("some event")),
			("Event with trailing space on value", "data: some event ", .data("some event ")),
			("Data with two leading spaces on value", "data:  some event", .data(" some event")),

			("ID without surrounding spaces", "id:some event", .id("some event")),
			("ID with single leading space on value", "id: some event", .id("some event")),
			("Event with trailing space on value", "id: some event ", .id("some event ")),
			("ID with two leading spaces on value", "id:  some event", .id(" some event")),

			("Retry without surrounding spaces", "retry:123", .retry(123)),
			("Retry with single leading space on value", "retry: 123", .retry(123)),

			("Comment without surrounding spaces", ":some event", .comment("some event")),
			("Comment with single leading space on value", ": some event", .comment("some event")),
			("Event with trailing space on value", ": some event ", .comment("some event ")),
			("Comment with two leading spaces on value", ":  some event", .comment(" some event")),
		]

		for (description, input, expected) in tests {
			let actual = MessageLine(string: input)
			XCTAssertEqual(actual, expected, description)
		}
	}

	func test__initWithString__invalidInputs__returnsExpected() throws {
		let tests: [(description: String, input: String, expected: MessageLine?)] = [
			("Event with trailing space on key", "event :some event", .unknown("event ", "some event")),
			("Event with leading space on key", " event:some event", .unknown(" event", "some event")),
			("Data with trailing space on key", "data :some event", .unknown("data ", "some event")),
			("Data with leading space on key", " data:some event", .unknown(" data", "some event")),
			("ID with trailing space on key", "id :some event", .unknown("id ", "some event")),
			("ID with leading space on key", " id:some event", .unknown(" id", "some event")),
			("Retry with decimal number", "retry: 12.3", .unknown("retry", "12.3")),
			("Retry with characters", "retry: some event", .unknown("retry", "some event")),
			("Retry with two leading spaces on value", "retry:  123", .unknown("retry", " 123")),
			("Retry with trailing space on value", "retry: 123 ", .unknown("retry", "123 ")),
			("Comment with space on key", " :some event", .unknown(" ", "some event")),
			("Key with newline", "ke\ny:some event", nil),
			("Value with newline", "key:some\nevent", nil),
			("Line with newline", "some\nevent", nil),
		]

		for (description, input, expected) in tests {
			let actual = MessageLine(string: input)
			XCTAssertEqual(actual, expected, description)
		}
	}

	func test__asString__validTypes__formatsTheLineCorrectly() throws {
		let tests: [(line: MessageLine, expected: String)] = [
			(.event("some event"), "event: some event"),
			(.data("some event"), "data: some event"),
			(.id("some event"), "id: some event"),
			(.retry(123), "retry: 123"),
			(.comment("some event"), ": some event"),
			(.unknown("some key", "some event"), "some key: some event"),
		]

		for (line, expected) in tests {
			XCTAssertEqual(line.asString, expected)
		}
	}
}
