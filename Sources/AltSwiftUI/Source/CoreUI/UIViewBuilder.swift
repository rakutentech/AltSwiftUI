//
//  UIViewBuilder.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit
import StoreKit

extension UIView {
    /// Configures all `View` generic properties into the underlying
    /// UIView.
    @discardableResult func setViewValues(_ context: Context, update: Bool) -> UIView {
        guard let viewValues = context.viewValues else {
            assert(false, "View Values should be set")
            return UIView()
        }
        
        setColor(viewValues)
        setLayout(viewValues, animation: viewValues.animatedValues?.first?.animation ?? context.transaction?.animation, update: update)
        setViewStyle(context, update: update)
        setupViewInteraction(viewValues)
        setupNavigation(context)
        setupGestures(context)
        setupAnimations(viewValues, animation: context.transaction?.animation, update: update)
        if let animatedValues = viewValues.animatedValues {
            for animatedValue in animatedValues {
                setupAnimations(animatedValue, animation: animatedValue.animation, update: update)
            }
        }
        if let shieldedValues = viewValues.animationShieldedValues {
            setupAnimations(shieldedValues, animation: nil, update: update)
        }
        setupController(context, update: update)
        setupCoordinate(context)
        return self
    }
    private func setColor(_ viewValues: ViewValues) {
        if let background = viewValues.background {
            backgroundColor = background
        }
        if let accentColor = viewValues.accentColor {
            tintColor = accentColor
        }
    }
    private func setLayout(_ viewValues: ViewValues, animation: Animation?, update: Bool) {
        setDimensions(viewValues, animation: animation, update: update)
        
        if let layoutPriority = viewValues.layoutPriority {
            var priority: UILayoutPriority = .defaultLow
            if layoutPriority == 1 {
                priority = .defaultHigh
            } else if layoutPriority == 2 {
                priority = .required
            }
            setContentHuggingPriority(priority, for: .horizontal)
            setContentCompressionResistancePriority(priority, for: .horizontal)
            setContentHuggingPriority(priority, for: .vertical)
            setContentCompressionResistancePriority(priority, for: .vertical)
        }
        
        if let geometryView = self as? (GeometryListener & UIView), let geometry = viewValues.geometry {
            geometryView.registerGeometryListener(geometry)
        }
    }
    private func setDimensions(_ viewValues: ViewValues, animation: Animation?, update: Bool) {
        guard viewValues.viewDimensions != lastRenderableView?.view.viewStore.viewDimensions else {
            return
        }
        
        if update {
            if animation != nil {
                superview?.layoutIfNeeded()
            }
            if let dimensionConstraints = dimensionConstraints?.value {
                removeConstraints(dimensionConstraints)
            }
        }
        
        var constraints = [NSLayoutConstraint]()
        
        if let width = viewValues.viewDimensions?.width {
            constraints.append(widthAnchor.constraint(equalToConstant: width))
        }
        if let height = viewValues.viewDimensions?.height {
            constraints.append(heightAnchor.constraint(equalToConstant: height))
        }
        if let minWidth = viewValues.viewDimensions?.minWidth {
            constraints.append(widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth))
        }
        if let maxWidth = viewValues.viewDimensions?.maxWidth {
            constraints.append(widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).withPriority(.required))
            constraints.append(widthAnchor.constraint(equalToConstant: maxWidth).withPriority(.required - 1))
        }
        if let minHeight = viewValues.viewDimensions?.minHeight {
            constraints.append(heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight))
        }
        if let maxHeight = viewValues.viewDimensions?.maxHeight {
            constraints.append(heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).withPriority(.required))
            constraints.append(heightAnchor.constraint(equalToConstant: maxHeight).withPriority(.required - 1))
        }
        constraints.activate()
        if let animation = animation, update {
            setNeedsLayout()
            animation.performAnimation({ [weak self] in
                self?.superview?.layoutIfNeeded()
            })
        }
        
        dimensionConstraints = DimensionConstraints(value: constraints)
    }
    private func setupGestures(_ context: Context) {
        if let gestures = context.viewValues?.gestures {
            if gestureHolders == nil {
                gestureHolders = GestureHolders(gestures: [])
            }
            for (index, gesture) in gestures.enumerated() {
                let recognizerName = "RakutenTravelCore.AltSwiftUI.GenericGesture_\(index)"
                
                let holder = GestureHolder(gesture: gesture)
                let recognizer = gesture.recognizer(target: holder, action: #selector(GestureHolder.processGesture(gestureRecognizer:)))
                if context.viewValues?.disabled != true {
                    isUserInteractionEnabled = true
                }
                
                if let existingRecognizer = gestureRecognizers?.first(where: {$0.name == recognizerName }),
                    type(of: existingRecognizer) == type(of: recognizer) {
                    // Update gesture
                    gestureHolders?.gestures[safe: index]?.gesture = gesture
                } else {
                    // Replace gesture
                    if (gestureHolders?.gestures.count ?? 0) > index {
                        gestureHolders?.gestures[safe: index] = holder
                    } else {
                        gestureHolders?.gestures.append(holder)
                    }
                    
                    recognizer.name = recognizerName
                    recognizer.delegate = holder
                    if gesture.priority == .simultaneous {
                        holder.isSimultaneous = true
                    }
                    gestureRecognizers?.removeAll { $0.name == recognizerName }
                    addGestureRecognizer(recognizer)
                }
            }
        }
    }
    private func setupAnimations(_ viewValues: AnimatedViewValuesHolder, animation: Animation?, update: Bool) {
        if let animation = animation, update {
            animation.performAnimation({ [weak self] in
                self?.setupAnimatedValues(viewValues)
            })
        } else {
            setupAnimatedValues(viewValues)
        }
    }
    private func setupAnimatedValues(_ viewValues: AnimatedViewValuesHolder) {
        if let opacity = viewValues.opacity {
            alpha = CGFloat(opacity)
        }
        if viewValues.transform != nil || viewValues.scale != nil || viewValues.rotation != nil {
            self.transform = .identity
        }
        if let transform = viewValues.transform {
            self.transform = transform
        }
        if let scale = viewValues.scale {
            transform = transform.scaledBy(x: scale.width, y: scale.height)
        }
        if let rotation = viewValues.rotation {
            transform = transform.rotated(by: CGFloat(rotation.radians))
        }
    }
    private func setViewStyle(_ context: Context, update: Bool) {
        guard let viewValues = context.viewValues else { return }
        
        if let overlay = viewValues.overlay {
            if !update {
                context.viewOperationQueue.addOperation { [weak self] in
                    if let overlayView = overlay.view.renderableView(parentContext: context, drainRenderQueue: false) {
                        overlayView.tag = 99
                        self?.addSubview(overlayView)
                        self?.align(overlayView, alignment: overlay.alignment)
                    }
                }
            } else if let overlayView = (subviews.first { $0.tag == 99 }) {
                overlay.view.scheduleUpdateRender(uiView: overlayView, parentContext: context)
            }
        }
        if let border = viewValues.border {
            if let traitHandler = self as? (TraitColorHandler & UIView) {
                traitHandler.borderColor = border.color
            } else {
                layer.borderColor = border.color.cgColor
            }
            layer.borderWidth = border.width
        }
        if let disabled = viewValues.disabled {
            isUserInteractionEnabled = !disabled
        }
        if let antialiasClip = viewValues.antialiasClip {
            clipsToBounds = true
            layer.allowsEdgeAntialiasing = antialiasClip
        }
        if let cornerRadius = viewValues.cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        if let shadow = viewValues.shadow {
            layer.shadowColor = shadow.color.cgColor
            layer.shadowOffset = CGSize(width: shadow.xOffset, height: shadow.yOffset)
            layer.shadowRadius = shadow.radius
            layer.shadowOpacity = 1
        }
        if let mask = viewValues.mask {
            context.viewOperationQueue.addOperation { [weak self] in
                if let uiView = update ? self?.mask : mask.renderableView(parentContext: context, drainRenderQueue: false) {
                    if let maskWidth = mask.viewStore.viewDimensions?.width,
                        let maskHeight = mask.viewStore.viewDimensions?.height {
                        if let animation = context.transaction?.animation, update, uiView.frame.width != maskWidth || uiView.frame.height != maskHeight {
                            animation.performAnimation({
                                uiView.frame = CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight)
                            })
                        } else {
                            uiView.frame = CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight)
                        }
                    }
                    
                    self?.mask = uiView
                }
            }
        }
    }
    private func setupViewInteraction(_ viewValues: ViewValues) {
        if let tapAction = viewValues.tapAction {
            let actionHandler = TapActionHandler(action: tapAction)
            let tapGesture = UITapGestureRecognizer(target: actionHandler, action: #selector(TapActionHandler.executeAction))
            tapGesture.tapActionHandler = actionHandler
            tapGesture.delegate = actionHandler
            if let gestureRecognizers = gestureRecognizers {
                for gesture in gestureRecognizers where gesture is UITapGestureRecognizer {
                    removeGestureRecognizer(gesture)
                }
            }
            addGestureRecognizer(tapGesture)
        }
        
        if let onDrag = viewValues.onDrag {
            if let savedDrag = onDragDelegate {
                savedDrag.onDrag = onDrag
            } else {
                let delegate = OnDragDelegate(onDrag: onDrag)
                onDragDelegate = delegate
                isUserInteractionEnabled = true
                let interaction = UIDragInteraction(delegate: delegate)
                interaction.isEnabled = true
                addInteraction(interaction)
            }
        }
        
        if let onDrop = viewValues.onDrop {
            if let savedDrop = onDropDelegate {
                savedDrop.onDrop = onDrop
            } else {
                let delegate = OnDropDelegate(onDrop: onDrop)
                onDropDelegate = delegate
                isUserInteractionEnabled = true
                let interaction = UIDropInteraction(delegate: delegate)
                addInteraction(interaction)
            }
        }
    }
    private func setupNavigation(_ context: Context) {
        guard let controller = context.rootController ?? context.overwriteRootController else { return }
        
        if let navigationTitle = context.viewValues?.navigationTitle {
            controller.title = navigationTitle.title
            switch navigationTitle.displayMode {
            case .automatic:
                controller.navigationItem.largeTitleDisplayMode = .automatic
            case .inline:
                controller.navigationItem.largeTitleDisplayMode = .never
            case .large:
                controller.navigationItem.largeTitleDisplayMode = .always
            }
        }
        if let navigationItems = context.viewValues?.navigationItems {
            if let accentColor = context.viewValues?.accentColor {
                controller.navigationController?.navigationBar.tintColor = accentColor
            }
            if let leadingItems = navigationItems.leading {
                controller.navigationItem.setLeftBarButtonItems(leadingItems, animated: false)
            }
            if let trailingItems = navigationItems.trailing {
                controller.navigationItem.setRightBarButtonItems(trailingItems, animated: false)
            }
        }
        if let sheetPresentation = context.viewValues?.sheetPresentation {
            if sheetPresentation.isPresented.wrappedValue {
                controller.presentView(viewValues: context.viewValues, sheetPresentation: sheetPresentation)
            } else {
                controller.dismissPresentedView(sheetPresentation: sheetPresentation)
            }
        }
        if let alert = context.viewValues?.alert {
            controller.presentAlert(alert)
        }
        if let actionSheet = context.viewValues?.actionSheet {
            controller.presentActionSheet(actionSheet)
        }
        if let statusBarHidden = context.viewValues?.statusBarHidden {
            context.rootController?.setStatusBarHidden(statusBarHidden)
        }
        if let navigationBarHidden = context.viewValues?.navigationBarHidden {
            context.rootController?.setNavigationBarHidden(navigationBarHidden)
        }
        if let statusBarStyle = context.viewValues?.statusBarStyle {
            context.rootController?.setStatusBarStyle(statusBarStyle)
        }
        if #available(iOS 13.0, *) {
            if let contextMenuHolder = context.viewValues?.contextMenu {
                if let contextMenu = contextMenuHolder.content {
                    if let contextMenuHandler = self.contextMenuHandler {
                        contextMenuHandler.contextMenu = contextMenu
                    } else {
                        let contextMenuHandler = ContextMenuHandler(contextMenu: contextMenu)
                        self.contextMenuHandler = contextMenuHandler
                        addInteraction(UIContextMenuInteraction(delegate: contextMenuHandler))
                    }
                } else {
                    self.contextMenuHandler = nil
                    interactions.removeAll { $0 is UIContextMenuInteraction }
                }
            }
        }
        if #available(iOS 14.0, *) {
            if let skOverlayPresentation = context.viewValues?.skOverlayPresentation,
               let scene = controller.view.window?.windowScene {
                if skOverlayPresentation.isPresented.wrappedValue {
                    let overlay = SKOverlay(configuration: skOverlayPresentation.configuration())
                    overlay.present(in: scene)
                } else {
                    SKOverlay.dismiss(in: scene)
                }
            }
        }
    }
    private func setupController(_ context: Context, update: Bool) {
        guard let controller = context.rootController else { return }
        
        if let onAppear = context.viewValues?.onAppear {
            let handler = EventCodeHandler(handler: onAppear)
            controller.onAppearHandlers.setObject(handler, forKey: self)
            if let parentViewEventHandler = context.viewValues?.parentViewEventHandler {
                parentViewEventHandler.onAppearHandlers.setObject(handler, forKey: self)
            } else if !update {
                controller.insertOnAppearHandlers.setObject(handler, forKey: self)
            }
        }
        if let onDisappear = context.viewValues?.onDisappear {
            let handler = EventCodeHandler(handler: onDisappear)
            controller.onDisappearHandlers.setObject(handler, forKey: self)
            if let disappearHandlerView = self as? DisappearHandler {
                disappearHandlerView.disappearHandler = handler
            }
        }
    }
    private func setupCoordinate(_ context: Context) {
        if let coordinateSpace = context.viewValues?.coordinateSpace {
            EnvironmentHolder.coordinateSpaceNames[coordinateSpace] = WeakObject(object: self)
        }
    }
    
    // MARK: - Private methods: Helpers
    
    private func align(_ view: UIView, alignment: Alignment) {
        switch alignment.horizontal {
        case .leading:
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        case .center:
            view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        case .trailing:
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        switch alignment.vertical {
        case .top:
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        case .center:
            view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        case .bottom:
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        view.edgesGreaterOrEqualTo(view: self).activate()
    }
}

class ViewBinderHolder {
    var binders: [Int: ViewBinder] = [:]
}

extension UIView {
    static var ownedSwiftUIDelegateAssociatedKey = "OwnedSwiftUIDelegateAssociatedKey"
    static var pairedViewAssociatedKey = "PairedViewAssociatedKey"
    static var dimensionConstraintsAssociatedKey = "DimensionConstraintsAssociatedKey"
    static var lastRenderableViewAssociatedKey = "LastRenderableViewAssociatedKey"
    static var isAnimatingRemovalAssociatedKey = "isAnimatingRemovalAssociatedKey"
    static var hasPushedViewAssociatedKey = "HasPushedViewAssociatedKey"
    static var gestureHolderAssociatedKey = "GestureHolderAssociatedKey"
    static var contextMenuHandlerAssociatedKey = "ContextMenuHandlerAssociatedKey"
    static var onDragAssociatedKey = "onDragAssociatedKey"
    static var onDropAssociatedKey = "onDropAssociatedKey"
    var ownedSwiftUIDelegate: NSObject? {
        get {
            objc_getAssociatedObject(self, &Self.ownedSwiftUIDelegateAssociatedKey) as? NSObject
        }
        set {
            objc_setAssociatedObject(self, &Self.ownedSwiftUIDelegateAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var _viewBinderHolder: ViewBinderHolder? {
        get {
            objc_getAssociatedObject(self, &Self.pairedViewAssociatedKey) as? ViewBinderHolder
        }
        set {
            objc_setAssociatedObject(self, &Self.pairedViewAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func viewBinder(index: Int) -> ViewBinder? {
        _viewBinderHolder?.binders[index]
    }
    func addViewBinder(_ viewBinder: ViewBinder?, index: Int) {
        viewBinder?.uiView = self
        if let binder = _viewBinderHolder {
            binder.binders[index] = viewBinder
        } else {
            let binder = ViewBinderHolder()
            binder.binders[index] = viewBinder
            _viewBinderHolder = binder
        }
    }
    var dimensionConstraints: DimensionConstraints? {
        get {
            objc_getAssociatedObject(self, &Self.dimensionConstraintsAssociatedKey) as? DimensionConstraints
        }
        set {
            objc_setAssociatedObject(self, &Self.dimensionConstraintsAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var lastRenderableView: LastRenderableView? {
        get {
            objc_getAssociatedObject(self, &Self.lastRenderableViewAssociatedKey) as? LastRenderableView
        }
        set {
            objc_setAssociatedObject(self, &Self.lastRenderableViewAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var isAnimatingRemoval: Bool? {
        get {
            objc_getAssociatedObject(self, &Self.isAnimatingRemovalAssociatedKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &Self.isAnimatingRemovalAssociatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var hasPushedView: Bool? {
        get {
            objc_getAssociatedObject(self, &Self.hasPushedViewAssociatedKey) as? Bool
        }
        set {
            objc_setAssociatedObject(self, &Self.hasPushedViewAssociatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    var gestureHolders: GestureHolders? {
        get {
            objc_getAssociatedObject(self, &Self.gestureHolderAssociatedKey) as? GestureHolders
        }
        set {
            objc_setAssociatedObject(self, &Self.gestureHolderAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @available(iOS 13.0, *)
    var contextMenuHandler: ContextMenuHandler? {
        get {
            objc_getAssociatedObject(self, &Self.contextMenuHandlerAssociatedKey) as? ContextMenuHandler
        }
        set {
            objc_setAssociatedObject(self, &Self.contextMenuHandlerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var onDragDelegate: OnDragDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.onDragAssociatedKey) as? OnDragDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.onDragAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var onDropDelegate: OnDropDelegate? {
        get {
            objc_getAssociatedObject(self, &Self.onDropAssociatedKey) as? OnDropDelegate
        }
        set {
            objc_setAssociatedObject(self, &Self.onDropAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Utility

extension UIEdgeInsets {
    static func withEdgeInsets(_ edgeInsets: EdgeInsets) -> Self {
        UIEdgeInsets(top: edgeInsets.top, left: edgeInsets.leading, bottom: edgeInsets.bottom, right: edgeInsets.trailing)
    }
}

extension UILabel {
    func alignText(alignment: TextAlignment) {
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
        switch alignment {
        case .leading:
            textAlignment = .natural
        case .center:
            textAlignment = .center
        case .trailing:
            textAlignment = (layoutDirection == .leftToRight) ? .right : .left
        }
    }
}
