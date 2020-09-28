//
//  FoundationExtensions.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/01/22.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

enum DiffableDataSourceOperation<Data> {
    case insert(data: Data)
    case delete(data: Data)
    case update(data: Data)
}

enum CollectionDiffIndex {
    case current(index: Int)
    case old(index: Int)
}

extension Array {
    subscript(safe index: Index) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
        set {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}

extension RandomAccessCollection {
    /// Iterates and specifies the operation to apply the current
    /// collection's data to the `oldData`.
    /// - Parameters:
    ///   - oldData: The previos collection
    ///   - id: The keypath to use to get the id of an element in the collection
    ///   - startIndex: A base index to offset the operation index
    ///   - iteration: Closure called for each operation iteration
    func iterateDataDiff<OldData, ID>(oldData: OldData, id: (Element) -> ID, startIndex: Int = 0, dynamicIndex: Bool = true, iteration: (Int, CollectionDiffIndex, DiffableDataSourceOperation<Element>) -> Void)
    where OldData: RandomAccessCollection, OldData.Element == Element, ID: Hashable {
        let currentCount = count
        let oldCount =  oldData.count
        if currentCount == 0 && oldCount == 0 {
            return
        }
        var startIndex = startIndex
        
        var oldIndex = 0
        var currentIndex = 0
        while(oldIndex < oldCount || currentIndex < currentCount) {
            let currentElement = element(for: currentIndex)
            let oldElement = oldData.element(for: oldIndex)
            
            if let oldElement = oldElement, let currentElement = currentElement {
                let currentId = id(currentElement)
                let oldId = id(oldElement)
                let oldContainsCurrent = oldData.containsId(currentId, idFetcher: id)
                let currentContainsOld = containsId(oldId, idFetcher: id)
                if currentId == oldId || (oldContainsCurrent && currentContainsOld) {
                    // Place swap
                    iteration(startIndex, .current(index: currentIndex), .update(data: currentElement))
                    oldIndex += 1
                    currentIndex += 1
                    startIndex += 1
                } else if oldContainsCurrent {
                    // Delete item
                    iteration(startIndex, .old(index: oldIndex), .delete(data: oldElement))
                    oldIndex += 1
                    if !dynamicIndex {
                        startIndex += 1
                    }
                } else {
                    // New item
                    iteration(startIndex, .current(index: currentIndex), .insert(data: currentElement))
                    currentIndex += 1
                    if dynamicIndex {
                        startIndex += 1
                    }
                }
            } else if let currentElement = currentElement {
                // New item
                iteration(startIndex, .current(index: currentIndex), .insert(data: currentElement))
                oldIndex += 1
                currentIndex += 1
                if dynamicIndex {
                    startIndex += 1
                }
            } else if let oldElement = oldElement {
                // Delete item
                iteration(startIndex, .old(index: oldIndex), .delete(data: oldElement))
                oldIndex += 1
                currentIndex += 1
                if !dynamicIndex {
                    startIndex += 1
                }
            } else {
                break
            }
        }
    }
    
    func element(for numberIndex: Int) -> Element? {
        if numberIndex >= count {
            return nil
        }
        
        let dataIndex = index(startIndex, offsetBy: numberIndex)
        return self[dataIndex]
    }
    
    func containsId<ID: Hashable>(_ id: ID, idFetcher: (Element) -> ID) -> Bool {
        contains { idFetcher($0) == id }
    }
}

extension URL {
    init?(stringToUrlEncode: String) {
        self.init(string: stringToUrlEncode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
}
