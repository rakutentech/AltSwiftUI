//
//  UIKitCollections.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

class SwiftUIScrollView: UIScrollView, UIKitViewHandler {
    var contentOffsetBinding: Binding<CGPoint>?
    var contentView: UIView?
    var interactiveScrollEnabled = true {
        didSet {
            var offset = contentOffset
            if offset.y < 0 {
                offset = .zero
                fixBouncingScroll = true
            }
            previousInteractiveScrollOffset = offset
        }
    }
    var previousInteractiveScrollOffset: CGPoint = .zero
    var fixBouncingScroll = false
    let axis: Axis
    init(axis: Axis) {
        self.axis = axis
        super.init(frame: .zero)
        setupView()
        delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: (axis == .horizontal) ? CGFloat.limitForUI : size.width,
                      height: (axis == .vertical) ? CGFloat.limitForUI : size.height)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    private func setupView() {
        if axis == .vertical || axis == .both {
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        }
        if axis == .horizontal || axis == .both {
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
}

extension SwiftUIScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !interactiveScrollEnabled {
            if fixBouncingScroll && scrollView.contentOffset.y < 0 {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    guard let `self` = self else { return }
                    scrollView.contentOffset = self.previousInteractiveScrollOffset
                }
            } else {
                scrollView.contentOffset = previousInteractiveScrollOffset
            }
            if fixBouncingScroll {
                fixBouncingScroll = false
            }
            return
        }
        withHighPerformance {
            self.contentOffsetBinding?.wrappedValue = scrollView.contentOffset
        }
    }
}

class SwiftUITableView: UITableView, UIKitViewHandler {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: CGFloat.limitForUI, height: CGFloat.limitForUI)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    private func setupView() {
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        keyboardDismissMode = .interactive
    }
}

class SwiftUIStackView: UIStackView, UIKitViewHandler {
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in arrangedSubviews {
            if view.point(inside: convert(point, to: view), with: event) {
                return true
            }
        }
        for subView in subviews {
            if subView.point(inside: convert(point, to: subView), with: event) {
                return true
            }
        }
        return false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
}
