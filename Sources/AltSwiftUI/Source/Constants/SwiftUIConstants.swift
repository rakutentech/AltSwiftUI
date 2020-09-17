//
//  SwiftUIConstants.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

struct SwiftUIConstants {
    static let defaultCellHeight: CGFloat = 44
    static let defaultPadding: CGFloat = 10
    static let defaultCellPadding: CGFloat = 12
    static let defaultSpacing: CGFloat = 5
    static var systemGray: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            return UIColor(white: 0.9, alpha: 1)
        }
    }
    static let minHeaderHeight: CGFloat = 25
}
