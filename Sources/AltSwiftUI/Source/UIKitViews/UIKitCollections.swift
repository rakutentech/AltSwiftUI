//
//  UIKitCollections.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class SwiftUIScrollView: UIScrollView, UIKitViewHandler {
    var contentOffsetBinding: Binding<CGPoint>?
    var contentView: UIView?
    var interactiveScrollEnabled = true {
        didSet {
            var offset = contentOffset
            if offset.y < 0 {
                offset = .zero
                fixBouncingScroll = true
            }
            previousInteractiveScrollOffset = offset
        }
    }
    var previousInteractiveScrollOffset: CGPoint = .zero
    var fixBouncingScroll = false
    let axis: Axis
    var onScroll: (() -> Void)?
    let containerView = UIView().noAutoresizingMask()
    weak var rootLazyStack: SwiftUIStackView?
    private var isPendingFirstLayout = true
    private var onNewLayoutOperationQueue = [() -> Void]()
    
    init(axis: Axis) {
        self.axis = axis
        super.init(frame: .zero)
        setupView()
        delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: (axis == .horizontal || axis == .both) ? CGFloat.limitForUI : size.width,
                      height: (axis == .vertical || axis == .both) ? CGFloat.limitForUI : size.height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
        if UIView.inheritedAnimationDuration > 0 {
            // Execute operations outside of animations
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                for operation in self.onNewLayoutOperationQueue {
                    operation()
                }
            }
        } else {
            for operation in self.onNewLayoutOperationQueue {
                operation()
            }
        }
        
        isPendingFirstLayout = false
        // TODO: P3 lock tree
    }
    func addMainSubview(_ view: UIView) {
        containerView.addSubview(view)
        addSubview(containerView)
        contentView = view
        
        view.edgesAnchorEqualTo(destinationView: containerView).activate()
        containerView.edgesAnchorEqualTo(destinationView: self).activate()
        if axis == .horizontal {
            heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        } else if axis == .vertical {
            widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }
    func executeOnNewLayout(_ operation: @escaping () -> Void) {
        if !isPendingFirstLayout {
            operation()
        }
        onNewLayoutOperationQueue.append(operation)
    }
    private func setupView() {
        if axis == .vertical || axis == .both {
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        }
        if axis == .horizontal || axis == .both {
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
}

extension SwiftUIScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !interactiveScrollEnabled {
            if fixBouncingScroll && scrollView.contentOffset.y < 0 {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let `self` = self else { return }
                    scrollView.contentOffset = self.previousInteractiveScrollOffset
                }
            } else {
                scrollView.contentOffset = previousInteractiveScrollOffset
            }
            if fixBouncingScroll {
                fixBouncingScroll = false
            }
            return
        }
        withHighPerformance {
            self.contentOffsetBinding?.wrappedValue = scrollView.contentOffset
        }
        onScroll?()
    }
}

class SwiftUITableView: UITableView, UIKitViewHandler {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: CGFloat.limitForUI, height: CGFloat.limitForUI)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    private func setupView() {
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        keyboardDismissMode = .interactive
    }
}

class SwiftUIStackView: UIStackView, UIKitViewHandler {
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in arrangedSubviews {
            if view.point(inside: convert(point, to: view), with: event) {
                return true
            }
        }
        for subView in subviews {
            if subView.point(inside: convert(point, to: subView), with: event) {
                return true
            }
        }
        return false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
}

class SwiftUILazyStackView: SwiftUIStackView {
    class LazyStackTreeLock {
        var locked = false
    }
    
