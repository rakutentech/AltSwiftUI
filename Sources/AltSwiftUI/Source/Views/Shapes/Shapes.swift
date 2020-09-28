//
//  Shapes.swift
//  AltSwiftUI
//
//  Created by Nodehi, Jabbar on 2020/09/10.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class AltShapeView: UIView {
    public var caShapeLayer = CAShapeLayer()
}

public protocol Shape: View, Renderable {
    var fillColor: Color { get set }
    var strokeBorderColor: Color { get set }
    var style: StrokeStyle { get set }
}

extension Shape {
    
    /// Fills this shape with a color.
    ///
    /// - Parameters:
    ///   - color: The color to use when filling this shape.
    /// - Returns: A shape filled with the color you supply.
    public func fill(_ color: Color) -> Self {
        var view = self
        view.fillColor = color
        return view
    }
    
    /// Returns a view that is the result of filling the `width`-sized
    /// border (aka inner stroke) of `self` with `content`. This is
    /// equivalent to insetting `self` by `width / 2` and stroking the
    /// resulting shape with `width` as the line-width.
    public func strokeBorder(_ color: Color, lineWidth: CGFloat = 1) -> Self {
        var view = self
        view.strokeBorderColor = color
        view.style.lineWidth = lineWidth
        return view
    }
    
    /// Returns a view that is the result of insetting `self` by
    /// `style.lineWidth / 2`, stroking the resulting shape with
    /// `style`, and then filling with `content`.
    public func stroke(_ color: Color, style: StrokeStyle) -> Self {
        var view = self
        view.strokeBorderColor = color
        view.style = style
        return view
    }
    
    // MARK: Internal methods
    
    /// Updates all generic shape layer values, except
    /// by unique properties like path.
    func updateShapeLayerValues(view: AltShapeView, context: Context) {
        let layer = view.caShapeLayer
        let animation = context.transaction?.animation
        
        performUpdate(layer: layer, keyPath: "strokeColor", newValue: strokeBorderColor.color.cgColor, animation: animation)
        performUpdate(layer: layer, keyPath: "fillColor", newValue: fillColor.color.cgColor, animation: animation)
        performUpdate(layer: layer, keyPath: "lineWidth", newValue: style.lineWidth, animation: animation)
        performUpdate(layer: layer, keyPath: "lineCap", newValue: lineCap(fromCGLineCap: style.lineCap), animation: animation)
        performUpdate(layer: layer, keyPath: "lineJoin", newValue: lineJoin(fromCGLineCap: style.lineJoin), animation: animation)
        performUpdate(layer: layer, keyPath: "miterLimit", newValue: style.miterLimit, animation: animation)
        performUpdate(layer: layer, keyPath: "lineDashPattern", newValue: style.dash.map { NSNumber(value: Float($0)) }, animation: animation)
        performUpdate(layer: layer, keyPath: "lineDashPhase", newValue: style.dashPhase, animation: animation)
    }
    
    /// Performs an update to a layer property with animation, if any. If
    /// animation is `nil`, the update is executed normally.
    func performUpdate(layer: CALayer, keyPath: String, newValue: Any?, animation: Animation?) {
        if let animation = animation {
            animation.performCALayerAnimation(layer: layer, keyPath: keyPath, newValue: newValue)
        } else {
            layer.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    /// Performs an update to a layer property with animation, if any. If
    /// animation is `nil`, the update is executed normally.
    func performUpdate(animation: Animation?, animationCode: @escaping () -> Void) {
        if let animation = animation {
            animation.performAnimation(animationCode)
        } else {
            animationCode()
        }
    }
    
    func lineCap(fromCGLineCap value: CGLineCap) -> CAShapeLayerLineCap {
        switch value {
        case .butt:
            return .butt
        case .round:
            return .round
        case .square:
            return .square
        default:
            return .round
        }
    }
    
    func lineJoin(fromCGLineCap value: CGLineJoin) -> CAShapeLayerLineJoin {
        switch value {
        case .bevel:
            return .bevel
        case .miter:
            return .miter
        case .round:
            return .round
        default:
            return .miter
        }
    }
}

/// Type that hold style properties of a stroke.
public struct StrokeStyle : Equatable {

    /// The width of the stroke's line
    public var lineWidth: CGFloat
    
    /// The cap style of the stroke's line extremes
    public var lineCap: CGLineCap
    
    /// The way lines join in the stroke
    public var lineJoin: CGLineJoin
    
    /// If the line join style is set to kCALineJoinMiter, the
    /// miter limit determines whether the lines should be joined with
    /// a bevel instead of a miter. The length of the miter is divided by
    /// the line width. If the result is greater than the miter limit, the
    /// path is drawn with a bevel.
    public var miterLimit: CGFloat
    
    /// An array of dash sizes that determine the dash pattern.
    public var dash: [CGFloat]
    
    /// How far into the dash pattern the line will start.
    public var dashPhase: CGFloat
    
    /// Initializes an instance of a stroke style.
    /// - Parameters:
    ///   - lineWidth: The width of the stroke's line
    ///   - lineCap: The cap style of the stroke's line extremes
    ///   - lineJoin: The way lines join in the stroke
    ///   - miterLimit: The miter limit if the join type is kCALineJoinMiter
    ///   - dash: An array of dash sizes that determine the dash pattern.
    ///   - dashPhase: How far into the dash pattern the line will start.
    public init(
        lineWidth: CGFloat = 1,
        lineCap: CGLineCap = .butt,
        lineJoin: CGLineJoin = .miter,
        miterLimit: CGFloat = 10,
        dash: [CGFloat] = [CGFloat](),
        dashPhase: CGFloat = 0
    ) {
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.miterLimit = miterLimit
        self.dash = dash
        self.dashPhase = dashPhase
    }
}

