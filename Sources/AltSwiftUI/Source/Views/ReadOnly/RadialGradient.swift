//
//  RadialGradient.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/5/27.
//

import UIKit
public struct RadialGradient: View {
    public var viewStore: ViewValues = ViewValues()
    let gradient: Gradient
    let center: CGPoint
    let startRadius: CGFloat
    let endRadius: CGFloat
    
    public init(gradient: Gradient, center: CGPoint, startRadius: CGFloat, endRadius: CGFloat ){
        self.gradient = gradient
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }
    
    public var body: View {
        self
    }
}
extension RadialGradient: Renderable, GradientProtocol {
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIGradientView<RadialGradient> else { return }
        view.setUpRadialGradient(gradient: self)
        if self.viewStore.background != nil{
            view.backgroundColor = self.viewStore.background
        }
        else{
            view.backgroundColor = Color.clear.rawColor
        }
        guard let animation = context.transaction?.animation, let oldView = view.lastRenderableView?.view as? RadialGradient else {
            return
        }
        self.performUpdate(layer: view.layer, keyPath: "startPoint", newValue: self.center, animation: animation, oldValue: oldView.center)
        self.performUpdate(layer: view.layer, keyPath: "startRadius", newValue: self.startRadius, animation: animation,oldValue: oldView.startRadius)
        self.performUpdate(layer: view.layer, keyPath: "endRadius", newValue: self.endRadius, animation: animation,oldValue: oldView.endRadius)
        self.performUpdate(layer: view.layer, keyPath: "colors", newValue: getColorComponents(gradient: self.gradient), animation: animation,oldValue: getColorComponents(gradient: oldView.gradient))
    }
    
    public func createView(context: Context) -> UIView {
        let view = SwiftUIGradientView<RadialGradient>(gradient: self, path: self.viewStore.path).noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
}

