//
//  CollectionProtocols.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

protocol ComparableViewGrouper {
    func iterateDiff(oldViewGroup: ComparableViewGrouper, startDisplayIndex: inout Int, iterate: (Int, DiffableViewSourceOperation) -> Void)
    var viewContent: [View] { get }
}

protocol ViewGrouper {
    var viewContent: [View] { get }
}
