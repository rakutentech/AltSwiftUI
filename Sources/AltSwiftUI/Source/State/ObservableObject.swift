//
//  ObservableObject.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// An object that can be observed. Use this in conjunction with
/// `Published` property wrappers inside the object and
/// `ObservedObject` property wrappers for observing the object from a view.
public protocol ObservableObject: AnyObject {
}

extension ObservableObject {
    func setupPublishedValues() {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let childWrapper = child.value as? ChildWrapper {
                childWrapper.setParent(self)
            }
        }
    }
}
