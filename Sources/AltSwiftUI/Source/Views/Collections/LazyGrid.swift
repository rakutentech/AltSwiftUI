//
//  LazyGrid.swift
//  AltSwiftUI
//
//  Created by Furqan, Sara | Sara | TID on 2021/02/26.
//

import UIKit

/// A container view that arranges its child views in a grid that
/// grows horizontally, creating items only as needed.
///
/// The grid is "lazy," in that the grid view does not create items until
/// they are needed.
public struct LazyHGrid<Content>: View where Content : View {
    var rows: [GridItem]
    var alignment: VerticalAlignment
    var spacing: CGFloat?
    let viewContent: [Content]
    public var viewStore = ViewValues()
    /// Creates a grid that grows horizontally, given the provided properties.
    ///
    /// - Parameters:
    ///   - rows: An array of grid items to size and position each column of
    ///    the grid.
    ///   - alignment: The alignment of the grid within its parent view.
    ///   - spacing: The spacing beween the grid and the next item in its
    ///   parent view.
    ///   - pinnedViews: Views to pin to the bounds of a parent scroll view.
    ///   - content: The content of the grid.
    public init(rows: [GridItem], alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> View) {
        let contentView = content()
        viewContent = contentView.mappedSubViews { $0 } as! [Content]
        self.rows = rows
        self.alignment = alignment
        self.spacing = spacing
        viewStore.direction = .horizontal
    }
    init(viewContent: [Content]) {
        self.viewContent = viewContent
        alignment = .center
        spacing = SwiftUIConstants.defaultSpacing
    }
    public var body: View {
        EmptyView()
    }
}
extension LazyHGrid: Renderable {
    public func createView(context: Context) -> UIView {
        let configuration = CollectionView<Content>.Configuration(
                itemSize: rows.first?.size,
                automaticItemSize: true,
                scrollDirection: UICollectionView.ScrollDirection.horizontal,
                backgroundColor: nil,
                showsHorizontalScrollIndicator: true,
                showsVerticalScrollIndicator: false,
                minimumInteritemSpacing: rows.first?.spacing ?? 0,
                minimumLineSpacing: 0,
                isItemPagingEnabled: true,
                extraEmptyItems: 1
            )
        let hGrid = CollectionView(
            cellData: viewContent,
            configuration: configuration) { (data, index) -> UIHostingController in
            UIHostingController(rootView: data)
        }
        return hGrid
    }
    public func updateView(_ view: UIView, context: Context) {
        
    }
}

/// A container view that arranges its child views in a grid that
/// grows vertically, creating items only as needed.
///
/// The grid is "lazy," in that the grid view does not create items until
/// they are needed.
public struct LazyVGrid<Content>: View where Content : View {
    public var viewStore = ViewValues()
    
    var columns: [GridItem]
    var alignment: HorizontalAlignment
    var spacing: CGFloat?
    var viewContent: [Content]

    /// Creates a grid that grows vertically, given the provided properties.
    ///
    /// - Parameters:
    ///   - columns: An array of grid items to size and position each row of
    ///    the grid.
    ///   - alignment: The alignment of the grid within its parent view.
    ///   - spacing: The spacing beween the grid and the next item in its
    ///   parent view.
    ///   - pinnedViews: Views to pin to the bounds of a parent scroll view.
    ///   - content: The content of the grid.
    public init(columns: [GridItem], alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> View) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        let contentView = content()
        self.viewContent = contentView.mappedSubViews { $0 } as! [Content]
    }
    public var body: View {
        EmptyView()
    }
}

extension LazyVGrid: Renderable {
    public func createView(context: Context) -> UIView {
        let configuration = CollectionView<Content>.Configuration(
            itemSize: columns.first?.size,
            automaticItemSize: true,
            scrollDirection: UICollectionView.ScrollDirection.vertical,
            backgroundColor: nil,
            showsHorizontalScrollIndicator: false,
            showsVerticalScrollIndicator: true,
            minimumInteritemSpacing: columns.first?.spacing ?? 0,
            minimumLineSpacing: 0,
            isItemPagingEnabled: true,
            extraEmptyItems: 1)
        
        let vGrid = CollectionView(
            cellData: viewContent,
            configuration: configuration) { (data, index) -> UIHostingController in
            UIHostingController(rootView: data)
        }
        return vGrid
    }
    public func updateView(_ view: UIView, context: Context) {
    }
}

