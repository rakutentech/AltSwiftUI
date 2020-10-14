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
        view.updateOnLayout = { rect in
            updatePath(view: view, path: path(from: rect), animation: nil)
        }
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        
        let width = context.viewValues?.viewDimensions?.width ?? view.bounds.width
        let height = context.viewValues?.viewDimensions?.height ?? view.bounds.height
        let animation = context.transaction?.animation
        view.lastSizeFromViewUpdate = CGSize(width: width, height: height)
        
        updatePath(view: view, path: path(from: CGRect(x: 0, y: 0, width: width, height: height)), animation: animation)
        updateShapeLayerValues(view: view, context: context)
    }
    
    private func path(from rect: CGRect) -> UIBezierPath {
        let minDimensions = min(rect.width, rect.height)
        let x = (rect.width - minDimensions) / 2
        let y = (rect.height - minDimensions) / 2
        
        return UIBezierPath(
            roundedRect: CGRect(x: x, y: y, width: minDimensions, height: minDimensions),
            cornerRadius: minDimensions/2
        )
    }
}
