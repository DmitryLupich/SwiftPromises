# SwiftPromise

## A simple library with an implementation of the Promises concept

### Example:
```swift
let session = URLSession.shared

// Create Promise with some async work
let promise: Promise<String> = .init { promise in
    session.dataTask(with: .init(url: .init(string: "google.com")!))
    { _, _, _ in
        promise("Some_Data")
    }.resume()
}

// Chain another async work
promise.flatMap { data in
    Promise { promise in
        session.dataTask(with: .init(url: .init(string: "google.com")!))
        { _, _, _ in
            promise("Another_Data")
        }.resume()
    }
}
// Do some transformations
.compactMap(Int.init, or: 10_000)
.map { $0 / 2 }
// ..and finally subscribe to get the result on specific queue
.subscribe(on: .main) { intValue in
    print("Result:", intValue)
}
```
