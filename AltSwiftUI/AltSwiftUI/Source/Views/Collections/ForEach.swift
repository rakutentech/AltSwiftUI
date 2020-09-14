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
    public var viewStore: ViewValues = ViewValues()
    var viewContent: [View]
    let data: Data
    let idKeyPath: KeyPath<Data.Element, ID>
    
    public var body: View {
        return EmptyView()
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

extension ForEach where ID == Data.Element.ID, Data.Element : Identifiable {

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
    func containsId(id: Any) -> Bool {
        if let id = id as? ID {
            return data.contains { $0[keyPath: idKeyPath] == id }
        } else {
            return false
        }
    }
    func numberOfItems() -> Int {
        data.count
    }
    func viewForIndex(index: Int) -> View {
        viewContent[index]
    }
    func iterateDiff(oldViewGroup: ComparableViewGrouper, startDisplayIndex: inout Int, iterate: (Int, DiffableSourceOperation) -> Void) {
        let currentCount = data.count
        let oldCount =  oldViewGroup.numberOfItems()
        if currentCount == 0 && oldCount == 0 {
            return
        }
        
        var oldIndex = 0
        var currentIndex = 0
        while(oldIndex < oldCount || currentIndex < currentCount) {
            let oldId = oldViewGroup.idForIndex(index: oldIndex) as? ID
            let currentId = idForIndex(index: currentIndex) as? ID
            if let oldId = oldId, let currentId = currentId {
                let oldContainsCurrent = oldViewGroup.containsId(id: currentId)
                let currentContainsOld = containsId(id: oldId)
                if currentId == oldId || (oldContainsCurrent && currentContainsOld) {
                    // Place swap
                    iterate(startDisplayIndex, .update(view: viewForIndex(index: currentIndex)))
                    oldIndex += 1
                    currentIndex += 1
                } else if oldContainsCurrent {
                    // Delete item
                    iterate(startDisplayIndex, .delete(view: oldViewGroup.viewForIndex(index: oldIndex)))
                    oldIndex += 1
                } else {
                    // New item
                    iterate(startDisplayIndex, .insert(view: viewForIndex(index: currentIndex)))
                    currentIndex += 1
                }
            } else if currentId != nil {
                // New item
                iterate(startDisplayIndex, .insert(view: viewForIndex(index: currentIndex)))
                oldIndex += 1
                currentIndex += 1
            } else if oldId != nil {
                // Delete item
                iterate(startDisplayIndex, .delete(view: oldViewGroup.viewForIndex(index: oldIndex)))
                oldIndex += 1
                currentIndex += 1
            } else {
                break
            }
            
            startDisplayIndex += 1
        }
    }
    func idForIndex(index: Int) -> Any? {
        if index >= data.count {
            return nil
        }
        
        let dataIndex = data.index(data.startIndex, offsetBy: index)
        let element = data[dataIndex]
        return element[keyPath: idKeyPath]
    }
}
