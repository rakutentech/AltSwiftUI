//
//  Binding.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// A binding is a reference to a value. It does not represent a source
/// of truth, but it acts as a proxy being able to read and modify the
/// original value. Reading it's `wrappedValue` from a view's body will
/// trigger a subscription from the view to changes in the originally referenced
/// value.
@propertyWrapper @dynamicMemberLookup
public struct Binding<Value> {
    private var get: (() -> Value)
    private var set: ((Value) -> Void)
    
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }
    
    /// The value referenced by the binding. Assignments to the value
    /// will be immediately visible on reading (assuming the binding
    /// represents a mutable location), but the view changes they cause
    /// may be processed asynchronously to the assignment.
    public var wrappedValue: Value {
        get {
            get()
        }
        nonmutating set {
            set(newValue)
        }
    }
    
    /// The binding value, as "unwrapped" by accessing `$foo` on a `@Binding` property.
    public var projectedValue: Binding<Value> {
        return self
    }
    
    /// Creates a new `Binding` focused on `Subject` using a key path.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        Binding<Subject>(get: {
            self.wrappedValue[keyPath: keyPath]
        }, set: { value in
            self.wrappedValue[keyPath: keyPath] = value
        })
    }
}
