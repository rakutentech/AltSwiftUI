//
//  SecureField.swift
//  AltSwiftUI
//
//  Created by Elvis Lin on 2020/12/1.
//

import UIKit

/// A view into which the user securely enters private text.
public struct SecureField: View {
    public var viewStore = ViewValues()

    var textField: TextField<String>

    public var body: View {
        textField
    }

    /// Creates an instance with a a value of type `String`.
    ///
    /// - Parameters:
    ///     - title: The title of `self`, used as a placeholder.
    ///     - text: The text to be displayed and edited.
    ///     - onCommit: The action to perform when the user performs an action
    ///     (usually the return key) while the `SecureField` has focus.
    public init(_ title: String, text: Binding<String>, onCommit: @escaping () -> Void = {}) {
        self.textField = TextField(title, text: text, isSecureTextEntry: true, onCommit: onCommit)
    }

    /// Sets if this view is the first responder or not.
    ///
    /// Setting a value of `true` will make this view become the first
    /// responder if not already.
    /// Setting a value of `false` will make this view resign beign first
    /// responder if it is the first responder.
    ///
    /// - important: Not SwiftUI compatible.
    public func firstResponder(_ firstResponder: Binding<Bool>) -> Self {
        var view = self
        view.textField = textField
            .firstResponder(firstResponder)
        return view
    }
}
