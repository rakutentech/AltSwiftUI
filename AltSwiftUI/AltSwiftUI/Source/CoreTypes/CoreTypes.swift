//
//  CoreTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Data

/// A type that can be uniquely identified.
public protocol Identifiable {

    /// A type representing the stable identity of the entity associated with `self`.
    associatedtype ID : Hashable

    /// The stable identity of the entity associated with `self`.
    var id: Self.ID { get }
}

struct WeakObject<T: AnyObject> {
    weak var object: T?
}

// MARK: - Layout

class DimensionConstraints {
    init(value: [NSLayoutConstraint]) {
        self.value = value
    }
    let value: [NSLayoutConstraint]
}

// MARK: - Style

private struct TraitColorHandlerAssociation {
    static var borderColorKey = "DisappearHandlerAssociatedKey"
}

protocol TraitColorHandler: AnyObject {
}

extension TraitColorHandler where Self: UIView {
    var borderColor: UIColor? {
        get {
            objc_getAssociatedObject(self, &TraitColorHandlerAssociation.borderColorKey) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &TraitColorHandlerAssociation.borderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    func updateOnTraitChange(previousTrait: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTrait) {
                layer.borderColor = self.borderColor?.cgColor
            }
        }
    }
}

// MARK: - Drag and Drop

class OnDragDelegate: NSObject, UIDragInteractionDelegate {
    var onDrag: OnDragValues
    
    init(onDrag: OnDragValues) {
        self.onDrag = onDrag
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        [UIDragItem(itemProvider: onDrag.provider())]
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        onDrag.dragBegan?()
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, session: UIDragSession, willEndWith operation: UIDropOperation) {
        onDrag.dragEnded?(operation)
    }
}

class OnDropDelegate: NSObject, UIDropInteractionDelegate {
    var onDrop: OnDropValues
    init(onDrop: OnDropValues) {
        self.onDrop = onDrop
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        _ = onDrop.action(session.items.map { $0.itemProvider })
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        if session.localDragSession == nil {
            return UIDropProposal(operation: .forbidden)
        }
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        onDrop.isTargeted?.wrappedValue = true
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        onDrop.isTargeted?.wrappedValue = false
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        onDrop.isTargeted?.wrappedValue = false
    }
}

// MARK: - Geometry Listener

protocol GeometryListener: AnyObject {
}

extension UIView {
    static var geometryProxyAssociatedKey = "GeometryProxyAssociatedKey"
}

extension GeometryListener where Self: UIView {
    var geometryProxy: GeometryProxyHolder? {
        get {
            objc_getAssociatedObject(self, &UIView.geometryProxyAssociatedKey) as? GeometryProxyHolder
        }
        set {
            objc_setAssociatedObject(self, &UIView.geometryProxyAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func registerGeometryListener(_ geometry: Binding<GeometryProxy>) {
        geometryProxy = GeometryProxyHolder(geometry: geometry)
    }
    
    func notifyGeometryListener(frame: CGRect) {
        geometryProxy?.geometry.wrappedValue = GeometryProxy(frame: frame, view: self)
    }
}

class GeometryProxyHolder {
    let geometry: Binding<GeometryProxy>
    init(geometry: Binding<GeometryProxy>) {
        self.geometry = geometry
    }
}

// MARK: - View Handlers

class TapActionHandler: NSObject, UIGestureRecognizerDelegate {
    let action: () -> Void
    init(action: @escaping () -> Void) {
        self.action = action
    }
    @objc func executeAction() {
        action()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is SwiftUIButton {
            return false
        } else {
            return true
        }
    }
}

extension UIGestureRecognizer {
    static var tapActionHandlerAssociatedKey = "TapActionHandlerAssociatedKey"
    var tapActionHandler: TapActionHandler? {
        get {
            objc_getAssociatedObject(self, &Self.tapActionHandlerAssociatedKey) as? TapActionHandler
        }
        set {
            objc_setAssociatedObject(self, &Self.tapActionHandlerAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class ParentViewEventHandler {
    var onAppearHandlers: NSMapTable<UIView, EventCodeHandler> = NSMapTable(keyOptions: .weakMemory, valueOptions: .strongMemory)
    
    func executeOnAppearHandlers() {
        let enumerator = onAppearHandlers.objectEnumerator()
        while let handler = enumerator?.nextObject() as? EventCodeHandler {
            handler.handler()
        }
    }
}

@available(iOS 13.0, *)
class ContextMenuHandler: NSObject, UIContextMenuInteractionDelegate {
    var contextMenu: ContextMenu
    
    init(contextMenu: ContextMenu) {
        self.contextMenu = contextMenu
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] elements in
            guard let `self` = self else {
                return UIMenu(title: "", image: nil, identifier: nil, children: [])
            }
            
            var actions: [UIMenuElement] = []
            self.contextMenu.items.iterateFullViewInsert { view in
                guard let button = view as? Button else { return }
                
                let label = button.labels.first { $0 is Text } as? Text
                let image = button.labels.first { $0 is Image } as? Image
                let action = UIAction(title: label?.string ?? "", image: image?.image, identifier: nil, state: .off) { _ in
                    button.action()
                }
                actions.append(action)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, children: actions)
        }
    }
}

private struct DisappearHandlerAssociation {
    static var key = "DisappearHandlerAssociatedKey"
}

protocol DisappearHandler: AnyObject {
    func executeDisappearHandler()
}

extension DisappearHandler {
    var disappearHandler: EventCodeHandler? {
        get {
            objc_getAssociatedObject(self, &DisappearHandlerAssociation.key) as? EventCodeHandler
        }
        set {
            objc_setAssociatedObject(self, &DisappearHandlerAssociation.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func executeDisappearHandler() {
        disappearHandler?.handler()
    }
}

/// UIView that is able to handle View events
protocol UIKitViewHandler: GeometryListener, TraitColorHandler, DisappearHandler {}
