//
//  ViewValues.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

/// Represents the values of a view, which can be customized
/// by view modifiers. For internal use only.
public struct ViewValues: AnimatedViewValuesHolder {
    var animatedValues: [AnimatedViewValues]?
    var animationShieldedValues: AnimatedViewValues?
    
    // When you add new properties, be sure to add them to `merge` methods
    // to make sure view values are inherited in the right scenarios.
    
    var background: UIColor?
    var direction: Direction?
    var viewDimensions: ViewDimensions?
    var buttonStyle: ButtonStyle?
    var overlay: AlignedView?
    var border: Border?
    var aspectRatio: AspectRatio?
    var foregroundColor: UIColor?
    var edgesIgnoringSafeArea: Edge.Set?
    var accentColor: UIColor?
    var disabled: Bool?
    var opacity: Double?
    var antialiasClip: Bool?
    var cornerRadius: CGFloat?
    var shadow: Shadow?
    var font: Font?
    var keyboardType: UIKeyboardType?
    var navigationBarHidden: Bool?
    var statusBarHidden: Bool?
    var lineLimit: Int?
    var tapAction: (() -> Void)?
    var layoutPriority: Double?
    var labelsHidden: Bool?
    var tag: Int?
    var tabItem: TabItem?
    var navigationTitle: NavigationTitle?
    var navigationItems: NavigationButtons?
    var sheetPresentation: SheetPresentation?
    var alert: Alert?
    var actionSheet: ActionSheet?
    var multilineTextAlignment: TextAlignment?
    var modifier: ViewModifier?
    var transform: CGAffineTransform?
    var rotation: Angle?
    var scale: CGSize?
    var transition: AnyTransition?
    var onAppear: (() -> Void)?
    var onDisappear: (() -> Void)?
    var mask: View?
    var gestures: [ExecutableGesture]?
    var isTransformUpdate = false
    var geometry: Binding<GeometryProxy>?
    var parentViewEventHandler: ParentViewEventHandler?
    var coordinateSpace: String?
    var tabBarHidden: Bool?
    var statusBarStyle: UIStatusBarStyle?
    var contextMenu: RemoveByNilHolder<ContextMenu>?
    var listRowInsets: EdgeInsets?
    var textContentType: UITextContentType?
    var onDrag: OnDragValues?
    var onDrop: OnDropValues?
    var strictOnHighPerformance: Bool?
    var skipOnHighPerformance: Bool?
    var navigationAccentColor: UIColor?
    
    private var skOverlayPresentationObject: Any? = nil // Workaround as SKOverlayPresentation is only available from iOS 14.0+
    @available(iOS 14.0, *)
    var skOverlayPresentation: SKOverlayPresentation? {
        get {
            skOverlayPresentationObject as? SKOverlayPresentation
        }
        set {
            skOverlayPresentationObject = newValue
        }
    }
    
    public init() {}
    
    func withAnimatedValues(animation: Animation?) -> ViewValues {
        var values = self
        let newAnimatedValues = AnimatedViewValues(animation: animation, opacity: opacity, transform: transform, rotation: rotation, scale: scale, transition: transition)
        values.opacity = nil
        values.transform = nil
        values.rotation = nil
        values.scale = nil
        values.transition = nil
        
        if animation != nil {
            var animatedValueCollection = self.animatedValues ?? [AnimatedViewValues]()
            animatedValueCollection.append(newAnimatedValues)
            values.animatedValues = animatedValueCollection
        } else {
            values.animationShieldedValues = newAnimatedValues
        }
        
        return values
    }
}

extension ViewValues {
    
    /// Merges values when navigating to a different view.
    func screenTransferMerge(defaultValues: ViewValues?, isNavigating: Bool) -> ViewValues {
        guard let defaultValues = defaultValues else {
            return self
        }
        var mergedValues = self
        
        if accentColor == nil {
            // Accent color for navigated views come from the NavigationView
            mergedValues.accentColor = isNavigating ? defaultValues.navigationAccentColor : defaultValues.accentColor
        }
        if navigationAccentColor == nil { mergedValues.navigationAccentColor = defaultValues.navigationAccentColor }
        
        return mergedValues
    }
    
    /// Merges with default values. If no value exist for a given
    /// property, the default value will be used. In case a value
    /// exists, the value inside `defaultValues` will be ignored.
    func merge(defaultValues: ViewValues?) -> ViewValues {
        guard let defaultValues = defaultValues else {
            return self
        }
        var mergedValues = self
        
        if direction == nil { mergedValues.direction = defaultValues.direction }
        if buttonStyle == nil { mergedValues.buttonStyle = defaultValues.buttonStyle }
        if foregroundColor == nil { mergedValues.foregroundColor = defaultValues.foregroundColor }
        if accentColor == nil { mergedValues.accentColor = defaultValues.accentColor }
        if font == nil { mergedValues.font = defaultValues.font }
        if keyboardType == nil { mergedValues.keyboardType = defaultValues.keyboardType }
        if lineLimit == nil { mergedValues.lineLimit = defaultValues.lineLimit }
        if labelsHidden == nil { mergedValues.labelsHidden = defaultValues.labelsHidden }
        if multilineTextAlignment == nil { mergedValues.multilineTextAlignment = defaultValues.multilineTextAlignment }
        if defaultValues.isTransformUpdate {
            mergedValues.isTransformUpdate = defaultValues.isTransformUpdate
        }
        if parentViewEventHandler == nil {
            mergedValues.parentViewEventHandler = defaultValues.parentViewEventHandler }
        if edgesIgnoringSafeArea == nil {
            mergedValues.edgesIgnoringSafeArea = defaultValues.edgesIgnoringSafeArea
        }
        if textContentType == nil { mergedValues.textContentType = defaultValues.textContentType }
        if navigationAccentColor == nil { mergedValues.navigationAccentColor = defaultValues.navigationAccentColor }
        
        return mergedValues
    }
    
