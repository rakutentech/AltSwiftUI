//
//  ViewPropertyViewTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit
import StoreKit

// MARK: - Public Types

/// Type that represents a system alert. Use it to customize the
/// texts and actions that will be shown in the alert.
public struct Alert {
    let title: String
    let message: String?
    let primaryButton: Alert.Button?
    let secondaryButton: Alert.Button?
    var alertIsPresented: Binding<Bool>?

    /// Creates an alert with one button.
    public init(title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil) {
        self.title = title.string
        self.message = message?.string
        primaryButton = dismissButton
        secondaryButton = nil
    }

    /// Creates an alert with two buttons.
    ///
    /// - Note: the system determines the visual ordering of the buttons.
    public init(title: Text, message: Text? = nil, primaryButton: Alert.Button, secondaryButton: Alert.Button) {
        self.title = title.string
        self.message = message?.string
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }

    /// A button representing an operation of an alert presentation.
    public struct Button {
        enum Style {
            case `default`, cancel, destructive
        }
        
        let text: String
        let action: (() -> Void)?
        let style: Style

        /// Creates an `Alert.Button` with the default style.
        public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Alert.Button {
            Button(text: label.string, action: action, style: .default)
        }

        /// Creates an `Alert.Button` that indicates cancellation of some
        /// operation.
        public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Alert.Button {
            Button(text: label.string, action: action, style: .cancel)
        }

        /// Creates an `Alert.Button` with a style indicating destruction of
        /// some data.
        public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Alert.Button {
            Button(text: label.string, action: action, style: .destructive)
        }
    }
}

/// Type that represents a system action sheet. Use it to customize the
/// texts and actions that will be shown in the action sheet.
@available(OSX, unavailable)
public struct ActionSheet {
    let title: String?
    let message: String?
    let buttons: [Button]
    var actionSheetIsPresented: Binding<Bool>?

    /// Creates an action sheet with the provided buttons.
    ///
    /// Send nil in the title to hide the title space in the
    /// action sheet. This behavior is not compatible with SwiftUI.
    public init(title: Text? = nil, message: Text? = nil, buttons: [ActionSheet.Button]) {
        self.title = title?.string
        self.message = message?.string
        self.buttons = buttons
    }

    /// A button representing an operation of an action sheet presentation.
    public typealias Button = Alert.Button
}

/// A container whose view content children will be presented as a menu items
/// in a contextual menu after completion of the standard system gesture.
///
/// The controls contained in a `ContextMenu` should be related to the context
/// they are being shown from.
///
/// - SeeAlso: `View.contextMenu`, which attaches a `ContextMenu` to a `View`.
@available(tvOS, unavailable)
public struct ContextMenu {
    let items: [View]
    
    ///__Important__: Only Buttons with `Image` or `Text` are allowed as items.
    /// The following 3 view combinations are allowed for building a contextual menu:
    ///
    ///     ContextMenu {
    ///         // First combination
    ///         Button(Text("Add")) {}
    ///         // Second combination
    ///         Button(action: {}) {
    ///             Image()
    ///         }
    ///         // Third combination
    ///         Button(action: {}) {
    ///             Text("Add")
    ///             Image()
    ///         }
    ///     }
    public init(@ViewBuilder menuItems: () -> View) {
        items = menuItems().subViews
    }
}

// MARK: - Internal Types

@available(iOS 14.0, *)
@available(macCatalyst, unavailable)
@available(OSX, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct SKOverlayPresentation {
    let isPresented: Binding<Bool>
    let configuration: () -> SKOverlay.Configuration
}
