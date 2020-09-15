//
//  ViewPropertyGestureTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

/// This protocol represents a stream of actions that will be performed
/// based on the implemented gesture.
public protocol Gesture {
    associatedtype Value
    associatedtype Body: Gesture
    
    /// Storage for onChanged events
    var onChanged: ((Self.Value) -> Void)? { get set }
    
    /// Storage for onChanged events
    var onEnded: ((Self.Value) -> Void)? { get set }
    
    /// Returns the concrete gesture that this gesture represents
    var body: Self.Body { get }
}

extension Gesture {
    /// Event that fires when the value of an active gesture changes
    public func onChanged(_ action: @escaping (Self.Value) -> Void) -> Self {
        var gesture = self
        gesture.onChanged = action
        return gesture
    }
    
    /// Event that fires when an active gesture ends
    public func onEnded(_ action: @escaping (Self.Value) -> Void) -> Self {
        var gesture = self
        gesture.onEnded = action
        return gesture
    }
    
    internal func firstExecutableGesture(level: Int = 0) -> ExecutableGesture? {
        if level == 2 {
            // Gestures that don't contain executable gesture won't be
            // counted as valid executable gestures
            return nil
        }
        
        if let executableGesture = self as? ExecutableGesture {
            return executableGesture
        } else {
            return body.firstExecutableGesture(level: level + 1)
        }
    }
}

/// This type will handle events of a user's tap gesture.
public struct TapGesture: Gesture, ExecutableGesture {
    var priority: GesturePriority = .default
    public var onChanged: ((Self.Value) -> Void)?
    public var onEnded: ((Self.Value) -> Void)?
    
    public init() {
        self.onChanged = nil
        self.onEnded = nil
    }
    
    public var body: TapGesture {
        TapGesture()
    }
    
    // MARK: ExecutableGesture
    
    func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        gesture.cancelsTouchesInView = false
        return gesture
    }
    func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder) {
        onEnded?(())
    }
    
    public typealias Value = Void
}

/// This type will handle events of a user's drag gesture.
public struct DragGesture: Gesture, ExecutableGesture {
    public struct Value : Equatable {

        /// The location of the current event.
        public var location: CGPoint
        
        /// The location of the first event.
        public var startLocation: CGPoint

        /// The total translation from the first event to the current
        /// event. Equivalent to `location.{x,y} -
        /// startLocation.{x,y}`.
        public var translation: CGSize
    }
    
    var priority: GesturePriority = .default
    public var onChanged: ((Self.Value) -> Void)?
    public var onEnded: ((Self.Value) -> Void)?
    
    public init() {
        self.onChanged = nil
        self.onEnded = nil
    }
    
    public var body: DragGesture {
        DragGesture()
    }
    
    // MARK: ExecutableGesture
    
    func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer {
        UIPanGestureRecognizer(target: target, action: action)
    }
    
    func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder) {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return }
        let translation = panGesture.translation(in: panGesture.view)
        let location = panGesture.location(in: panGesture.view)
        let value = Value(location: location, startLocation: holder.firstLocation, translation: CGSize(width: translation.x, height: translation.y))
        switch panGesture.state {
        case .began:
            holder.firstLocation = location
        case .changed:
            withHighPerformance {
                self.onChanged?(value)
            }
        case .ended:
            onEnded?(value)
        case .cancelled:
            onEnded?(value)
        default: break
        }
    }
}

// MARK: - Internal Types

enum GesturePriority {
    case `default`, high, simultaneous
}

protocol ExecutableGesture {
    var priority: GesturePriority { get set }
    func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer
    func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder)
}

class GestureHolder: NSObject {
    var gesture: ExecutableGesture
    var isSimultaneous = false
    var firstLocation: CGPoint = .zero
    
    init(gesture: ExecutableGesture) {
        self.gesture = gesture
    }
    
    @objc func processGesture(gestureRecognizer: UIGestureRecognizer) {
        gesture.processGesture(gestureRecognizer: gestureRecognizer, holder: self)
    }
}

extension GestureHolder: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        isSimultaneous
    }
}

class GestureHolders: NSObject {
    var gestures: [GestureHolder]
    init(gestures: [GestureHolder]) {
        self.gestures = gestures
    }
}