    var isPendingFirstLayout = true
    var viewsLengthSum: CGFloat = 0
    var lastContext: Context?
    // TODO: P3 Set lazy direction and current tree node in context from scroll view. Build tree in lazyStack: View createView method.
    weak var lazyStackTreeParent: SwiftUIStackView?
    var lazyStackTreeChildren: [WeakObject<SwiftUIStackView>] = []
    var lazyStackTreeLock = LazyStackTreeLock()
    weak var lazyStackScrollView: UIScrollView?
    var lazyStackContentViews: [View] = []
    var insertLazyContentOnFirstLayout = false
    var lastInsertedIndex: Int {
        arrangedSubviews.count - 1
    }
    var lazyStackLastEdge: CGFloat {
        if axis == .horizontal {
            let visibleLength = lazyStackScrollView?.bounds.width ?? 0
            let offset = lazyStackScrollView?.contentOffset.x ?? 0
            return visibleLength + offset - lazyStackOffsetInContainer.minX
        } else {
            let visibleLength = lazyStackScrollView?.bounds.height ?? 0
            let offset = lazyStackScrollView?.contentOffset.y ?? 0
            return visibleLength + offset - lazyStackOffsetInContainer.minY
        }
    }
    var lazyStackOffsetInContainer: CGRect {
        guard let containerView = lazyStackScrollView?.subviews.first else {
            return .zero
        }
        return superview?.convert(frame, to: containerView) ?? .zero
    }
    
    override func layoutSubviews() {
        // TODO: P3 Lock lazy tree
        let locker = !lazyStackTreeLock.locked
        if locker {
            lazyStackTreeLock.locked = true
        }
        
        super.layoutSubviews()
        
        if isPendingFirstLayout {
            isPendingFirstLayout = false
            if insertLazyContentOnFirstLayout {
                insertLazyViews()
            }
        }
        
        if locker {
            // TODO:  P3 If locker, insert remaining views.
            lazyStackTreeLock.locked = false
            if let scrollView = lazyStackScrollView {
                
            }
        }
    }
    override var intrinsicContentSize: CGSize {
        if lazyStackScrollView != nil {
            var superSize = super.intrinsicContentSize
            if axis == .horizontal {
                superSize.height = CGFloat.limitForUI
            } else {
                superSize.width = CGFloat.limitForUI
            }
            return superSize
        } else {
            return super.intrinsicContentSize
        }
    }
    
    /// Inserts views since the last inserted index until the last view of the visible area
    func insertLazyViews() {
        guard let lastContext = lastContext else {
            return
        }
        if isPendingFirstLayout {
            insertLazyContentOnFirstLayout = true
            return
        }
        
        // TODO: P3 Insert in last child and use updated size for sum in maxLength
        let lastEdge = lazyStackLastEdge
        var maxCurrentLength = viewsLengthSum
        if maxCurrentLength < lastEdge && bounds.size == .zero {
            layoutIfNeeded()
        }
        while maxCurrentLength < lastEdge {
            guard let viewToInsert = lazyStackContentViews[safe: lastInsertedIndex + 1],
                  let uiView = viewToInsert.renderableView(parentContext: lastContext) else {
                break
            }
            let uiViewLength = viewLength(for: uiView)
            addArrangedSubview(uiView)
            // TODO: P3 Insert in new child and update uiViewLength
            maxCurrentLength += uiViewLength
        }
        viewsLengthSum = maxCurrentLength
    }
    
    /// Updates only loaded views
    func updateLazyViews(newViews: [View], isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        guard let lastContext = lastContext else {
            return
        }
        
        // Update all loaded views
        let numberOfLoadedViews = arrangedSubviews.count
        let loadedViews = Array(newViews.prefix(numberOfLoadedViews))
        let loadedOldViews = Array(lazyStackContentViews.prefix(numberOfLoadedViews))
        // update numberOfLoadediews only
        updateViews(loadedViews, oldViews: loadedOldViews, context: lastContext, isEquallySpaced: isEquallySpaced, setEqualDimension: setEqualDimension)
        // Update views length after update
        lastContext.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            self.viewsLengthSum = self.viewLength(for: self)
        }
        
        lazyStackContentViews = newViews
    }
    
    func appendToLazyStackTreeParent(_ parent: SwiftUILazyStackView) {
        lazyStackTreeParent = parent
        parent.lazyStackTreeChildren.append(WeakObject(object: self))
        lazyStackTreeLock = parent.lazyStackTreeLock
        lazyStackScrollView = parent.lazyStackScrollView
    }
    
    private func viewLength(for view: UIView) -> CGFloat {
        switch axis {
        case .horizontal:
            let targetSize = CGSize(width: 0, height: bounds.height)
            return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required).width
        case .vertical:
            let targetSize = CGSize(width: bounds.width, height: 0)
            return view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
        @unknown default:
            return 1
        }
    }
}
