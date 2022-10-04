//
//  File.swift
//  
//
//  Created by Dmitriy Lupych on 04.10.2022.
//

public final class Promise<T> {
    public typealias Action = (@escaping (T) -> Void) -> Void
    internal let promise: Action

    public init(_ promise: @escaping Action) {
        self.promise = promise
    }

    public init(_ value: T) {
        self.promise = { p in
            p(value)
        }
    }
}
