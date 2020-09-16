//
//  TextField.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that allows text input in one line.
public struct TextField<T>: View {
    public var viewStore: ViewValues = ViewValues()
    let title: String
    let onCommit: () -> Void
    let onEditingChanged: (Bool) -> Void
    var formatter: Formatter?
    var text: Binding<String>?
    var value: Binding<T>?
    var isFirstResponder: Bool?
    var isSecureTextEntry: Bool?
    
    public var body: View {
        return EmptyView()
    }

    /// Create an instance which binds with a value of type `T`.
    ///
    /// - Parameters:
    ///   - title: The title of `self`, used as a placeholder.
    ///   - value: The underlying value to be edited.
    ///   - formatter: The `Formatter` to use when converting between the
    ///     `String` the user edits and the underlying value of type `T`.
    ///     In the event that `formatter` is unable to perform the conversion,
    ///     `binding.value` will not be modified.
    ///   - onEditingChanged: An `Action` that will be called when the user
    ///     begins editing `text` and after the user finishes editing `text`,
    ///     passing a `Bool` indicating whether `self` is currently being edited
    ///     or not.
    ///   - onCommit: The action to perform when the user performs an action
    ///     (usually the return key) while the `TextField` has focus.
    public init(_ title: String, value: Binding<T>, formatter: Formatter, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
        self.title = title
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.value = value
        self.formatter = formatter
    }
    
    /// Sets if this view is the first responder or not.
    ///
    /// Setting a value of `true` will make this view become the first
    /// responder if not already.
    /// Setting a value of `false` will make this view resign beign first
    /// responder if it is the first responder.
    ///
    /// - important: Not SwiftUI compatible.
    public func firstResponder(_ firstResponder: Bool) -> Self {
        var view = self
        view.isFirstResponder = firstResponder
        return view
    }
}

extension TextField where T == String {
    /// Creates an instance with a a value of type `String`.
    ///
    /// - Parameters:
    ///     - title: The title of `self`, used as a placeholder.
    ///     - text: The text to be displayed and edited.
    ///     - isSecureTextEntry: Specifies if text entry will be masked.
    ///     - onEditingChanged: An `Action` that will be called when the user
    ///     begins editing `text` and after the user finishes editing `text`,
    ///     passing a `Bool` indicating whether `self` is currently being edited
    ///     or not.
    ///     - onCommit: The action to perform when the user performs an action
    ///     (usually the return key) while the `TextField` has focus.
    public init(_ title: String, text: Binding<String>, isSecureTextEntry: Bool = false, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
        self.title = title
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.text = text
        self.isSecureTextEntry = isSecureTextEntry
    }
}

extension TextField: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUITextField<T>().noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUITextField<T> else { return }
        
        view.value = value
        view.textBinding = text
        view.formatter = formatter
        view.onCommit = onCommit
        view.onEditingChanged = onEditingChanged
        view.placeholder = title
        view.textContentType = viewStore.textContentType
        if let text = text?.wrappedValue, view.lastWrittenText != text {
            view.text = text
        }
        if let text = formatter?.string(for: value?.wrappedValue), view.lastWrittenText != text {
            view.text = text
        }
        if let fgColor = context.viewValues?.foregroundColor {
            view.textColor = fgColor
        }
        view.font = context.viewValues?.font?.font
        if let keyboardType = context.viewValues?.keyboardType {
            view.keyboardType = keyboardType
        }
        if let firstResponder = isFirstResponder {
            if firstResponder {
                view.becomeFirstResponder()
            } else {
                view.resignFirstResponder()
            }
        }
        if let isSecureTextEntry = isSecureTextEntry {
            view.isSecureTextEntry = isSecureTextEntry
        }
    }
}
