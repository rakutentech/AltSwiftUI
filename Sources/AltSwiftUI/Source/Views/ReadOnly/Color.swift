//
//  Color.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that represents a color.
///
/// By default, a `Color` that is directly rendered in a view hierarchy
/// will expand both horizontally and vertically infinitely as much as
/// its parent view allows it to.
public struct Color: View {
    public var viewStore = ViewValues()
    
    /// Stores the original color held by this view
    var rawColor: UIColor
    
    /// Calculates the color of this view based on its properties,
    /// like opacity.
    var color: UIColor {
        if let opacity = viewStore.opacity {
            var alpha: CGFloat = 0
            rawColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
            return rawColor.withAlphaComponent(alpha * CGFloat(opacity))
        }
        return rawColor
    }
    
    public init(white: Double, opacity: Double = 1) {
        self.init(UIColor(white: CGFloat(white), alpha: CGFloat(opacity)))
    }
    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(opacity)))
    }
    public init(_ name: String, bundle: Bundle? = nil) {
        self.init(UIColor(named: name) ?? .black)
    }
    public init(_ uicolor: UIColor) {
        rawColor = uicolor
    }
    
    /// The opacity of the color. Applying opacity on top of a color
    /// that already contains an alpha channel, will multiply
    /// the color's alpha value.
    public func opacity(_ opacity: Double) -> Color {
        var view = self
        view.viewStore.opacity = opacity
        return view
    }
    
    public var body: View {
        self
    }
}

extension Color {
    public static let black = Color(.black)
    public static let white = Color(.white)
    public static let blue = Color(.systemBlue)
    public static let red = Color(.systemRed)
    public static let yellow = Color(.systemYellow)
    public static let green = Color(.systemGreen)
    public static let orange = Color(.systemOrange)
    public static let pink = Color(.systemPink)
    public static let purple = Color(.systemPurple)
    public static let gray = Color(.systemGray)
    public static let clear = Color(.clear)
    
    /// Color for primary content, ex: Texts
    public static var primary: Color {
        if #available(iOS 13.0, *) {
            return Color(.label)
        } else {
            return Color(UIColor(white: 0, alpha: 1))
        }
    }
    
    /// Color for secondary content, ex: Texts
    public static var secondary: Color {
        if #available(iOS 13.0, *) {
            return Color(.secondaryLabel)
        } else {
            return Color(UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6))
        }
    }
    
    static var systemAccentColor: Color {
        .blue
    }
}

extension Color: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIExpandView(expandWidth: true, expandHeight: true).noAutoresizingMask()
        updateView(view, context: context.withoutTransaction)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let animation = context.transaction?.animation {
            animation.performAnimation {
                view.backgroundColor = rawColor
            }
        } else {
            view.backgroundColor = rawColor
        }
    }
}
