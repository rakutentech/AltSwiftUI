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

public protocol shape: View, Renderable {
    var fillColor: Color {get set}
    var strokeBorderColor: Color {get set}
    var style: StrokeStyle {get set}
}

extension shape {
    
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

public struct StrokeStyle : Equatable {

    public var lineWidth: CGFloat
    public var lineCap: CGLineCap
    public var lineJoin: CGLineJoin
    public var miterLimit: CGFloat
    public var dash: [CGFloat]
    public var dashPhase: CGFloat

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

