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
    var scrollEnabled = true
    var interactiveScrollEnabled = true
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode?
    
    public init(_ axis: Axis = .vertical, showsIndicators: Bool = true, content: () -> View) {
        contentView = content()
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
    
    /// Sets the keyboard dismiss mode of the ScrollView.
    /// If not set, by default it will be `interactive`.
    ///
    /// - important: Not SwiftUI compatible.
    public func keyboardDismissMode(_ dismissMode: UIScrollView.KeyboardDismissMode) -> Self {
        var list = self
        list.keyboardDismissMode = dismissMode
        return list
    }
}

extension ScrollView: Renderable {
    public func createView(context: Context) -> UIView {
        let scrollView = SwiftUIScrollView(axis: axis).noAutoresizingMask()
        scrollView.bounces = true
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
            EnvironmentHolder.withoutNotifyingStateChanges {
                appliedVisibleRect?.wrappedValue = nil
            }
        }
        view.interactiveScrollEnabled = interactiveScrollEnabled
        let keyboardDismissModeValue = keyboardDismissMode ?? .interactive
        if view.keyboardDismissMode != keyboardDismissModeValue {
            view.keyboardDismissMode = keyboardDismissModeValue
        }
    }
}

public struct LazyGridView: View, Renderable {
    public var viewStore = ViewValues()
    public var body: View {
        EmptyView()
    }
    
    var baseSubview: View
    var views: [View]
    var axis: Axis
    public init(_ axis: Axis = .vertical, @ViewBuilder items: () -> View) {
        baseSubview = items()
        views = baseSubview.subViews
        self.axis = axis
    }
    
    public func createView(context: Context) -> UIView {
        let view = SwiftUICollectionView(orientation: axis == .horizontal ? .horizontal : .vertical).noAutoresizingMask();
        setupViewConfig(view: view, context: context);
        
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUICollectionView else { return }
        
        setupViewConfig(view: view, context: context)
        
        if let oldView = view.lastRenderableView?.view as? LazyGridView {
            if context.transaction?.animation != nil {
                var indexReduce = 0
                view.performBatchUpdates {
                    views.iterateFullViewDiff(oldList: oldView.views) { index, operation in
                        let index = index - indexReduce
                        let indexPaths = [IndexPath(row: index, section: 0)]
                        switch operation {
                        case .insert(_):
                            view.insertItems(at: indexPaths)
                            //reloadIndexPaths.insert(IndexPath(row: index, section: 0))
                        case .delete(_):
                            view.deleteItems(at: indexPaths)
                            indexReduce += 1
                        case .update(_):
                            view.reloadItems(at: indexPaths)
                        }
                    }
                }
            } else {
                var needsReload = false
                views.iterateFullViewDiff(oldList: oldView.views) { index, operation in
                    switch operation {
                    case .insert(_), .delete(_):
                        needsReload = true
                    default: break
                    }
                }
                if needsReload {
                    view.reloadData()
                } else {
                    for cell in view.visibleCells {
                        guard let cell = cell as? SwiftUICollectionViewCell,
                              let indexPath = view.indexPath(for: cell),
                              indexPath.row < views.count,
                              let cellUIView = cell.contentViewRoot else {
                            continue
                        }

                        let cellView = views[indexPath.row]
                        context.viewOperationQueue.addOperation {
                            cellView.updateRender(uiView: cellUIView, parentContext: context, drainRenderQueue: false)
                            if let animation = context.transaction?.animation {
                                animation.performAnimation {
                                    cell.updateRendering()
                                }
                            } else {
                                cell.updateRendering()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupViewConfig(view: SwiftUICollectionView, context: Context) {
        let updateViews = baseSubview.totallyFlatSubViews
        view.updateItems(itemCount: updateViews.count) { index in
            updateViews[index].renderableView(parentContext: context) ?? UIView()
        }
    }
}
