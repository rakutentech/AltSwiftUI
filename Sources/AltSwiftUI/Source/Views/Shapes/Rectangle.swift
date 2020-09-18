//
//  Rectangle.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a Rectangle shape.
public struct Rectangle: shape {
    public var viewStore: ViewValues = ViewValues()
    
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
        updateView(view, context: context)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        let width = context.viewValues?.viewDimensions?.width ?? .infinity
        let height = context.viewValues?.viewDimensions?.height ?? .infinity
        
        if let view = view as? AltShapeView {
            view.caShapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: height)).cgPath
            view.caShapeLayer.strokeColor = strokeBorderColor.color.cgColor
            view.caShapeLayer.fillColor =  fillColor.color.cgColor
            view.caShapeLayer.lineWidth = style.lineWidth
            view.caShapeLayer.lineCap = lineCap(fromCGLineCap: style.lineCap)
            view.caShapeLayer.lineJoin = lineJoin(fromCGLineCap: style.lineJoin)
            view.caShapeLayer.miterLimit = style.miterLimit
            view.caShapeLayer.lineDashPattern = style.dash.map {NSNumber(value: Float($0))}
            view.caShapeLayer.lineDashPhase = style.dashPhase
        }
    }
}
