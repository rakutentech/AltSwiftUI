//
//  Link.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/05/21.
//

import UIKit

@available(iOS 14.0, *)
/// A view that can be tapped by the user to open a url link.
public struct Link<Title: View, Icon: View>: View {
    public var viewStore = ViewValues()
    var label: Label<Title, Icon>
    var url: URL
    var labelStyle: LabelStyle?
    
    /// Creates an instance with a `Text` visual representation.
    ///
    /// - Parameters:
    ///     - label: The visual representation of the label
    ///     - destination: The url for the web site
    public init(destination url: URL, label: () -> Label<Title, Icon>) {
        self.label = label()
        self.url = url
    }
    
    public var body: View {
        self
    }
}

@available(iOS 14.0, *)
extension Link where Title == Text, Icon == Image {
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - title: the string of the title lebel
    ///     - destination: The url for the web site
    public init<S>(_ title: S, destination url: URL) where S: StringProtocol {
        self.label = Label(title, image: "")
        self.url = url
        self.labelStyle = TitleOnlyLabelStyle()
    }
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - title: the localizedStringKey of the title lebel
    ///     - destination: The url for the web site
    public init(_ title: LocalizedStringKey, destination url: URL) {
        self.label = Label(title, image: "")
        self.url = url
        self.labelStyle = TitleOnlyLabelStyle()
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
            UIApplication.shared.open(url)
        } label: { () -> View in
            label
                .labelStyle(labelStyle ?? DefaultLabelStyle())
        }
        return button.createView(context: context)
    }
}
