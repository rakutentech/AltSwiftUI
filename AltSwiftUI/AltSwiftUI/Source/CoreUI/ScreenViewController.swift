//
//  ScreenViewController.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class EventCodeHandler {
    let handler: () -> Void
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
}

class ScreenViewController: UIViewController {
    var contentView: View
    private var isNavigationController: Bool
    private var presenter: SwiftUIPresenter?
    private var onDismiss: (() -> Void)?
    private var onPop: (() -> Void)?
    var onAppearHandlers: NSMapTable<UIView, EventCodeHandler> = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    var onDisappearHandlers: NSMapTable<UIView, EventCodeHandler> = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    var insertOnAppearHandlers: NSMapTable<UIView, EventCodeHandler> = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    private var executedInsertAppearHandlers: NSMapTable<UIView, EventCodeHandler> = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    var statusBarHidden = false
    var customStatusBarStyle: UIStatusBarStyle?
    var sheetPresentation: SheetPresentation?
    var isPushed: Bool = false
    var background: UIColor?
    lazy var lazyLayoutConstraints: [NSLayoutConstraint] = []
    var navigationBarTint: UIColor?
    
    public init(
        contentView: View,
        parentContext: Context? = nil,
        isNavigationController: Bool = false,
        onDismiss: (() -> Void)? = nil,
        onPop: (() -> Void)? = nil,
        background: UIColor? = nil,
        isNavigating: Bool = false) {
        self.contentView = contentView
        self.isNavigationController = isNavigationController
        self.onDismiss = onDismiss
        self.onPop = onPop
        self.background = background
        super.init(nibName: nil, bundle: nil)
        initViewData(parentContext: parentContext, isNavigating: isNavigating)
        setupTab()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
        render()
    }
    
