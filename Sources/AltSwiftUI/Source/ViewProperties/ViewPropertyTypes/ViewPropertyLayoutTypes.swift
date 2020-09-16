//
//  ViewPropertyLayoutTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

/// The inset distances for the sides of a rectangle.
public struct EdgeInsets : Equatable {
    public var top: CGFloat
    public var leading: CGFloat
    public var bottom: CGFloat
    public var trailing: CGFloat
    
    /// Initializes an EdgeInsets instance with the specified insets of each side.
    public init(top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    public static func == (a: EdgeInsets, b: EdgeInsets) -> Bool {
        if a.top == b.top &&
            a.leading == b.leading &&
            a.bottom == b.bottom &&
            a.trailing == b.trailing {
            return true
        } else {
            return false
        }
    }
    
    var uiEdgeInsets: UIEdgeInsets {
        UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
}

/// A type that specifies the horizontal alignment of the
/// content inside its container.
public enum HorizontalAlignment {
    case leading, center, trailing
}

/// A type that specifies the vertical alignment of the
/// content inside its container.
public enum VerticalAlignment {
    case top, center, bottom
}

/// A type that specifies the alignment of the
/// content inside its container.
public struct Alignment : Equatable {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    public static func == (a: Alignment, b: Alignment) -> Bool {
        a.horizontal == b.horizontal && a.vertical == b.vertical
    }

    public static let center = Alignment(horizontal: .center, vertical: .center)
    public static let leading = Alignment(horizontal: .leading, vertical: .center)
    public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
    public static let top = Alignment(horizontal: .center, vertical: .top)
    public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
    public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
    public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
    public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
    public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}

public extension CGFloat {
    /// heigh / widith's limit for view based on screen size
    static let limitForUI: CGFloat = Swift.max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    func limitedForUI() -> CGFloat {
        CGFloat.minimum(self, CGFloat.limitForUI)
    }
}

/// A type that specifies how the content scales to
/// its container's size.
public enum ContentMode {
    case fit, fill
}

/// A type representing an edge in a rectangle.
public enum Edge: Int8 {
    case top, leading, bottom, trailing
    
    /// An efficient option set of `Edge`s.
    public struct Set : OptionSet {

        /// The element type of the option set.
        ///
        /// To inherit all the default implementations from the `OptionSet` protocol,
        /// the `Element` type must be `Self`, the default.
        public typealias Element = Edge.Set

        /// The corresponding value of the raw type.
        ///
        /// A new instance initialized with `rawValue` will be equivalent to this
        /// instance. For example:
        ///
        ///     enum PaperSize: String {
        ///         case A4, A5, Letter, Legal
        ///     }
        ///
        ///     let selectedSize = PaperSize.Letter
        ///     print(selectedSize.rawValue)
        ///     // Prints "Letter"
        ///
        ///     print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
        ///     // Prints "true"
        public let rawValue: Int8

        /// Creates a new option set from the given raw value.
        ///
        /// This initializer always succeeds, even if the value passed as `rawValue`
        /// exceeds the static properties declared as part of the option set. This
        /// example creates an instance of `ShippingOptions` with a raw value beyond
        /// the highest element, with a bit mask that effectively contains all the
        /// declared static members.
        ///
        ///     let extraOptions = ShippingOptions(rawValue: 255)
        ///     print(extraOptions.isStrictSuperset(of: .all))
        ///     // Prints "true"
        ///
        /// - Parameter rawValue: The raw value of the option set to create. Each bit
        ///   of `rawValue` potentially represents an element of the option set,
        ///   though raw values may include bits that are not defined as distinct
        ///   values of the `OptionSet` type.
        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let top: Edge.Set = Set(rawValue: 1 << 0)

        public static let leading: Edge.Set = Set(rawValue: 1 << 1)

        public static let bottom: Edge.Set = Set(rawValue: 1 << 2)

        public static let trailing: Edge.Set = Set(rawValue: 1 << 3)

        public static let all: Edge.Set = [.top, .leading, .bottom, .trailing]

        public static let horizontal: Edge.Set = [.leading, .trailing]

        public static let vertical: Edge.Set = [.top, .bottom]

        /// Creates an instance containing just `e`
        public init(_ e: Edge) {
            switch e {
            case .top: self = Set.top
            case .leading: self = Set.leading
            case .bottom: self = Set.bottom
            case .trailing: self = Set.trailing
            }
        }

        /// The type of the elements of an array literal.
        public typealias ArrayLiteralElement = Edge.Set.Element

        /// The raw type that can be used to represent all values of the conforming
        /// type.
        ///
        /// Every distinct value of the conforming type has a corresponding unique
        /// value of the `RawValue` type, but there may be values of the `RawValue`
        /// type that don't have a corresponding value of the conforming type.
        public typealias RawValue = Int8
    }
}

/// A visual axis
public enum Axis {
    case horizontal, vertical
}

/// A type that represents the alignment position of text
public enum TextAlignment {
    case leading, center, trailing
}

/// Represents a coordinate space.
public enum CoordinateSpace {
    /// Coordinate space in terms of the parent view
    case global
    
    /// Coordinate space in terms of the current view
    case local
    
    /// Coordinate space in terms of a named coordinated space view.
    /// __See__: ```View.coordinateSpace```
    case named(String)
}

/// A proxy for access to the size and coordinate space (for anchor resolution)
/// of the container view.
public struct GeometryProxy {
    let frame: CGRect
    weak var view: UIView?
    
    /// The size of the container view.
    public var size: CGSize {
        frame.size
    }

    /// The container view's bounds rectangle converted to a defined
    /// coordinate space.
    public func frame(in coordinateSpace: CoordinateSpace) -> CGRect {
        switch coordinateSpace {
        case .local:
            return view?.frame ?? frame
        case .global:
            if let viewFrame = view?.frame, let superView = view?.superview, let superCoordinateSystemView = superView.superview {
                return superView.convert(viewFrame, to: superCoordinateSystemView)
            } else {
                return frame
            }
        case .named(let name):
            if let viewFrame = view?.frame, let referenceView = EnvironmentHolder.coordinateSpaceNames[name]?.object, let superView = view?.superview {
                return superView.convert(viewFrame, to: referenceView)
            } else {
                return frame
            }
        }
    }
    
    public static var `default` = GeometryProxy(frame: .zero, view: nil)
}

// MARK: - Internal Types

enum Direction {
    case horizontal, vertical
}

struct AlignedView {
    var view: View
    var alignment: Alignment
}

struct ViewDimensions: Equatable {
    var width: CGFloat?
    var height: CGFloat?
    var minWidth: CGFloat?
    var maxWidth: CGFloat?
    var minHeight: CGFloat?
    var maxHeight: CGFloat?
    
    init(width: CGFloat? = nil,
        height: CGFloat? = nil,
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil) {
        self.width = width
        self.height = height
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
}
