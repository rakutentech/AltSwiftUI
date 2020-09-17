//
//  StateTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

class DynamicPropertyHolder<Value> {
    var value: Value
    init(value: Value) {
        self.value = value
    }
}

/// Represents a stored variable in a `View` type that is dynamically
/// updated from some external property of the view. These variables
/// will be given valid values immediately before `body()` is called.
protocol DynamicProperty {

    /// Called immediately before the view's body() function is
    /// executed, after updating the values of any dynamic properties
    /// stored in `self`.
    func update(context: Context)
}

/// An object that can have it's internal value retrieved and changed
/// externally.
protocol MigratableProperty: AnyObject {
    var internalValue: Any { get }
    func setInternalValue(_ value: Any)
}
