//
//  Functions.swift
//  
//
//  Created by Dmitriy Lupych on 04.10.2022.
//

import Foundation

//MARK: - Subscribe

public extension Promise {
    /// Subscribe and receive values from upstream on selected queue
    func subscribe(on queue: DispatchQueue? = nil, _ subscriber: @escaping (T) -> Void) {
        let s: (T) -> Void = queue.map { queue in
            { t in
                queue.async {
                    subscriber(t)
                }
            }
        } ?? subscriber
        promise(s)
    }
}

//MARK: - Map

public extension Promise {
    /// Converts value using transform function, just like other familiar map functions
    func map<U>(_ transform: @escaping (T) -> U) -> Promise<U> {
        .init { promise in
            self.subscribe { value in
                promise(transform(value))
            }
        }
    }
}

//MARK: - FlatMap

public extension Promise {
    /// Flattens nested "promise in promise" type to single promise
    func flatMap<U>(_ transform: @escaping (T) -> Promise<U>) -> Promise<U> {
        .init { promise in
            self.subscribe { value in
                transform(value)
                    .subscribe { uValue in
                        promise(uValue)
                }
            }
        }
    }
}

//MARK: - CompactMap

public extension Promise {
    /// Transforms and filters nil values
    func compactMap<U>(_ transform: @escaping (T) -> U?) -> Promise<U> {
        .init { promise in
            self.subscribe { value in
                transform(value).map(promise)
            }
        }
    }

    /// Transforms and substitutes nil value with predefined value
    func compactMap<U>(_ transform: @escaping (T) -> U?, or someValue: U) ->
    Promise<U> {
        .init { promise in
            self.subscribe { value in
                promise(transform(value) ?? someValue)
            }
        }
    }
}

//MARK: - Combine

public extension Promise {
    /// Combines promise with another promise and returns new one with tuple value
    func combine<U>(with promise: Promise<U>) -> Promise<(T, U)> {
        let group = DispatchGroup()
        var tValue: T!
        var uValue: U!

        group.enter()

        subscribe { value in
            tValue = value
            group.leave()
        }

        group.enter()

        promise.subscribe { value in
            uValue = value
            group.leave()
        }

        return .init { promise in
            group.notify(queue: .main) {
                promise((tValue, uValue)) }
        }
    }
}
