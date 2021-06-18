//
//  Path.swift
//  AltSwiftUI
//
//  Created by Nodehi, Jabbar on 2021/06/03.
//

import UIKit

/// A view that represents a Path shape.
public struct Path: Shape {
    public var viewStore = ViewValues()
    
    public var fillColor = Color.clear
    public var strokeBorderColor = Color.clear
    public var style = StrokeStyle()
    var trimStartFraction: CGFloat = 0
    var trimEndFraction: CGFloat = 1
    
    var myPath = CGMutablePath()
    
    public var body: View {
        EmptyView()
    }
    
    public init() {}
    
    public init(_ callback: @escaping (inout Path) -> Void) {
        callback(&self)
    }
    
    public func trim(from startFraction: CGFloat = 0, to endFraction: CGFloat = 1) -> Self {
        var path = self
        path.trimStartFraction = startFraction
        path.trimEndFraction = endFraction
        return path
    }
        
    public func createView(context: Context) -> UIView {
        let view = AltShapeView().noAutoresizingMask()
        view.overrideIntrinsicContentSize = true
        view.updateOnLayout = { [weak view] rect in
            guard let view = view else { return }
            updatePath(view: view, path: UIBezierPath(cgPath: myPath), animation: nil)
        }
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        let oldView = view.lastRenderableView?.view as? Path
        
        let width = context.viewValues?.viewDimensions?.width ?? view.bounds.width
        let height = context.viewValues?.viewDimensions?.height ?? view.bounds.height
        view.pathBoundingBox = myPath.boundingBox
        view.setNeedsLayout()
        let animation = context.transaction?.animation
        view.lastSizeFromViewUpdate = CGSize(width: width, height: height)
        
        if fillColor.rawColor != Color.clear.rawColor {
            updatePath(
                view: view,
                path: UIBezierPath(cgPath: myPath),
                animation: animation)
        } else {
            if context.viewValues?.viewDimensions != oldView?.viewStore.viewDimensions {
                updatePath(view: view, path: UIBezierPath(cgPath: myPath), animation: animation)
            }
            performUpdate(layer: view.caShapeLayer, keyPath: "strokeStart", newValue: trimStartFraction, animation: animation, oldValue: oldView?.trimStartFraction)
            performUpdate(layer: view.caShapeLayer, keyPath: "strokeEnd", newValue: trimEndFraction, animation: animation, oldValue: oldView?.trimEndFraction)
        }
        updateShapeLayerValues(view: view, context: context)
    }
}

extension Path {
    
    public func addRoundedRect(
        in rect: CGRect,
        cornerWidth: CGFloat,
        cornerHeight: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        myPath.addRoundedRect(in: rect, cornerWidth: cornerWidth, cornerHeight: cornerHeight, transform: transform)
    }
    
    public func move(to p: CGPoint) {
        myPath.move(to: p)
    }
    public func addLine(to p: CGPoint) {
        myPath.addLine(to: p)
    }
    
    public func addQuadCurve(to end: CGPoint, control: CGPoint, transform: CGAffineTransform = .identity) {
        myPath.addQuadCurve(to: end, control: control, transform: transform)
    }

    public func addCurve(to end: CGPoint, control1: CGPoint, control2: CGPoint, transform: CGAffineTransform = .identity) {
        myPath.addCurve(to: end, control1: control1, control2: control2, transform: transform)
    }

    public func addRect(_ rect: CGRect, transform: CGAffineTransform = .identity) {
        myPath.addRect(rect, transform: transform)
    }

    public func addRects(_ rects: [CGRect], transform: CGAffineTransform = .identity) {
        myPath.addRects(rects, transform: transform)
    }

    public func addLines(between points: [CGPoint], transform: CGAffineTransform = .identity) {
        myPath.addLines(between: points, transform: transform)
    }

    public func addEllipse(in rect: CGRect, transform: CGAffineTransform = .identity) {
        myPath.addEllipse(in: rect, transform: transform)
    }

    public func addRelativeArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        delta: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        myPath.addRelativeArc(center: center, radius: radius, startAngle: startAngle, delta: delta, transform: transform)
    }

    public func addArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        clockwise: Bool,
        transform: CGAffineTransform = .identity
    ) {
        myPath.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise, transform: transform)
    }

    public func addArc(
        tangent1End: CGPoint,
        tangent2End: CGPoint,
        radius: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        myPath.addArc(tangent1End: tangent1End, tangent2End: tangent2End, radius: radius, transform: transform)
    }

    public func addPath(_ path: CGPath, transform: CGAffineTransform = .identity) {
        myPath.addPath(path, transform: transform)
    }
    
}
