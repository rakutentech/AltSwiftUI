//
//  ZStack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// This view arranges subviews one in front of the other, using the _z_ axis.
public struct ZStack: View {
    public var viewStore = ViewValues()
    let viewContent: [View]
    let alignment: Alignment
    
    /// Creates an instance of a view that arranges subviews horizontally.
    ///
    /// - Parameters:
    ///   - alignment: The alignment guide for its children. Defaults to `center`.
    ///   - content: A view builder that creates the content of this stack. The
    ///     last view will be the topmost view.
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> View) {
        viewContent = content().subViews
        self.alignment = alignment
    }
    
    public var body: View {
        self
    }
}

extension ZStack: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIView().noAutoresizingMask()
        
        context.viewOperationQueue.addOperation {
            self.viewContent.iterateFullViewInsert { subView in
                if let renderView = subView.renderableView(parentContext: context, drainRenderQueue: false) {
                    view.addSubview(renderView)
                    LayoutSolver.solveLayout(parentView: view, contentView: renderView, content: subView, parentContext: context, alignment: self.alignment)
                }
            }
        }
        
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let oldZStack = view.lastRenderableView?.view as? Self {
            context.viewOperationQueue.addOperation {
                var indexSkip = 0
                self.viewContent.iterateFullViewDiff(oldList: oldZStack.viewContent) { i, operation in
                    let index = i + indexSkip
                    switch operation {
                    case .insert(let suiView):
                        if let subView = suiView.renderableView(parentContext: context, drainRenderQueue: false) {
                            view.insertSubview(subView, at: index)
                            LayoutSolver.solveLayout(parentView: view, contentView: subView, content: suiView, parentContext: context, alignment: self.alignment)
                            suiView.performInsertTransition(view: subView, animation: context.transaction?.animation) {}
                        }
                    case .delete(let suiView):
                        guard let subViewData = view.firstNonRemovingSubview(index: index) else {
                            break
                        }
                        
                        indexSkip += subViewData.skippedSubViews
                        let subView = subViewData.uiView
                        subView.isAnimatingRemoval = true
                        if suiView.performRemovalTransition(view: subView, animation: context.transaction?.animation, completion: {
                            subView.removeFromSuperview()
                        }) {
                            indexSkip -= 1
                        }
                    case .update(let suiView):
                        guard let subViewData = view.firstNonRemovingSubview(index: index) else {
                            break
                        }
                        
                        indexSkip += subViewData.skippedSubViews
                        let subView = subViewData.uiView
                        suiView.updateRender(uiView: subView, parentContext: context, drainRenderQueue: false)
                    }
                }
            }
        }
    }
}
