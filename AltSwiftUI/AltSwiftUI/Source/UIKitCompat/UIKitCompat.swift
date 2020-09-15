//
//  UIKitCompat.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - UIViewControllerRepresentable

/// The context used in a `UIViewControllerRepresentable` type.
public struct UIViewControllerRepresentableContext<Representable> where Representable : UIViewControllerRepresentable {

    /// The view's associated coordinator.
    public let coordinator: Representable.Coordinator

    /// The current `Transaction`.
    public var transaction: Transaction

    /// The current `Environment`.
    public var environment: EnvironmentValues
}

/// Use this protocol to create a custom `View` that represents a `UIViewController`.
public protocol UIViewControllerRepresentable: View, Renderable {
    associatedtype UIViewControllerType : UIViewController
    typealias UIContext = UIViewControllerRepresentableContext<Self>
    associatedtype Coordinator = Void
    
    /// Creates a `UIViewController` instance to be presented.
    func makeUIViewController(context: UIContext) -> UIViewControllerType

    /// Updates the presented `UIViewController` (and coordinator) to the latest
    /// configuration.
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIContext)

    /// Creates a `Coordinator` instance to coordinate with the
    /// `UIViewController`.
    ///
    /// `Coordinator` can be accessed via `Context`.
    func makeCoordinator() -> Coordinator
}

extension UIViewControllerRepresentable where Coordinator == Void {
    public func makeCoordinator() -> Void {}
}

extension UIViewControllerRepresentable {
    public var body: View {
        EmptyView()
    }
    public func createView(context: Context) -> UIView {
        guard let rootController = context.rootController else { return UIView() }
        
        let coordinator = makeCoordinator()
        let context = UIContext(coordinator: coordinator, transaction: context.transaction ?? Transaction(), environment: EnvironmentValues(rootController: rootController))
        let controller = makeUIViewController(context: context)
        rootController.addChild(controller)
        controller.view.uiViewRepresentableCoordinator = coordinator as AnyObject
        updateUIViewController(controller, context: context)
        return controller.view.noAutoresizingMask()
    }
    public func updateView(_ view: UIView, context: Context) {
        guard let rootController = context.rootController else { return }
        
        if let controller = (rootController.children.first { $0.view == view }) as? UIViewControllerType,
        let coordinator = controller.view.uiViewRepresentableCoordinator as? Coordinator {
            let context = UIContext(coordinator: coordinator, transaction: context.transaction ?? Transaction(), environment: EnvironmentValues(rootController: rootController))
            updateUIViewController(controller, context: context)
        }
    }
}

// MARK: - UIViewRepresentable

/// The context used in a `UIViewRepresentable` type.
public struct UIViewRepresentableContext<Representable> where Representable : UIViewRepresentable {

    /// The view's associated coordinator.
    public let coordinator: Representable.Coordinator

    /// The current `Transaction`.
    public var transaction: Transaction

    /// The current `Environment`.
    public var environment: EnvironmentValues
}

/// Use this protocol to create a custom `View` that represents a `UIView`.
public protocol UIViewRepresentable : View, Renderable {
    associatedtype UIViewType : UIView
    typealias UIContext = UIViewRepresentableContext<Self>
    associatedtype Coordinator = Void
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: UIContext) -> UIViewType

    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ uiView: UIViewType, context: UIContext)
    
    /// Creates a `Coordinator` instance to coordinate with the
    /// `UIView`.
    ///
    /// `Coordinator` can be accessed via `Context`.
    func makeCoordinator() -> Coordinator
}

extension UIViewRepresentable where Coordinator == Void {
    public func makeCoordinator() -> Void {}
}

extension UIViewRepresentable {
    public var body: View {
        EmptyView()
    }
    public func createView(context: Context) -> UIView {
        let coordinator = makeCoordinator()
        let context = UIContext(coordinator: coordinator, transaction: context.transaction ?? Transaction(), environment: EnvironmentValues(rootController: context.rootController))
        let uiView = makeUIView(context: context).noAutoresizingMask()
        uiView.uiViewRepresentableCoordinator = coordinator as AnyObject
        updateUIView(uiView, context: context)
        return uiView
    }
    public func updateView(_ view: UIView, context: Context) {
        if let view = view as? UIViewType, let coordinator = view.uiViewRepresentableCoordinator as? Coordinator {
            let context = UIContext(coordinator: coordinator, transaction: context.transaction ?? Transaction(), environment: EnvironmentValues(rootController: context.rootController))
            updateUIView(view, context: context)
        }
    }
}

extension UIView {
    static var uiViewRepresentableCoordinatorAssociatedKey = "UIViewRepresentableCoordinatorAssociatedKey"
    var uiViewRepresentableCoordinator: AnyObject? {
        get {
            objc_getAssociatedObject(self, &Self.uiViewRepresentableCoordinatorAssociatedKey) as AnyObject
        }
        set {
            objc_setAssociatedObject(self, &Self.uiViewRepresentableCoordinatorAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
