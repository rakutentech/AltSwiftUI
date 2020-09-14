//
//  StateObject.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/25.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// StateObject works similarly as ObservedObject, with the only
/// difference that for being part of a view's state, if the view
/// is recreated while owning an object, the object won't be recreated
/// and will keep it's previous data.
///
/// On view recreation (by a state change in its parent):
/// - ObservedObject owned by view: Gets recreated (re-initialized)
/// - StateObject owned by view: Keeps same instance
@propertyWrapper
public class StateObject<ObjectType: ObservableObject>: ObservedObject<ObjectType> {
    public override var wrappedValue: ObjectType {
        get {
            super.wrappedValue
        }
        set {
            super.wrappedValue = newValue
        }
    }
}

extension StateObject: MigratableProperty {
    var internalValue: Any {
        _wrappedValue
    }
    func setInternalValue(_ value: Any) {
        if let value = value as? ObjectType {
            _wrappedValue = value
        }
    }
}
