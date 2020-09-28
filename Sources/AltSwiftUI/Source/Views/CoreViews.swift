//
//  CoreViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Renderable Views

/// An empty view with no content.
public struct EmptyView: View {
    public var viewStore = ViewValues()
    public var body: View {
        self
    }
    public init() {}
}

extension EmptyView: Renderable {
    public func updateView(_ view: UIView, context: Context) {
    }
    
    public func createView(context: Context) -> UIView {
        UIView().noAutoresizingMask()
    }
}

/// A view that adds padding to another view.
public struct PaddingView: View, Equatable {
    public static func == (lhs: PaddingView, rhs: PaddingView) -> Bool {
        if let lContent = lhs.contentView as? PaddingView, let rContent = rhs.contentView as? PaddingView {
            return lContent == rContent
        } else {
            return type(of: lhs.contentView) == type(of: rhs.contentView)
        }
    }
    
    public var viewStore = ViewValues()
    public var body: View {
        EmptyView()
    }
    var contentView: View
    var padding: CGFloat?
    var paddingInsets: EdgeInsets?
}

extension PaddingView: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIPaddingView().noAutoresizingMask()
        
        context.viewOperationQueue.addOperation {
            guard let renderedContentView = self.contentView.renderableView(parentContext: context, drainRenderQueue: false) else { return }
            view.content = renderedContentView
            self.setupView(view, context: context)
        }
        
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIPaddingView else { return }
        if let content = view.content {
            context.viewOperationQueue.addOperation {
                self.contentView.updateRender(uiView: content, parentContext: context, drainRenderQueue: false)
                self.setupView(view, context: context)
            }
        }
    }
    
    private func setupView(_ view: SwiftUIPaddingView, context: Context) {
        if let paddingInsets = paddingInsets {
            view.insets = UIEdgeInsets.withEdgeInsets(paddingInsets)
        } else if let padding = padding {
            view.insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
    }
}

// MARK: - Builder Views

public struct OptionalView: View {
    public var viewStore = ViewValues()
    public var body: View {
        EmptyView()
    }
    let content: [View]?
}

public struct TupleView: View, ViewGrouper {
    public var viewStore = ViewValues()
    var viewContent: [View]
    
    public init(_ values: [View]) {
        viewContent = values
    }
    
    public var body: View {
        EmptyView()
    }
}
