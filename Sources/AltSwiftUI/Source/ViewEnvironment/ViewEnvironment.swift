//
//  Environment.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Environment

/// Main container for global environment properties
enum EnvironmentHolder {
    static var currentBodyViewBinderStack: [ViewBinder] = []
    static var environmentObjects: [String: ObservableObject] = [:]
    static var globalAnimation: Animation?
    static var coordinateSpaceNames = [String: WeakObject<UIView>]()
    static var highPerformanceMode: Bool = false
    static var notifyStateChanges = true
    
    static var notificationUserInfo: [AnyHashable: Any] {
        var transaction = Transaction()
        if let animation = Self.globalAnimation {
            transaction.animation = animation
        }
        if Self.highPerformanceMode {
            transaction.isHighPerformance = true
        }
        return [ViewBinder.StateNotification.transactionKey: transaction]
    }
}

/// Contains the Environment values set by the framework.
public struct EnvironmentValues {
    weak var rootController: ScreenViewController?
    
    public var presentationMode: Binding<PresentationMode> {
        Binding(get: {
            PresentationMode(controller: self.rootController, isPresented: self.rootController?.presentingViewController != nil)
        }, set: { _ in })
    }
}

// MARK: - Context

/// Contains merged view values and contextual information while traversing
/// a view hierarchy.
public struct Context {
    // When you add new properties, be sure to add them to `merge` methods
    // to transfer context information when merging contexts.
    
    var viewValues: ViewValues?
    weak var rootController: ScreenViewController?
    // Currently used for Tab controller
    weak var overwriteRootController: UIViewController?
    var transaction: Transaction?
    var viewOperationQueue = ViewOperationQueue()
    var postRenderOperationQueue = ViewOperationQueue()
    
    /// True when the current view context is inside a button. Use this
    /// to handle special View behavior when inside buttons.
    var isInsideButton = false
    
    /// Normally used when handling context without animation.
    var withoutTransaction: Context {
        var newContext = self
        newContext.transaction = nil
        return newContext
    }
    
    var shouldSkipUpdate: Bool {
        transaction?.isHighPerformance == true && viewValues?.skipOnHighPerformance == true
    }
    var isStrictUpdate: Bool {
        transaction?.isHighPerformance == true && viewValues?.strictOnHighPerformance == true
    }
}

extension Context {
    /// Merges values that can be inherited and takes priority from `viewValues`.
    func merge(viewValues: ViewValues?) -> Context {
        if let viewValues = viewValues {
            return Context(viewValues: viewValues.merge(defaultValues: self.viewValues), rootController: rootController, overwriteRootController: overwriteRootController, transaction: transaction, viewOperationQueue: viewOperationQueue, postRenderOperationQueue: postRenderOperationQueue, isInsideButton: isInsideButton)
        } else {
            return self
        }
    }
    
    /// Merges all values and takes priority from `viewValues`.
    func completeMerge(viewValues: ViewValues?) -> Context {
        if let viewValues = viewValues {
            return Context(viewValues: viewValues.completeMerge(defaultValues: self.viewValues), rootController: rootController, overwriteRootController: overwriteRootController, transaction: transaction, viewOperationQueue: viewOperationQueue, postRenderOperationQueue: postRenderOperationQueue, isInsideButton: isInsideButton)
        } else {
            return self
        }
    }
}

class ViewOperation {
    let operation: () -> Void
    let viewBinder: ViewBinder?
    
    init(_ operation: @escaping () -> Void) {
        self.operation = operation
        self.viewBinder = EnvironmentHolder.currentBodyViewBinderStack.last
    }
}

/// A queue for storing operations to be done while traversing a view hierarchy.
class ViewOperationQueue {
    private var operations: [ViewOperation] = []
    
    func addOperation(_ operation: @escaping () -> Void) {
        operations.append(ViewOperation(operation))
    }
    
    // Executes all queued operations. If any operation adds more
    // operations, traversing follows a Breadth First Search approach.
    func drainRecursively() {
        while !operations.isEmpty {
           let operationsCopy = operations
           operations.removeAll()
           for operation in operationsCopy {
                if let viewBinder = operation.viewBinder {
                    EnvironmentHolder.currentBodyViewBinderStack.append(viewBinder)
                    operation.operation()
                    EnvironmentHolder.currentBodyViewBinderStack.removeLast()
                } else {
                    operation.operation()
                }
           }
        }
    }
}

/// Contains originating attributes of a view update transaction
public struct Transaction {
    class OverwriteAnimationParentContainer {
        weak var view: UIView?
    }
    
    init() {
        animation = nil
    }
    public init(animation: Animation?) {
        self.animation = animation
    }
    var animation: Animation?

    var disablesAnimations: Bool = false
    
    var isHighPerformance: Bool = false
    
    /// When the animation in this transaction takes priority over other transactions.
    /// Usually when animating with `View.animation()`.
    var overwriteAnimationParent: OverwriteAnimationParentContainer?
    
    /// Returns the animation in the transaction if
    /// animations are not disabled.
    var animationInContext: Animation? {
        disablesAnimations ? nil : animation
    }
}

extension Transaction: Hashable {
    public static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.disablesAnimations == rhs.disablesAnimations &&
            lhs.animation == rhs.animation
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(animation)
        hasher.combine(disablesAnimations)
    }
}
