//
//  ViewPropertyRenderingTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

public struct Font {
    public enum Weight {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
    }
    
    var font: UIFont
    var weight: Weight?
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        Font(UIFont.preferredFont(forTextStyle: .largeTitle))
    }

    /// Create a font with the title text style.
    public static var title: Font {
        Font(UIFont.preferredFont(forTextStyle: .title1))
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        Font(UIFont.preferredFont(forTextStyle: .headline))
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        Font(UIFont.preferredFont(forTextStyle: .subheadline))
    }

    /// Create a font with the body text style.
    public static var body: Font {
        Font(UIFont.preferredFont(forTextStyle: .body))
    }

    /// Create a font with the callout text style.
    public static var callout: Font {
        Font(UIFont.preferredFont(forTextStyle: .callout))
    }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
        Font(UIFont.preferredFont(forTextStyle: .footnote))
    }

    /// Create a font with the caption text style.
    public static var caption: Font {
        Font(UIFont.preferredFont(forTextStyle: .caption1))
    }
    
    /// Create a system font with the given `size`, `weight` and `design`.
    public static func system(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font(UIFont.systemFont(ofSize: size, weight: uiweightForWeight(weight)), weight: weight)
    }

    /// Create a custom font with the given `name` and `size`.
    public static func custom(_ name: String, size: CGFloat) -> Font {
        Font(UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size))
    }
    
    init(_ font: UIFont, weight: Weight? = nil) {
        self.font = font
        self.weight = weight
    }
    
    public func bold() -> Self {
        weight(.bold)
    }
    
    public func weight(_ weight: Font.Weight) -> Font {
        var font = self
        font.weight = weight
        font.font = fontWithWeight(font: font.font, weight: weight)
        return font
    }
    
    func fontWithWeight(font: UIFont, weight: Font.Weight) -> UIFont {
        let descriptor = font.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [UIFontDescriptor.TraitKey.weight: Self.uiweightForWeight(weight)]
        ])
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    static func uiweightForWeight(_ weight: Font.Weight) -> UIFont.Weight {
        switch weight {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }
}

public struct ButtonStyleConfiguration {
    /// A view that describes the effect of toggling `isPressed`.
    public let label: View

    /// Whether or not the button is currently being pressed down by the user.
    public let isPressed: Bool
}

public protocol ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> View

    /// The properties of a `Button` instance being created.
    typealias Configuration = ButtonStyleConfiguration
}

public protocol PickerStyle {
    
}

public protocol ViewModifier {
    /// Returns the current body of `self`. `content` is a proxy for
    /// the view that will have the modifier represented by `Self`
    /// applied to it.
    func body(content: Content) -> View
    
    typealias Content = View
}

public struct Angle {
    public var radians: Double
    public var degrees: Double

    public init(radians: Double) {
        self.radians = radians
        degrees = radians / Double.pi * 180
    }

    public init(degrees: Double) {
        self.degrees = degrees
        radians = degrees / 180 * Double.pi
    }

    public static func radians(_ radians: Double) -> Angle {
        Angle(radians: radians)
    }

    public static func degrees(_ degrees: Double) -> Angle {
        Angle(degrees: degrees)
    }
}

// MARK: - Internal Types

struct Border {
    var color: UIColor
    var width: CGFloat
}

struct AspectRatio {
    var contentMode: ContentMode
}

struct Shadow {
    var color: UIColor
    var radius: CGFloat
    var xOffset: CGFloat
    var yOffset: CGFloat
}
