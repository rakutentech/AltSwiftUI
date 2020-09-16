//
//  List.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A list of elements that creates each subview on demand.
public struct List<Content: View, Data>: View {
    public var viewStore: ViewValues = ViewValues()
    public var body: View { EmptyView() }
    var sections: [Section]? = nil
    var data: [Data]? = nil
    var rowBuilder: ((Data) -> View)? = nil
    var contentOffset: Binding<CGPoint>?
    var rowHeight: CGFloat?
    var isAlwaysReloadData: Bool = false
    var isBounceEnabled = true
    var separatorStyle = UITableViewCell.SeparatorStyle.singleLine
    var insets: (insets: EdgeInsets, animated: Bool)?
    var dragStarted: (() -> Void)?
    var dragEnded: (() -> Void)?
    var ignoresHighPerformance: Bool = false
    
    public init(@ViewBuilder content: () -> Content) {
        let contentResult = content()
        self.init(sections: contentResult.originalSubViews.totallyFlatGroupedBySection())
    }

    /// Creates a List that identifies its rows based on the `id` key path to a
    /// property on an underlying data element.
    public init<ID>(_ data: [Data], id: KeyPath<Data, ID>, @ViewBuilder rowContent: @escaping (Data) -> View) where Content == ForEach<[Data], ID, HStack>, ID : Hashable {
        self.data = data
        self.rowBuilder = rowContent
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
}

extension List where Data: Identifiable, Content == ForEach<[Data], String, HStack> {
    /// Creates a List that computes its rows on demand from an underlying
    /// collection of identified data.
    public init(_ data: [Data], @ViewBuilder rowContent: @escaping (Data) -> View) {
        self.data = data
        self.rowBuilder = rowContent
    }
}

extension List where Data == Int, Content == ForEach<[Data], Int, HStack> {
    /// Creates a List that computes views on demand over a *constant* range.
    ///
    /// This instance only reads the initial value of `data` and so it does not
    /// need to identify views across updates.
    ///
    /// To compute views on demand over a dynamic range use
    /// `List(_:id:content:)`.
    public init(_ data: Range<Int>, @ViewBuilder rowContent: @escaping (Int) -> View) {
        let views = data.map { data -> View in
            let rowContentView = rowContent(data)
            return rowContentView.subViews[0]
        }
        self.init(sections: [Section(views: views)])
    }
}

extension List: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUITableView().noAutoresizingMask()
        view.register(SwiftUITableViewCell.self, forCellReuseIdentifier: SwiftUITableViewCell.swiftUICellReuseIdentifier)
        setupView(view, context: context)
        updateViewSetup(view, context: context)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUITableView,
              let tableDelegate = view.delegate as? GenericTableViewDelegate<Data>,
              context.transaction?.isHighPerformance == false ||
                ignoresHighPerformance
        else { return }

        updateViewSetup(view, context: context)
        
        let oldTotalCount = tableDelegate.totalCount
        tableDelegate.update(sections: sections, data: data, rowBuilder: rowBuilder, context: context, contentOffset: contentOffset)
        