public struct GridItem {
    /// The size in the minor axis of one or more rows or columns in a grid
    /// layout.
    public enum Size {
        /// A single item with the specified fixed size.
        case fixed(CGFloat)
        /// A single flexible item.
        ///
        /// The size of this item is the size of the grid with spacing and
        /// inflexible items removed, divided by the number of flexible items,
        /// clamped to the provided bounds.
        case flexible(minimum: CGFloat = 10, maximum: CGFloat = .infinity)
        /// Multiple items in the space of a single flexible item.
        ///
        /// This size case places one or more items into the space assigned to
        /// a single `flexible` item, using the provided bounds and
        /// spacing to decide exactly how many items fit. This approach prefers
        /// to insert as many items of the `minimum` size as possible
        /// but lets them increase to the `maximum` size.
        case adaptive(minimum: CGFloat, maximum: CGFloat = .infinity)
    }
    /// The size of the item, which is the width of a column item or the
    /// height of a row item.
    public var size: GridItem.Size
    /// The spacing to the next item.
    ///
    /// If this value is `nil`, the item uses a reasonable default for the
    /// current platform.
    public var spacing: CGFloat?
    /// The alignment to use when placing each view.
    ///
    /// Use this property to anchor the view's relative position to the same
    /// relative position in the view's assigned grid space.
    public var alignment: Alignment?
    /// Creates a grid item with the provided size, spacing, and alignment
    /// properties.
    ///
    /// - Parameters:
    ///   - size: The size of the grid item.
    ///   - spacing: The spacing to use between this and the next item.
    ///   - alignment: The alignment to use for this grid item.
    public init(_ size: GridItem.Size = .flexible(), spacing: CGFloat? = nil, alignment: Alignment? = nil) {
        self.size = size
        self.spacing = spacing
        self.alignment = alignment
    }
}

public struct CollectionView<Data>: UIViewControllerRepresentable {
    public typealias BuildCellClosure = (Data, Int) -> UIHostingController
    public typealias SelectionClosure = (Data, Int) -> Void
    public var viewStore: ViewValues = ViewValues()

    private var cellData: [Data]
    private let buildCell: BuildCellClosure
    private let collectionViewConfiguration: Configuration
    private let onSelection: SelectionClosure?
    private let selectedPageIndex: Binding<Int>?
    
    public init(
        cellData: [Data],
        configuration: Configuration,
        selectedPageIndex: Binding<Int>? = nil,
        cellBuilder: @escaping BuildCellClosure,
        onSelection: SelectionClosure? = nil) {
        self.cellData = cellData
        self.onSelection = onSelection
        self.collectionViewConfiguration = configuration
        self.selectedPageIndex = selectedPageIndex
        self.buildCell = cellBuilder
    }
    
    public func makeCoordinator() -> CollectionView.Coordinator {
        Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: UIContext) -> CollectionViewController {
        let layout = UICollectionViewFlowLayout()
        if let itemSize = collectionViewConfiguration.itemSize {
            layout.itemSize = itemSize
        }
        if collectionViewConfiguration.automaticItemSize {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        layout.scrollDirection = collectionViewConfiguration.scrollDirection
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = collectionViewConfiguration.backgroundColor
        collectionView.showsHorizontalScrollIndicator = collectionViewConfiguration.showsHorizontalScrollIndicator
        collectionView.showsVerticalScrollIndicator = collectionViewConfiguration.showsVerticalScrollIndicator
        layout.sectionInset = collectionViewConfiguration.sectionInset
        layout.minimumInteritemSpacing = collectionViewConfiguration.minimumInteritemSpacing
        layout.minimumLineSpacing = collectionViewConfiguration.minimumLineSpacing
        
        let controller = CollectionViewController(collectionView: collectionView)
        context.coordinator.viewController = controller
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: CollectionViewController, context: UIContext) {
        context.coordinator.parent = self

        uiViewController.collectionView.reloadData()
        if let selectedPageIndex = selectedPageIndex?.wrappedValue {
            if !uiViewController.isLaidOut {
                uiViewController.collectionView.performBatchUpdates({}) { _ in
                    context.coordinator.move(toIndex: selectedPageIndex, setIndexBinding: false, animated: false)
                }
            } else {
                context.coordinator.move(toIndex: selectedPageIndex, setIndexBinding: false)
            }
        }
    }
    
    public struct Configuration {
        public let itemSize: CGSize?
        public let automaticItemSize: Bool
        public let scrollDirection: UICollectionView.ScrollDirection
        public let backgroundColor: UIColor?
        public let showsHorizontalScrollIndicator: Bool
        public let showsVerticalScrollIndicator: Bool
        public let sectionInset: UIEdgeInsets
        public let minimumInteritemSpacing: CGFloat
        public let minimumLineSpacing: CGFloat
        public let isItemPagingEnabled: Bool
        /**
         Extra empty items will be appended to the end, but won't be
         interactable.
         */
        public let extraEmptyItems: Int
        
        public init(itemSize: CGSize? = nil,
                    automaticItemSize: Bool = false,
                    scrollDirection: UICollectionView.ScrollDirection = .vertical,
                    backgroundColor: UIColor?,
                    showsHorizontalScrollIndicator: Bool = true,
                    showsVerticalScrollIndicator: Bool = true,
                    sectionInset: UIEdgeInsets = .zero,
                    minimumInteritemSpacing: CGFloat = 0,
                    minimumLineSpacing: CGFloat = 0,
                    isItemPagingEnabled: Bool = false,
                    extraEmptyItems: Int = 0) {
            self.itemSize = itemSize
            self.automaticItemSize = automaticItemSize
            self.scrollDirection = scrollDirection
            self.backgroundColor = backgroundColor
            self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
            self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
            self.sectionInset = sectionInset
            self.minimumInteritemSpacing = minimumInteritemSpacing
            self.minimumLineSpacing = minimumLineSpacing
            self.isItemPagingEnabled = isItemPagingEnabled
            self.extraEmptyItems = extraEmptyItems
        }
    }
    
    public class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var parent: CollectionView
        var viewController: CollectionViewController?
        var currentIndex = 0
        var lastTargetExtraOffset: CGFloat = 0
        
        public init(parent: CollectionView) {
            self.parent = parent
        }
        
        // MARK: Public methods
        
        func move(toIndex index: Int, setIndexBinding: Bool, animated: Bool = true) {
            guard currentIndex != index, let scrollOffset = snapOffset(for: index) else {
                return
            }
            scroll(toOffset: scrollOffset, index: index, setIndexBinding: setIndexBinding, animated: animated)
        }

        // MARK: UICollectionViewDataSource

        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            numberOfItems + parent.collectionViewConfiguration.extraEmptyItems
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCollectionViewCell else {
                return UICollectionViewCell()
            }
            if indexPath.row >= numberOfItems {
                cell.setupEmpty()
            } else {
                let data = parent.cellData[indexPath.row]
                cell.parentController = viewController
                cell.setup(hostingController: parent.buildCell(data, indexPath.row))
            }
            
            return cell
        }

