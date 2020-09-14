//
//  CollectionProtocols.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

protocol ComparableViewGrouper {
    func containsId(id: Any) -> Bool
    func numberOfItems() -> Int
    func idForIndex(index: Int) -> Any?
    func viewForIndex(index: Int) -> View
    func iterateDiff(oldViewGroup: ComparableViewGrouper, startDisplayIndex: inout Int, iterate: (Int, DiffableSourceOperation) -> Void)
    var viewContent: [View] { get }
}

protocol ViewGrouper {
    var viewContent: [View] { get }
}
