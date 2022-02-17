//
//  AutolayoutExtensions.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/03/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

protocol AutolayoutHelperProtocol {}
extension UIView: AutolayoutHelperProtocol {}

extension AutolayoutHelperProtocol where Self: UIView {
    /**
     Build an instance without auto sizing transtation
     */
    static func noAutoSizingInstance() -> Self {
        let view = Self()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    /**
     Build an instance without auto sizing transtation and add it to the caller's subviews
     */
    func generateSubview<U: UIView>() -> U {
        let view = U.noAutoSizingInstance()
        self.addSubview(view)
        return view
    }
}

extension Array where Element: NSLayoutConstraint {
    /**
     Activates all layout constraints inside the array.
     */
    @discardableResult func activate() -> Array {
        forEach { $0.isActive = true }
        return self
    }
}

extension UIView {
    /**
     Enum that defines the index of layout constraints returned
     by edgesAnchor functions.
     */
    enum EdgeAnchorIndex: Int {
        case left = 0, right, top, bottom
    }

    /**
     Creates layout constrains for snapping the view to the provided superview

     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func edgesAnchorEqualTo(destinationView: UIView) -> [NSLayoutConstraint] {
        [leftAnchor.constraint(equalTo: destinationView.leftAnchor),
                rightAnchor.constraint(equalTo: destinationView.rightAnchor),
                topAnchor.constraint(equalTo: destinationView.topAnchor),
                bottomAnchor.constraint(equalTo: destinationView.bottomAnchor)]
    }

    /**
     Creates layout constrains for all 4 edges of a view,
     and makes it match to the provided view.
     
     - return: An array with 4 constraints. The indexes are
     defined by the `EdgeAnchorIndex` enum.
     
     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func edgesAnchorEqualTo(destinationView: UIView, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        [leftAnchor.constraint(equalTo: destinationView.leftAnchor, constant: insets.left),
                rightAnchor.constraint(equalTo: destinationView.rightAnchor, constant: -insets.right),
                topAnchor.constraint(equalTo: destinationView.topAnchor, constant: insets.top),
                bottomAnchor.constraint(equalTo: destinationView.bottomAnchor, constant: -insets.bottom)]
    }
    
    /**
     Creates layout constrains for all 4 edges of a view,
     and makes it match to the provided layout guide.
     
     - return: An array with 4 constraints. The indexes are
     defined by the `EdgeAnchorIndex` enum.
     
     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func edgesAnchorEqualTo(layoutGuide: UILayoutGuide, insets: UIEdgeInsets? = nil) -> [NSLayoutConstraint] {
        [leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: insets?.left ?? 0),
                rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -(insets?.right ?? 0)),
                topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets?.top ?? 0),
                bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -(insets?.bottom ?? 0))]
    }

    /**
      Snap the edge of the receiver to the view containing it

     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func edgesAnchorEqualTo(destinationView view: UIView, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let top = top {
            constraints.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: top))
        }
        if let bottom = bottom {
            constraints.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom))
        }
        if let left = left {
            constraints.append(self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left))
        }
        if let right = right {
            constraints.append(self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -right))
        }
        return constraints
    }

    /**
     Snap the edge of the receiver to the view containing it

     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func edgesAnchorEqualTo(destinationView view: UIView, verticalPadding: CGFloat? = nil, horizontalPadding: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let verticalPadding = verticalPadding {
            constraints.append(self.topAnchor.constraint(equalTo: view.topAnchor, constant: verticalPadding))
            constraints.append(self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -verticalPadding))
        }
        if let horizontalPadding = horizontalPadding {
            constraints.append(self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: horizontalPadding))
            constraints.append(self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -horizontalPadding))
        }
        return constraints
    }

    /**
     Size the receiver with given width and/or height

     - Important: Constraints are not activated. You need
     to activate them for them to take effect.
     */
    func sizing(width: CGFloat? = nil, height: CGFloat? = nil) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let width = width {
            constraints.append(self.widthAnchor.constraint(equalToConstant: width))
        }
        if let height = height {
            constraints.append(self.heightAnchor.constraint(equalToConstant: height))
        }
        return constraints
    }
    
