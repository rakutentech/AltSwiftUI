//
//  Label.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2021/05/24.
//

import UIKit

public typealias LocalizedStringKey = String

@available(iOS 14.0, *)
/// A view that can be tapped by the user to open a menu.
public struct Label<Title: View, Icon: View>: View {
    public enum LebelStyle {
        case DefaultLabelStyle, TitleAndIconLabelStyle, TitleOnlyLabelStyle, IconOnlyLabelStyle
    }
    
    public var viewStore = ViewValues()
    var title: View
    var icon: View
    var style: LebelStyle = .DefaultLabelStyle
    var viewContent: [View] = []
    
    /// Creates an instance that triggers an `action`.
    ///
    /// - Parameters:
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    ///     - label: The visual representation of the menu button
    public init(title: () -> Title, icon: () -> Icon) {
        self.title = title()
        self.icon = icon()
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
    /// Creates an instance with a `Text` visual representation.
    ///
    /// - Parameters:
    ///     - title: The title of the button.
    ///     - content: A view builder that creates the content of menu options.
    ///     Content can only support two specific types of view:
    ///         1. Button with Text inside
    ///         2. Menu
    public init<S: StringProtocol>(_ title: S, image: String) {
        self.title = Text(title)
        self.icon = Image(image)
    }
    
    public init(_ title: LocalizedStringKey, image: String) {
        self.title = Text(NSLocalizedString(title, comment: ""))
        self.icon = Image(image)
    }
    
    public init<S: StringProtocol>(_ title: S, systemImage: String) {
        self.title = Text(title)
        self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
    }
    
    public init(_ title: LocalizedStringKey, systemImage: String) {
        self.title = Text(NSLocalizedString(title, comment: ""))
        self.icon = Image(uiImage: UIImage(systemName: systemImage) ?? UIImage())
    }
}

@available(iOS 14.0, *)
extension Label: Renderable {
    public func updateView(_ view: UIView, context: Context) {}
    
    public func createView(context: Context) -> UIView {
        let hStack = HStack {
            if style != .TitleOnlyLabelStyle {
                self.icon
            }
            if style != .IconOnlyLabelStyle {
                self.title
            }
        }
        return hStack.createView(context: context)
    }
}

