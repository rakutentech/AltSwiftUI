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
            var subviewContext = context
            subviewContext.parentScrollView = scrollView
            
            if let renderView = self.contentView?.renderableView(parentContext: subviewContext, drainRenderQueue: false) {
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
        let view = SwiftUICollectionView(orientation: axis == .horizontal ? .horizontal : .vertical).noAutoresizingMask()
        setupViewConfig(view: view, context: context, flatViews: baseSubview.totallyFlatSubViews)
        
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUICollectionView else { return }
        
        let flatViews = baseSubview.totallyFlatSubViews
        setupViewConfig(view: view, context: context, flatViews: flatViews)
        
        if let oldView = view.lastRenderableView?.view as? LazyGridView {
            if context.transaction?.animation != nil {
                var indexReduce = 0
                view.performBatchUpdates {
                    var resettedCache = false
                    views.iterateFullViewDiff(oldList: oldView.views) { index, operation in
                        let index = index - indexReduce
                        let indexPaths = [IndexPath(row: index, section: 0)]
                        switch operation {
                        case .insert:
                            if !resettedCache {
                                resettedCache = true
                                view.resetCellCache()
                            }
                            view.insertItems(at: indexPaths)
                        case .delete:
                            if !resettedCache {
                                resettedCache = true
                                view.resetCellCache()
                            }
                            view.deleteItems(at: indexPaths)
                            indexReduce += 1
                        case .update:
                            view.reloadItems(at: indexPaths)
                        }
                    }
                }
            } else {
                var needsReload = false
                views.iterateFullViewDiff(oldList: oldView.views) { _, operation in
                    switch operation {
                    case .insert, .delete:
                        needsReload = true
                    default: break
                    }
                }
                if needsReload {
                    view.resetCellCache()
                    view.reloadData()
                } else {
                    for cell in view.visibleCells {
                        guard let cell = cell as? SwiftUICollectionViewCell,
                              let indexPath = view.indexPath(for: cell),
                              indexPath.row < flatViews.count,
                              let cellUIView = cell.contentViewRoot else {
                            continue
                        }

                        let cellView = flatViews[indexPath.row]
                        let previousProjectedSize = cellUIView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                        context.viewOperationQueue.addOperation {
                            cellView.updateRender(uiView: cellUIView, parentContext: context, drainRenderQueue: false)
                        }
                        
                        context.postRenderOperationQueue.addOperation {
                            cellUIView.layoutIfNeeded()
                            if previousProjectedSize != cellUIView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) {
                                UIView.performWithoutAnimation {
                                    cell.updateRendering()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupViewConfig(view: SwiftUICollectionView, context: Context, flatViews: [View]) {
        view.updateItems(itemCount: flatViews.count) { index in
            flatViews[index].renderableView(parentContext: context) ?? UIView()
        }
    }
}

protocol LazyStackInformation {
    var viewContent: [View] { get }
    func insertViews(contentOffset: CGPoint, containerSize: CGSize, viewOffsetInContainer: CGPoint, view: UIView)
    func updateLoadedViews(view: UIView)
}

public struct LazyVStack: LazyStackInformation, View {
    public var viewStore = ViewValues()
    
    let viewContent: [View]
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    var isStandaloneCreation = true
    var noPropertiesVStack: VStack
    
    public var body: View {
        EmptyView()
    }
    
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> View) {
        noPropertiesVStack = VStack(alignment: alignment, spacing: spacing, content: content)
        viewContent = noPropertiesVStack.viewContent
        self.alignment = alignment
        self.spacing = spacing ?? 0
        viewStore.direction = .vertical
    }
    
    func insertViews(contentOffset: CGPoint, containerSize: CGSize, viewOffsetInContainer: CGPoint, view: UIView) {
        guard let view = view as? SwiftUIStackView else {
            return
        }
        view.insertViews(visibleLength: containerSize.height, offset: contentOffset.y, viewOffsetInContainer: viewOffsetInContainer.y, views: viewContent)
    }
    
    func updateLoadedViews(view: UIView) {
        guard let view = view as? SwiftUIStackView else {
            return
        }
        if let oldView = view.lastRenderableView?.view as? LazyVStack {
            view.updateViews(
                views: viewContent,
                oldViews: oldView.viewContent,
                isEquallySpaced: noPropertiesVStack.subviewIsEquallySpaced,
                setEqualDimension: noPropertiesVStack.setSubviewEqualDimension)
        }
    }
}

extension LazyVStack: Renderable {
    public func createView(context: Context) -> UIView {
        if let scrollView = context.parentScrollView {
            let stackView = SwiftUIStackView().noAutoresizingMask()
            stackView.axis = .vertical
            stackView.setStackAlignment(alignment: alignment)
            stackView.spacing = spacing
            stackView.lastContext = context
            
            // TODO: P3 insert subviews only if root stack in scroll
            let insertSubviews = { [weak scrollView] in
                guard let scrollView = scrollView,
                      let containerView = scrollView.subviews.first else {
                    return
                }
                
                let viewOffset = stackView.superview?.convert(stackView.frame, to: containerView) ?? .zero
                insertViews(contentOffset: scrollView.contentOffset, containerSize: scrollView.bounds.size, viewOffsetInContainer: viewOffset.origin, view: stackView)
            }
            scrollView.executeAfterFirstLayout(insertSubviews)
            scrollView.onScroll = insertSubviews
            
            if context.viewValues?.background != nil || context.viewValues?.border != nil {
                return BackgroundView(content: stackView).noAutoresizingMask()
            } else {
                return stackView
            }
        } else {
            return updatedVStack.createView(context: context)
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        var stackView = view
        if let bgView = view as? BackgroundView {
            stackView = bgView.content
        }
        
        if let stackView = stackView as? SwiftUIStackView {
            stackView.lastContext = context
            updateLoadedViews(view: stackView)
        } else {
            // TODO: P2 Abstract vstack functions and use helper instead of vstack proxy state to prevent update failure due to oldviews lookup failure.
            updatedVStack.updateView(stackView, context: context)
        }
    }
    
    var updatedVStack: VStack {
        var stack = noPropertiesVStack
        stack.viewStore = viewStore
        return stack
    }
}

/*
 Scroll with lazy stack root::
 ------
 render:
 contentOffset -> detect row with size collection -> load next
 load + insert -> calculate size -> collect size
 
 update:
 Stack:detectDiff -> currentRow -> update/insert/delete prev/next -> update size collection -> pending update rows
 
 scroll:
 scroll -> pending update rows (no animation) -> update -> update size collection
 
 Stack::
 -------
 create:
 collect all Views
 
 detectDiff:
 return diff + row
 
 */