    /**
     Returns the safe area bottom anchor.
     If not available, returns the bottom anchor.
    */
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }
    
    /**
     Returns the safe area top anchor.
     If not available, returns the top anchor.
     */
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
    
    /**
     Returns an instance of `Self` with auto resizing
     masks turned off.
    */
    func noAutoresizingMask() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    /**
     Create constraints for edges to be inside the destination
     `view` and be able to expand until it hits the edge on all
     sides.
     Optionally specify if you want edges to constraint to safe
     anchors.
    */
    func edgesGreaterOrEqualTo(view: UIView, safeLeft: Bool = true, safeTop: Bool = true, safeRight: Bool = true, safeBottom: Bool = true, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        [topAnchor.constraint(greaterThanOrEqualTo: safeTop ? view.safeTopAnchor : view.topAnchor).withPriority(priority),
         leftAnchor.constraint(greaterThanOrEqualTo: safeLeft ? view.safeAreaLayoutGuide.leftAnchor : view.leftAnchor).withPriority(priority),
         bottomAnchor.constraint(lessThanOrEqualTo: safeBottom ? view.safeBottomAnchor : view.bottomAnchor).withPriority(priority),
         rightAnchor.constraint(lessThanOrEqualTo: safeRight ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor).withPriority(priority)]
    }
    
    /**
     Creates layout constrains for all 4 edges of a `view`,
     and makes it match to the provided view.
     Optionally specify if you want edges to constraint to safe
     anchors.
     */
    func edgesAnchorEqualTo(view: UIView, safeLeft: Bool = false, safeTop: Bool = false, safeRight: Bool = false, safeBottom: Bool = false) -> [NSLayoutConstraint] {
        [topAnchor.constraint(equalTo: safeTop ? view.safeTopAnchor : view.topAnchor),
         leftAnchor.constraint(equalTo: safeLeft ? view.safeAreaLayoutGuide.leftAnchor : view.leftAnchor),
         bottomAnchor.constraint(equalTo: safeBottom ? view.safeBottomAnchor : view.bottomAnchor),
         rightAnchor.constraint(equalTo: safeRight ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor)]
    }
    
    func edgesAnchorEqualTo(
        view: UIView,
        safeLeft: Bool = false,
        safeTop: Bool = false,
        safeRight: Bool = false,
        safeBottom: Bool = false,
        leftPriority: UILayoutPriority = .required,
        topPriority: UILayoutPriority = .required,
        rightPriority: UILayoutPriority = .required,
        bottomPriority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        [topAnchor.constraint(equalTo: safeTop ? view.safeTopAnchor : view.topAnchor).withPriority(topPriority),
         leftAnchor.constraint(equalTo: safeLeft ? view.safeAreaLayoutGuide.leftAnchor : view.leftAnchor).withPriority(leftPriority),
         bottomAnchor.constraint(equalTo: safeBottom ? view.safeBottomAnchor : view.bottomAnchor).withPriority(bottomPriority),
         rightAnchor.constraint(equalTo: safeRight ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor).withPriority(rightPriority)]
    }
    
    func leftAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        leftAnchor.constraint(equalTo: !safe ? view.leftAnchor : view.safeAreaLayoutGuide.leftAnchor)
    }
    func rightAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        rightAnchor.constraint(equalTo: !safe ? view.rightAnchor : view.safeAreaLayoutGuide.rightAnchor)
    }
    func topAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        topAnchor.constraint(equalTo: !safe ? view.topAnchor : view.safeAreaLayoutGuide.topAnchor)
    }
    func bottomAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        bottomAnchor.constraint(equalTo: !safe ? view.bottomAnchor : view.safeAreaLayoutGuide.bottomAnchor)
    }
    func centerXAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        centerXAnchor.constraint(equalTo: !safe ? view.centerXAnchor : view.safeAreaLayoutGuide.centerXAnchor)
    }
    func centerYAnchorEquals(_ view: UIView, safe: Bool = false) -> NSLayoutConstraint {
        centerYAnchor.constraint(equalTo: !safe ? view.centerYAnchor : view.safeAreaLayoutGuide.centerYAnchor)
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
    /**
     Assign the priority to the constraint and return the caller
     */
    func withPriority(_ priority: Float) -> NSLayoutConstraint {

        self.priority = UILayoutPriority(priority)
        return self
    }

    /**
     Set priority to 999 to avoid auto layout conflict
    */
    func withPriorityFix() -> NSLayoutConstraint {
        self.withPriority(999)
    }
}
