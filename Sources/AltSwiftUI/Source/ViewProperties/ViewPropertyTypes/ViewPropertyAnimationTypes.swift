//
//  ViewPropertyAnimationTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

/// A type that describes properties of an animation
public struct Animation {
    static let defaultDuration: Double = 0.25
    enum Curve: Hashable {
        case easeInOut(duration: Double)
        case easeIn(duration: Double)
        case easeOut(duration: Double)
        case linear(duration: Double)
        case spring(response: Double, dampingFraction: Double, blendDuration: Double)
    }
    let curve: Curve
    var delay: Double = 0
    var repeatCount: (count: Int?, autoReverse: Bool)? = nil
}

extension Animation {
    func performAnimation(_ animationCode: @escaping () -> Void, completion: (() -> Void)? = nil) {
            switch curve {
            case .easeInOut(let duration):
                performCurveAnimation(duration: duration, options: .curveEaseInOut, animationCode: animationCode, completion: completion)
            case .easeIn(let duration):
                performCurveAnimation(duration: duration, options: .curveEaseIn, animationCode: animationCode, completion: completion)
            case .easeOut(let duration):
                performCurveAnimation(duration: duration, options: .curveEaseOut, animationCode: animationCode, completion: completion)
            case .linear(let duration):
                performCurveAnimation(duration: duration, options: .curveLinear, animationCode: animationCode, completion: completion)
            case .spring(let response, let dampingFraction, _):
                let timingCurve = sprintTimingParameter(dampingRatio: CGFloat(dampingFraction), response: CGFloat(response))
                let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingCurve)
                animator.addAnimations {
                    animationCode()
                }
                if let completion = completion {
                    animator.addCompletion { _ in
                        completion()
                    }
                }
                if delay != 0 {
                    animator.startAnimation(afterDelay: delay)
                } else {
                    animator.startAnimation()
                }
            }
    }
    private func performCurveAnimation(duration: Double, options: UIView.AnimationOptions, animationCode: @escaping () -> Void, completion: (() -> Void)?) {
        var animationOptions = options
        var numberOfRepetitions: Int? = nil
        if let repeatCount = repeatCount {
            if repeatCount.autoReverse {
                animationOptions.insert(.autoreverse)
            }
            animationOptions.insert(.repeat)
            numberOfRepetitions = repeatCount.count
        }
        UIView.animate(withDuration: duration, delay: delay, options: animationOptions, animations: {
            if let numberOfRepetitions = numberOfRepetitions {
                UIView.setAnimationRepeatCount(Float(numberOfRepetitions))
            }
            animationCode()
        }, completion: { _ in
            completion?()
        })
    }
    private func sprintTimingParameter(dampingRatio: CGFloat, response: CGFloat) -> UISpringTimingParameters {
        let mass: CGFloat = 1
        let stiffness = pow(2 * .pi / response, 2)
        let damping = 4 * .pi * dampingRatio * mass / response
        return UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: .zero)
    }
}

extension Animation: Hashable {
    public static func == (lhs: Animation, rhs: Animation) -> Bool {
        lhs.curve == rhs.curve &&
            lhs.delay == rhs.delay &&
            lhs.repeatCount?.count == rhs.repeatCount?.count &&
            lhs.repeatCount?.autoReverse == rhs.repeatCount?.autoReverse
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(curve)
        hasher.combine(delay)
        hasher.combine(repeatCount?.count)
        hasher.combine(repeatCount?.autoReverse)
    }
}

extension Animation {

    /// A spring animation.
    ///
    /// - Parameters:
    ///   - response: The stiffness of the spring, defined as an
    ///     approximate duration in seconds. A value of zero requests
    ///     an infinitely-stiff spring, suitable for driving
    ///     interactive animations.
    ///   - dampingFraction: The amount of drag applied to the value
    ///     being animated. Use a value of 1 for no bouncing.
    /// - Returns: a spring animation.
    public static func spring(response: Double = 0.55, dampingFraction: Double = 0.825) -> Animation {
        Animation(curve: .spring(response: response, dampingFraction: dampingFraction, blendDuration: 0))
    }

    /// A convenience for a `spring()` animation with a lower
    /// `response` value, intended for driving interactive animations.
    public static func interactiveSpring(response: Double = 0.15, dampingFraction: Double = 0.86) -> Animation {
        spring(response: response, dampingFraction: dampingFraction)
    }
}

extension Animation {

    /// The default animation of the system.
    public static let `default`: Animation = Animation.easeInOut
}

extension Animation {

    /// Returns an Ease in out animation with the specified duration.
    public static func easeInOut(duration: Double) -> Animation {
        Animation(curve: .easeInOut(duration: duration))
    }

    /// Returns an Ease in out animation.
    public static var easeInOut: Animation {
        Animation(curve: .easeInOut(duration: Self.defaultDuration))
    }

    /// Returns an Ease in animation with the specified duration.
    public static func easeIn(duration: Double) -> Animation {
        Animation(curve: .easeIn(duration: duration))
    }

    /// Returns an Ease in animation.
    public static var easeIn: Animation {
        Animation(curve: .easeIn(duration: Self.defaultDuration))
    }

    /// Returns an Ease out animation with the specified duration.
    public static func easeOut(duration: Double) -> Animation {
        Animation(curve: .easeOut(duration: duration))
    }

    /// Returns an Ease out animation.
    public static var easeOut: Animation {
        Animation(curve: .easeOut(duration: Self.defaultDuration))
    }

    /// Returns a linear animation with the specified duration.
    public static func linear(duration: Double) -> Animation {
        Animation(curve: .linear(duration: duration))
    }

    /// Returns a linear animation.
    public static var linear: Animation {
        Animation(curve: .linear(duration: Self.defaultDuration))
    }
}

extension Animation {
    /// Returns a modified version of the animation with the
    /// specified delay.
    public func delay(_ delay: Double) -> Animation {
        var animation = self
        animation.delay = delay
        return animation
    }
    
    /// Returns a modified version of the animation with the
    /// specified repeat count.
    public func repeatCount(_ repeatCount: Int, autoreverses: Bool = true) -> Animation {
        var animation = self
        animation.repeatCount = (repeatCount, autoreverses)
        return animation
    }

    /// Returns a modified version of the animation with the
    /// specified value of `repeatForever`.
    public func repeatForever(autoreverses: Bool = true) -> Animation {
        var animation = self
        animation.repeatCount = (nil, autoreverses)
        return animation
    }
}
