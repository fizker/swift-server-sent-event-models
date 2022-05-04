# Chat Client Example

A brief example of a chat client.


## Setup

For the sake of this example, imagine a HTTP client that provides an easy way to stream data from the server and return that data as lines. This can be encapsulated as an `AsyncStream` that collects the incoming data and yields every time a newline is detected:

```swift
protocol HTTPClient {
	var newlineSeparatedInput: AsyncStream<String> { get }
}
```


## Parsing raw data

This can easily be extended into ``MessageEvent``s by collecting all the lines until an empty line is detected:

```swift
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
```


## Handle incoming messages

Now that we have an easy way to get incoming messages, we can consume this and emit events to the UI:

```swift
func handleData(client: HTTPClient) async throws {
	for await message in client.messages {
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
```
