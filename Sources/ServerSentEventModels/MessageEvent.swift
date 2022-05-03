public struct MessageEvent: Codable, Equatable {
	public var data: String
	public var eventType: String?
	public var lastEventID: String?
	public var id: String?
	public var retry: Int?
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
