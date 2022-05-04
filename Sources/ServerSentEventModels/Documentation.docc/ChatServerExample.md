# Chat Server Example

A brief example of a chat server.

The server in question is a simple chat-server.

To keep the example on point, it is expected that the infrastructure for the
server is already in place, and that it supports a continous stream to a client
where lines can be easily written.

The server in this example is expected to have a Client object with the following API:

```swift
protocol Client {
	/// Outputs the given line over HTTP.
	func writeLine(_ line: String) async throws
}
```

We extend this for convenience:

```swift
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
```


## Existing messages

The server has a list of messages that have previously been sent. For this example, some messages are already registered:

```swift
var messages: [MessageEvent] = [
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
```


## New client

When the client connects, these are written immediately:

```swift
func onNewClient(_ client: Client) async throws {
	self.client = client

	for message in messages {
		try await client.write(message)
	}
}
```


## Sending new message

Then later on, a new message is sent:

```swift
func sendNewMessage(message: MessageEvent) async throws {
	messages.append(message)
	try await client.write(message)
}
```


## Reconnecting clients

In the real world, a client might lose connection for a number of reasons. In this case, the client can include the last request they received, and only get the messages that appeared since:

```swift
func onReconnectingClient(_ client: Client, lastEventID: String) async throws {
	let requestedMessages = messages.drop(while: { $0.id != lastEventID })
	for message in requestedMessages {
		try await client.write(message)
	}
}
```