        // MARK: UICollectionViewDelegate

        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.row < numberOfItems,
                let data = parent.cellData[safe: indexPath.row] {
                parent.onSelection?(data, indexPath.row)
            }
        }
        
        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard parent.collectionViewConfiguration.isItemPagingEnabled else {
                return
            }
            
            let targetOffset = scrollDirection == .vertical ? targetContentOffset.pointee.y - scrollView.contentOffset.y : targetContentOffset.pointee.x - scrollView.contentOffset.x
            
            // Increase the deceleration effect of a normal swipe by 3
            lastTargetExtraOffset = targetOffset / 3
            if let bouncingTargetOffset = bouncingTargetOffset {
                targetContentOffset.pointee = bouncingTargetOffset
            } else {
                targetContentOffset.pointee = scrollView.contentOffset
            }
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            guard parent.collectionViewConfiguration.isItemPagingEnabled,
                bouncingTargetOffset == nil,
                let scrollIndex = snapIndex(with: lastTargetExtraOffset),
                let scrollOffset = snapOffset(for: scrollIndex) else {
                return
            }
            
            scroll(toOffset: scrollOffset, index: scrollIndex)
        }
        
        // MARK: Private methods
        
        private var numberOfItems: Int {
            parent.cellData.count
        }
        
        private var view: UICollectionView? {
            viewController?.collectionView
        }
        
        private var scrollDirection: UICollectionView.ScrollDirection {
            (view?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection ?? .vertical
        }
        
        private var bouncingTargetOffset: CGPoint? {
            guard let view = view else {
                return nil
            }
            let direction = scrollDirection
            let contentOffset = direction == .vertical ? view.contentOffset.y : view.contentOffset.x
            
            if contentOffset < 0 {
                return CGPoint(x: 0, y: 0)
            } else {
                let boundsSize = direction == .vertical ? view.bounds.height : view.bounds.width
                let contentSize = direction == .vertical ? view.contentSize.height : view.contentSize.width
                let maximumOffset = contentSize - boundsSize
                
                if contentOffset > maximumOffset {
                    let maxIndex = numberOfItems - 1
                    return snapOffset(for: maxIndex)
                } else {
                    return nil
                }
            }
        }
        
        private func scroll(toOffset offset: CGPoint, index: Int, setIndexBinding: Bool = true, animated: Bool = true) {
            if animated {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: { [weak self] in
                        self?.view?.contentOffset = CGPoint(x: offset.x, y: offset.y)
                    })
            } else {
                view?.contentOffset = CGPoint(x: offset.x, y: offset.y)
            }
            currentIndex = index
            if setIndexBinding {
                parent.selectedPageIndex?.wrappedValue = index
            }
        }
        
        private func snapOffset(for index: Int) -> CGPoint? {
            guard let view = view, let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {
                return nil
            }
            
            let itemSize = layout.scrollDirection == .vertical ? layout.itemSize.height : layout.itemSize.width
            let itemLineSpacing = layout.minimumLineSpacing
            
            let inset = parent.collectionViewConfiguration.sectionInset
            let offsetInset = layout.scrollDirection == .vertical ? inset.top : inset.bottom
            let snappedOffset = CGFloat(index) * (itemSize + itemLineSpacing) + offsetInset
            
            let boundsSize = layout.scrollDirection == .vertical ? view.bounds.height : view.bounds.width
            let contentSize = layout.scrollDirection == .vertical ? view.contentSize.height : view.contentSize.width
            
            var targetX: CGFloat = 0
            var targetY: CGFloat = 0
            if snappedOffset > contentSize - boundsSize {
                targetX = layout.scrollDirection == .vertical ? 0 : contentSize - boundsSize
                targetY = layout.scrollDirection == .horizontal ? 0 : contentSize - boundsSize
            } else  {
                targetX = layout.scrollDirection == .vertical ? 0 : snappedOffset
                targetY = layout.scrollDirection == .horizontal ? 0 : snappedOffset
            }
            return CGPoint(x: targetX, y: targetY)
        }
        
        private func snapIndex(with extraOffset: CGFloat) -> Int? {
            guard let view = view, let layout = view.collectionViewLayout as? UICollectionViewFlowLayout else {
                return nil
            }
            let config = parent.collectionViewConfiguration
            
            let itemSize = layout.scrollDirection == .vertical ? layout.itemSize.height : layout.itemSize.width
            let itemLineSpacing = layout.minimumLineSpacing
            let totalSize = layout.scrollDirection == .vertical ? view.contentOffset.y : view.contentOffset.x
            let fixedSpacedCalculationOffset = (itemLineSpacing/2)
            let inset = layout.scrollDirection == .vertical ? config.sectionInset.top : config.sectionInset.left
            
            let totalItemWidth = itemSize + itemLineSpacing
            let insetReducingIndex = (inset / 3) / totalItemWidth
            let projectedOffset = totalSize + extraOffset + fixedSpacedCalculationOffset
            let indexPosition = (projectedOffset / totalItemWidth) - insetReducingIndex
            
            let snappedIndex = numberOfItems == 0 ? 0 : (0...(numberOfItems-1)).clamped(to: 0...Int(round(indexPosition))).max()
            return snappedIndex
        }
    }
}

