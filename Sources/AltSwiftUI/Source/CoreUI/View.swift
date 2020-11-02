//
//  View.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class RenderProperties {
    var skipRender = false
    var overrideRootController: UIViewController?
}

/// Views conforming to this protocol won't depend on the
/// `body` to render. Instead, the view will depend on
/// `createView` and `updateView`. For internal use in the
/// AltSwiftUI library.
public protocol Renderable {
    func createView(context: Context) -> UIView
    func updateView(_ view: UIView, context: Context)
}

class LastRenderableView {
    let view: View
    init(view: View) {
        self.view = view
    }
}

/// A type that represents a view.
public protocol View {
    var viewStore: ViewValues { get set }
    var body: View { get }
}

extension View {
    /// Updates the renderable representation of the view and all subviews
    /// in its hierarchy. Changes in view properties and in the context
    /// will be processed here.
    func updateRender(uiView: UIView, parentContext: Context, completeMerge: Bool = false, bodyLevel: Int = 0, drainRenderQueue: Bool = true) {
        var mergedContext = completeMerge ? parentContext.completeMerge(viewValues: viewStore) : parentContext.merge(viewValues: viewStore)
        
        if let renderableSelf = self as? Renderable {
            if !mergedContext.shouldSkipUpdate {
                if !mergedContext.isStrictUpdate {
                    
                    if mergedContext.viewValues?.animatedValues?.first?.animation != nil {
                        uiView.layoutIfNeeded()
                    }
                    
                    // Set animation originating from this view into the transaction
                    mergedContext = updatedAnimationContext(context: mergedContext, uiView: uiView)
                    
                    // Update view properties
                    renderableSelf.updateView(uiView, context: mergedContext)
                    uiView.setViewValues(mergedContext, update: true)
                    
                    // Execute sub render operations with Breadth First Search
                    if drainRenderQueue {
                        mergedContext.viewOperationQueue.drainRecursively()
                    }
                    
                    // Layout the hierarchy if this view generates an animation.
                    if mergedContext.transaction?.disablesAnimations == true {
                        uiView.layoutIfNeeded()
                    } else {
                        mergedContext.viewValues?.animatedValues?.first?.animation?.performAnimation {
                            uiView.layoutIfNeeded()
                        }
                    }
                } else {
                    uiView.setViewValues(mergedContext, update: true)
                }
            }
            var mergedView = self
            if let mergedViewValues = mergedContext.viewValues {
                mergedView.viewStore = mergedViewValues
            }
            uiView.lastRenderableView = LastRenderableView(view: mergedView)
        } else if let binder = uiView.viewBinder(index: bodyLevel) {
            // Store the context values into the view inside the binder,
            // for future atomic updates without the same context.
            let oldView = binder.view
            var updatedView = self
            updatedView.migrateState(fromView: oldView)
            if let mergedViewValues = mergedContext.viewValues {
                updatedView.viewStore = mergedViewValues
            }
            binder.view = updatedView
            binder.isInsideButton = mergedContext.isInsideButton
            binder.overwriteTransaction = overwriteTransaction(from: mergedContext.transaction)
            
            EnvironmentHolder.currentBodyViewBinderStack.append(binder)
            setupDynamicProperties(context: mergedContext)
            body.updateRender(uiView: uiView, parentContext: mergedContext, completeMerge: true, bodyLevel: bodyLevel + 1, drainRenderQueue: drainRenderQueue)
            EnvironmentHolder.currentBodyViewBinderStack.removeLast()
        }
    }
    
    /// Schedules a render update to be invoked in a flattened operation queue
    /// rather than instantly executing it to prevent stack overflows.
    func scheduleUpdateRender(uiView: UIView, parentContext: Context) {
        parentContext.viewOperationQueue.addOperation {
            self.updateRender(uiView: uiView, parentContext: parentContext, drainRenderQueue: false)
        }
    }
    
