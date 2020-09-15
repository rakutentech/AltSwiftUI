//
//  ViewPropertyTransitionTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

/// A type that represents a transition used by a view
/// when being added or removed from a hierarchy.
public struct AnyTransition {
    struct InternalTransition {
        var transform: CGAffineTransform?
        var opacity: CGFloat?
        var animation: Animation?
        var replaceTransform: Bool = false
        
        func combining(_ transition: InternalTransition) -> InternalTransition {
            var base = self
            if let newTransform = transition.transform {
                base.transform = transform?.concatenating(newTransform) ?? newTransform
            }
            if let newOpacity = transition.opacity {
                base.opacity = newOpacity
            }
            if let newAnimation = transition.animation {
                base.animation = newAnimation
            }
            return base
        }
        
        func performTransition(view: UIView) {
            if let opacity = opacity {
                view.alpha = opacity
            }
            if let transform = transform {
                setViewTransform(view: view, transform: transform)
            }
        }
        private func setViewTransform(view: UIView, transform: CGAffineTransform) {
            if replaceTransform {
                view.transform = transform
            } else {
                view.transform = view.transform.concatenating(transform)
            }
        }
    }
    var insertTransition: InternalTransition
    var removeTransition: InternalTransition?
    
    init(_ insertTransition: InternalTransition) {
        self.insertTransition = insertTransition
    }
    init(insert: InternalTransition, remove: InternalTransition) {
        self.insertTransition = insert
        self.removeTransition = remove
    }
    
    // MARK: Public methods
    
    /// Transitions from a specified offset
    public static func offset(_ offset: CGSize) -> AnyTransition {
        AnyTransition(InternalTransition(transform: CGAffineTransform(translationX: offset.width, y: offset.height)))
    }

    /// Transitions from a specified offset
    public static func offset(x: CGFloat = 0, y: CGFloat = 0) -> AnyTransition {
        AnyTransition(InternalTransition(transform: CGAffineTransform(translationX: x, y: y)))
    }
    
    /// Transitions by scaling from 0.01
    public static var scale: AnyTransition {
        AnyTransition(InternalTransition(transform: CGAffineTransform(scaleX: 0.01, y: 0.01)))
    }

    /// Transitions by scaling from the specified offset
    public static func scale(scale: CGFloat) -> AnyTransition {
        AnyTransition(InternalTransition(transform: CGAffineTransform(scaleX: scale, y: scale)))
    }
    
    /// A transition from transparent to opaque on insertion and opaque to
    /// transparent on removal.
    public static let opacity: AnyTransition = AnyTransition(InternalTransition(opacity: 0))
    
    /// A composite `Transition` that gives the result of two transitions both
    /// applied.
    public func combined(with other: AnyTransition) -> AnyTransition {
        var transition = self
        transition.insertTransition = transition.insertTransition.combining(other.insertTransition)
        if let newRemoveTransition = other.removeTransition {
            transition.removeTransition = transition.removeTransition?.combining(newRemoveTransition) ?? newRemoveTransition
        } else if let removeTransition = transition.removeTransition {
            transition.removeTransition = removeTransition.combining(other.insertTransition)
        }
        return transition
    }
    
    /// Attach an animation to this transition.
    public func animation(_ animation: Animation?) -> AnyTransition {
        var transition = self
        transition.insertTransition.animation = animation
        transition.removeTransition?.animation = animation
        return transition
    }
    
    /// A composite `Transition` that uses a different transition for
    /// insertion versus removal.
    public static func asymmetric(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition {
        AnyTransition(insert: insertion.insertTransition, remove: removal.insertTransition)
    }
    
    /// A transition that has no change in state.
    public static var identity: AnyTransition {
        AnyTransition(InternalTransition())
    }
}
