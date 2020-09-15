//
//  NavigationViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/09.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that adds navigation capabilities to a whole view hierarchy.
/// Add only one `NavigationView` per view hierarchy.
///
/// By adding a `NavigationView`, a navigation bar will be shown by default.
public struct NavigationView: View {
    public var viewStore: ViewValues = ViewValues()
    public var body: View {
        EmptyView()
    }
    
    let content: View
    public init(@ViewBuilder content: () -> View) {
        self.content = content().subViews.first ?? EmptyView()
    }
}

extension NavigationView: Renderable {
    public func createView(context: Context) -> UIView {
        let updatedContext = modifiedContext(context)
        context.rootController?.setNavigationController(true)
        let renderContainer = UIView().noAutoresizingMask()
        
        context.viewOperationQueue.addOperation {
            let contentView = self.content.renderableView(parentContext: updatedContext, drainRenderQueue: false) ?? UIView()
            renderContainer.addSubview(contentView)
            contentView.edgesAnchorEqualTo(view: renderContainer).activate()
        }
        
        setupNavigation(context: context)
        
        return renderContainer
    }
    
    public func updateView(_ view: UIView, context: Context) {
        let updatedContext = modifiedContext(context)
        if let subView = view.subviews.first {
            content.scheduleUpdateRender(uiView: subView, parentContext: updatedContext)
        }
        setupNavigation(context: context)
    }
    
    private func modifiedContext(_ context: Context) -> Context {
        var newContext = context
        if let accentColor = context.viewValues?.accentColor {
            newContext.viewValues?.navigationAccentColor = accentColor
        }
        return newContext
    }
    
    private func setupNavigation(context: Context) {
        if let accentColor = context.viewValues?.accentColor {
            context.rootController?.setNavigationBarTint(accentColor)
        }
    }
}

/// This view will perform navigation when triggered by the user.
/// The behavior of this view is same as a `Button`, but the action
/// is predefined to navigate to a specified `View`.
public struct NavigationLink: View {
    public var viewStore: ViewValues = ViewValues()
    public var body: View {
        EmptyView()
    }
    let contentView: View
    var destination: View
    var isActive: Binding<Bool>? = nil
    
    /// Creates an instance that will navigate to the `destination` when
    /// triggered by user interaction.
    ///
    /// - Parameters:
    ///     - destination: The view to which the current view hierarchy will
    ///     navigate to.
    ///     - label: The visual contents of `self`
    public init(destination: View, @ViewBuilder label: () -> View) {
        contentView = label().subViews.first ?? EmptyView()
        self.destination = destination
    }
    
    /// Creates an instance that will navigate to the `destination` when
    /// the specified `isActive` binding becomes `true`.
    ///
    /// - Parameters:
    ///     - destination: The view to which the current view hierarchy will
    ///     navigate to.
    ///     - isActive: Will trigger the navigation when true. When false, will
    ///     dismiss the navigation if active.
    ///     - label: The visual contents of `self`
    public init(destination: View, isActive: Binding<Bool>, @ViewBuilder label: () -> View) {
        contentView = label().subViews.first ?? EmptyView()
        self.destination = destination
        self.isActive = isActive
        if isActive.wrappedValue {} /* Listen to binding */
    }
    
    /// Setting this method to `true` will hide the tab bar every time
    /// the `destination` view is navigated to.
    ///
    /// - important: Not SwiftUI compatible.
    public func hidesTabBar(_ hidden: Bool) -> Self {
        var view = self
        view.destination.viewStore.tabBarHidden = hidden
        return view
    }
}

extension NavigationLink: Renderable {
    public func createView(context: Context) -> UIView {
        let paddingView = SwiftUIPaddingView().noAutoresizingMask()
        
        context.viewOperationQueue.addOperation {
            let button = self.linkButton(context: context).renderableView(parentContext: context, drainRenderQueue: false) ?? UIView()
            paddingView.content = button
        }
        
        return paddingView
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIPaddingView else { return }
        
        if let content = view.content {
            linkButton(context: context).scheduleUpdateRender(uiView: content, parentContext: context)
        }
        if let isActive = isActive {
            if isActive.wrappedValue {
                if !(view.hasPushedView ?? false) {
                    view.hasPushedView = true
                    context.rootController?.navigateToView(self.destination, context: context, onPop: {
                        view.hasPushedView = false
                        isActive.wrappedValue = false
                    })
                }
            } else if let hasPushedView = view.hasPushedView, hasPushedView {
                view.hasPushedView = false
                context.rootController?.popView()
            }
        }
    }
    
    private func linkButton(context: Context) -> Button {
        Button(action: {
            if let isActive = self.isActive {
                isActive.wrappedValue = true
            } else {
                context.rootController?.navigateToView(self.destination, context: context)
            }
        }) { () -> View in
            contentView
        }
    }
}
