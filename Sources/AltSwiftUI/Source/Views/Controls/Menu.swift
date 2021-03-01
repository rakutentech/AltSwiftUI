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
    var labels: [View]
    let viewContent: [View]
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - - content: A view builder that creates the content of menu options.
    ///     - label: The visual representation of the menu button
    public init(@ViewBuilder content: () -> View, @ViewBuilder label: () -> View) {
        self.labels = label().subViews
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
    public init(_ title: String, @ViewBuilder content: () -> View) {
        labels = [Text(title)]
        self.viewContent = content().subViews
    }
}

@available(iOS 14.0, *)
extension Menu: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIMenuButton,
            let lastView = view.lastRenderableView?.view as? Self,
            let firstLabel = labels.first,
            let firstOldLabel = lastView.labels.first else { return }
        
        context.viewOperationQueue.addOperation {
            [firstLabel].iterateFullViewDiff(oldList: [firstOldLabel]) { _, operation in
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
        guard let contentView = labels.first?.renderableView(parentContext: context) else { return UIView() }
        let menu = UIMenu(title: "", image: nil, options: .displayInline, children: generateUIMenuElements(viewContent: viewContent))
        let button = SwiftUIMenuButton(contentView: contentView, menu: menu).noAutoresizingMask()
        if let buttonStyle = context.viewValues?.buttonStyle {
            let styledContentView = buttonStyle.makeBody(configuration: ButtonStyleConfiguration(label: labels[0], isPressed: false))
            styledContentView.updateRender(uiView: contentView, parentContext: context)
        }
        
        return button
    }
    
    private func generateUIMenuElements(viewContent: [View]) -> [UIMenuElement] {
        var elements = [UIMenuElement]()
        viewContent.totallyFlatIterate { (view) in
            if let buttonView = view as? Button,
               let textView = buttonView.labels.first as? Text {
                let action = UIAction(title: textView.string, image: nil, handler: { _ in buttonView.action() })
                elements.append(action)
            } else if let menuView = view as? Menu, let textView = menuView.labels.first as? Text {
                let menu = UIMenu(title: textView.string, image: nil, children: generateUIMenuElements(viewContent: menuView.viewContent))
                elements.append(menu)
            }
        }
        return elements
    }
}
