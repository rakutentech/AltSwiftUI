//
//  UIKitReadOnlyViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class SwiftUIImageView: UIImageView, UIKitViewHandler {
    deinit {
        executeDisappearHandler()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
}

class SwiftUILabel: UILabel, UIKitViewHandler {
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let maxSize = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 1))
        return CGSize(width: maxSize.width, height: size.height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
}
