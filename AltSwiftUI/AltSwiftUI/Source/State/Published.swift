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

@propertyWrapper public class Published<Value>: ChildWrapper {
    public var _wrappedValue: Value
    private weak var parent: AnyObject?
    
    public init(wrappedValue value: Value) {
        _wrappedValue = value
    }
    
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

    public var projectedValue: Published<Value> {
        self
    }
    
    public func setParent(_ parent: AnyObject) {
        self.parent = parent
    }
    
    private func sendStateChangeNotification() {
        if let parent = parent {
            let userInfo = EnvironmentHolder.notificationUserInfo
            NotificationCenter.default.post(name: ViewBinder.StateNotification.name, object: parent, userInfo: userInfo)
        }
    }
}
