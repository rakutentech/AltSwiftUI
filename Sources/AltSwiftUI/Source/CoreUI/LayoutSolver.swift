//
//  LayoutSolver.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// In charge of setting the correct layout constraints for a `View` configuration.
class LayoutSolver {
    static func solveLayout(parentView: UIView, contentView: UIView, content: View, expand: Bool = false, alignment: Alignment = .center, context: Context) {
        var safeTop = true
        var safeLeft = true
        var safeRight = true
        var safeBottom = true
        let edges = content.viewStore.edgesIgnoringSafeArea ?? contentView.lastRenderableView?.view.viewStore.edgesIgnoringSafeArea
        let rootView = edges != nil
        if let ignoringEdges = edges {
            if ignoringEdges.contains(.top) {
                safeTop = false
            }
            if ignoringEdges.contains(.leading) {
                safeLeft = false
            }
            if ignoringEdges.contains(.bottom) {
                safeBottom = false
            }
            if ignoringEdges.contains(.trailing) {
                safeRight = false
            }
        }
        
        let originalParentView = parentView
        var parentView = parentView
        var lazy = false
        if let contextController = context.rootController, rootView {
            parentView = contextController.view
            lazy = true
        }
        var constraints = [NSLayoutConstraint]()
        
        if expand {
            constraints = contentView.edgesAnchorEqualTo(view: parentView, safeLeft: safeLeft, safeTop: safeTop, safeRight: safeRight, safeBottom: safeBottom)
        } else {
            switch alignment {
            case .center:
                if safeLeft && safeRight {
                    constraints.append(contentsOf: [contentView.centerXAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerXAnchor)])
                } else if !rootView {
                    constraints.append(contentsOf: [contentView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)])
                }
                if safeTop && safeBottom {
                    constraints.append(contentsOf: [contentView.centerYAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerYAnchor)])
                } else if !rootView {
                    constraints.append(contentsOf: [contentView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)])
                }
            case .leading:
                constraints = [contentView.leftAnchorEquals(parentView, safe: safeLeft),
                 contentView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)]
            case .trailing:
                constraints = [contentView.rightAnchorEquals(parentView, safe: safeRight),
                 contentView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)]
            case .top:
                constraints = [contentView.topAnchorEquals(parentView, safe: safeTop),
                contentView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)]
            case .bottom:
                constraints = [contentView.bottomAnchorEquals(parentView, safe: safeBottom),
                contentView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)]
            case .bottomLeading:
                constraints = [contentView.bottomAnchorEquals(parentView, safe: safeBottom),
                contentView.leftAnchorEquals(parentView, safe: safeLeft)]
            case .bottomTrailing:
                constraints = [contentView.bottomAnchorEquals(parentView, safe: safeBottom),
                contentView.rightAnchorEquals(parentView, safe: safeRight)]
            case .topLeading:
                constraints = [contentView.topAnchorEquals(parentView, safe: safeTop),
                contentView.leftAnchorEquals(parentView, safe: safeLeft)]
            case .topTrailing:
                constraints = [contentView.topAnchorEquals(parentView, safe: safeTop),
                contentView.rightAnchorEquals(parentView, safe: safeRight)]
            default: break
            }
            
            if rootView {
                if !safeTop {
                    constraints.append(contentView.topAnchor.constraint(equalTo: parentView.topAnchor))
                }
                if !safeBottom {
                    constraints.append(contentView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor))
                }
                if !safeLeft {
                    constraints.append(contentView.leftAnchor.constraint(equalTo: parentView.leftAnchor))
                }
                if !safeRight {
                    constraints.append(contentView.rightAnchor.constraint(equalTo: parentView.rightAnchor))
                }
            }
            constraints.append(contentsOf: contentView.edgesGreaterOrEqualTo(view: parentView, safeLeft: safeLeft, safeTop: safeTop, safeRight: safeRight, safeBottom: safeBottom))
            if rootView && parentView != originalParentView {
                constraints.append(contentsOf: contentView.edgesGreaterOrEqualTo(view: originalParentView, safeLeft: safeLeft, safeTop: safeTop, safeRight: safeRight, safeBottom: safeBottom, priority: .defaultHigh))
            }
        }
        
        if !lazy {
            constraints.activate()
        } else if let controller = context.rootController {
            controller.lazyLayoutConstraints.append(contentsOf: constraints)
        }
    }
}