    /// Generates a `UIView` out of the view and it's subview hierarchy.
    func renderableView(parentContext: Context, completeMerge: Bool = false, bodyLevel: Int = 0, renderProperties: RenderProperties? = nil, drainRenderQueue: Bool = true) -> UIView? {
        var view: UIView?
        var mergedContext = completeMerge ? parentContext.completeMerge(viewValues: viewStore) : parentContext.merge(viewValues: viewStore)
        
        if let renderableSelf = self as? Renderable {
            // Set animation originating from this view into the transaction
            // for children in queue to identify the overwrite transaction.
            let updatedTransaction = updatedAnimationTransaction(context: mergedContext)
            if let updatedTransaction = updatedTransaction {
                mergedContext.transaction = updatedTransaction
            }
            
            view = renderableSelf.createView(context: mergedContext).setViewValues(mergedContext, update: false)
            
            // Set the view of the overwrite transaction after UIView is created and
            // before children are rendered.
            updatedTransaction?.overwriteAnimationParent?.view = view
            
            if drainRenderQueue {
                // Execute sub render operations with Breadth First Search
                mergedContext.viewOperationQueue.drainRecursively()
            }
            
            var mergedView = self
            if let mergedViewValues = mergedContext.viewValues {
                mergedView.viewStore = mergedViewValues
            }
            view?.lastRenderableView = LastRenderableView(view: mergedView)
        } else {
            var updatedView = self
            if let mergedViewValues = mergedContext.viewValues {
                updatedView.viewStore = mergedViewValues
            }
            let binder = ViewBinder(
                view: updatedView,
                rootController: mergedContext.rootController,
                bodyLevel: bodyLevel,
                isInsideButton: mergedContext.isInsideButton,
                overwriteTransaction: overwriteTransaction(from: mergedContext.transaction))
            EnvironmentHolder.currentBodyViewBinderStack.append(binder)
            setupDynamicProperties(context: mergedContext)
            view = body.renderableView(parentContext: mergedContext, completeMerge: true, bodyLevel: bodyLevel + 1, renderProperties: renderProperties, drainRenderQueue: drainRenderQueue)
            if let overrideRootController = renderProperties?.overrideRootController {
                binder.overwriteRootController = overrideRootController
            }
            view?.addViewBinder(EnvironmentHolder.currentBodyViewBinderStack.last, index: bodyLevel)
            EnvironmentHolder.currentBodyViewBinderStack.removeLast()
        }
        
        if self is TabView {
            renderProperties?.skipRender = true
            if let controller = UIApplication.shared.activeWindow?.rootViewController as? UITabBarController {
                renderProperties?.overrideRootController = controller
            }
        }
        
        return view
    }
    
    /// Finds the first view in the hierarchy that conforms to `Renderable`.
    func firstRenderableView(parentContext: Context, completeMerge: Bool = false) -> View {
        let mergedContext = completeMerge ? parentContext.completeMerge(viewValues: viewStore) : parentContext.merge(viewValues: viewStore)
        if self is Renderable {
            var mergedSelf = self
            if let viewValues = mergedContext.viewValues {
                mergedSelf.viewStore = viewValues
            }
            return mergedSelf
        } else {
            setupDynamicProperties(context: parentContext)
            return body.firstRenderableView(parentContext: mergedContext, completeMerge: true)
        }
    }
    
    /// Returns all direct subviews flattened in a single array. This is useful
    /// when handling the result of `ViewBuilder` or Groups.
    /// If the view doesn't group subviews, returns an array with the current view.
    var subViews: [View] {
        var views: [View]
        if let viewGroup = self as? ViewGrouper {
            views = viewGroup.viewContent
        } else {
            views = [self]
        }
        
        var flatViews = [View]()
        views.flatIterate(viewValues: viewStore) { view in
            flatViews.append(view)
        }
        return flatViews
    }
    
    /// Returns all direct subviews flattened in a single array, mapped by the
    /// `map` closure. This is useful when handling the result of `ViewBuilder`
    /// or Groups.
    /// If the view doesn't group subviews, returns an array with the current view.
    func mappedSubViews(_ map: (View) -> View) -> [View] {
        var views: [View]
        if let viewGroup = self as? ViewGrouper {
            views = viewGroup.viewContent
        } else {
            views = [self]
        }
        
        var flatViews = [View]()
        views.flatIterate(viewValues: viewStore) { view in
            flatViews.append(map(view))
        }
        return flatViews
    }
    
    /// Returns all direct and indirect subviews flattened in a single array.
    /// This is useful when you want access to all final subviews, even if they
    /// exist in `ForEach` loops or marked as optional.
    /// If the view doesn't group subviews, returns an array with the current view.
    var totallyFlatSubViews: [View] {
        var views: [View]
        if let viewGroup = self as? ViewGrouper {
            views = viewGroup.viewContent
        } else {
            views = [self]
        }
        
        var flatViews = [View]()
        views.totallyFlatIterate(viewValues: viewStore) { view in
            flatViews.append(view)
        }
        return flatViews
    }
    
    /// Returns only the directly immediate subviews.
    var originalSubViews: [View] {
        if let viewGroup = self as? ViewGrouper {
            return viewGroup.viewContent
        } else {
            return [self]
        }
    }
    
