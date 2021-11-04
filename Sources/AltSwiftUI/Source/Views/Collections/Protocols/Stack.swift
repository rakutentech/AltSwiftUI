//
//  Stack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/11/04.
//

import UIKit

protocol Stack: View, Renderable {
    var viewContent: [View] { get }
    var subviewIsEquallySpaced: (View) -> Bool { get }
    var setSubviewEqualDimension: (UIView, UIView) -> Void { get }
    func updateView(_ view: UIView, context: Context, oldViewContent: [View]?)
}
