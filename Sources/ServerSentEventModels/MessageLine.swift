import Foundation

/// A line in the raw stream of events.
public enum MessageLine: Codable, Equatable {
	/// The type of a message.
	case event(String)

	/// A line of data. Multiple lines of data is allowed in a message.
	case data(String)

	/// The ID of the message.
	case id(String)

	/// The number of milliseconds that the reconnection time must be set to.
	case retry(Int)

	/// A comment line. According to spec, comment lines should be ignored by browsers.
	case comment(String)

	/// Unknown key-value pair. This is present to allow lines not currently supported in the spec. The spec says that browsers should ignore unknown lines, so this is safe to include.
	case unknown(String, String)
}

public extension MessageLine {
	/// Creates a Line by parsing the raw input.
	/// - parameter string:A raw input line.
	/// - returns: A ``MessageLine`` of the appropriate type, ``MessageLine/unknown(_:_:)`` if an unknown or invalid key is present or `nil` if the line contains a newline character.
	init?(string: String) {
		guard !string.contains(where: \.isNewline)
		else { return nil }

		let key: String
		let value: String
		if let colon = string.firstIndex(of: ":") {
			key = String(string[..<colon])
			let v = String(string[string.index(after: colon)...])
			value = v.starts(with: " ")
			? String(v[v.index(after: v.startIndex)...])
			: v
		} else {
			key = string
			value = ""
		}

		switch key {
		case "":
			self = .comment(value)
		case "event":
			self = .event(value)
		case "id":
			self = .id(value)
		case "data":
			self = .data(value)
		case "retry":
			guard let val = Int(value)
			else { fallthrough }
			self = .retry(val)
		default:
			self = .unknown(key, value)
		}
	}

	/// Converts the ``MessageLine`` to a raw line.
	var asString: String {
		switch self {
		case let .event(value):
			return "event: \(value)"
		case let .data(value):
			return "data: \(value)"
		case let .id(value):
			return "id: \(value)"
		case let .retry(value):
			return "retry: \(value)"
		case let .comment(value):
			return ": \(value)"
		case let .unknown(key, value):
			return "\(key): \(value)"
		}
	}
}
