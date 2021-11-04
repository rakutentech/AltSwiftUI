//
//  LazyVStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/11/04.
//

import UIKit

/// Arranges subviews vertically. If inside a `ScrollView`, subviews will be
/// lazy loaded.
///
/// __Important__: There should only be one `LazyVStack` per `ScrollView`.
/// If there are more than one, only the first one will be lazy loaded.
///
/// This view expands its width dimension by default.
///
/// It's not recommended to use this view outside a `ScrollView` as there is no
/// lazy loading benefit and there will be some extra overhead as compared to using a
/// `VStack`.
public struct LazyVStack: LazyStack {
    public var viewStore = ViewValues()
    
    let viewContentBuilder: () -> View
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    var noPropertiesStack: Stack
    
    public var body: View {
        EmptyView()
    }
    var scrollAxis: Axis { .vertical }
    var stackAxis: NSLayoutConstraint.Axis { .vertical }
    
    /// Creates an instance of a view that arranges subviews vertically. If inside
    /// a `ScrollView`, subviews will be lazy loaded.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment guide for its children. Defaults to `center`.
    ///   - spacing: The vertical distance between subviews. If not specified,
    ///   the distance will be 0.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> View) {
        noPropertiesStack = VStack(alignment: alignment, spacing: spacing, content: content)
        viewContentBuilder = content
        self.alignment = alignment
        self.spacing = spacing ?? 0
        viewStore.direction = .vertical
    }
    
    func updateStackAlignment(stack: SwiftUILazyStackView) {
        stack.setStackAlignment(alignment: alignment)
    }
}