        if oldTotalCount != tableDelegate.totalCount {
            tableDelegate.storedViews.removeAllObjects()
            view.reloadData()
        } else {
            if isAlwaysReloadData {
                view.reloadData()
            } else {
                let storedViews = tableDelegate.storedViews
                let enumerator = storedViews.objectEnumerator()
                while let storedView: UIView = enumerator.nextObject() as? UIView {
                    if let cellOptions = storedView.cellViewOptions {
                        let updateView = tableDelegate.viewForIndex(section: cellOptions.section, row: cellOptions.row)
                        updateView.scheduleUpdateRender(uiView: storedView, parentContext: context)
                    }
                }
            }
        }
    }
    
    @discardableResult private func setupView(_ view: SwiftUITableView, context: Context) -> GenericTableViewDelegate<Data> {
        let delegate = GenericTableViewDelegate<Data>(sections: sections, data: data, rowBuilder: rowBuilder, context: context, contentOffset: contentOffset, dragStarted: dragStarted, dragEnded: dragEnded)
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

class GenericTableViewDelegate<Data>: NSObject, UITableViewDelegate, UITableViewDataSource {
    var sections: [Section]?
    var data: [Data]?
    var rowBuilder: ((Data) -> View)?
    var context: Context
    var storedViews = NSHashTable<UIView>(options: .weakMemory)
    var contentOffsetBinding: Binding<CGPoint>?
    var dragStarted: (() -> Void)?
    var dragEnded: (() -> Void)?
    
    init(sections: [Section]?, data: [Data]?, rowBuilder: ((Data) -> View)?, context: Context, contentOffset: Binding<CGPoint>?, dragStarted: (() -> Void)?, dragEnded: (() -> Void)?) {
        self.data = data
        self.rowBuilder = rowBuilder
        self.sections = sections
        self.context = context
        self.contentOffsetBinding = contentOffset
        self.dragStarted = dragStarted
        self.dragEnded = dragEnded
    }
    
    func update(sections: [Section]?, data: [Data]?, rowBuilder: ((Data) -> View)?, context: Context, contentOffset: Binding<CGPoint>?) {
        self.data = data
        self.rowBuilder = rowBuilder
        self.sections = sections
        self.context = context
        self.contentOffsetBinding = contentOffset
    }
    
    func viewForIndex(section: Int, row: Int) -> View {
        if let data = data, let builder = rowBuilder {
            return builder(data[row])
        } else if let sections = sections {
            return sections[section].viewContent[row]
        }
        return EmptyView()
    }
    
    var totalCount: Int {
        let sectionCount: Int? = sections?.reduce(0) { $0 + $1.viewContent.count }
        return data?.count ?? sectionCount ?? 0
    }
    
    func idForIndexPath(_ indexPath: IndexPath) -> String {
        "\(indexPath.section)-\(indexPath.row)"
    }
    
    // Data Source + Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data?.count ?? sections?[section].viewContent.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let suiView = viewForIndex(section: indexPath.section, row: indexPath.row)
        let eventHandler = ParentViewEventHandler()
        var handlerContext = context
        handlerContext.viewValues?.parentViewEventHandler = eventHandler
        let view = suiView.renderableView(parentContext: handlerContext) ?? UIView()
        let cell = tableView.dequeueReusableCell(withIdentifier: SwiftUITableViewCell.swiftUICellReuseIdentifier, for: indexPath) as? SwiftUITableViewCell
        cell?.reconfigureView(content: view, insets: suiView.viewStore.listRowInsets)
        storedViews.add(view)
        view.cellViewOptions = CellViewOptions(view: suiView, section: indexPath.section, row: indexPath.row)
        cell?.parentEventHandler = eventHandler
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sections = sections {
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
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if data != nil || sections?[section].header == nil {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let sections = sections {
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
        if data != nil || sections?[section].footer == nil {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        withHighPerformance {
            self.contentOffsetBinding?.wrappedValue = scrollView.contentOffset
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStarted?()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        dragEnded?()
    }
    
    private func configureAlignmentHeaderView(_ view: SwiftUIAlignmentView<UIView>) {
        view.backgroundColor = SwiftUIConstants.systemGray
        view.heightAnchor.constraint(greaterThanOrEqualToConstant: SwiftUIConstants.minHeaderHeight).isActive = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.parentEventHandler?.executeOnAppearHandlers()
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

struct CellViewOptions {
    let view: View
    let section: Int
    let row: Int
}

extension UIView {
    static var cellViewOptionsKey = "CellViewOptionsAssociatedKey"
    var cellViewOptions: CellViewOptions? {
        get {
            objc_getAssociatedObject(self, &Self.cellViewOptionsKey) as? CellViewOptions
        }
        set {
            objc_setAssociatedObject(self, &Self.cellViewOptionsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

struct Section: View {
    public var viewStore: ViewValues = ViewValues()
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
        return EmptyView()
    }
}
