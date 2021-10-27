//
//  UIScrollViewExtensions.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/10/27.
//

import UIKit

// TODO: Support more than just direct level UI

extension UIScrollView {
    var firstChildView: UIView? {
        subviews.first?.subviews.first
    }
}

extension UIView {
    var parentScrollView: UIScrollView? {
        superview?.superview as? UIScrollView
    }
}