public class CollectionViewController: UIViewController {
    let collectionView: UICollectionView
    var isLaidOut = false
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.edgesAnchorEqualTo(view: view).activate()
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isLaidOut {
            isLaidOut = true
        }
    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    var hostingController: UIHostingController?
    var parentController: CollectionViewController?
    
    func setup(hostingController: UIHostingController) {
        setupEmpty()
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        hostingController.view.edgesAnchorEqualTo(view: contentView).activate()
        
        parentController?.addChild(hostingController)
        hostingController.didMove(toParent: parentController)
        hostingController.view.setNeedsLayout()
        
        self.hostingController = hostingController
    }
    
    func setupEmpty() {
        if let existingHostingController = self.hostingController {
            existingHostingController.removeFromParent()
        }
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.subviews.first?.removeFromSuperview()
        self.hostingController = nil
    }
}

/// In the following example, a ``ScrollView`` contains a
/// `LazyVGrid` consisting of a two-column grid of ``Text`` views, showing
/// Unicode code points from the "Smileys" group and their corresponding emoji:
///
///      var columns: [GridItem] =
///              Array(repeating: .init(.flexible()), count: 2)
///      ScrollView {
///          LazyVGrid(columns: columns) {
///              ForEach((0...79), id: \.self) {
///                  let codepoint = $0 + 0x1f600
///                  let codepointString = String(format: "%02X", codepoint)
///                  Text("\(codepointString)")
///                  let emoji = String(Character(UnicodeScalar(codepoint)!))
///                  Text("\(emoji)")
///              }
///          }.font(.largeTitle)
///      }
///
/// In the following example, a ``ScrollView`` contains a `LazyHGrid` that
/// consists of a horizontally-arranged grid of ``Text`` views, aligned to
/// the top of the scroll view. For each column in the grid, the top row shows
/// a Unicode code point from the "Smileys" group, and the bottom shows its
/// corresponding emoji.
///
///     var rows: [GridItem] =
///             Array(repeating: .init(.fixed(20)), count: 2)
///     ScrollView(.horizontal) {
///         LazyHGrid(rows: rows, alignment: .top) {
///             ForEach((0...79), id: \.self) {
///                 let codepoint = $0 + 0x1f600
///                 let codepointString = String(format: "%02X", codepoint)
///                 Text("\(codepointString)")
///                     .font(.footnote)
///                 let emoji = String(Character(UnicodeScalar(codepoint)!))
///                 Text("\(emoji)")
///                     .font(.largeTitle)
///             }
///         }
///     }

