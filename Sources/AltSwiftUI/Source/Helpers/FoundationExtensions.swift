//
//  FoundationExtensions.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/01/22.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

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

extension URL {
    init?(stringToUrlEncode: String) {
        self.init(string: stringToUrlEncode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
}
