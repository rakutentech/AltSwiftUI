//
//  Menu.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/02/25.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
/// A view that can be tapped by the user to open a menu.
public struct Menu: View {
    public var viewStore = ViewValues()
    var label: View
    var viewContent: [View]
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    ///     - label: The visual representation of the menu button
    public init(@ViewBuilder content: () -> View, label: () -> View) {
        self.label = label()
        self.viewContent = content().subViews
    }
    
    public var body: View {
        self
    }
}

@available(iOS 14.0, *)
extension Menu {
    /// Creates an instance with a `Text` visual representation.
    ///
    /// - Parameters:
    ///     - title: The title of the button.
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    public init(_ title: String, @ViewBuilder content: () -> View) {
        label = Text(title)
        self.viewContent = content().subViews
    }
}

@available(iOS 14.0, *)
extension Menu: Renderable {
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
        view.menu = menu
    }
    
    public func createView(context: Context) -> UIView {
        let button = Button {
            
        } label: { () -> View in
            label
        }
        if let uiButton = button.createView(context: context) as? SwiftUIButton {
            uiButton.showsMenuAsPrimaryAction = true
            uiButton.menu = menu
            return uiButton
        }
        
        return UIView()
    }
    
    private var menu: UIMenu {
        UIMenu(title: "", image: nil, options: .displayInline, children: menuElements(viewContent: viewContent))
    }
    
    private func menuElements(viewContent: [View]) -> [UIMenuElement] {
        var elements = [UIMenuElement]()
        viewContent.totallyFlatIterate { (view) in
            if let buttonView = view as? Button,
               let textView = buttonView.labels.first as? Text {
                let action = UIAction(title: textView.string, image: nil, handler: { _ in buttonView.action() })
                elements.append(action)
            } else if let menuView = view as? Menu, let textView = menuView.label.subViews.first as? Text {
                let menu = UIMenu(title: textView.string, image: nil, children: menuElements(viewContent: menuView.viewContent))
                elements.append(menu)
            }
        }
        return elements
    }
}
