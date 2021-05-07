//
//  Rectangle.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a Rectangle shape.
public struct Rectangle: Shape {
    public var viewStore = ViewValues()
    
    public var fillColor = Color.clear
    public var strokeBorderColor = Color.clear
    public var style = StrokeStyle()
    
    public var body: View {
        EmptyView()
    }
    
    public init() {}
    
    public func createView(context: Context) -> UIView {
        let view = AltShapeView().noAutoresizingMask()
        view.updateOnLayout = { [weak view] rect in
            guard let view = view else { return }
            updatePath(view: view, path: UIBezierPath(rect: rect), animation: nil)
        }
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        let oldView = view.lastRenderableView?.view as? Rectangle
        
        let width = context.viewValues?.viewDimensions?.width ?? view.bounds.width
        let height = context.viewValues?.viewDimensions?.height ?? view.bounds.height
        let animation = context.transaction?.animation
        view.lastSizeFromViewUpdate = CGSize(width: width, height: height)
        
        if context.viewValues?.viewDimensions != oldView?.viewStore.viewDimensions {
            updatePath(view: view, path: UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height)), animation: animation)
        }
        updateShapeLayerValues(view: view, context: context)
    }
}
