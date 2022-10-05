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
