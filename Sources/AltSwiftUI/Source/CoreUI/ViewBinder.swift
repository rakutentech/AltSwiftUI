//
//  ViewBinder.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// This class holds and describes the relationship between a
/// `View` and a `UIView`. A `View` is associated to a single `UIView`, but
/// a `UIView` may be associated to multiple views differentiating them by their
/// `bodyLevel`.
class ViewBinder {
    enum StateNotification {
        static let name = Notification.Name(rawValue: "AltSwiftUI.Notification.State")
        static let transactionKey = "Transaction"
    }
    struct OverwriteTransaction {
        var transaction: Transaction
        weak var parent: UIView?
    }
    
    var view: View
    weak var uiView: UIView?
    weak var rootController: ScreenViewController?
    weak var overwriteRootController: UIViewController?
    var isQueuingTransactionUpdate = [Transaction: Bool]()
    var isQueuingStandardUpdate = false
    var isInsideButton: Bool
    var overwriteTransaction: OverwriteTransaction?
    weak var parentScrollView: SwiftUIScrollView?
    
    /// The body level describes how many parent views the current view
    /// has to traverse to reach the topmost View in the hierarchy associated
    /// to the same `UIView`.
    var bodyLevel: Int
    
    init(view: View, rootController: ScreenViewController?, bodyLevel: Int, isInsideButton: Bool, overwriteTransaction: OverwriteTransaction?, parentScrollView: SwiftUIScrollView?) {
        self.view = view
        self.rootController = rootController
        self.bodyLevel = bodyLevel
        self.isInsideButton = isInsideButton
        self.overwriteTransaction = overwriteTransaction
        self.parentScrollView = parentScrollView
    }

    func registerStateNotification(origin: Any) {
        NotificationCenter.default.removeObserver(self, name: Self.StateNotification.name, object: origin)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateNotification(notification:)), name: Self.StateNotification.name, object: origin)
    }
    
    // MARK: - Private methods
    
    private func updateView(transaction: Transaction?) {
        if let subView = uiView {
            assert(rootController?.lazyLayoutConstraints.isEmpty ?? true, "State changed while the body is being executed")
            if transaction?.animation != nil {
                rootController?.view.layoutIfNeeded()
            } else if overwriteTransaction?.transaction.animation != nil {
                overwriteTransaction?.parent?.layoutIfNeeded()
            }
            
            let postRenderQueue = ViewOperationQueue()
            view.updateRender(
                uiView: subView,
                parentContext: Context(
                    rootController: rootController,
                    overwriteRootController: overwriteRootController,
                    transaction: overwriteTransaction?.transaction ?? transaction,
                    postRenderOperationQueue: postRenderQueue,
                    parentScrollView: parentScrollView,
                    isInsideButton: isInsideButton),
                bodyLevel: bodyLevel)
            rootController?.executeLazyConstraints()
            rootController?.executeInsertAppearHandlers()
            
            overwriteTransaction?.transaction.animation?.performAnimation({ [weak self] in
                self?.overwriteTransaction?.parent?.layoutIfNeeded()
            })
            transaction?.animation?.performAnimation({ [weak self] in
                self?.rootController?.view.layoutIfNeeded()
            })
            
            postRenderQueue.drainRecursively()
        }
    }
    @objc private func handleStateNotification(notification: Notification) {
        if notification.name == Self.StateNotification.name {
            let transaction = notification.userInfo?[Self.StateNotification.transactionKey] as? Transaction
            // TODO: Improves view update performance,
            // but causes small delay. Need to find better way
            // to queue without delay, before render happens.
            // queueRenderUpdate(transaction: transaction)
            updateView(transaction: transaction)
        }
    }
    private func queueRenderUpdate(transaction: Transaction?) {
        if let transaction = transaction {
            if isQueuingTransactionUpdate[transaction] == true {
                return
            } else {
                isQueuingTransactionUpdate[transaction] = true
                DispatchQueue.main.async { [weak self] in
                    self?.updateView(transaction: transaction)
                    self?.isQueuingTransactionUpdate[transaction] = false
                }
            }
        } else {
            if isQueuingStandardUpdate {
                return
            } else {
                isQueuingStandardUpdate = true
                DispatchQueue.main.async { [weak self] in
                    self?.updateView(transaction: transaction)
                    self?.isQueuingStandardUpdate = false
                }
            }
        }
    }
}
