//
//  LazyStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/11/04.
//

import UIKit

protocol LazyStack: Renderable, View {
    var viewContentBuilder: () -> View { get }
    var spacing: CGFloat { get }
    var noPropertiesStack: Stack { get }
    var scrollAxis: Axis { get }
    var stackAxis: NSLayoutConstraint.Axis { get }
    func updateStackAlignment(stack: SwiftUILazyStackView)
}

extension LazyStack {
    /// Insert latest updated view content. Should be called outside of actual
    /// create and update operations
    func insertRemainingViews(view: SwiftUILazyStackView) {
        view.insertViewsUntilVisibleArea()
    }
    
    func updateLoadedViews(view: SwiftUILazyStackView) {
        view.updateLazyStack(
            newViews: viewContentBuilder().totallyFlatSubViewsWithOptionalViewInfo,
            isEquallySpaced: noPropertiesStack.subviewIsEquallySpaced,
            setEqualDimension: noPropertiesStack.setSubviewEqualDimension)
    }
}

// MARK: - Renderable

extension LazyStack {
    public func createView(context: Context) -> UIView {
        if let scrollView = context.parentScrollView,
           scrollView.axis == scrollAxis,
           scrollView.rootLazyStack == nil {
            let stackView = SwiftUILazyStackView().noAutoresizingMask()
            stackView.axis = stackAxis
            updateStackAlignment(stack: stackView)
            stackView.spacing = spacing
            stackView.lastContext = context
            stackView.lazyStackFlattenedContentViews = viewContentBuilder().totallyFlatSubViewsWithOptionalViewInfo
            stackView.lazyStackScrollView = scrollView
            
            context.postRenderOperationQueue.addOperation {
                let insertSubviews = { [weak stackView] in
                    guard let stackView = stackView else { return }
                    // Render operation initiated by UIKit layout
                    // calls rather than AltSwiftUI render cycle.
                    insertRemainingViews(view: stackView)
                }
                scrollView.executeOnNewLayout(insertSubviews)
            }
            scrollView.rootLazyStack = stackView
            
            if context.viewValues?.background != nil || context.viewValues?.border != nil {
                return BackgroundView(content: stackView).noAutoresizingMask()
            } else {
                return stackView
            }
        } else {
            return updatedStack.createView(context: context)
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        var stackView = view
        if let bgView = view as? BackgroundView {
            stackView = bgView.content
        }
        
        if let stackView = stackView as? SwiftUILazyStackView,
           stackView.lazyStackScrollView != nil {
            stackView.lastContext = context
            updateLoadedViews(view: stackView)
        } else {
            let oldViewContent = (view.lastRenderableView?.view as? LazyStack)?.noPropertiesStack.viewContent
            updatedStack.updateView(stackView, context: context, oldViewContent: oldViewContent)
        }
    }
    
    var updatedStack: Stack {
        var stack = noPropertiesStack
        stack.viewStore = viewStore
        return stack
    }
}
