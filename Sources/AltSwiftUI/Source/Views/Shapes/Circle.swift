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
    var trimStartFraction: CGFloat = 0
    var trimEndFraction: CGFloat = 1
    
    public var body: View {
        EmptyView()
    }
    
    public init() {}
    
    /// Trims the path of the shape by the specified fractions.
    public func trim(from startFraction: CGFloat = 0, to endFraction: CGFloat = 1) -> Self {
        var circle = self
        circle.trimStartFraction = startFraction
        circle.trimEndFraction = endFraction
        return circle
    }
    
    public func createView(context: Context) -> UIView {
        let view = AltShapeView().noAutoresizingMask()
        view.updateOnLayout = { rect in
            updatePath(view: view, path: path(from: rect), animation: nil)
        }
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        let oldView = view.lastRenderableView?.view as? Circle
        
        let width = context.viewValues?.viewDimensions?.width ?? view.bounds.width
        let height = context.viewValues?.viewDimensions?.height ?? view.bounds.height
        let animation = context.transaction?.animation
        view.lastSizeFromViewUpdate = CGSize(width: width, height: height)
        
        if fillColor.rawColor != Color.clear.rawColor {
            updatePath(
                view: view,
                path: path(
                    from: CGRect(x: 0, y: 0, width: width, height: height),
                    startFraction: trimStartFraction,
                    endFraction: trimEndFraction),
                animation: animation)
        } else {
            if context.viewValues?.viewDimensions != oldView?.viewStore.viewDimensions {
                updatePath(view: view, path: path(from: CGRect(x: 0, y: 0, width: width, height: height)), animation: animation)
            }
            performUpdate(layer: view.caShapeLayer, keyPath: "strokeStart", newValue: trimStartFraction, animation: animation, oldValue: oldView?.trimStartFraction)
            performUpdate(layer: view.caShapeLayer, keyPath: "strokeEnd", newValue: trimEndFraction, animation: animation, oldValue: oldView?.trimEndFraction)
        }
        updateShapeLayerValues(view: view, context: context)
    }
    
    private func path(from rect: CGRect, startFraction: CGFloat = 0, endFraction: CGFloat = 1) -> UIBezierPath {
        let minDimensions = min(rect.width, rect.height)
        let x = ((rect.width - minDimensions) / 2) + minDimensions / 2
        let y = ((rect.height - minDimensions) / 2) + minDimensions / 2
        let startAngle = CGFloat(-(Double.pi / 2)) + startFraction * CGFloat(Double.pi * 2)
        let endAngle = CGFloat(-(Double.pi / 2)) + endFraction * CGFloat(Double.pi * 2)
        
        return UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: minDimensions / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
}
