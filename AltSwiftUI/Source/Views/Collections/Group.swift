//
//  Group.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// A group is a convenience view that groups multiple views into a single view. This
/// view has no visual representation and does not affect the subviews layouts in
/// any way.
///
/// Use this when the number of elements inside a `ViewBuilder` exceeds the limit.
public struct Group: View, ViewGrouper {
    public var viewStore: ViewValues = ViewValues()
    var viewContent: [View]
    public init(@ViewBuilder content: () -> View) {
        viewContent = content().subViews
    }
    public var body: View {
        viewContent.first ?? EmptyView()
    }
}
