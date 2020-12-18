//
//  UIKitCoreViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

class SwiftUIView: UIView, UIKitViewHandler {
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

class SwiftUIEmptyView: UIView, UIKitViewHandler {
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
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 0)
    }
}

class SwiftUIExpandView: UIView, UIKitViewHandler {
    let expandWidth: Bool
    let expandHeight: Bool
    init(expandWidth: Bool = false, expandHeight: Bool = false, ignoreTouch: Bool = false) {
        self.expandWidth = expandWidth
        self.expandHeight = expandHeight
        super.init(frame: .zero)
        setupView()
        if !ignoreTouch {
            isUserInteractionEnabled = true
        }
    }
    convenience init(direction: Direction, ignoreTouch: Bool = false) {
        switch direction {
        case .horizontal: self.init(expandWidth: true, ignoreTouch: ignoreTouch)
        case .vertical: self.init(expandHeight: true, ignoreTouch: ignoreTouch)
        }
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
        let superSize = super.intrinsicContentSize
        return CGSize(width: expandWidth ? CGFloat.limitForUI : superSize.width, height: expandHeight ? CGFloat.limitForUI : superSize.height)
    }
    
    private func setupView() {
        if expandHeight {
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        }
        if expandWidth {
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
}

class SwiftUILabeledView<Label: UIView, Control: UIView>: UIStackView, UIKitViewHandler {
    let control: Control
    let label: Label
    lazy var labelView = UILabel(frame: .zero)
    init(label: Label, control: Control) {
        self.control = control
        self.label = label
        super.init(frame: .zero)
        setupView()
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    
    private func setupView() {
        addArrangedSubview(label)
        addArrangedSubview(SwiftUIExpandView(direction: .horizontal))
        addArrangedSubview(control)
    }
}

class SwiftUITableViewCell: UITableViewCell {
    static let swiftUICellReuseIdentifier = "SwiftUICellReuseIdentifier"
    weak var renderedView: UIView?
    func reconfigureView(content: UIView, insets: EdgeInsets?) {
        let cellInsets = insets ?? EdgeInsets(top: 0, leading: SwiftUIConstants.defaultCellPadding, bottom: 0, trailing: 0)
        for subView in contentView.subviews {
            subView.removeFromSuperview()
        }
        contentView.addSubview(content)
        [content.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: cellInsets.leading),
         content.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -cellInsets.trailing),
         content.topAnchor.constraint(equalTo: contentView.topAnchor, constant: cellInsets.top).withPriority(.required - 1),
         content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cellInsets.bottom)]
            .activate()
        selectionStyle = .none
        
        renderedView = content
    }
}

class SwiftUIAlignmentView<Content: UIView>: UIView, UIKitViewHandler {
    let content: Content
    let horizontalAlignment: HorizontalAlignment
    let horizontalAlignmentConstant: CGFloat
    init(content: Content, horizontalAlignment: HorizontalAlignment = .center, horizontalAlignmentConstant: CGFloat = 0) {
        self.content = content
        self.horizontalAlignment = horizontalAlignment
        self.horizontalAlignmentConstant = horizontalAlignmentConstant
        super.init(frame: .zero)
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
    
    private func setupView() {
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        content.edgesGreaterOrEqualTo(view: self).activate()
        switch horizontalAlignment {
        case .leading:
            content.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalAlignmentConstant).isActive = true
        case .center:
            content.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        case .trailing:
            content.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalAlignmentConstant).isActive = true
        }
        content.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

class SwiftUIPaddingView: UIView, UIKitViewHandler {
    var content: UIView? {
        willSet {
            content?.removeFromSuperview()
        }
        didSet {
            setupView()
        }
    }
    var insets = UIEdgeInsets() {
        didSet {
            updateInsets()
        }
    }
    var edgeConstraints: [NSLayoutConstraint] = []
    init(content: UIView) {
        self.content = content
        super.init(frame: .zero)
        setupView()
    }
    init() {
        super.init(frame: .zero)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
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
    
    private func setupView() {
        guard let content = self.content else { return }
        
        addSubview(content)
        edgeConstraints = content.edgesAnchorEqualTo(destinationView: self).activate()
    }
    private func updateInsets() {
        if edgeConstraints.count != 4 {
            return
        }
        
        edgeConstraints[UIView.EdgeAnchorIndex.top.rawValue].constant = insets.top
        edgeConstraints[UIView.EdgeAnchorIndex.left.rawValue].constant = insets.left
        edgeConstraints[UIView.EdgeAnchorIndex.right.rawValue].constant = -insets.right
        edgeConstraints[UIView.EdgeAnchorIndex.bottom.rawValue].constant = -insets.bottom
    }
}

class BackgroundView: UIView, UIKitViewHandler {
    let content: UIStackView
    init(content: UIStackView) {
        self.content = content
        super.init(frame: .zero)
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
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    private func setupView() {
        addSubview(content.noAutoresizingMask())
        content.edgesAnchorEqualTo(view: self).activate()
    }
}
