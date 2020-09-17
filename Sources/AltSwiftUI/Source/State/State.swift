//
//  State.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import Foundation

class StateValueHolder<Value> {
    var value: Value
    init(value: Value) {
        self.value = value
    }
}

/// Represents a mutable value to be held by a `View`. Reading a state's
/// `wrappedValue` property inside a view's `body` computed property will
/// trigger a subscribption by the view to listen to changes in the state's value.
///
/// - Important: You shouldn't modify a state's wrapped value when the view's
/// `body` property is being read.
@propertyWrapper
public class State<Value> {
    var _wrappedValue: StateValueHolder<Value>
    
    public init(wrappedValue value: Value) {
        _wrappedValue = StateValueHolder(value: value)
    }
    
    /// The internal value of this wrapper type.
    public var wrappedValue: Value {
        get {
            EnvironmentHolder.currentBodyViewBinderStack.last?.registerStateNotification(origin: _wrappedValue)
            return _wrappedValue.value
        }
        set {
            if let hashOld = _wrappedValue.value as? AnyHashable, let hashNew = newValue as? AnyHashable, hashOld == hashNew {
                return
            }
            _wrappedValue.value = newValue
            sendStateChangeNotification()
        }
    }
    
    /// The direct value of this wrapper, as accessing $foo on a @State property.
    public var projectedValue: Binding<Value> {
        Binding<Value>(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    private func sendStateChangeNotification() {
        let userInfo = EnvironmentHolder.notificationUserInfo
        NotificationCenter.default.post(name: ViewBinder.StateNotification.name, object: _wrappedValue, userInfo: userInfo)
    }
}

extension State: MigratableProperty {
    var internalValue: Any {
        _wrappedValue
    }
    func setInternalValue(_ value: Any) {
        if let value = value as? StateValueHolder<Value> {
            _wrappedValue = value
        }
    }
}
