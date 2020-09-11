//
//  Divider.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that creates a line divider for dividing content.
///
/// When used inside a `VStack`, the divider will display a
/// horizontal line.
///
/// When used inside a `HStack`, the divider will display a
/// vertical line.
///
/// Otherwise, the divider will always display a horizontal line.
public struct Divider : View {
    public var viewStore: ViewValues = ViewValues()
    public var body: View {
        return self
    }
    public init() {}
}

extension Divider: Renderable {
    public func createView(context: Context) -> UIView {
        let expandDirection: Direction = (context.viewValues?.direction ?? .horizontal) == .horizontal ? .vertical : .horizontal
        let view = SwiftUIExpandView(direction: expandDirection, ignoreTouch: true).noAutoresizingMask()
        view.backgroundColor = .lightGray
        if expandDirection == .horizontal {
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        } else {
            view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        }
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        
    }
}
