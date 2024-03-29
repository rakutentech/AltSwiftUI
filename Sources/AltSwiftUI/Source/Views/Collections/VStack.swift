//
//  VStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// This view arranges subviews vertically.
public struct VStack: View, Stack {
    public var viewStore = ViewValues()
    let viewContent: [View]
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    /// Creates an instance of a view that arranges subviews vertically.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment guide for its children. Defaults to `center`.
    ///   - spacing: The vertical distance between subviews. If not specified,
    ///   the distance will be 0.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> View) {
        let contentView = content()
        viewContent = contentView.subViews
        self.alignment = alignment
        self.spacing = spacing
        viewStore.direction = .vertical
    }
    public var body: View {
        EmptyView()
    }
}

extension VStack: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        let oldVStackViewContent = (view.lastRenderableView?.view as? VStack)?.viewContent
        updateView(view, context: context, oldViewContent: oldVStackViewContent)
    }
    
    public func createView(context: Context) -> UIView {
        let stack = SwiftUIStackView().noAutoresizingMask()
        stack.axis = .vertical
        setupView(stack, context: context)
        stack.addViews(viewContent, context: context, isEquallySpaced: subviewIsEquallySpaced, setEqualDimension: setSubviewEqualDimension)
        if context.viewValues?.background != nil || context.viewValues?.border != nil {
            return BackgroundView(content: stack).noAutoresizingMask()
        } else {
            return stack
        }
    }
    
    func updateView(_ view: UIView, context: Context, oldViewContent: [View]? = nil) {
        var stackView = view
        if let bgView = view as? BackgroundView {
            stackView = bgView.content
        }
        
        guard let concreteStackView = stackView as? SwiftUIStackView else { return }
        setupView(concreteStackView, context: context)
        
        if let oldViewContent = oldViewContent {
            concreteStackView.updateViews(viewContent,
                             oldViews: oldViewContent,
                             context: context,
                             isEquallySpaced: subviewIsEquallySpaced,
                             setEqualDimension: setSubviewEqualDimension)
        }
    }
    
    private func setupView(_ view: SwiftUIStackView, context: Context) {
        view.setStackAlignment(alignment: alignment)
        view.spacing = spacing ?? 0
    }
    
    var subviewIsEquallySpaced: (View) -> Bool { { view in
           if (view is Spacer ||
               view.viewStore.viewDimensions?.maxHeight == CGFloat.limitForUI
               )
               &&
               (view.viewStore.viewDimensions?.height == nil) {
               return true
           } else {
               return false
           }
        }
    }
    
    var setSubviewEqualDimension: (UIView, UIView) -> Void { { firstView, secondView in
            firstView.heightAnchor.constraint(equalTo: secondView.heightAnchor).isActive = true
        }
    }
}
