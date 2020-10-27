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
public class StateObject<ObjectType: ObservableObject> {
    /// A wrapper of the underlying `ObservableObject` that can create
    /// `Binding`s to its properties using dynamic member lookup.
    @dynamicMemberLookup public struct Wrapper {

        var parent: StateObject
        
        /// Creates a `Binding` to a value semantic property of a
        /// reference type.
        ///
        /// If `Value` is not value semantic, the updating behavior for
        /// any views that make use of the resulting `Binding` is
        /// unspecified.
        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, Subject>) -> Binding<Subject> {
            Binding(get: { self.parent.wrappedValue[keyPath: keyPath] },
                    set: { self.parent.wrappedValue[keyPath: keyPath] = $0 })
        }
    }
    
    var _wrappedValue: ObjectType
    
    public init(wrappedValue value: ObjectType) {
        _wrappedValue = value
        value.setupPublishedValues()
    }
    
    /// The internal value of this wrapper type.
    public var wrappedValue: ObjectType {
        get {
            EnvironmentHolder.currentBodyViewBinderStack.last?.registerStateNotification(origin: _wrappedValue)
            return _wrappedValue
        }
        set {
            _wrappedValue = newValue
        }
    }
    
    /// The direct value of this wrapper, as accessing $foo on a @EnvironmentObject property.
    public var projectedValue: StateObject<ObjectType>.Wrapper {
        Wrapper(parent: self)
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
