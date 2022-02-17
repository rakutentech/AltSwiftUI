//
//  HStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// This view arranges subviews horizontally.
public struct HStack: View, Stack {
    public var viewStore = ViewValues()
    let viewContent: [View]
    let alignment: VerticalAlignment
    let spacing: CGFloat
    
    /// Creates an instance of a view that arranges subviews horizontally.
    ///
    /// - Parameters:
    ///   - alignment: The vertical alignment guide for its children. Defaults to `center`.
    ///   - spacing: The horizontal distance between subviews. If not specified,
    ///   the distance will use the default spacing specified by the framework.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> View) {
        let contentView = content()
        viewContent = contentView.mappedSubViews { subView in
            // Prevent UIStackView from creating custom
            // constraints that break children layout.
            if let text = subView as? Text,
               text.viewStore.lineLimit == nil,
               text.viewStore.viewDimensions?.width != nil {
                return VStack { subView }
            } else {
                return subView
            }
        }
        self.alignment = alignment
        self.spacing = spacing ?? SwiftUIConstants.defaultSpacing
        viewStore.direction = .horizontal
    }
    init(viewContent: [View]) {
        self.viewContent = viewContent
        alignment = .center
        spacing = SwiftUIConstants.defaultSpacing
    }
    public var body: View {
        EmptyView()
    }
}

extension HStack: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        let oldHStackContent = (view.lastRenderableView?.view as? Self)?.viewContent
        updateView(view, context: context, oldViewContent: oldHStackContent)
    }
    
    public func createView(context: Context) -> UIView {
        let stack = SwiftUIStackView().noAutoresizingMask()
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
    
    var subviewIsEquallySpaced: (View) -> Bool { { view in
           if (view is Spacer &&
               view.viewStore.viewDimensions?.width == nil)
               ||
               (view.viewStore.viewDimensions?.maxWidth == CGFloat.limitForUI) {
               return true
           } else {
               return false
           }
        }
    }
    
    var setSubviewEqualDimension: (UIView, UIView) -> Void { { firstView, secondView in
            firstView.widthAnchor.constraint(equalTo: secondView.widthAnchor).isActive = true
        }
    }
    
    private func setupView(_ view: SwiftUIStackView, context: Context) {
        view.setStackAlignment(alignment: alignment)
        view.spacing = spacing
    }
}
