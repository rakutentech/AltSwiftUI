//
//  EnvironmentObject.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// Used to reference and observe environment objects previously set. Environment
/// objects are identified by their __type__, meaning only one of the same type can
/// exist at a time as an environment object.
///
/// - Important: Referencing an environment object not previously set
/// will trigger an exception.
@propertyWrapper public class EnvironmentObject<ObjectType>: DynamicProperty where ObjectType : ObservableObject {
    /// A wrapper of the underlying `ObservableObject` that can create
    /// `Binding`s to its properties using dynamic member lookup.
    @dynamicMemberLookup public struct Wrapper {

       var parent: EnvironmentObject
       
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

    var _wrappedValue: ObjectType? = nil
    
    public init() {
    }
    
    /// The internal value of this wrapper type.
    public var wrappedValue: ObjectType {
        get {
            assert(_wrappedValue != nil, "EnvironmentObject being called outside of body")
            EnvironmentHolder.currentBodyViewBinderStack.last?.registerStateNotification(origin: _wrappedValue!)
            return _wrappedValue!
        }
        set {
        }
    }
    
    /// The direct value of this wrapper, as accessing $foo on a @EnvironmentObject property.
    public var projectedValue: EnvironmentObject<ObjectType>.Wrapper {
        Wrapper(parent: self)
    }
    
    func update(context: Context) {
        if _wrappedValue != nil {
            return
        }
        
        if let envObject = EnvironmentHolder.environmentObjects[String(describing: ObjectType.self)] as? ObjectType {
            _wrappedValue = envObject
            _wrappedValue?.setupPublishedValues()
        } else {
            assertionFailure("Environment object of type \(ObjectType.self) should be set")
        }
    }
}
