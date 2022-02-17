//
//  LazyHStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/11/04.
//

import UIKit

/// Arranges subviews horizontally. If inside a `ScrollView`, subviews will be
/// lazy loaded.
///
/// __Important__: There should only be one `LazyHStack` per `ScrollView`.
/// If there are more than one, only the first one will be lazy loaded.
///
/// This view expands its width dimension by default.
///
/// It's not recommended to use this view outside a `ScrollView` as there is no
/// lazy loading benefit and there will be some extra overhead as compared to using a
/// `HStack`.
public struct LazyHStack: LazyStack, View {
    public var viewStore = ViewValues()
    
    let viewContentBuilder: () -> View
    let alignment: VerticalAlignment
    let spacing: CGFloat
    var noPropertiesStack: Stack
    
    public var body: View {
        EmptyView()
    }
    var scrollAxis: Axis { .horizontal }
    var stackAxis: NSLayoutConstraint.Axis { .horizontal }
    
    /// Creates an instance of a view that arranges subviews horizontally. If inside
    /// a `ScrollView`, subviews will be lazy loaded.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment guide for its children. Defaults to `center`.
    ///   - spacing: The vertical distance between subviews. If not specified,
    ///   the distance will be 0.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> View) {
        noPropertiesStack = HStack(alignment: alignment, spacing: spacing, content: content)
        viewContentBuilder = content
        self.alignment = alignment
        self.spacing = spacing ?? 0
        viewStore.direction = .horizontal
    }
    
    func updateStackAlignment(stack: SwiftUILazyStackView) {
        stack.setStackAlignment(alignment: alignment)
    }
}
