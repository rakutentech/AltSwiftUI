//
//  Circle.swift
//  AltSwiftUI
//
//  Created by Nodehi, Jabbar on 2020/09/08.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a Circle shape.
public struct Circle: Shape {
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
        view.layer.addSublayer(view.caShapeLayer)
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        
        let width = context.viewValues?.viewDimensions?.width ?? .infinity
        let height = context.viewValues?.viewDimensions?.height ?? .infinity
        let minDimensions = min(width, height)
        let x = (width - minDimensions) / 2
        let y = (height - minDimensions) / 2
        let animation = context.transaction?.animation
        let path = UIBezierPath(
            roundedRect: CGRect(x: x, y: y, width: minDimensions, height: minDimensions),
            cornerRadius: minDimensions/2
        ).cgPath
        
        performUpdate(layer: view.caShapeLayer, keyPath: "path", newValue: path, animation: animation)
        updateShapeLayerValues(view: view, context: context)
    }
}
