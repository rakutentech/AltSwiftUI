//
//  List.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A list of elements that creates each subview on demand.
public struct List<Content: View, Data, ID: Hashable>: View {
    public var viewStore = ViewValues()
    public var body: View { EmptyView() }
    var sections: [Section]?
    var data: [Data]?
    var rowBuilder: ((Data) -> View)?
    var contentOffset: Binding<CGPoint>?
    var rowHeight: CGFloat?
    var isAlwaysReloadData: Bool = false
    var isBounceEnabled = true
    var separatorStyle = UITableViewCell.SeparatorStyle.singleLine
    var insets: (insets: EdgeInsets, animated: Bool)?
    var dragStarted: (() -> Void)?
    var dragEnded: (() -> Void)?
    var ignoresHighPerformance: Bool = false
    var idKeyPath: KeyPath<Data, ID>?
    var listStyle: ListStyle?
    
    public init(@ViewBuilder content: () -> Content) {
        let contentResult = content()
        self.init(sections: contentResult.originalSubViews.totallyFlatGroupedBySection())
    }

    /// Creates a List that identifies its rows based on the `id` key path to a
    /// property on an underlying data element.
    public init(_ data: [Data], id: KeyPath<Data, ID>, @ViewBuilder rowContent: @escaping (Data) -> View) where Content == ForEach<[Data], ID, HStack> {
        self.data = data
        self.rowBuilder = rowContent
        self.idKeyPath = id
    }
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    /// Listen to changes in the List's content offset.
    ///
    /// - warning:
    /// Updates to the value of this binding
    /// triggers _high performance_ rendering when updating views.
    /// High performance updates don't update children views of
    /// ScrollView and List.
    /// See __High Performance__ in the documentation for more information.
    ///
    /// Not SiwftUI compatible.
    ///
    /// Also see: ```View.ignoreHighPerformance``` and ```View.skipHighPerformanceUpdate```.
    public func contentOffset(_ offset: Binding<CGPoint>) -> Self {
        var view = self
        view.contentOffset = offset
        return view
    }
    
    /// The estimated row height of the list
    public func estimatedRowHeight(_ height: CGFloat) -> Self {
        var list = self
        list.rowHeight = height
        return list
    }
    
    /// Will always reload the whole list on rendering updates instead of
    /// doing individual cell updates.
    ///
    /// - important: Not SwiftUI compatible.
    public func alwaysReloadData() -> Self {
        var list = self
        list.isAlwaysReloadData = true
        return list
    }
    
    /// Determines if the list can bounce.
    ///
    /// - important: Not SwiftUI compatible.
    public func bounces(_ bounces: Bool) -> Self {
        var list = self
        list.isBounceEnabled = bounces
        return list
    }
    
    /// Sets the separatorStyle for the list.
    ///
    /// - important: Not SwiftUI compatible.
    public func separatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        var list = self
        list.separatorStyle = separatorStyle
        return list
    }
    
    /// Sets the content insets for the list.
    ///
    /// - important: Not SwiftUI compatible.
    public func contentInsets(_ insets: EdgeInsets, animated: Bool = false) -> Self {
        var list = self
        list.insets = (insets: insets, animated: animated)
        return list
    }
    
    /// Fires when a drag is started by the user.
    ///
    /// - important: Not SwiftUI compatible.
    public func onDragStarted(_ dragStarted: @escaping () -> Void) -> Self {
        var list = self
        list.dragStarted = dragStarted
        return list
    }
    
    /// Fires when a drag is ended by the user.
    ///
    /// - important: Not SwiftUI compatible.
    public func onDragEnded(_ dragEnded: @escaping () -> Void) -> Self {
        var list = self
        list.dragEnded = dragEnded
        return list
    }
    
    /// Updates this view during a high performance update.
    ///
    /// See `High Performance Updates` in the documentation for more
    /// information.
    ///
    /// - important: Not SwiftUI compatible.
    public func ignoreHighPerformance() -> Self {
        var list = self
        list.ignoresHighPerformance = true
        return list
    }
    
    /// Returns an instance of `self` with the specified list
    /// style.
    /// - Parameter style: A style to apply. Pass a predefined instance of the types that conforms to ListStyle.
    /// - Returns: An styled instance of `self`
    public func listStyle(_ style: ListStyle) -> Self {
        var list = self
        list.listStyle = style
        return list
    }
}

extension List where Data: Identifiable, Content == ForEach<[Data], String, HStack>, ID == Data.ID {
    /// Creates a List that computes its rows on demand from an underlying
    /// collection of identified data.
    public init(_ data: [Data], @ViewBuilder rowContent: @escaping (Data) -> View) {
        self.data = data
        self.rowBuilder = rowContent
        self.idKeyPath = \Data.id
    }
}

