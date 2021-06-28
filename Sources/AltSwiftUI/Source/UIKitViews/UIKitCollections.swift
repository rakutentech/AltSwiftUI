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

class SwiftUICollectionView: UICollectionView {
    enum Orientation {
        case vertical, horizontal
    }
    class FlowLayout: UICollectionViewFlowLayout {
        let orientation: Orientation
        init(orientation: Orientation) {
            self.orientation = orientation;
            super.init()
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)
            layoutAttributesObjects?.forEach({ layoutAttributes in
                if layoutAttributes.representedElementCategory == .cell {
                    if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                        layoutAttributes.frame = newFrame
                    }
                }
            })
            return layoutAttributesObjects
        }
        
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            guard let collectionView = collectionView else {
                return nil;
            }
            guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else {
                return nil
            }

            switch orientation {
            case .horizontal:
                layoutAttributes.frame.origin.y = sectionInset.top
                layoutAttributes.frame.size.height = collectionView.safeAreaLayoutGuide.layoutFrame.height - sectionInset.top - sectionInset.bottom
            case .vertical:
                layoutAttributes.frame.origin.x = sectionInset.left
                layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
            }
            
            return layoutAttributes
        }
    }
    
    let orientation: Orientation
    var itemViewBuilder: ((Int) -> UIView)?
    var itemCount: Int = 0
    let cellReuseIdentifier = "SwiftUICollectionCellReuseId";
    
    init(orientation: Orientation) {
        self.orientation = orientation
        let layout = FlowLayout(orientation: orientation)
        switch orientation {
        case .horizontal: layout.scrollDirection = .horizontal
        case .vertical: layout.scrollDirection = .vertical
        }
        
        layout.sectionInsetReference = .fromContentInset
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
//        }
//        layout.scrollDirection = collectionViewConfiguration.scrollDirection
//        layout.sectionInset = collectionViewConfiguration.sectionInset
//        layout.minimumInteritemSpacing = collectionViewConfiguration.minimumInteritemSpacing
//        layout.minimumLineSpacing = collectionViewConfiguration.minimumLineSpacing
        super.init(frame: .zero, collectionViewLayout: layout)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: CGFloat.limitForUI, height: CGFloat.limitForUI)
    }
    
    func setupView() {
        delegate = self
        dataSource = self
        register(SwiftUICollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        backgroundColor = .clear
        contentInsetAdjustmentBehavior = .always
    }
    
    func updateItems(itemCount: Int, itemViewBuilder: @escaping (Int) -> UIView) {
        self.itemCount = itemCount
        self.itemViewBuilder = itemViewBuilder
    }
}

extension SwiftUICollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? SwiftUICollectionViewCell else {
            return UICollectionViewCell();
        }
        if let itemViewBuilder = itemViewBuilder {
            cell.setupContent(
                view: itemViewBuilder(indexPath.row).noAutoresizingMask(),
                orientation: orientation) { [weak self] in
                self?.performBatchUpdates(nil)
            }
        }
        return cell;
    }
}

class SwiftUICollectionViewCell: UICollectionViewCell {
    var orientation: SwiftUICollectionView.Orientation?
    var onResizeRequested: (() -> Void)?
    var contentViewRoot: UIView?
    
    private var lastLayoutSize: CGSize?
    private var lastTargetSize: CGSize?
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let autoLayoutSize = layoutSize(targetSize: layoutAttributes.frame.size)
        lastLayoutSize = autoLayoutSize
        lastTargetSize = layoutAttributes.frame.size
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func setupContent(
        view: UIView,
        orientation: SwiftUICollectionView.Orientation,
        onResizeRequested: @escaping () -> Void) {
        self.orientation = orientation
        self.onResizeRequested = onResizeRequested
        contentViewRoot = view
        cleanContent()
        contentView.addSubview(view)
        view.edgesAnchorEqualTo(view: contentView, rightPriority: .required - 1, bottomPriority: .required - 1).activate()
    }
    
    func cleanContent() {
        lastLayoutSize = nil;
        lastTargetSize = nil;
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func updateRendering() {
        if let lastLayoutSize = lastLayoutSize,
           let lastTargetSize = lastTargetSize,
           layoutSize(targetSize: lastTargetSize) != lastLayoutSize {
            onResizeRequested?()
        }
    }
    
    private func layoutSize(targetSize: CGSize) -> CGSize {
        switch orientation {
        case .horizontal:
            let targetSize = CGSize(width: 0, height: targetSize.height)
            return contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required)
        case .vertical:
            let targetSize = CGSize(width: targetSize.width, height: 0)
            return contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        case .none: return CGSize(width: 1, height: 1)
        }
    }
}
