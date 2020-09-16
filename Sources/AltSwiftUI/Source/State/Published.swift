//
//  Published.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

protocol ChildWrapper {
    func setParent(_ parent: AnyObject)
}

/// A type that publishes a property.
///
/// When the wrapped value of a published type changes, views that have
/// accessed to its parent `ObservableObject` through a `@ObservedObject`
/// property, will receive render updates.
///
/// - Important: Published types should be used only in `ObservableObject` classes.
@propertyWrapper public class Published<Value>: ChildWrapper {
    var _wrappedValue: Value
    private weak var parent: AnyObject?
    
    public init(wrappedValue value: Value) {
        _wrappedValue = value
    }
    
    /// The internal value of this wrapper type.
    public var wrappedValue: Value {
        get {
            _wrappedValue
        }
        set {
            if let hashOld = _wrappedValue as? AnyHashable, let hashNew = newValue as? AnyHashable, hashOld == hashNew {
                return
            }
            _wrappedValue = newValue
            sendStateChangeNotification()
        }
    }

    /// The value as accessing $foo on a @Published property.
    public var projectedValue: Published<Value> {
        self
    }
    
    func setParent(_ parent: AnyObject) {
        self.parent = parent
    }
    
    private func sendStateChangeNotification() {
        if let parent = parent {
            let userInfo = EnvironmentHolder.notificationUserInfo
            NotificationCenter.default.post(name: ViewBinder.StateNotification.name, object: parent, userInfo: userInfo)
        }
    }
}