    private func migrateState(fromView oldView: View) {
        let oldChildren = Mirror(reflecting: oldView).children
        let updatedChildren = Mirror(reflecting: self).children
        
        if oldChildren.count == updatedChildren.count {
            let oldIterator = oldChildren.makeIterator()
            let updatedIterator = updatedChildren.makeIterator()
            
            for _ in 0..<oldChildren.count {
                let oldValue = oldIterator.next()?.value
                let updatedValue = updatedIterator.next()?.value
                
                if let oldValue = oldValue as? MigratableProperty,
                    let updatedValue = updatedValue as? MigratableProperty {
                    updatedValue.setInternalValue(oldValue.internalValue)
                }
            }
        }
    }
    
    private func isTransformDifference(context: Context, view: UIView) -> Bool {
        let oldView = view.lastRenderableView?.view
        return context.viewValues?.transform != oldView?.viewStore.transform ||
            context.viewValues?.scale != oldView?.viewStore.scale ||
            context.viewValues?.rotation?.degrees != oldView?.viewStore.rotation?.degrees ||
            context.viewValues?.opacity != oldView?.viewStore.opacity
    }
    
    private func overwriteTransaction(from transaction: Transaction?) -> ViewBinder.OverwriteTransaction? {
        if let transaction = transaction,
           let overwriteAnimationParent = transaction.overwriteAnimationParent?.view {
            return .init(transaction: transaction, parent: overwriteAnimationParent)
        } else {
            return nil
        }
    }
    
    private func updatedAnimationContext(context: Context, uiView: UIView?) -> Context {
        var newContext = context
        if let updatedTransaction = updatedAnimationTransaction(context: context) {
            updatedTransaction.overwriteAnimationParent?.view = uiView
            newContext.transaction = updatedTransaction
        }
        return newContext
    }
    
    private func updatedAnimationTransaction(context: Context) -> Transaction? {
        if let firstAnimatedValues = context.viewValues?.animatedValues?.first {
            var updatedTransaction = context.transaction ?? Transaction()
            if let firstAnimation = firstAnimatedValues.animation {
                updatedTransaction.animation = firstAnimation
            } else {
                updatedTransaction.disablesAnimations = true
            }
            updatedTransaction.overwriteAnimationParent = .init()
            return updatedTransaction
        } else {
            return nil
        }
    }
}

extension View {
    func setupDynamicProperties(context: Context) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.update(context: context)
            }
        }
    }
}

extension View {
    var firstTransition: (transition: AnyTransition, animationValues: AnimatedViewValues?)? {
        if let transition = viewStore.transition {
            return (transition: transition, animationValues: nil)
        } else if let animationValues = viewStore.animatedValues {
           for values in animationValues {
               if let transition = values.transition {
                   return (transition: transition, animationValues: values)
               }
           }
        }
        
        return nil
    }
    func performInsertTransition(view: UIView, animation: Animation?, completion: @escaping () -> Void) {
        if let transition = firstTransition {
            let identityTransition = AnyTransition.InternalTransition(transform: view.transform, opacity: view.alpha, replaceTransform: true)
            transition.transition.insertTransition.performTransition(view: view)
            
            if let viewAnimation = transition.animationValues?.animation {
                viewAnimation.performAnimation({
                    identityTransition.performTransition(view: view)
                }, completion: completion)
            } else if transition.animationValues != nil {
                identityTransition.performTransition(view: view)
                completion()
            } else if let transitionAnimation = transition.transition.insertTransition.animation {
                transitionAnimation.performAnimation({
                    identityTransition.performTransition(view: view)
                }, completion: completion)
            } else if let contextAnimation = animation {
                contextAnimation.performAnimation({
                    identityTransition.performTransition(view: view)
                }, completion: completion)
            } else {
                identityTransition.performTransition(view: view)
                completion()
            }
        } else {
            completion()
        }
    }
    /**
     Performs removal transition and returns if
     transition was performed inline.
     */
    @discardableResult func performRemovalTransition(view: UIView, animation: Animation?, completion: @escaping () -> Void) -> Bool {
        if let firstAvailableTransition = firstTransition {
            let transition = firstAvailableTransition.transition.removeTransition ?? firstAvailableTransition.transition.insertTransition
            
            if let viewAnimation = firstAvailableTransition.animationValues?.animation {
                viewAnimation.performAnimation({
                    transition.performTransition(view: view)
                }, completion: completion)
            } else if firstAvailableTransition.animationValues != nil {
                transition.performTransition(view: view)
                completion()
                return true
            } else if let transitionAnimation = transition.animation {
                transitionAnimation.performAnimation({
                    transition.performTransition(view: view)
                }, completion: completion)
            } else if let contextAnimation = animation {
                contextAnimation.performAnimation({
                    transition.performTransition(view: view)
                }, completion: completion)
            } else {
                transition.performTransition(view: view)
                completion()
                return true
            }
        } else {
            completion()
            return true
        }
        
        return false
    }
}
