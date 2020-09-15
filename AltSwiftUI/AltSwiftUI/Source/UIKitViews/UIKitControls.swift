//
//  UIKitControls.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/12/16.
//

import UIKit

class SwiftUISlider: UISlider, UIKitViewHandler {
    var valueChanged: (() -> Void)?
    init() {
        super.init(frame: .zero)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: CGFloat.limitForUI, height: size.height)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    
    private func setupView() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    @objc private func sliderValueChanged() {
        valueChanged?()
    }
}

class SwiftUISwitch: UISwitch, UIKitViewHandler {
    var isOnBinding: Binding<Bool>?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    deinit {
        executeDisappearHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    
    private func setupView() {
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    @objc private func valueChanged() {
        isOnBinding?.wrappedValue = isOn
    }
}

class SwiftUITextField<T>: UITextField, UITextFieldDelegate, UIKitViewHandler {
    var onCommit: (() -> Void)?
    var onEditingChanged: ((Bool) -> Void)?
    var value: Binding<T>?
    var textBinding: Binding<String>?
    var formatter: Formatter?
    lazy var lastWrittenText: String? = text
    override var text: String? {
        didSet {
            lastWrittenText = text
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.delegate = self
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
        let size = super.intrinsicContentSize
        return CGSize(width: CGFloat.limitForUI, height: size.height)
    }
    
    //MARK: Private methods
    
    private func setupView() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    private func setBindingText(_ text: String) {
        if let value = value, let formatter = formatter {
            var object: AnyObject?
            formatter.getObjectValue(&object, for: text, errorDescription: nil)
            if let object = object as? T {
                value.wrappedValue = object
            }
        } else if let textBinding = textBinding {
            textBinding.wrappedValue = text
        }
    }
    
    //MARK: TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onCommit?()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingChanged?(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        onEditingChanged?(false)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let text = newText, textBinding?.wrappedValue != text {
            lastWrittenText = text
            setBindingText(text)
        }
        return true
    }
}

class SwiftUIButton: UIControl, UIKitViewHandler {
    var contentView: UIView
    var action: () -> Void
    var animates = true
    init(contentView: UIView, action: @escaping () -> Void) {
        self.contentView = contentView
        self.action = action
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
    func updateContentView(_ contentView: UIView) {
        contentView.isUserInteractionEnabled = false
        self.contentView.removeFromSuperview()
        self.contentView = contentView
        addSubview(contentView)
        contentView.edgesAnchorEqualTo(destinationView: self).activate()
        setNeedsLayout()
    }
    private func setupView() {
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        contentView.edgesAnchorEqualTo(destinationView: self).activate()
        addTarget(self, action: #selector(selectView), for: .touchDown)
        addTarget(self, action: #selector(actionView), for: .touchUpInside)
        addTarget(self, action: #selector(deselectView), for: [.touchCancel, .touchDragExit])
    }
    @objc private func selectView() {
        if !animates {
            return
        }
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.contentView.alpha = 0.25
        }
    }
    @objc private func actionView() {
        action()
        deselectView()
    }
    @objc private func deselectView() {
        if !animates {
            return
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.contentView.alpha = 1
        }
    }
}

class SwiftUISegmentedControl: UISegmentedControl, UIKitViewHandler {
    deinit {
        executeDisappearHandler()
    }
    
    var selectionBinding = Binding<Int>(get: {0}, set: {_ in})
    
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    
    private func setup() {
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc private func valueChanged() {
        selectionBinding.wrappedValue = selectedSegmentIndex
    } 
}

class SwiftUIDatePicker: UIDatePicker, UIKitViewHandler {
    var dateBinding: Binding<Date>?
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: CGFloat.limitForUI, height: size.height)
    }
    
    private func setupView() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged(_ datePicker: UIDatePicker) {
        if let dateBinding = dateBinding {
            dateBinding.wrappedValue = datePicker.date
        }
    }
}

