///
//  Label.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/05/24.
//

import UIKit

public typealias LocalizedStringKey = String

/// A view that display icon with text.
public struct Label<Title: View, Icon: View>: View {
    public var viewStore = ViewValues()
    var title: Title?
    var icon: Icon?
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The visual representation of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(title: () -> Title, icon: () -> Icon) {
        self.title = title()
        self.icon = icon()
    }

    public var body: View {
        self
    }
}

extension Label where Title == Text, Icon == Image {
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The string of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init<S: StringProtocol>(_ title: S, image: String) {
        if !title.isEmpty {
            self.title = Text(title)
        }
        if !image.isEmpty {
            self.icon = Image(image)
        }
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(_ title: LocalizedStringKey, image: String) {
        if !title.isEmpty {
            self.title = Text(NSLocalizedString(title, comment: ""))
        }
        if !image.isEmpty {
            self.icon = Image(image)
        }
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The string of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    @available(iOS 13.0, *)
    public init<S: StringProtocol>(_ title: S, systemImage: String) {
        if !title.isEmpty {
            self.title = Text(title)
        }
        if !systemImage.isEmpty {
            self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
        }
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    @available(iOS 13.0, *)
    public init(_ title: LocalizedStringKey, systemImage: String) {
        if !title.isEmpty {
            self.title = Text(NSLocalizedString(title, comment: ""))
        }
        if !systemImage.isEmpty {
            self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
        }
    }
}

extension Label: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let concreteStackView = view as? UIStackView else { return }
        
        if let oldHStack = view.lastRenderableView?.view as? Self {
            concreteStackView.updateViews(
                getViewContent(context, title, icon),
                oldViews: getViewContent(context, oldHStack.title, oldHStack.icon),
                context: context,
                isEquallySpaced: subviewIsEquallySpaced,
                setEqualDimension: setSubviewEqualDimension)
        }
    }
    
    public func createView(context: Context) -> UIView {
        let stack = SwiftUIStackView().noAutoresizingMask()
        
        stack.addViews(getViewContent(context, title, icon), context: context, isEquallySpaced: subviewIsEquallySpaced, setEqualDimension: setSubviewEqualDimension)
        
        return stack
    }
    
    private func getViewContent(_ context: Context, _ title: Title?, _ icon: Icon?) -> [View] {
        let labelStyle = context.viewValues?.labelStyle?.labelStyleType ?? .titleAndIcon
        var viewContent = [View]()
        
        if let icon = icon, labelStyle != .titleOnly {
            viewContent.append(icon)
        }
        
        if let title = title, labelStyle != .iconOnly {
            viewContent.append(title)
        }
        
        return viewContent
    }
    
    private var subviewIsEquallySpaced: (View) -> Bool { { view in
           if (view is Spacer &&
               view.viewStore.viewDimensions?.width == nil)
               ||
               (view.viewStore.viewDimensions?.maxWidth == CGFloat.limitForUI) {
               return true
           } else {
               return false
           }
        }
    }
    
    private var setSubviewEqualDimension: (UIView, UIView) -> Void { { firstView, secondView in
            firstView.widthAnchor.constraint(equalTo: secondView.widthAnchor).isActive = true
        }
    }
}