    /// Merges with default values even if default values apply to one specific view.
    /// If no value exist for a given
    /// property, the default value will be used. In case a value
    /// exists, the value inside `defaultValues` will be ignored.
    func completeMerge(defaultValues: ViewValues?) -> ViewValues {
        guard let defaultValues = defaultValues else {
            return self
        }
        var mergedValues = merge(defaultValues: defaultValues)
        
        if background == nil { mergedValues.background = defaultValues.background }
        if viewDimensions == nil { mergedValues.viewDimensions = defaultValues.viewDimensions }
        if overlay == nil { mergedValues.overlay = defaultValues.overlay }
        if border == nil { mergedValues.border = defaultValues.border }
        if aspectRatio == nil { mergedValues.aspectRatio = defaultValues.aspectRatio }
        if disabled == nil { mergedValues.disabled = defaultValues.disabled }
        if opacity == nil { mergedValues.opacity = defaultValues.opacity }
        if antialiasClip == nil { mergedValues.antialiasClip = defaultValues.antialiasClip }
        if cornerRadius == nil { mergedValues.cornerRadius = defaultValues.cornerRadius }
        if shadow == nil { mergedValues.shadow = defaultValues.shadow }
        if tapAction == nil { mergedValues.tapAction = defaultValues.tapAction }
        if layoutPriority == nil { mergedValues.layoutPriority = defaultValues.layoutPriority }
        if tag == nil { mergedValues.tag = defaultValues.tag }
        if tabItem == nil { mergedValues.tabItem = defaultValues.tabItem }
        if navigationTitle == nil { mergedValues.navigationTitle = defaultValues.navigationTitle }
        if navigationItems == nil { mergedValues.navigationItems = defaultValues.navigationItems }
        if sheetPresentation == nil { mergedValues.sheetPresentation = defaultValues.sheetPresentation }
        if alert == nil { mergedValues.alert = defaultValues.alert }
        if actionSheet == nil { mergedValues.actionSheet = defaultValues.actionSheet }
        if onAppear == nil { mergedValues.onAppear = defaultValues.onAppear }
        if onDisappear == nil { mergedValues.onDisappear = defaultValues.onDisappear }
        if modifier == nil { mergedValues.modifier = defaultValues.modifier }
        if transform == nil { mergedValues.transform = defaultValues.transform }
        if rotation == nil { mergedValues.rotation = defaultValues.rotation }
        if scale == nil { mergedValues.scale = defaultValues.scale }
        if animatedValues == nil { mergedValues.animatedValues = defaultValues.animatedValues }
        if transition == nil { mergedValues.transition = defaultValues.transition }
        if animationShieldedValues == nil { mergedValues.animationShieldedValues = defaultValues.animationShieldedValues }
        if animatedValues == nil { mergedValues.animatedValues = defaultValues.animatedValues }
        if mask == nil { mergedValues.mask = defaultValues.mask }
        if geometry == nil { mergedValues.geometry = defaultValues.geometry }
        if coordinateSpace == nil { mergedValues.coordinateSpace = defaultValues.coordinateSpace }
        if navigationBarHidden == nil { mergedValues.navigationBarHidden = defaultValues.navigationBarHidden }
        if statusBarHidden == nil { mergedValues.statusBarHidden = defaultValues.statusBarHidden }
        if tabBarHidden == nil { mergedValues.tabBarHidden = defaultValues.tabBarHidden }
        if statusBarStyle == nil { mergedValues.tabBarHidden = defaultValues.tabBarHidden }
        if contextMenu == nil { mergedValues.contextMenu = defaultValues.contextMenu }
        if listRowInsets == nil { mergedValues.listRowInsets = defaultValues.listRowInsets }
        if onDrag == nil { mergedValues.onDrag = defaultValues.onDrag }
        if onDrop == nil { mergedValues.onDrop = defaultValues.onDrop }
        if strictOnHighPerformance == nil { mergedValues.strictOnHighPerformance = defaultValues.strictOnHighPerformance }
        if skipOnHighPerformance == nil { mergedValues.skipOnHighPerformance = defaultValues.skipOnHighPerformance }
        
        if #available(iOS 14.0, *) {
            if skOverlayPresentation == nil {
                mergedValues.skOverlayPresentation = defaultValues.skOverlayPresentation
            }
        }
        
        return mergedValues
    }
}

// MARK: - Supporting Types

protocol AnimatedViewValuesHolder {
    var opacity: Double? { get }
    var transform: CGAffineTransform? { get }
    var rotation: Angle? { get }
    var scale: CGSize? { get }
    var transition: AnyTransition? { get }
}

struct AnimatedViewValues: AnimatedViewValuesHolder {
    let animation: Animation?
    var opacity: Double?
    var transform: CGAffineTransform?
    var rotation: Angle?
    var scale: CGSize?
    var transition: AnyTransition?
}

struct DefaultableColor {
    let color: UIColor?
}

struct RemoveByNilHolder<Type> {
    let content: Type?
}

struct NavigationTitle {
    let title: String
    let displayMode: NavigationBarTitleDisplayMode
}

struct OnDragValues {
    let provider: () -> NSItemProvider
    let dragBegan: (() -> Void)?
    let dragEnded: ((UIDropOperation) -> Void)?
}

struct OnDropValues {
    let supportedTypes: [String]
    let isTargeted: Binding<Bool>?
    let action: ([NSItemProvider]) -> Bool
}
