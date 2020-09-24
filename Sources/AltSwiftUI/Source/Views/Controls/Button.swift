//
//  Button.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that can be tapped by the user to trigger some action.
public struct Button: View {
    public var viewStore = ViewValues()
    var labels: [View]
    var action: () -> Void
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - action: The action to perform when the button is triggered.
    ///     - label: The visual representation of the button
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> View) {
        self.labels = label().subViews
        self.action = action
    }
    
    /// Performs the primary action.
    public func trigger() {
        action()
    }
    
    public var body: View {
        self
    }
}

extension Button {
    /// Creates an instance with a `Text` visual representation.
    ///
    /// - Parameters:
    ///     - title: The title of the button.
    ///     - action: The action to perform when the button is triggered.
    public init(_ title: String, action: @escaping () -> Void) {
        labels = [Text(title)]
        self.action = action
    }
}

extension Button: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIButton,
            let lastView = view.lastRenderableView?.view as? Self,
            let firstLabel = labels.first,
            let firstOldLabel = lastView.labels.first else { return }
        let customContext = modifiedContext(context)
        
        context.viewOperationQueue.addOperation {
            [firstLabel].iterateFullViewDiff(oldList: [firstOldLabel]) { _, operation in
                switch operation {
                case .insert(let newView):
                    if let newRenderView = newView.renderableView(parentContext: customContext, drainRenderQueue: false) {
                        view.updateContentView(newRenderView)
                    }
                case .delete:
                    break
                case .update(let newView):
                    newView.updateRender(uiView: view.contentView, parentContext: customContext, drainRenderQueue: false)
                }
            }
        }
        view.action = action
    }
    
    public func createView(context: Context) -> UIView {
        let customContext = modifiedContext(context)
        guard let contentView = labels.first?.renderableView(parentContext: customContext) else { return UIView() }
        
        let button = SwiftUIButton(contentView: contentView, action: action).noAutoresizingMask()
        if let buttonStyle = customContext.viewValues?.buttonStyle {
            button.animates = false
            let styledContentView = buttonStyle.makeBody(configuration: ButtonStyleConfiguration(label: labels[0], isPressed: false))
            styledContentView.updateRender(uiView: contentView, parentContext: customContext)
        }
        
        return button
    }
    
    private func modifiedContext(_ context: Context) -> Context {
        var customContext = context
        customContext.isInsideButton = true
        
        // Set a default accentColor since SwiftUIButton subviews won't
        // take the button's tint color.
        if context.viewValues?.accentColor == nil {
            customContext.viewValues?.accentColor = Color.systemAccentColor.color
        }
        
        return customContext
    }
}
