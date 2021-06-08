//
//  Graident.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/5/26.
//

import UIKit

public struct LinearGradient:  View {
    public var viewStore: ViewValues = ViewValues()
    let gradient: Gradient
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    public init(gradient: Gradient, startPoint: CGPoint, endPoint: CGPoint){
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    public var body: View {
        self
    }
}
extension LinearGradient: Renderable, GradientProtocol {
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIGradientView<LinearGradient> else { return }
        view.setUpLinearGradient(gradient: self)
        if self.viewStore.background != nil{
            view.backgroundColor = self.viewStore.background
            view.layer.backgroundColor = self.viewStore.background?.cgColor
        }
        else{
            view.backgroundColor = Color.clear.rawColor
            view.layer.backgroundColor = Color.clear.rawColor.cgColor
        }
        
        guard let animation = context.transaction?.animation, let oldView = view.lastRenderableView?.view as? LinearGradient else {
            return
        }
        self.performUpdate(layer: view.layer, keyPath: "startPoint", newValue: self.startPoint, animation: animation, oldValue: oldView.startPoint)
        self.performUpdate(layer: view.layer, keyPath: "endPoint", newValue: self.endPoint, animation: animation,oldValue: oldView.endPoint)
        self.performUpdate(layer: view.layer, keyPath: "colors", newValue: getColorComponents(gradient: self.gradient), animation: animation,oldValue: getColorComponents(gradient: oldView.gradient))
    }

    public func createView(context: Context) -> UIView {
        let view = SwiftUIGradientView(gradient: self, path: self.viewStore.path).noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
    
}
