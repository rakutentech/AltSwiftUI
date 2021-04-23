//
//  Text.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a read only text
public struct Text: View {
    public var viewStore = ViewValues()
    public var string: String
    private var combinedTexts: [Text]?
    private var strikethroughColor: DefaultableColor?
    private var underlineColor: DefaultableColor?
    private var minimumScaleFactorValue: CGFloat?
    
    /// Creates a text view based on a unlocalized string
    public init(verbatim string: String) {
        self.string = string
    }
    
    /// Creates a text view based on a unlocalized string
    ///
    /// Unlike SwiftUI, calling this will result in the same of
    /// calling `init(verbatim:)`. If you want to use localized
    /// strings, use `init(key:)` instead.
    public init<S>(_ content: S) where S: StringProtocol {
        self.string = String(content)
    }
    
    /// Creates a text view based on a localized string.
    /// If the localized string cannot be located, the value of `key`
    /// will be used instead.
    ///
    /// - Parameters:
    ///   - key: The key of the localized string. It's value will be
    ///   used if the localized string cannot be found.
    ///   - tableName: The name of the table to look for the localized string.
    ///   If not specified, the strings defined in Localizable.strings will be
    ///   used.
    ///   - bundle: The bundle to search in.
    ///   - comment: A description of this string. Only for reference.
    public init(key: String, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) {
        let bundle = bundle ?? Bundle.main
        var stringComment: String = ""
        if let comment = comment {
            stringComment = String(describing: comment)
        }
        string = NSLocalizedString(key, tableName: tableName, bundle: bundle, value: key, comment: stringComment)
    }
    
    private init(combinedTexts: [Text]) {
        self.combinedTexts = combinedTexts
        self.string = ""
    }
    
    public var body: View {
        self
    }
    
    /// Sets the strikethrough style of the text, optionally with a
    /// separate color. Not passing a color or passing nil will use
    /// the same foreground color as the text.
    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> Self {
        var view = self
        view.strikethroughColor = active ? DefaultableColor(color: color?.color) : nil
        return view
    }

    /// Applies an underline to the text.
    ///
    /// - Parameters:
    ///   - active: A Boolean value that indicates whether the text has an
    ///     underline.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    ///
    /// - Returns: Text with a line running along its baseline.
    public func underline(_ active: Bool = true, color: Color? = nil) -> Text {
        var view = self
        view.underlineColor = active ? DefaultableColor(color: color?.color) : nil
        return view
    }
    
    /// Sets the minimum amount that text in this view scales down to fit in the
    /// available space.
    ///
    /// Use the `minimumScaleFactor(_:)` modifier if the text you place in a
    /// view doesn't fit and it's okay if the text shrinks to accommodate.
    /// For example, a label with a `minimumScaleFactor` of `0.5` draws its
    /// text in a font size as small as half of the actual font if needed.
    ///
    /// - Parameter factor: A fraction between 0 and 1 (inclusive) you use to
    ///   specify the minimum amount of text scaling that this view permits.
    /// - Returns: A view that limits the amount of text downscaling.
    public func minimumScaleFactor(_ factor: CGFloat) -> Self {
        var view = self
        view.minimumScaleFactorValue = factor
        return view
    }
    
    /// Returns the result of combining two texts. The properties
    /// of each text is maintained even after the combination.
    public static func + (left: Text, right: Text) -> Text {
        Text(combinedTexts: left.viewStoreMergedCombinedTexts + right.viewStoreMergedCombinedTexts)
    }
    
    private var viewStoreMergedCombinedTexts: [Text] {
        if let combinedTexts = combinedTexts {
            return combinedTexts.map { combinedText in
                var newCombinedText = combinedText
                newCombinedText.viewStore = combinedText.viewStore.merge(defaultValues: viewStore)
                if newCombinedText.strikethroughColor == nil {
                    newCombinedText.strikethroughColor = strikethroughColor
                }
                if newCombinedText.underlineColor == nil {
                    newCombinedText.underlineColor = underlineColor
                }
                return newCombinedText
            }
        } else {
            return [self]
        }
    }
}

extension Text: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        guard let label = view as? SwiftUILabel else { return }
        
        if let combinedTexts = combinedTexts {
            updateTextAttributes(with: combinedTexts, label: label, context: context)
        } else {
            updateTextAttributes(with: string, label: label, context: context)
        }
        
        label.alignText(alignment: context.viewValues?.multilineTextAlignment ?? .center)
        label.numberOfLines = context.viewValues?.lineLimit ?? 0
        if let minimumScaleFactor = minimumScaleFactorValue {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = minimumScaleFactor
        }
    }
    
    public func createView(context: Context) -> UIView {
        let label = SwiftUILabel().noAutoresizingMask()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.baselineAdjustment = .alignCenters
        updateView(label, context: context)
        return label
    }
    
    // MARK: Private methods
    
    private func updateTextAttributes(with texts: [Text], label: SwiftUILabel, context: Context) {
        label.attributedText = texts.reduce(NSMutableAttributedString(string: "")) { totalString, nextString in
            totalString.append(nextString.mergedAttributedString(parentText: self, context: context))
            return totalString
        }
    }
    
    private func updateTextAttributes(with string: String, label: SwiftUILabel, context: Context) {
        if let attributedString = attributedStringFromModifiers() {
            label.attributedText = attributedString
        } else {
            label.text = string
        }
        if let fgColor = context.viewValues?.foregroundColor {
            label.textColor = fgColor
        } else if context.isInsideButton, let accentColor = context.viewValues?.accentColor {
            label.textColor = accentColor
        }
        label.font = context.viewValues?.font?.font
    }
    
    private func mergedAttributedString(parentText: Text, context: Context) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: Any]()
        if let font = viewStore.font ?? context.viewValues?.font {
            attributes[.font] = font.font
        }
        if let foregroundColor = viewStore.foregroundColor ?? context.viewValues?.foregroundColor {
            attributes[.foregroundColor] = foregroundColor
        }
        if let strikethroughColor = strikethroughColor ?? parentText.strikethroughColor {
            attributes[.strikethroughStyle] = NSNumber(value: NSUnderlineStyle.single.rawValue)
            attributes[.strikethroughColor] = strikethroughColor.color ?? UIColor.black
        }
        if let underlineColor = underlineColor ?? parentText.underlineColor {
            attributes[.underlineStyle] = NSNumber(value: NSUnderlineStyle.single.rawValue)
            attributes[.underlineColor] = underlineColor.color ?? UIColor.black
        }
        
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    private func attributedStringFromModifiers() -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: Any]()
        if let strikethroughColor = strikethroughColor {
            attributes[.strikethroughStyle] = NSNumber(value: NSUnderlineStyle.single.rawValue)
            attributes[.strikethroughColor] = strikethroughColor.color ?? UIColor.black
        }
        if let underlineColor = underlineColor {
            attributes[.underlineStyle] = NSNumber(value: NSUnderlineStyle.single.rawValue)
            attributes[.underlineColor] = underlineColor.color ?? UIColor.black
        }
        
        if attributes.isEmpty {
            return nil
        } else {
            return NSAttributedString(string: string, attributes: attributes)
        }
    }
}