extension List where Data == Int, Content == ForEach<[Data], Int, HStack>, ID == Int {
    /// Creates a List that computes views on demand over a *constant* range.
    ///
    /// This instance only reads the initial value of `data` and so it does not
    /// need to identify views across updates.
    ///
    /// To compute views on demand over a dynamic range use
    /// `List(_:id:content:)`.
    public init(_ data: Range<Int>, @ViewBuilder rowContent: @escaping (Int) -> View) {
        self.init(Array(data), id: \.self, rowContent: rowContent)
    }
}

extension List: Renderable {
    public func createView(context: Context) -> UIView {
        var style = UITableView.Style.plain
        if let listStyle = listStyle {
            if listStyle is GroupedListStyle {
                style = .grouped
            } else if #available(iOS 13.0, *),
                      listStyle is InsetGroupedListStyle {
                style = .insetGrouped
            }
        }
        let view = SwiftUITableView(frame: .zero, style: style).noAutoresizingMask()
        view.register(SwiftUITableViewCell.self, forCellReuseIdentifier: SwiftUITableViewCell.swiftUICellReuseIdentifier)
        setupView(view, context: context)
        updateViewSetup(view, context: context)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUITableView,
              let tableDelegate = view.delegate as? GenericTableViewDelegate<Content, Data, ID>,
              context.transaction?.isHighPerformance == false ||
                ignoresHighPerformance
        else { return }

        updateViewSetup(view, context: context)
        
        let oldTotalCount = tableDelegate.totalCount
        let oldData = tableDelegate.list.data
        tableDelegate.update(list: self, context: context)
        
        if isAlwaysReloadData {
            view.reloadData()
            view.layoutIfNeeded()
        } else if oldTotalCount != tableDelegate.totalCount,
           let data = data,
           let oldData = oldData {
            if context.transaction?.animation != nil {
                // Animated
                if let idKeyPath = idKeyPath {
                    let visibleCells = view.visibleCells
                    var cellStoredViewMap = [Int: UIView]()
                    for cell in visibleCells {
                        guard let cell = cell as? SwiftUITableViewCell,
                              let storedView = cell.renderedView,
                              let row = view.indexPath(for: cell)?.row else { continue }
                        cellStoredViewMap[row] = storedView
                    }
                    
                    view.beginUpdates()
                    data.iterateDataDiff(oldData: oldData, id: { $0[keyPath: idKeyPath] }, dynamicIndex: false) { iteratedIndex, collectionIndex, operation in
                        switch operation {
                        case .insert:
                            view.insertRows(at: [IndexPath(item: iteratedIndex, section: 0)], with: .automatic)
                        case .delete:
                            view.deleteRows(at: [IndexPath(item: iteratedIndex, section: 0)], with: .automatic)
                        case .update:
                            if case let .current(currentDataIndex) = collectionIndex,
                               let storedView = cellStoredViewMap[iteratedIndex] {
                                let updateView = tableDelegate.viewForIndex(section: 0, row: currentDataIndex)
                                updateView.scheduleUpdateRender(uiView: storedView, parentContext: context)
                            }
                        }
                    }
                    view.endUpdates()
                } else {
                    let sectionsRange = 0...(max(0, sections?.count ?? 0))
                    view.reloadSections(IndexSet(integersIn: sectionsRange), with: .automatic)
                }
            } else {
                // Non animated
                view.reloadData()
                view.layoutIfNeeded()
            }
        } else {
            // If there is no change in cell numbers, only update
            // visible cells.
            for cell in view.visibleCells {
                guard let cell = cell as? SwiftUITableViewCell,
                      let storedView = cell.renderedView,
                      let indexPath = view.indexPath(for: cell) else { continue }
                let updateView = tableDelegate.viewForIndex(section: indexPath.section, row: indexPath.row)
                updateView.scheduleUpdateRender(uiView: storedView, parentContext: context)
            }
        }
    }
    
    @discardableResult private func setupView(_ view: SwiftUITableView, context: Context) -> GenericTableViewDelegate<Content, Data, ID> {
        let delegate = GenericTableViewDelegate(list: self, context: context)
        view.ownedSwiftUIDelegate = delegate
        view.delegate = delegate
        view.dataSource = delegate
        if let rowHeight = rowHeight {
            view.estimatedRowHeight = rowHeight
        }
        return delegate
    }
    
    private func updateViewSetup(_ view: SwiftUITableView, context: Context) {
        view.bounces = isBounceEnabled
        if let insets = insets {
            if insets.animated {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.4, options: [], animations: {
                    view.contentInset = insets.insets.uiEdgeInsets
                })
            } else {
                view.contentInset = insets.insets.uiEdgeInsets
            }
        }
        view.separatorStyle = separatorStyle
    }
}

// MARK: - Supporting Types

