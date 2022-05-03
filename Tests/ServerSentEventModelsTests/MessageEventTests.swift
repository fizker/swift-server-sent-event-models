import XCTest
import ServerSentEventModels

final class MessageEventTests: XCTestCase {
	func test__initWithLines__multipleOfEachLineTypeAvailable__dataIsLineSeparatedFields_otherFieldsSetToLastOfType() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
			.data("some data"),
			.retry(123),
			.event("some event"),
			.comment("some comment"),
			.unknown("some", "unknown"),
			.id("some other ID"),
			.data("some more data"),
			.retry(456),
			.event("some other event"),
			.comment("some other comment"),
			.unknown("some", "more unknown"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			data: """
			some data
			some more data
			""",
			eventType: "some other event",
			lastEventID: "some other ID",
			id: "some other ID"
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__oneOfEachLineTypeAvailable__allFieldsSet() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
			.data("some data"),
			.retry(123),
			.event("some event"),
			.comment("some comment"),
			.unknown("some", "unknown"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			data: "some data",
			eventType: "some event",
			lastEventID: "some ID",
			id: "some ID"
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__multipleDataLines__dataIsLineSeparatedString() throws {
		let lines: [MessageLine] = [
			.data("some data"),
			.data("on multiple"),
			.data("lines"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: nil)
		let expected = MessageEvent(
			data: """
			some data
			on multiple
			lines
			""",
			eventType: nil,
			lastEventID: nil,
			id: nil
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__idLinePresent_lastEventIDSet__idAndLastIDFieldsSetToID_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			data: "",
			eventType: nil,
			lastEventID: "some ID",
			id: "some ID"
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__idLinePresent_noLastEventID__idAndLastIDFieldsSetToID_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: nil)
		let expected = MessageEvent(
			data: "",
			eventType: nil,
			lastEventID: "some ID",
			id: "some ID"
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__noLines_lastEventIDSet__lastEventIDSet_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			data: "",
			eventType: nil,
			lastEventID: "last ID",
			id: nil
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__noLines_noLastEventID__allFieldsNil_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
		]

		let actual = MessageEvent(lines: lines, lastEventID: nil)
		let expected = MessageEvent(
			data: "",
			eventType: nil,
			lastEventID: nil,
			id: nil
		)

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__dataEmptyString_lastEventIDPresent_idNotPresent__dataIsNotIncluded_idIsNotIncluded() throws {
		let message = MessageEvent(
			data: "",
			eventType: nil,
			lastEventID: "last ID",
			id: nil
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
		]

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__multipleLinesOfData_otherValuesNil__returnsExpected() throws {
		let message = MessageEvent(
			data: """
			some data
			on multiple
			lines
			""",
			eventType: nil,
			lastEventID: nil,
			id: nil
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
			.data("some data"),
			.data("on multiple"),
			.data("lines"),
		]

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__singleLineOfData_eventTypeSet_lastEventIDPresent_idPresent__returnsExpected() throws {
		let message = MessageEvent(
			data: """
			some data
			""",
			eventType: "event1",
			lastEventID: "last ID",
			id: "this ID"
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
			.data("some data"),
			.id("this ID"),
			.event("event1"),
		]

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__multipleLinesOfData_eventTypeSet_lastEventIDPresent_idPresent__returnsExpected() throws {
		let message = MessageEvent(
			data: """
			some data
			on multiple
			lines
			""",
			eventType: "event1",
			lastEventID: "last ID",
			id: "this ID"
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
			.data("some data"),
			.data("on multiple"),
			.data("lines"),
			.id("this ID"),
			.event("event1"),
		]

		XCTAssertEqual(actual, expected)
	}
}
