//
//  HStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// This view arranges subviews horizontally.
public struct HStack: View {
    public var viewStore: ViewValues = ViewValues()
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
        var stackView = view
        if let bgView = view as? BackgroundView {
            stackView = bgView.content
        }
        
        guard let concreteStackView = stackView as? UIStackView else { return }
        setupView(concreteStackView, context: context)
        if let oldHStack = view.lastRenderableView?.view as? Self {
            concreteStackView.updateViews(viewContent,
                             oldViews: oldHStack.viewContent,
                             context: context,
                             isEquallySpaced: subviewIsEquallySpaced,
                             setEqualDimension: setSubviewEqualDimension)
        }
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
    
    private func setupView(_ view: UIStackView, context: Context) {
        view.setStackAlignment(alignment: alignment)
        view.spacing = spacing
    }
    
    private var subviewIsEquallySpaced: (View) -> Bool {
        { view in
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
    
    private var setSubviewEqualDimension: (UIView, UIView) -> Void {
        { firstView, secondView in
            firstView.widthAnchor.constraint(equalTo: secondView.widthAnchor).isActive = true
        }
    }
}
