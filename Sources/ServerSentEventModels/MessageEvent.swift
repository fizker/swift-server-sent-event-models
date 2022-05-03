import Foundation

/// A MessageEvent representing multiple ``MessageLine``.
///
/// An event consists of mulplie lines. A message must contain at least one line, but all line types are optional.
///
/// A message supports multiple ``MessageLine/data(_:)`` lines. For all other types, only the last instance should be respected.
///
/// It parses the list of line according to the rules listed in
/// https://html.spec.whatwg.org/multipage/server-sent-events.html#event-stream-interpretation.
public struct MessageEvent: Codable, Equatable {
	/// The data that the message contains.
	public var data: String
	/// The type of message.
	public var eventType: String?
	/// The last received ID.
	public var lastEventID: String?
	/// The ID of the message.
	public var id: String?
	/// A number of milliseconds that the reconnection time should be set to.
	public var retry: Int?
	/// A number of comments that was included in the message.
	public var comments: [String] = []

	public init(
		data: String = "",
		eventType: String? = nil,
		lastEventID: String? = nil,
		id: String? = nil,
		retry: Int? = nil,
		comments: [String] = []
	) {
		self.data = data
		self.eventType = eventType
		self.lastEventID = id ?? lastEventID
		self.id = id
		self.retry = retry
		self.comments = comments
	}
}

public extension MessageEvent {
	/// Creates a new MessageEvent from a list of ``MessageLine``. If there is an ID line, ``lastEventID`` will be set to that result, even if it was given as a parameter.
	init?(lines: [MessageLine], lastEventID: String?) {
		var data: [String] = []
		for line in lines {
			switch line {
			case let .event(value):
				eventType = value
			case let .data(value):
				data.append(value)
			case let .id(value):
				id = value
			case let .comment(value):
				comments.append(value)
			case let .retry(value):
				retry = value
			case .unknown(_, _):
				break
			}
		}

		self.data = data.joined(separator: "\n")
		self.lastEventID = id ?? lastEventID
	}

	/// Converts the MessageEvent to a list of ``MessageLine``.
	/// The order of the lines is deterministic. If more control is required, it is necessary to create the list manually.
	var asLines: [MessageLine] {
		var lines: [MessageLine] = []

		if !data.isEmpty {
			lines.append(contentsOf: data.components(separatedBy: .newlines).map { .data($0) })
		}

		if let id = id {
			lines.append(.id(id))
		}
		if let eventType = eventType {
			lines.append(.event(eventType))
		}
		if let retry = retry {
			lines.append(.retry(retry))
		}
		lines.append(contentsOf: comments.map(MessageLine.comment))

		return lines
	}
}
