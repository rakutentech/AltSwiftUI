//
//  Label.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/05/24.
//

import UIKit

public typealias LocalizedStringKey = String

@available(iOS 14.0, *)
/// A view that display icon with text.
public struct Label<Title: View, Icon: View>: View {
    public enum LebelStyle {
        case DefaultLabelStyle, TitleAndIconLabelStyle, TitleOnlyLabelStyle, IconOnlyLabelStyle
    }
    
    public var viewStore = ViewValues()
    var title: [View]
    var icon: [View]
    var style: LebelStyle = .DefaultLabelStyle
    var viewContent: [View] = []
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The visual representation of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(@ViewBuilder title: () -> Title, icon: () -> Icon) {
        self.title = title().subViews
        self.icon = icon().subViews
        self.viewContent.append(contentsOf: self.icon)
        self.viewContent.append(contentsOf: self.title)
    }
    
    public var body: View {
        self
    }
    
    public mutating func setLabelStyle(style: LebelStyle) {
        self.style = style
    }
}

@available(iOS 14.0, *)
extension Label where Title == Text, Icon == Image {
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The string of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init<S: StringProtocol>(_ title: S, image: String) {
        self.title = [Text(title)]
        self.icon = [Image(image)]
        self.viewContent.append(contentsOf: self.icon)
        self.viewContent.append(contentsOf: self.title)
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(_ title: LocalizedStringKey, image: String) {
        self.title = [Text(NSLocalizedString(title, comment: ""))]
        self.icon = [Image(image)]
        self.viewContent.append(contentsOf: self.icon)
        self.viewContent.append(contentsOf: self.title)
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The string of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    public init<S: StringProtocol>(_ title: S, systemImage: String) {
        self.title = [Text(title)]
        self.icon = [Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())]
        self.viewContent.append(contentsOf: self.icon)
        self.viewContent.append(contentsOf: self.title)
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    public init(_ title: LocalizedStringKey, systemImage: String) {
        self.title = [Text(NSLocalizedString(title, comment: ""))]
        self.icon = [Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())]
        self.viewContent.append(contentsOf: self.icon)
        self.viewContent.append(contentsOf: self.title)
    }
}

@available(iOS 14.0, *)
extension Label: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let stackView = view as? UIStackView else { return }
        setupView(stackView, context: context)
    }
    
    public func createView(context: Context) -> UIView {
        let stack = SwiftUIStackView().noAutoresizingMask()
        stack.addViews(viewContent, context: context, isEquallySpaced: subviewIsEquallySpaced, setEqualDimension: setSubviewEqualDimension)
        setupView(stack, context: context)
        return stack
    }
    
    private func setupView(_ view: UIStackView, context: Context) {
        context.viewOperationQueue.addOperation {
            for i in 0..<view.arrangedSubviews.count {
                if i < self.icon.count {
                    view.arrangedSubviews[i].isHidden = (self.style == .TitleOnlyLabelStyle)
                } else {
                    view.arrangedSubviews[i].isHidden = (self.style == .IconOnlyLabelStyle)
                }
            }
        }
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

