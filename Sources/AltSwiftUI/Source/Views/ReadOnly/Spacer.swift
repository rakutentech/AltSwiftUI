//
//  Spacer.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that expands infinitely as much as it is allowed by
/// its parent view. Spacers should only be used inside `HStack` or
/// `VStack`, otherwise it's behavior will be undefined.
///
/// When inside a `HStack`, the spacer will expand horizontally.
///
/// When inside a `VStack`, the spacer will expand vertically.
public struct Spacer: View {
    public var viewStore: ViewValues = ViewValues()
    
    public var body: View {
        self
    }
    
    public init() {}
}

extension Spacer: Renderable {
    public func createView(context: Context) -> UIView {
        if let direction = context.viewValues?.direction {
            return SwiftUIExpandView(direction: direction, ignoreTouch: true)
        } else {
            return UIView()
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        
    }
}
