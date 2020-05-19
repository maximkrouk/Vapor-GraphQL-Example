//
//  Builder.swift
//  App
//
//  Created by Maxim Krouk on 5/16/20.
//

public struct Builder<T> {
    private var initial: T
    private var transform: (T) -> T = { $0 }
    
    public init(_ initialize: @escaping () -> T) { self.init(initialize()) }
    
    public init(_ initial: T) { self.initial = initial }
    
    public func setIf<Value>(_ condition: Bool, _ keyPath: WritableKeyPath<T, Value>, _ value: Value) -> Self {
        if condition { return self.set(keyPath, value) }
        else { return self }
    }
    
    public func setIf(_ condition: Bool, _ transform: @escaping (inout T) -> Void) -> Self {
        if condition { return self.set(transform) }
        else { return self }
    }
    
    public func setIf(_ condition: Bool, _ transform: @escaping (T) -> T) -> Self {
        if condition { return self.set(transform) }
        else { return self }
    }
    
    public func set<Value>(_ keyPath: WritableKeyPath<T, Value>, _ value: Value) -> Self {
        self.set(keyPath == value)
    }
    
    public func set(_ transform: @escaping (inout T) -> Void) -> Self {
        modification(of: self) { _self in
            _self.transform = { object in
                modification(of: self.transform(object), transform: transform)
            }
        }
    }
    
    public func set(_ transform: @escaping (T) -> T) -> Self {
        modification(of: self) { _self in
            _self.transform = { object in
                transform(self.transform(object))
            }
        }
    }
    
    public func build() -> T { transform(initial) }
    
}

public func ==<Object, Value>(_ lhs: WritableKeyPath<Object, Value>, _ rhs: Value)
-> (Object) -> Object {
    return { object in
        modification(of: object) { $0[keyPath: lhs] = rhs }
    }
}

public func modification<Object>(
    of object: Object,
    transform: (inout Object) throws -> Void
) rethrows -> Object {
    var object = object
    try transform(&object)
    return object
}
