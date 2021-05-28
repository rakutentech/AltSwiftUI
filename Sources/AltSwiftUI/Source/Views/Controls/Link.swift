//
//  Link.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/05/21.
//

import UIKit

@available(iOS 14.0, *)
/// A view that can be tapped by the user to open a menu.
public struct Link: View {
    public var viewStore = ViewValues()
    var label: View
    var destination: URL
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    ///     - label: The visual representation of the menu button
    public init<S>(_ title: S, destination: URL) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
    }
    
    public var body: View {
        self
    }
}

@available(iOS 14.0, *)
extension Link {
    /// Creates an instance with a `Text` visual representation.
    ///
    /// - Parameters:
    ///     - title: The title of the button.
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    public init(destination: URL, label: () -> View) {
        self.label = label()
        self.destination = destination
    }
}

@available(iOS 14.0, *)
extension Link: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIButton,
              let lastView = view.lastRenderableView?.view as? Self else { return }
        
        context.viewOperationQueue.addOperation {
            [label].iterateFullViewDiff(oldList: [lastView.label]) { _, operation in
                switch operation {
                case .insert(let newView):
                    if let newRenderView = newView.renderableView(parentContext: context, drainRenderQueue: false) {
                        view.updateContentView(newRenderView)
                    }
                case .delete:
                    break
                case .update(let newView):
                    newView.updateRender(uiView: view.contentView, parentContext: context, drainRenderQueue: false)
                }
            }
        }
    }
    
    public func createView(context: Context) -> UIView {
        let button = Button {
            
        } label: { () -> View in
            label
        }
        if let uiButton = button.createView(context: context) as? SwiftUIButton {
            return uiButton
        }
        
        return UIView()
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

