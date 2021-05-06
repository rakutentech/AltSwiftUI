//
//  RoundedRectangle.swift
//  AltSwiftUI
//
//  Created by Nodehi, Jabbar on 2020/09/09.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a RoundedRectangle shape.
public struct RoundedRectangle: Shape {
    public var viewStore = ViewValues()
    
    public var fillColor = Color.clear
    public var strokeBorderColor = Color.clear
    public var style = StrokeStyle()
    public var cornerRadius: CGFloat
    
    public var body: View {
        EmptyView()
    }

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    public func createView(context: Context) -> UIView {
        let view = AltShapeView().noAutoresizingMask()
        view.updateOnLayout = { [weak view] rect in
            guard let view = view else { return }
            updatePath(view: view, path: path(from: rect), animation: nil)
        }
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? AltShapeView else { return }
        let oldView = view.lastRenderableView?.view as? RoundedRectangle
        
        let width = context.viewValues?.viewDimensions?.width ?? view.bounds.width
        let height = context.viewValues?.viewDimensions?.height ?? view.bounds.height
        let animation = context.transaction?.animation
        view.lastSizeFromViewUpdate = CGSize(width: width, height: height)
        
        if context.viewValues?.viewDimensions != oldView?.viewStore.viewDimensions {
            updatePath(view: view, path: path(from: CGRect(x: 0, y: 0, width: width, height: height)), animation: animation)
        }
        updateShapeLayerValues(view: view, context: context)
    }
    
    private func path(from rect: CGRect) -> UIBezierPath {
        UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: rect.width, height: rect.height),
            cornerRadius: cornerRadius
        )
    }
}
