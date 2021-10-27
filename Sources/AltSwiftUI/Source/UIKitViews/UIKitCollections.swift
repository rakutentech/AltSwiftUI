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
    private var isPendingFirstLayout = true
    private var onFirstLayoutOperationQueue = [() -> Void]()
    
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
        if onFirstLayoutOperationQueue.count > 0 {
            for operation in onFirstLayoutOperationQueue {
                operation()
            }
            onFirstLayoutOperationQueue.removeAll()
        }
        isPendingFirstLayout = false
    }
    func executeAfterFirstLayout(_ operation: @escaping () -> Void) {
        if isPendingFirstLayout {
            onFirstLayoutOperationQueue.append(operation)
        } else {
            operation()
        }
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
    var viewsLength: [CGFloat] = []
    var maxViewsLengthSum: CGFloat {
        viewsLength.reduce(0, +)
    }
    var updatedViewsIndexes = Set<Int>()
    var lastContext: Context?
    var lastInsertedIndex: Int {
        viewsLength.count - 1
    }
    
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
    
    /// Inserts views since the last inserted index until the last view of the visible area
    func insertViews(visibleLength: CGFloat, offset: CGFloat, views: [View]) {
        guard let lastContext = lastContext else {
            return
        }
        
        let lastEdge = visibleLength + offset
        var maxCurrentLength = maxViewsLengthSum
        while maxCurrentLength < lastEdge {
            guard let viewToInsert = views[safe: lastInsertedIndex + 1],
                  let uiView = viewToInsert.renderableView(parentContext: lastContext) else {
                return
            }
            let uiViewLength = viewLength(for: uiView)
            insertView(uiView, viewLength: uiViewLength)
            maxCurrentLength += uiViewLength
        }
    }
    
    /// Updates all loaded views. If views are missing before the start of the visible area, or
    /// after the last inserted view until the end of the visible area, these view are inserted.
    func updateViews(visibleLength: CGFloat, offset: CGFloat, views: [View], oldViews: [View], isEquallySpaced: @escaping (View) -> Bool, setEqualDimension: @escaping (UIView, UIView) -> Void) {
        guard let lastContext = lastContext else {
            return
        }
        
        // Update all loaded views
        let numberOfLoadedViews = arrangedSubviews.count
        let loadedViews = Array(views.prefix(numberOfLoadedViews))
        let loadedOldViews = Array(oldViews.prefix(numberOfLoadedViews))
        // update numberOfLoadediews only
        updateViews(loadedViews, oldViews: loadedOldViews, context: lastContext, isEquallySpaced: isEquallySpaced, setEqualDimension: setEqualDimension)
        
        // Insert missing views until end of visible area
        insertViews(visibleLength: visibleLength, offset: offset, views: views)
    }
    
//    /// If views are missing before the start of the visible area, or
//    /// after the last inserted view until the end of the visible area, these view are inserted.
//    func setVisibleOffset(visibleLength: CGFloat, offset: CGFloat, viewForIndex: (_ index: Int) -> View?) {
//        guard let lastContext = lastContext else {
//            return
//        }
//
//        let maxCurrentLength = maxViewsLengthSum
//        if maxCurrentLength <= offset {
//            // Views are missing before the start of the visible area.
//            // Insert only.
//            insertViews(visibleLength: visibleLength, offset: offset, viewForIndex: viewForIndex)
//        } else {
//            updatedViewsIndexes.removeAll()
//            var iterationIndex = 0
//            var viewLengthSum: CGFloat = 0
//
//            // find the first index of visible area
//            for viewLength in viewsLength {
//                viewLengthSum += viewLength
//                if viewLengthSum > offset {
//                    break
//                }
//                iterationIndex += 1
//            }
//
//            // iterate visible views
//            let lastEdge = visibleLength + offset
//            while viewLengthSum < lastEdge {
//                let viewToUpdate = viewForIndex(iterationIndex)
//                guard viewToUpdate != nil else {
//                    break
//                }
//
//                if arrangedSubviews.count <= iterationIndex {
//                    // Insert view
//                    guard let uiviewToInsert = viewToUpdate?.renderableView(parentContext: lastContext) else {
//                        break
//                    }
//                    let insertedViewLength = viewLength(for: uiviewToInsert)
//                    insertView(uiviewToInsert, viewLength: insertedViewLength)
//
//                    // add to total length
//                    viewLengthSum += insertedViewLength
//                }
//
//                iterationIndex += 1
//            }
//        }
//    }
    
    private func insertView(_ view: UIView, viewLength: CGFloat) {
        let index = arrangedSubviews.count
        addArrangedSubview(view)
        viewsLength.append(viewLength)
        updatedViewsIndexes.insert(index)
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
    var cells = [Int: SwiftUICollectionViewCell]()
    
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
    
    func resetCellCache() {
        cells = [:]
    }
}

extension SwiftUICollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cachedCell = cells[indexPath.row] {
            return cachedCell
        }
        
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? SwiftUICollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if cells[indexPath.row] == nil {
            cells[indexPath.row] = cell
        }
        
        if let itemViewBuilder = itemViewBuilder {
            cell.setupContent(
                view: itemViewBuilder(indexPath.row).noAutoresizingMask(),
                orientation: orientation) { [weak self] in
                self?.reloadItems(at: [indexPath])
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
        if orientation == .horizontal {
            view.edgesAnchorEqualTo(view: contentView, rightPriority: .required - 1).activate()
        } else {
            view.edgesAnchorEqualTo(view: contentView, bottomPriority: .required - 1).activate()
        }
    }
    
    func cleanContent() {
        lastLayoutSize = nil;
        lastTargetSize = nil;
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func updateRendering() {
//        if let lastLayoutSize = lastLayoutSize,
//           let lastTargetSize = lastTargetSize,
//           layoutSize(targetSize: lastTargetSize) != lastLayoutSize {
//            onResizeRequested?()
//            print("yay")
//        }
        print("yay")
        onResizeRequested?()
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
