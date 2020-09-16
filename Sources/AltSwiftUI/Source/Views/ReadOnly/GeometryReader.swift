//
//  GeometryReader.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/21.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A container view that provides its children a
/// `GeometryProxy` value with it's own frame.
///
/// By default this view's dimensions are flexible.
public struct GeometryReader: View {
    public var viewStore = ViewValues()
    var viewContent: (GeometryProxy) -> View
    @State private var geometryProxy: GeometryProxy = .default
    
    public init(@ViewBuilder content: @escaping (GeometryProxy) -> View) {
        viewContent = content
    }
    
    public var body: View {
        ZStack(alignment: .topLeading) {
            viewContent(geometryProxy)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .geometryListener($geometryProxy)
    }
}
