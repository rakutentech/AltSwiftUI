//
//  UIKitNavigationViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/09.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

/// The default TabBarController used by AltSwiftUI.
///
/// Subclass this class if you want to add custom behavior to
/// the `UITabBarController` and add it to `UIHostingController.customRootTabBarController`.
open class SwiftUITabBarController: UITabBarController, UITabBarControllerDelegate {
    var selectionChanged: ((Int) -> Void)?
    var currentSelectedIndex: Int = 0
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupController()
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var selectedIndex: Int {
        didSet {
            currentSelectedIndex = selectedIndex
        }
    }
    
    private func setupController() {
        delegate = self
    }
    
    //MARK: Delegate
    
    override open func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            currentSelectedIndex = index
            selectionChanged?(index)
        }
    }
}

// MARK: - Internal Types

class SwiftUIPresenter: NSObject, UIAdaptivePresentationControllerDelegate {
    let onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }
}

class SwiftUIBarButtonItem: UIBarButtonItem {
    class ActionHolder {
        var buttonAction: () -> Void
        init(buttonAction: @escaping () -> Void) {
            self.buttonAction = buttonAction
        }
        @objc func performAction() {
            buttonAction()
        }
    }
    
    var actionHolder: ActionHolder?
    
    convenience init(title: String, style: UIBarButtonItem.Style, accent: UIColor? = nil,  buttonAction: @escaping () -> Void) {
        let actionHolder = ActionHolder(buttonAction: buttonAction)
        self.init(title: title, style: style, target: actionHolder, action: #selector(ActionHolder.performAction))
        self.actionHolder = actionHolder
        tintColor = accent
    }
    convenience init(image: UIImage, style: UIBarButtonItem.Style, accent: UIColor? = nil,  buttonAction: @escaping () -> Void) {
        let actionHolder = ActionHolder(buttonAction: buttonAction)
        self.init(image: image, style: style, target: actionHolder, action: #selector(ActionHolder.performAction))
        self.actionHolder = actionHolder
        tintColor = accent
    }
}
