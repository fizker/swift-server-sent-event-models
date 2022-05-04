import XCTest
import ServerSentEventModels

final class MessageEventTests: XCTestCase {
	func test__init__idSet_lastEventIDSet__bothValuesGetsSetToID() throws {
		let actual = MessageEvent(id: "this ID", lastEventID: "last ID")
		let expected = MessageEvent(id: "this ID", lastEventID: "this ID")

		XCTAssertEqual(actual, expected)
	}

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
			id: "some other ID",
			lastEventID: "some other ID",
			eventType: "some other event",
			retry: 456,
			comments: [
				"some comment",
				"some other comment",
			],
			data: """
			some data
			some more data
			"""
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
			id: "some ID",
			lastEventID: "some ID",
			eventType: "some event",
			retry: 123,
			comments: [
				"some comment",
			],
			data: "some data"
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
			"""
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__idLinePresent_lastEventIDSet__idAndLastIDFieldsSetToID_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			id: "some ID",
			lastEventID: "some ID",
			data: ""
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__idLinePresent_noLastEventID__idAndLastIDFieldsSetToID_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
			.id("some ID"),
		]

		let actual = MessageEvent(lines: lines, lastEventID: nil)
		let expected = MessageEvent(
			id: "some ID",
			lastEventID: "some ID",
			data: ""
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__noLines_lastEventIDSet__lastEventIDSet_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
		]

		let actual = MessageEvent(lines: lines, lastEventID: "last ID")
		let expected = MessageEvent(
			lastEventID: "last ID"
		)

		XCTAssertEqual(actual, expected)
	}

	func test__initWithLines__noLines_noLastEventID__allFieldsNil_dataIsEmptyString() throws {
		let lines: [MessageLine] = [
		]

		let actual = MessageEvent(lines: lines, lastEventID: nil)
		let expected = MessageEvent()

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__dataEmptyString_lastEventIDPresent_idNotPresent__dataIsNotIncluded_idIsNotIncluded() throws {
		let message = MessageEvent(
			lastEventID: "last ID"
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
			"""
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
			id: "this ID",
			lastEventID: "last ID",
			eventType: "event1",
			data: """
			some data
			"""
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
			.id("this ID"),
			.event("event1"),
			.data("some data"),
		]

		XCTAssertEqual(actual, expected)
	}

	func test__asLines__allFieldsSet__returnsExpected() throws {
		let message = MessageEvent(
			id: "this ID",
			lastEventID: "last ID",
			eventType: "event1",
			retry: 123,
			comments: [
				"first comment",
				"second comment",
			],
			data: """
			some data
			on multiple
			lines
			"""
		)

		let actual = message.asLines

		let expected: [MessageLine] = [
			.id("this ID"),
			.event("event1"),
			.retry(123),
			.data("some data"),
			.data("on multiple"),
			.data("lines"),
			.comment("first comment"),
			.comment("second comment"),
		]

		XCTAssertEqual(actual, expected)
	}
}
