//
//  ScrollView.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// Creates a view that can scroll its subviews. Unlike a `List`,
/// all subviews are created together with this view.
public struct ScrollView: View {
    public var viewStore = ViewValues()
    public var body: View {
        EmptyView()
    }
    var contentView: View?
    let showsIndicators: Bool
    let axis: Axis
    var contentOffset: Binding<CGPoint>?
    var appliedVisibleRect: Binding<CGRect?>?
    var isBounceEnabled = true
    var ignoresHighPerformance = false
    var scrollEnabled: Bool = true
    var interactiveScrollEnabled = true
    
    public init(_ axis: Axis = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> View) {
        contentView = content().subViews.first
        self.axis = axis
        self.showsIndicators = showsIndicators
    }
    
    /// Listen to changes in the ScrollView's content offset.
    /// Setting the value of this binding does **not** affect the ScrollView's content offset.
    ///
    /// - warning:
    /// Updates to the value of this binding
    /// triggers _high performance_ rendering when updating views.
    /// High performance updates don't update children views of
    /// ScrollView and List.
    /// See __High Performance__ in the documentation for more information.
    ///
    /// - important:
    /// Not SwiftUI compatible.
    ///
    /// - Note:
    /// Also see: ```View.ignoreHighPerformance``` and ```View.skipHighPerformanceUpdate```.
    public func contentOffset(_ offset: Binding<CGPoint>) -> Self {
        var view = self
        view.contentOffset = offset
        return view
    }
    
    /// Applies the specified offset to the ScrollView's content. Once applied,
    /// the value inside the Binding will be set to `nil`.
    ///
    /// - Parameter offset: The visible rect to apply
    ///
    /// - important: Not SwiftUI compatible.
    public func appliedVisibleRect(_ rect: Binding<CGRect?>) -> Self {
        // Listen to changes in this binding
        _ = rect.wrappedValue
        var view = self
        view.appliedVisibleRect = rect
        return view
    }
    
    /// Determines if the scroll view can bounce.
    /// 
    /// - important: Not SwiftUI compatible.
    public func bounces(_ bounces: Bool) -> Self {
        var list = self
        list.isBounceEnabled = bounces
        return list
    }
    
    /// Updates this view during a high performance update.
    ///
    /// See `High Performance Updates` in the documentation for more
    /// information.
    ///
    /// - important: Not SwiftUI compatible.
    public func ignoreHighPerformance() -> Self {
        var list = self
        list.ignoresHighPerformance = true
        return list
    }
    
    /// Sets if scrolling in this view is enabled or not.
    ///
    /// - important: Not SwiftUI compatible.
    public func scrollEnabled(_ enabled: Bool) -> Self {
        var list = self
        list.scrollEnabled = enabled
        return list
    }
    
    /// Sets if scrolling is enabled, while still capturing user gestures.
    /// Use this instead of `scrollEnabled` if you want to start/stop receiving
    /// updates from user gestures while it's being executed.
    ///
    /// - important: Not SwiftUI compatible.
    public func interactiveScrollEnabled(_ enabled: Bool) -> Self {
        var list = self
        list.interactiveScrollEnabled = enabled
        return list
    }
}

extension ScrollView: Renderable {
    public func createView(context: Context) -> UIView {
        let scrollView = SwiftUIScrollView(axis: axis).noAutoresizingMask()
        scrollView.bounces = true
        scrollView.keyboardDismissMode = .interactive
        if !showsIndicators {
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
        }
        context.viewOperationQueue.addOperation {
            if let renderView = self.contentView?.renderableView(parentContext: context, drainRenderQueue: false) {
                let container = UIView().noAutoresizingMask()
                container.addSubview(renderView)
                scrollView.addSubview(container)
                scrollView.contentView = renderView
                
                renderView.edgesAnchorEqualTo(destinationView: container).activate()
                container.edgesAnchorEqualTo(destinationView: scrollView).activate()
                if self.axis == .horizontal {
                    scrollView.heightAnchor.constraint(equalTo: renderView.heightAnchor).isActive = true
                } else if self.axis == .vertical {
                    scrollView.widthAnchor.constraint(equalTo: renderView.widthAnchor).isActive = true
                }
            }
        }
        setupView(scrollView, context: context)
        return scrollView
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIScrollView,
              context.transaction?.isHighPerformance == false ||
                ignoresHighPerformance
        else { return }
        
        let updatedContext = context
        
        setupView(view, context: context)
        if let subView = view.contentView {
            contentView?.scheduleUpdateRender(uiView: subView, parentContext: updatedContext)
        }
    }
    
    private func setupView(_ view: SwiftUIScrollView, context: Context) {
        view.contentOffsetBinding = contentOffset
        view.bounces = isBounceEnabled
        view.isScrollEnabled = scrollEnabled
        if let appliedRect = appliedVisibleRect?.wrappedValue {
            let animated = context.transaction?.animation != nil
            view.scrollRectToVisible(appliedRect, animated: animated)
            EnvironmentHolder.notifyStateChanges = false
            appliedVisibleRect?.wrappedValue = nil
            EnvironmentHolder.notifyStateChanges = true
        }
        view.interactiveScrollEnabled = interactiveScrollEnabled
    }
}
