//
//  ViewPropertyInteractionTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

public enum GesturePriority {
    case `default`, high, simultaneous
}

public protocol Gesture: ExecutableGesture {
    var onChanged: ((Self.Value) -> Void)? { get set }
    var onEnded: ((Self.Value) -> Void)? { get set }
    associatedtype Value
}

extension Gesture {
    public func onChanged(_ action: @escaping (Self.Value) -> Void) -> Self {
        var gesture = self
        gesture.onChanged = action
        return gesture
    }
    public func onEnded(_ action: @escaping (Self.Value) -> Void) -> Self {
        var gesture = self
        gesture.onEnded = action
        return gesture
    }
}

public struct TapGesture: Gesture {
    public var priority: GesturePriority = .default
    public var onChanged: ((Self.Value) -> Void)?
    public var onEnded: ((Self.Value) -> Void)?
    
    public init() {
        self.onChanged = nil
        self.onEnded = nil
    }
    public func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        gesture.cancelsTouchesInView = false
        return gesture
    }
    public func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder) {
        onEnded?(())
    }
    
    public typealias Value = Void
}

public struct DragGesture: Gesture {
    public var priority: GesturePriority = .default
    public var onChanged: ((Self.Value) -> Void)?
    public var onEnded: ((Self.Value) -> Void)?
    
    public init() {
        self.onChanged = nil
        self.onEnded = nil
    }
    
    public func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer {
        UIPanGestureRecognizer(target: target, action: action)
    }
    public func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder) {
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
}

// MARK: - Utility

public protocol ExecutableGesture {
    var priority: GesturePriority { get set }
    func recognizer(target: Any?, action: Selector?) -> UIGestureRecognizer
    func processGesture(gestureRecognizer: UIGestureRecognizer, holder: GestureHolder)
}

public class GestureHolder: NSObject {
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
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        isSimultaneous
    }
}

// MARK: - Internal Types

class GestureHolders: NSObject {
    var gestures: [GestureHolder]
    init(gestures: [GestureHolder]) {
        self.gestures = gestures
    }
}
