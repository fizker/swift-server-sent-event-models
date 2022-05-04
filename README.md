# ServerSentEventModels

Models representing the data-layer for [Server-sent events](https://html.spec.whatwg.org/multipage/server-sent-events.html).

The models are strongly typed, but have some escape-hatches in case that non-specced data is needed.

[DocC code documentation][docc].

## How to install

1. Add the package to your dependencies in Package.swift: `.package(url: "https://github.com/fizker/swift-server-sent-event-models.git", from: "0.0.1"),`.
2. Add the dependency to all targets that need it: `.product(name: "ServerSentEventModels", package: "swift-server-sent-event-models"),`.
3. Import the module in your code: `import ServerSentEventModels`.

For an example, see the [Package.swift][demo-package-swift] and the [routes.swift][demo-routes-swift] from the [demo project][demo] for an example.


## How to use

For detailed examples on how to use the package, see [the DocC docs][docc].


[docc]: https://fizker.github.io/server-sent-event-models/documentation/serversenteventmodels/
[demo]: https://github.com/fizker/server-sent-events-demo
[demo-package-swift]: https://github.com/fizker/server-sent-events-demo/blob/main/swift-server/Package.swift
[demo-routes-swift]: https://github.com/fizker/server-sent-events-demo/blob/main/swift-server/Sources/EventSourceServer/routes.swift
