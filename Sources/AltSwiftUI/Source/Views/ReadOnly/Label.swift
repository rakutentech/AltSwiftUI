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
    public var viewStore = ViewValues()
    var title: Title
    var icon: Icon
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The visual representation of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(@ViewBuilder title: () -> Title, icon: () -> Icon) {
        self.title = title()
        self.icon = icon()
    }

    public var body: View {
        self
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
        self.title = Text(title)
        self.icon = Image(image)
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The visual representation of left part image of the label
    public init(_ title: LocalizedStringKey, image: String) {
        self.title = Text(NSLocalizedString(title, comment: ""))
        self.icon = Image(image)
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The string of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    public init<S: StringProtocol>(_ title: S, systemImage: String) {
        self.title = Text(title)
        self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
    }
    
    /// Creates an instance that disaly an `icon` with a `title`.
    ///
    /// - Parameters:
    ///     - title: The LocalizedStringKey of right part text of the label
    ///     - icon: The system icon name of left part image of the label
    public init(_ title: LocalizedStringKey, systemImage: String) {
        self.title = Text(NSLocalizedString(title, comment: ""))
        self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
    }
}

@available(iOS 14.0, *)
extension Label: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let stackView = view as? SwiftUIStackView else { return }
        setupView(stackView, context: context)
    }
    
    public func createView(context: Context) -> UIView {
        let hstack = HStack {
            self.icon
            self.title
        }
        if let stackView = hstack.createView(context: context) as? SwiftUIStackView {
            setupView(stackView, context: context)
            return stackView
        }
        
        return UIView()
    }
    
    private func setupView(_ view: UIStackView, context: Context) {
        guard let labelStyleType = context.viewValues?.labelStyle?.labelStyleType else { return }
        
        context.viewOperationQueue.addOperation {
            for i in 0..<view.arrangedSubviews.count {
                if i < self.icon.subViews.count {
                    view.arrangedSubviews[i].isHidden = (labelStyleType == .TitleOnly)
                } else {
                    view.arrangedSubviews[i].isHidden = (labelStyleType == .IconOnly)
                }
            }
        }
    }
}

