//
//  ViewCollectionIteration.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

enum DiffableSourceOperation {
    case insert(view: View)
    case delete(view: View)
    case update(view: View)
}

extension Array where Element == View {
    
    /// Iterates through all direct views, flattening Groups.
    /// Iterated views have their parent properties merged.
    func flatIterate(viewValues: ViewValues = ViewValues(), action: (View) -> Void) {
        for view in self {
            let mergedValues = view.viewStore.merge(defaultValues: viewValues)
            if let group = view as? (ViewGrouper & View) {
                group.viewContent.flatIterate(viewValues: mergedValues, action: action)
            } else {
                var view = view
                view.viewStore = mergedValues
                action(view)
            }
        }
    }
    
    /// Iterates through all direct and indirect views.
    /// Iterated views have their parent properties merged.
    ///
    /// This is useful when you want to iterate through all final subviews, even if they
    /// exist in `ForEach` loops or marked as optional.
    func totallyFlatIterate(viewValues: ViewValues = ViewValues(), action: (View) -> Void) {
        for view in self {
            let mergedValues = view.viewStore.merge(defaultValues: viewValues)
            if let group = view as? (ViewGrouper & View) {
                group.viewContent.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else if let group = view as? OptionalView {
                group.content?.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else if let group = view as? ComparableViewGrouper {
                group.viewContent.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else {
                var view = view
                view.viewStore = mergedValues
                action(view)
            }
        }
    }
    
    /// Groups all views in sections.
    ///
    /// If a view is a `Section`, it won't
    /// be grouped. All other views that are not of `Section` type  will be sequentially
    /// grouped until the next view is a `Section`. Each view that is not a `Section`
    /// is not added to a `Section` directly, instead, resultant views from `View.totallyFlatSubViews`
    /// are used.
    func totallyFlatGroupedBySection() -> [Section] {
        var sections = [Section]()
        var temporalSection: Section?
        for view in self {
            if let section = view as? Section {
                if let unwrappedSection = temporalSection {
                    sections.append(unwrappedSection)
                    temporalSection = nil
                }
                sections.append(section)
            } else {
                if temporalSection == nil {
                    temporalSection = Section()
                }
                temporalSection?.viewContent.append(contentsOf: view.totallyFlatSubViews)
            }
        }
        
        if let temporalSection = temporalSection {
            sections.append(temporalSection)
        }
        
        return sections
    }
    
    /// Iterates each view totally flatly and calls the iteration
    /// closure. Groups are not flattened, and are expected to already be
    /// flattened.
    func iterateFullViewInsert(iteration: (View) -> Void) {
        for subView in self {
            if let optionalView = subView as? OptionalView {
                if let optionalViewContent = optionalView.content {
                    optionalViewContent.iterateFullViewInsert(iteration: iteration)
                }
            } else if let comparableGroupView = subView as? ComparableViewGrouper {
                comparableGroupView.viewContent.iterateFullViewInsert(iteration: iteration)
            } else {
                iteration(subView)
            }
        }
    }
    
    /// Iterates each view totally flatly and specifies what operations
    /// happen between the diff of an old list and a current list.
    ///
    /// The iteration returns:
    /// - index: The index in the UIView hierarchy to apply the operation to
    /// - operation: The operation that should happen at this index
    /// - currentView: The value of the current view, if it exists
    /// - oldView: The value of the old view, if it exists
    ///
    /// Groups are not flattened, and are expected to already be
    /// flattened.
    func iterateFullViewDiff(oldList: [View] = [], iteration: (Int, DiffableSourceOperation) -> Void) {
        var displayIndex = 0
        let maxCount = Swift.max(count, oldList.count)
        if maxCount == 0 {
            return
        }
        
        for index in 0..<maxCount {
            var subView: View?
            var oldView: View?
            if count > index {
                subView = self[index]
            }
            if oldList.count > index {
                oldView = oldList[index]
            }
            iterateFullSubviewDiff(subView: subView, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
        }
    }
    
    private func iterateFullSubviewDiff(subView: View?, oldView: View?, iteration: (Int, DiffableSourceOperation) -> Void, displayIndex: inout Int) {
        if let optionalView = subView as? OptionalView, let optionalViewContent = optionalView.content {
            // Optional insert / update
            let oldOptionalView = oldView as? OptionalView
            let maxCount = Swift.max(optionalViewContent.count, oldOptionalView?.content?.count ?? 0)
            if maxCount > 0 {
                for i in 0..<maxCount {
                    let subView = optionalViewContent[safe: i]
                    let oldSubView = oldOptionalView?.content?[safe: i]
                    iterateFullSubviewDiff(subView: subView, oldView: oldSubView, iteration: iteration, displayIndex: &displayIndex)
                }
            }
            // Normal delete
            if let oldView = oldView, oldOptionalView == nil {
                iterateFullSubviewDiff(subView: nil, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
            }
        } else if let oldOptionalView = oldView as? OptionalView, let oldOptionalViewContent = oldOptionalView.content {
            // Optional delete
            for oldSubView in oldOptionalViewContent {
                iterateFullSubviewDiff(subView: nil, oldView: oldSubView, iteration: iteration, displayIndex: &displayIndex)
            }
            // Optional delete + normal insert
            if let subView = subView, !(subView is OptionalView) {
                iterateFullSubviewDiff(subView: subView, oldView: nil, iteration: iteration, displayIndex: &displayIndex)
            }
        } else if subView is OptionalView && oldView is OptionalView {
            // Both Optional empty
            return
        } else if let comparableGroupView = subView as? ComparableViewGrouper {
            if let oldComparableGroupView = oldView as? ComparableViewGrouper {
                // ForEach update
                comparableGroupView.iterateDiff(oldViewGroup: oldComparableGroupView, startDisplayIndex: &displayIndex, iterate: iteration)
            } else {
                // ForEach insert
                for comparableSubview in comparableGroupView.viewContent {
                    iteration(displayIndex, .insert(view: comparableSubview))
                    displayIndex += 1
                }
                // Normal Delete
                if let oldView = oldView, !(oldView is OptionalView) {
                    iterateFullSubviewDiff(subView: nil, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
                }
            }
        } else if let oldComparableGroupView = oldView as? ComparableViewGrouper {
            // ForEach delete
            for comparableSubview in oldComparableGroupView.viewContent {
                iteration(displayIndex, .delete(view: comparableSubview))
                displayIndex += 1
            }
            // Normal insert
            if let subView = subView, !(subView is OptionalView) {
                iterateFullSubviewDiff(subView: subView, oldView: nil, iteration: iteration, displayIndex: &displayIndex)
            }
        } else {
            if let subView = subView {
                if let oldView = oldView {
                    // Normal update
                    if let padSubView = subView as? PaddingView, let padOldView = oldView as? PaddingView {
                        if padSubView == padOldView {
                            iteration(displayIndex, .update(view: subView))
                        } else {
                            iteration(displayIndex, .delete(view: oldView))
                            displayIndex += 1
                            iteration(displayIndex, .insert(view: subView))
                        }
                        displayIndex += 1
                    } else if type(of: subView) == type(of: oldView) {
                        iteration(displayIndex, .update(view: subView))
                        displayIndex += 1
                    } else {
                        if !(oldView is OptionalView) {
                            iteration(displayIndex, .delete(view: oldView))
                            displayIndex += 1
                        }
                        if !(subView is OptionalView) {
                            iteration(displayIndex, .insert(view: subView))
                            displayIndex += 1
                        }
                        return
                    }
                } else {
                    // Normal insert
                    if !(subView is OptionalView) {
                        iteration(displayIndex, .insert(view: subView))
                        displayIndex += 1
                    }
                }
            } else if let oldView = oldView {
                // Normal delete
                if !(oldView is OptionalView) {
                    iteration(displayIndex, .delete(view: oldView))
                    displayIndex += 1
                }
            }
        }
    }
}

extension UIStackView {
    func addViews(_ views: [View], context: Context, isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        context.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            var equalViews = [UIView]()
            views.iterateFullViewInsert() { view in
                if let renderView = view.renderableView(parentContext: context, drainRenderQueue: false) {
                    if isEquallySpaced(view) {
                        equalViews.append(renderView)
                    }
                    self.addArrangedSubview(renderView)
                }
            }
            if equalViews.count > 1 {
                for i in 1..<equalViews.count {
                    setEqualDimension(equalViews[i - 1], equalViews[i])
                }
            }
        }
    }
    func updateFirstView(view: View, context: Context) {
        guard let firstUIView = arrangedSubviews.first else { return }
        view.scheduleUpdateRender(uiView: firstUIView, parentContext: context)
    }
    func updateViews(_ views: [View], oldViews: [View],  context: Context, isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        context.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            
            var equalViews = [UIView]()
            var equalViewReference: UIView? = nil
            
            var indexSkip = 0
            views.iterateFullViewDiff(oldList: oldViews) { i, operation in
                let index = i + indexSkip
                switch operation {
                case .insert(let view):
                    if let uiView = view.renderableView(parentContext: context, drainRenderQueue: false) {
                        self.insertArrangedSubview(uiView, at: index)
                        if isEquallySpaced(view) {
                            equalViews.append(uiView)
                        }
                        if let animation = context.transaction?.animation {
                            uiView.isHidden = true
                            animation.performAnimation({
                                uiView.isHidden = false
                            })
                        }
                        view.performInsertTransition(view: uiView, animation: context.transaction?.animation) {}
                    }
                case .delete(let view):
                    guard let nonHiddenSubView = self.firstNonHiddenSubview(index: index) else {
                        break
                    }
                    
                    let uiView = nonHiddenSubView.uiView
                    indexSkip += nonHiddenSubView.skippedSubViews
                    let removeGroup = DispatchGroup()
                    
                    let viewAnim = context.viewValues?.animationShieldedValues == nil ?  context.viewValues?.animatedValues?.first?.animation : nil
                    if let animation = viewAnim ?? context.transaction?.animation {
                        removeGroup.enter()
                        animation.performAnimation({
                            uiView.isHidden = true
                        }) {
                            removeGroup.leave()
                        }
                    } else {
                        uiView.isHidden = true
                    }
                    
                    removeGroup.enter()
                    view.performRemovalTransition(view: uiView, animation: context.transaction?.animation, completion:{
                        removeGroup.leave()
                    })
                    
                    removeGroup.notify(queue: .main) {
                        uiView.removeFromSuperview()
                    }
                case .update(let view):
                    guard let nonHiddenSubView = self.firstNonHiddenSubview(index: index) else {
                        break
                    }
                    
                    let uiView = nonHiddenSubView.uiView
                    indexSkip += nonHiddenSubView.skippedSubViews
                    view.updateRender(uiView: uiView, parentContext: context, drainRenderQueue: false)
                    if equalViewReference == nil && isEquallySpaced(view) {
                        equalViewReference = uiView
                    }
                }
            }
            if let equalViewReference = equalViewReference {
                equalViews.insert(equalViewReference, at: 0)
            }
            
            if equalViews.count > 1 {
                for i in 1..<equalViews.count {
                    setEqualDimension(equalViews[i - 1], equalViews[i])
                }
            }
        }
    }
    func firstNonHiddenSubview(index: Int) -> (uiView: UIView, skippedSubViews: Int)? {
        var movingIndex = index
        while arrangedSubviews.count > movingIndex {
            let uiView = arrangedSubviews[movingIndex]
            if !uiView.isHidden {
                return (uiView: uiView, skippedSubViews: movingIndex - index)
            }
            movingIndex += 1
        }
        return nil
    }
    func setStackAlignment(alignment: HorizontalAlignment) {
        switch alignment {
        case .leading:
            self.alignment = .leading
        case .center:
            self.alignment = .center
        case .trailing:
            self.alignment = .trailing
        }
    }
    func setStackAlignment(alignment: VerticalAlignment) {
        switch alignment {
        case .top:
            self.alignment = .top
        case .center:
            self.alignment = .center
        case .bottom:
            self.alignment = .bottom
        }
    }
    private func removeAllSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}

extension UIView {
    func firstNonRemovingSubview(index: Int) -> (uiView: UIView, skippedSubViews: Int)? {
        var movingIndex = index
        while subviews.count > movingIndex {
            let uiView = subviews[movingIndex]
            if !(uiView.isAnimatingRemoval ?? false) {
                return (uiView: uiView, skippedSubViews: movingIndex - index)
            }
            movingIndex += 1
        }
        return nil
    }
}
