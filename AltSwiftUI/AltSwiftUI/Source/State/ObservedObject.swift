//
//  ObservedObject.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// Used to observe an `ObservableObject` when changes to its
/// `Published` properties occur.
@propertyWrapper
public class ObservedObject<ObjectType: ObservableObject> {
    /// A wrapper of the underlying `ObservableObject` that can create
    /// `Binding`s to its properties using dynamic member lookup.
    @dynamicMemberLookup public struct Wrapper {

        var parent: ObservedObject
        
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
    public var projectedValue: ObservedObject<ObjectType>.Wrapper {
        Wrapper(parent: self)
    }
}
