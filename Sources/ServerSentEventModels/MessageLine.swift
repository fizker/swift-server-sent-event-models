import Foundation

public enum MessageLine: Codable, Equatable {
	case event(String)
	case data(String)
	case id(String)
	case retry(Int)
	case comment(String)
	case unknown(String, String)
}

public extension MessageLine {
	init?(string: String) {
		guard !string.contains("\n")
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
