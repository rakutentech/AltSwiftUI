//
//  UIHostingController.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// The UIKit ViewController that acts as parent of a AltSwiftUI View hierarchy.
///
/// Initialize this controller with the view that you want to place at the
/// top of the hierarchy.
///
/// When using UIKit views, it's possible to interact with a AltSwiftUI views by
/// passing a UIHostingController that contains a `View` hierarchy.
///
open class UIHostingController: UINavigationController {
    /// Overrides the behavior of the current interactivePopGesture and enables/disables it accordingly.
    /// This property is `true` by default.
    /// - important: Not SwiftUI compatible.
    /// - note: Different to using UINavigationController's `interactivePopGesture?.isEnabled`,
    /// this property is able to turn on/off the gesture even if there is no existent `navigationBar` or if the `leftBarButtonItem` is set.
    public static var isInteractivePopGestureEnabled = true
    
    /// Indicates if a UIViewController is currently being pushed onto this navigation controller
    private var duringPushAnimation = false
    
    public init(rootView: View, background: UIColor? = nil) {
        let controller = ScreenViewController(contentView: rootView, background: background)
        super.init(rootViewController: controller)
        setupNavigation()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setupNavigation()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    /**
     Set this property to use a custom implementation for the application's root
     UIHostingController when there is a TabView in the hierarchy.
     The TabView will cause the root controller to be recreated, so don't
     subclass a UIHostingController and replace it in the app's delegate.
     */
    public static var customRootTabBarController = SwiftUITabBarController()
    private func setupNavigation() {
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.prefersLargeTitles = true
    }
}

extension UIHostingController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool) {
        
        (navigationController as? UIHostingController)?.duringPushAnimation = false
    }
}

extension UIHostingController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else { return true }

        // Disable pop gesture when:
        // 1) the view controller has the isInteractivePopGesture disabled manually
        guard Self.isInteractivePopGestureEnabled else { return false }
        
        // 2) when the pop animation is in progress
        // 3) when user swipes quickly a couple of times and animations don't have time to be performed
        // 4) when there is only one view controller on the stack
        return viewControllers.count > 1 && !duringPushAnimation
    }
}