    override var prefersStatusBarHidden: Bool {
        statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        customStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let handlersCopy = onAppearHandlers.copy(with: nil) as? NSMapTable<UIView, EventCodeHandler> else { return }
        
        for view in handlersCopy.keyEnumerator() {
            guard let view = view as? UIView, executedInsertAppearHandlers.object(forKey: view) == nil else {
                continue
            }
            
            if let handler = handlersCopy.object(forKey: view) {
                handler.handler()
            }
        }
        
        executedInsertAppearHandlers.removeAllObjects()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handlersCopy = onDisappearHandlers.copy(with: nil) as? NSMapTable<UIView, EventCodeHandler> else { return }
        
        for handler in handlersCopy.objectEnumerator() ?? NSEnumerator() {
            if let handler = handler as? EventCodeHandler {
                handler.handler()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed || isMovingFromParent {
            onPop?()
        }
    }
    
    // MARK: - Public methods
    
    func render() {
        let context = Context(rootController: self)
        let renderProperties = RenderProperties()
        guard let renderView = contentView.renderableView(parentContext: context, renderProperties: renderProperties) else { return }
        if renderProperties.skipRender {
            return
        }
        
        view.addSubview(renderView)
        LayoutSolver.solveLayout(parentView: view, contentView: renderView, content: contentView.firstRenderableView(context: context), expand: false, context: context)
        executeLazyConstraints()
        executeInsertAppearHandlers()
    }
    
    func setNavigationBarHidden(_ hidden: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: true)
    }
    func setStatusBarHidden(_ hidden: Bool) {
        statusBarHidden = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    func setStatusBarStyle(_ style: UIStatusBarStyle?) {
        if customStatusBarStyle == style {
            return
        }
        
        customStatusBarStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func setNavigationController(_ isNavigation: Bool) {
        isNavigationController = isNavigation
        navigationController?.setNavigationBarHidden(!isNavigationController, animated: false)
    }
    
    func setNavigationBarTint(_ tintColor: UIColor) {
        navigationBarTint = tintColor
        navigationController?.navigationBar.tintColor = tintColor
    }
    
    // MARK: - Public methods: Navigation
    
    func navigateToView(_ view: View, context: Context, onPop: (()->Void)? = nil) {
        let vc = ScreenViewController(
            contentView: view,
            parentContext: context,
            isNavigationController: true,
            onPop: onPop,
            isNavigating: true)
        vc.isPushed = true
        
        if view.viewStore.tabBarHidden == true {
            vc.hidesBottomBarWhenPushed = true
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func popView() {
        navigationController?.popViewController(animated: true)
    }
    
    func dismissPresentationMode() {
        if isPushed {
            popView()
        } else {
            sheetPresentation?.isPresented.wrappedValue = false
        }
    }
    
    func executeLazyConstraints() {
        lazyLayoutConstraints.activate()
        lazyLayoutConstraints = []
    }
    func executeInsertAppearHandlers() {
        guard let appearHandlers = insertOnAppearHandlers.copy(with: nil) as? NSMapTable<UIView, EventCodeHandler> else { return }
        insertOnAppearHandlers.removeAllObjects()
        for key in appearHandlers.keyEnumerator() {
            if let key = key as? UIView,
                let handler = appearHandlers.object(forKey: key) {
                executedInsertAppearHandlers.setObject(handler, forKey: key)
                handler.handler()
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        if let background = background {
            view.backgroundColor = background
        } else {
            if #available(iOS 13.0, *) {
                view.backgroundColor = .systemBackground
            } else {
                view.backgroundColor = .white
            }
        }
    }
    private func initViewData(parentContext: Context?, isNavigating: Bool) {
        guard let parentContext = parentContext else {
            return
        }
        
        contentView.viewStore = contentView.viewStore.screenTransferMerge(defaultValues: parentContext.viewValues, isNavigating: isNavigating)
        if let accentColor = parentContext.viewValues?.accentColor {
            setNavigationBarTint(accentColor)
        }
    }
    private func setupTab() {
        if let tabItem = contentView.viewStore.tabItem, let tag = contentView.viewStore.tag {
            tabBarItem = UITabBarItem(title: tabItem.text, image: tabItem.image, tag: tag)
        }
    }
    private func setupNavigation() {
        if !isNavigationController {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        if let onDismiss = onDismiss {
            presenter = SwiftUIPresenter(onDismiss: onDismiss)
            if let navigationController = navigationController {
                navigationController.presentationController?.delegate = presenter
            } else {
                presentationController?.delegate = presenter
            }
        }
    }
}

extension UIViewController {
    func presentView(viewValues: ViewValues?, sheetPresentation: SheetPresentation) {
        if presentedViewController != nil {
            return
        }
        
        let vc = ScreenViewController(contentView: sheetPresentation.sheetView,
                                      parentContext: Context(viewValues: viewValues),
                                      isNavigationController: false,
                                      onDismiss: sheetPresentation.onDismiss,
                                      isNavigating: true)
        vc.sheetPresentation = sheetPresentation
        let hostingVc = UIHostingController(rootViewController: vc)
        if sheetPresentation.isFullScreen {
            hostingVc.modalPresentationStyle = .fullScreen
        }
        present(hostingVc, animated: true)
    }
    func dismissPresentedView(sheetPresentation: SheetPresentation) {
        if let presentedVC = presentedViewController as? UIHostingController,
            let sheetVC = presentedVC.viewControllers.first as? ScreenViewController,
            !presentedVC.isBeingDismissed,
            sheetVC.sheetPresentation?.id == sheetPresentation.id {
            dismiss(animated: true)
        }
    }
    func presentAlert(_ alert: Alert) {
        if presentedViewController != nil {
            return
        }
        
        let controller = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        if let secondaryButton = alert.secondaryButton {
            controller.addAction(alertAction(alertButton: secondaryButton, alertIsPresented: alert.alertIsPresented))
        }
        if let primaryButton = alert.primaryButton {
            controller.addAction(alertAction(alertButton: primaryButton, alertIsPresented: alert.alertIsPresented))
        }
        present(controller, animated: true)
    }
    func presentActionSheet(_ actionSheet: ActionSheet) {
        if presentedViewController != nil {
            return
        }
        
        let controller = UIAlertController(title: actionSheet.title, message: actionSheet.message, preferredStyle: .actionSheet)
        for button in actionSheet.buttons {
            controller.addAction(alertAction(alertButton: button, alertIsPresented: actionSheet.actionSheetIsPresented))
        }
        present(controller, animated: true)
    }
    private func alertAction(alertButton: Alert.Button, alertIsPresented: Binding<Bool>?) -> UIAlertAction {
        UIAlertAction(title: alertButton.text, style: alertActionStyle(alertButtonStyle: alertButton.style), handler: { _ in
            alertButton.action?()
            alertIsPresented?.wrappedValue = false
        })
    }
    private func alertActionStyle(alertButtonStyle: Alert.Button.Style) -> UIAlertAction.Style {
        switch alertButtonStyle {
        case .default:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}
