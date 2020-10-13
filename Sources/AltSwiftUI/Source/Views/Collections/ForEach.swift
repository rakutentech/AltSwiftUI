//
//  ForEach.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// A view that creates views based on data. This view itself has no visual
/// representation. Adding a background to this view, for example, will have no effect.
public struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    public var viewStore = ViewValues()
    var viewContent: [View]
    let data: Data
    let idKeyPath: KeyPath<Data.Element, ID>
    
    public var body: View {
        EmptyView()
    }
    
    /// Creates views based on uniquely identifiable data, by using a custom id.
    ///
    /// The `id` value of each data should be unique.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - id: A keypath for the value that uniquely identify each data.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> Content) {
        viewContent = data.map { content($0) }
        self.data = data
        idKeyPath = id
    }
}

extension ForEach where ID == Data.Element.ID, Data.Element: Identifiable {

    /// Creates views based on uniquely identifiable data.
    ///
    /// The `id` value of each data should be unique.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        viewContent = data.map { content($0) }
        self.data = data
        idKeyPath = \Data.Element.id
    }
}

extension ForEach where Data == Range<Int>, ID == Int {

    /// Creates an instance that computes views on demand over a *constant*
    /// range.
    ///
    /// To compute views on demand over a dynamic range use
    /// `ForEach(_:id:content:)`.
    public init(_ data: Range<Int>, content: @escaping (Int) -> Content) {
        viewContent = data.map { content($0) }
        self.data = data
        idKeyPath = \Data.Element.self
    }
}

extension ForEach: ComparableViewGrouper {
    func iterateDiff(oldViewGroup: ComparableViewGrouper, startDisplayIndex: inout Int, iterate: (Int, DiffableViewSourceOperation) -> Void) {
        guard let oldViewGroup = oldViewGroup as? Self else { return }
        data.iterateDataDiff(oldData: oldViewGroup.data, id: id(for:), startIndex: startDisplayIndex) { currentDisplayIndex, collectionIndex, operation in
            startDisplayIndex = currentDisplayIndex + 1
            switch operation {
            case .insert:
                if case let .current(index) = collectionIndex {
                    iterate(currentDisplayIndex, .insert(view: viewContent[index]))
                }
            case .delete:
                if case let .old(index) = collectionIndex {
                    iterate(currentDisplayIndex, .delete(view: oldViewGroup.viewContent[index]))
                }
            case .update:
                if case let .current(index) = collectionIndex {
                    iterate(currentDisplayIndex, .update(view: viewContent[index]))
                }
            }
        }
    }
    
    private func id(for item: Data.Element) -> ID {
        item[keyPath: idKeyPath]
    }
}
