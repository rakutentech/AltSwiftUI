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
    var hiddenSubviewsCount = 0
    
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
    
    var nonHiddenSubviewsCount: Int {
        arrangedSubviews.count - hiddenSubviewsCount
    }
    
    func addViews(_ views: [View], context: Context, isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        context.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            var equalViews = [UIView]()
            views.iterateFullViewInsert { view in
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
    func updateViews(_ views: [View], oldViews: [View], context: Context, isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        context.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            
            var equalViews = [UIView]()
            var equalViewReference: UIView?
            
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
                    
                    let viewAnim = context.viewValues?.animatedValues?.first?.animation
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
                    self.hiddenSubviewsCount += 1
                    
                    removeGroup.enter()
                    view.performRemovalTransition(view: uiView, animation: context.transaction?.animation, completion: {
                        removeGroup.leave()
                    })
                    
                    removeGroup.notify(queue: .main) {
                        uiView.removeFromSuperview()
                        self.hiddenSubviewsCount -= 1
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
}

class SwiftUILazyStackView: SwiftUIStackView {
    var isPendingFirstLayout = true
    var viewsLengthSum: CGFloat = 0
    var lastContext: Context?
    weak var lazyStackScrollView: UIScrollView?
    /// Content views totally flattened with optional view information
    var lazyStackFlattenedContentViews: [View] = []
    var insertLazyContentOnFirstLayout = false
    var lastInsertedIndex: Int {
        nonHiddenSubviewsCount - 1
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
        super.layoutSubviews()
        
        if isPendingFirstLayout {
            isPendingFirstLayout = false
            if insertLazyContentOnFirstLayout {
                insertViewsUntilVisibleArea()
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
    func insertViewsUntilVisibleArea() {
        guard let lastContext = lastContext else {
            return
        }
        if isPendingFirstLayout {
            insertLazyContentOnFirstLayout = true
            return
        }
        
        let initialSubviewsCount = arrangedSubviews.count
        let lastEdge = lazyStackLastEdge
        var maxCurrentLength = viewsLengthSum
        if maxCurrentLength < lastEdge && bounds.size == .zero {
            layoutIfNeeded()
        }
        while maxCurrentLength < lastEdge {
            guard var viewToInsert = lazyStackFlattenedContentViews[safe: lastInsertedIndex + 1] else {
                break
            }
            if let optionalView = viewToInsert as? OptionalView,
               let optionalViewFirstContent = optionalView.content?.first {
                viewToInsert = optionalViewFirstContent
            }
            guard let uiView = viewToInsert.renderableView(parentContext: lastContext) else {
                break
            }
            
            let uiViewLength = viewLength(for: uiView)
            addArrangedSubview(uiView)
            maxCurrentLength += uiViewLength
        }
        viewsLengthSum = maxCurrentLength
        
        if initialSubviewsCount != arrangedSubviews.count {
            lastContext.executePostRender()
        }
    }
    
    /// Updates loaded views and insert views if resulting content size
    /// is less than the content size + visible area.
    func updateLazyStack(newViews: [View], isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        guard let lastContext = lastContext else {
            return
        }
        
        // Update all loaded views
        let numberOfLoadedViews = nonHiddenSubviewsCount
        let loadedViews = Array(newViews.prefix(numberOfLoadedViews))
        let loadedOldViews = Array(lazyStackFlattenedContentViews.prefix(numberOfLoadedViews))
        // update numberOfLoadediews only
        updateViews(loadedViews, oldViews: loadedOldViews, context: lastContext, isEquallySpaced: isEquallySpaced, setEqualDimension: setEqualDimension)
        
        lazyStackFlattenedContentViews = newViews
        
        // Update views length after update
        lastContext.viewOperationQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            let previousViewsLength = self.viewsLengthSum
            self.viewsLengthSum = self.viewLength(for: self)
            
            // Insert lazy views if there are no layout changes
            // Layout changes insertion will be handled by the scroll view.
            if previousViewsLength == self.viewsLengthSum {
                self.insertViewsUntilVisibleArea()
            }
        }
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
