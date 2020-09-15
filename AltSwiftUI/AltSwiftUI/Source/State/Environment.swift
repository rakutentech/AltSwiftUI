//
//  Environment.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// References and observes environment values set by the framework.
///
/// Currently supported environment values are:
/// - presentationMode
@propertyWrapper public class Environment<Value>: DynamicProperty {
    let keyPath: KeyPath<EnvironmentValues, Value>
    var _wrappedValue: Value?
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
    
    /// The internal value of this wrapper type.
    public var wrappedValue: Value {
        get {
            assert(_wrappedValue != nil, "Environment being called outside of body")
            //TODO: Register --> EnvironmentHolder.currentBodyViewBinderStack.last?.registerStateNotification(origin: _wrappedValue!)
            return _wrappedValue!
        }
        set {
        }
    }
    
    func update(context: Context) {
        let values = EnvironmentValues(rootController: context.rootController)
        _wrappedValue = values[keyPath: keyPath]
    }
}