class GenericTableViewDelegate<Content: View, Data, ID: Hashable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    typealias ParentList = List<Content, Data, ID>
    var list: ParentList
    var context: Context
    
    init(list: ParentList, context: Context) {
        self.list = list
        self.context = context
    }
    
    func update(list: ParentList, context: Context) {
        self.list = list
        self.context = context
    }
    
    func viewForIndex(section: Int, row: Int) -> View {
        if let data = list.data, let builder = list.rowBuilder {
            return builder(data[row])
        } else if let sections = list.sections {
            return sections[section].viewContent[row]
        }
        return EmptyView()
    }
    
    var totalCount: Int {
        let sectionCount: Int? = list.sections?.reduce(0) { $0 + $1.viewContent.count }
        return list.data?.count ?? sectionCount ?? 0
    }
    
    func idForIndexPath(_ indexPath: IndexPath) -> String {
        "\(indexPath.section)-\(indexPath.row)"
    }
    
    // Data Source + Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        list.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.data?.count ?? list.sections?[section].viewContent.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let suiView = viewForIndex(section: indexPath.section, row: indexPath.row)
        let eventHandler = ParentViewEventHandler()
        var handlerContext = context
        handlerContext.viewValues?.parentViewEventHandler = eventHandler
        let view = suiView.renderableView(parentContext: handlerContext) ?? UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: SwiftUITableViewCell.swiftUICellReuseIdentifier, for: indexPath) as? SwiftUITableViewCell
        cell?.reconfigureView(content: view, insets: suiView.viewStore.listRowInsets)
        cell?.parentEventHandler = eventHandler
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sections = list.sections {
            let sectionView = sections[section]
            let eventHandler = ParentViewEventHandler()
            var handlerContext = context
            handlerContext.viewValues?.parentViewEventHandler = eventHandler
            if let header = sectionView.header?.renderableView(parentContext: handlerContext) {
                eventHandler.executeOnAppearHandlers()
                header.translatesAutoresizingMaskIntoConstraints = true
                let alignmentView = SwiftUIAlignmentView(content: header, horizontalAlignment: .leading, horizontalAlignmentConstant: SwiftUIConstants.defaultCellPadding)
                configureAlignmentHeaderView(alignmentView)
                
                return alignmentView
            } else {
                return UIView()
            }
        } else if isGrouped {
            let view: UIView = .noAutoSizingInstance()
            view.heightAnchor.constraint(equalToConstant: SwiftUIConstants.minHeaderHeight).isActive = true
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isGrouped && (list.data != nil || list.sections?[section].header == nil) {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let sections = list.sections {
            let sectionView = sections[section]
            let eventHandler = ParentViewEventHandler()
            var handlerContext = context
            handlerContext.viewValues?.parentViewEventHandler = eventHandler
            if let footer = sectionView.footer?.renderableView(parentContext: handlerContext) {
                eventHandler.executeOnAppearHandlers()
                footer.translatesAutoresizingMaskIntoConstraints = true
                let alignmentView = SwiftUIAlignmentView(content: footer, horizontalAlignment: .leading, horizontalAlignmentConstant: SwiftUIConstants.defaultCellPadding)
                configureAlignmentHeaderView(alignmentView)
                return alignmentView
            } else {
                return UIView()
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if list.data != nil || list.sections?[section].footer == nil {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        withHighPerformance {
            self.list.contentOffset?.wrappedValue = scrollView.contentOffset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        list.dragStarted?()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        list.dragEnded?()
    }
    
    private func configureAlignmentHeaderView(_ view: SwiftUIAlignmentView<UIView>) {
        view.backgroundColor = SwiftUIConstants.systemGray
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: SwiftUIConstants.minHeaderHeight).isActive = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.parentEventHandler?.executeOnAppearHandlers()
    }
    
    // MARK: Private methods
    
    private var isGrouped: Bool {
        if #available(iOS 13.0, *), list.listStyle is InsetGroupedListStyle {
            return true
        } else if list.listStyle is GroupedListStyle {
            return true
        }
        return false
    }
}

extension UITableViewCell {
    private static var parentEventHandlerKey = "ParentEventHandlerAssociatedKey"
    var parentEventHandler: ParentViewEventHandler? {
        get {
            objc_getAssociatedObject(self, &Self.parentEventHandlerKey) as? ParentViewEventHandler
        }
        set {
            objc_setAssociatedObject(self, &Self.parentEventHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

struct Section: View {
    public var viewStore = ViewValues()
    var header: View?
    var footer: View?
    var viewContent: [View]
    
    public init(header: View? = nil, footer: View? = nil, @ViewBuilder _ content: () -> View) {
        viewContent = content().subViews
        self.header = header
        self.footer = footer
    }
    
    init() {
        viewContent = []
    }
    
    init(views: [View]) {
        self.viewContent = views
    }
    
    public var body: View {
        EmptyView()
    }
}
