//
//  ViewBuilder.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit
import StoreKit

extension View {
    public func background(_ color: Color?) -> Self {
        var view = self
        view.viewStore.background = color?.color
        return view
    }
    
    /// Creates a view that pads this view using the specified
    /// edge instets with a specified value.
    ///
    /// - Parameters:
    ///     - edges: The set of edges along which to inset this view.
    ///     - length: The amount to inset this view on each edge. If `nil`,
    ///       the amount is the system default amount.
    /// - Returns: A view that pads this view using the edge insets you specify.
    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> PaddingView {
        let paddingValue = length ?? SwiftUIConstants.defaultPadding
        let topInset = edges.contains(.top) ? paddingValue : 0
        let bottomInset = edges.contains(.bottom) ? paddingValue : 0
        let leadingInset = edges.contains(.leading) ? paddingValue : 0
        let trailingInset = edges.contains(.trailing) ? paddingValue : 0
        
        return PaddingView(contentView: self, paddingInsets: EdgeInsets(top: topInset, leading: leadingInset, bottom: bottomInset, trailing: trailingInset))
    }
    
    /// Creates a view that pads this view using the values inside
    /// of `EdgeInsets`.
    ///
    /// - Returns: A view that pads this view using the edge insets you specify.
    public func padding(_ insets: EdgeInsets) -> PaddingView {
        PaddingView(contentView: self, paddingInsets: insets)
    }
    
    /// Creates a view that pads this view along all edge insets
    /// by the amount you specify.
    ///
    /// - Parameter length: The amount to inset this view on each edge.
    /// - Returns: A view that pads this view by the amount you specify.
    public func padding(_ length: CGFloat) -> PaddingView {
        PaddingView(contentView: self, padding: length)
    }
    
    /// Creates a view that pads this view along all edges by a default
    /// amount.
    ///
    /// - Returns: A view that pads this view using the edge insets you specify.
    public func padding() -> PaddingView {
        padding(SwiftUIConstants.defaultPadding)
    }
    
    /// Sets the frame of a view with specified width and/or height.
    ///
    /// Pass at least one size parameter. Any `nil` or unspecified dimensions
    /// won't be applied to the frame.
    ///
    /// Specified dimensions will set the exact width or height of the view
    /// with required priority.
    /// You are responsible for making sure that the constraints don't conflict
    /// with other views' constraints.
    ///
    /// - Parameters:
    ///   - width: The width of the view's frame.
    ///   - height: The height of the view's frame.
    /// - Returns: The view with modified frame.
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        var view = self
        if view.viewStore.viewDimensions == nil {
            view.viewStore.viewDimensions = ViewDimensions()
        }
        
        if width != nil, view.viewStore.viewDimensions?.maxWidth == CGFloat.limitForUI {
            view.viewStore.viewDimensions?.maxWidth = nil
        }
        view.viewStore.viewDimensions?.width = width
        
        if height != nil, view.viewStore.viewDimensions?.maxHeight == CGFloat.limitForUI {
            view.viewStore.viewDimensions?.maxHeight = nil
        }
        view.viewStore.viewDimensions?.height = height
        
        return view
    }
    
    /// Sets the frame of a view with specified max/min width and/or height.
    ///
    /// Pass at least one size parameter. Any `nil` or unspecified dimensions
    /// won't be applied to the frame.
    ///
    /// Specify minimum or maximum dimensions when you want to constraint
    /// the frame of a view that can dynamically change it's size because
    /// of parent, child or sibling views.
    ///
    /// __Tip__: Pass .infinity to either maxWidth or maxHeight when you want
    /// the view's dimension to stretch as far as it's parent allows it to.
    ///
    /// - Parameters:
    ///   - minWidth: The minimum width of the resulting frame.
    ///   - maxWidth: The maximum width of the resulting frame.
    ///   - minHeight: The minimum height of the resulting frame.
    ///   - maxHeight: The maximum height of the resulting frame.
    /// - Returns: The view with modified frame.
    public func frame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> Self {
        var view = self
        if view.viewStore.viewDimensions == nil {
            view.viewStore.viewDimensions = ViewDimensions()
        }
        view.viewStore.viewDimensions?.minWidth = minWidth
        view.viewStore.viewDimensions?.maxWidth = maxWidth?.limitedForUI()
        view.viewStore.viewDimensions?.minHeight = minHeight
        view.viewStore.viewDimensions?.maxHeight = maxHeight?.limitedForUI()
        return view
    }

    /// This is to inform invalid case. `frame()` should always be called with
    /// at least one parameter.
    @available(*, deprecated, message: "Please pass one or more parameters.")
    public func frame() -> Self { return self }
    
    /// Adds a contextual menu to this view.
    ///
    /// Use contextual menus to add actions that change depending on the user's
    /// current focus and task.
    ///
    /// __Important__: Only Buttons with `Image` or `Text` are allowed.
    /// The following 3 view combinations are allowed for building a contextual menu:
    ///
    ///     Text("Control Click Me")
    ///     .contextMenu {
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
    ///
    /// - Returns: The view with a contextual menu.
    @available(tvOS, unavailable)
    public func contextMenu(@ViewBuilder menuItems: () -> View) -> Self {
        contextMenu(ContextMenu { menuItems() })
    }


    /// Attaches a `ContextMenu` and its children to `self`.
    ///
    /// This modifier allows for the contextual menu to be conditionally
    /// available by passing `nil` as the value for `contextMenu`.
    @available(tvOS, unavailable)
    public func contextMenu(_ contextMenu: ContextMenu?) -> Self {
        var view = self
        view.viewStore.contextMenu = RemoveByNilHolder(content: contextMenu)
        return view
    }
    
    
    public func buttonStyle<S>(_ style: S) -> Self where S : ButtonStyle {
        var view = self
        view.viewStore.buttonStyle = style
        return view
    }
     
    /// Layers a secondary view in front of this view.
    ///
    /// When you apply an overlay to a view, the original view continues to
    /// provide the layout characteristics for the resulting view. For example,
    /// the layout for the caption in this view fits within the width of the
    /// image:
    ///
    ///     Image(name: "artichokes")
    ///         .overlay(
    ///             HStack {
    ///                 Text("Artichokes"), // Text to use as a caption.
    ///                 Spacer()
    ///             }
    ///             .padding()
    ///             .foregroundColor(.white)
    ///             .background(Color.black.opacity(0.5)),
    ///
    ///             alignment: .bottom
    ///         )
    ///
    /// - Parameters:
    ///   - overlay: The view to layer in front of this view.
    ///   - alignment: The alignment for `overlay` in relation to this view.
    /// - Returns: The view with an `overlay` layer in front.
    public func overlay<Overlay>(_ overlay: Overlay, alignment: Alignment = .center) -> Self where Overlay : View {
        var view = self
        view.viewStore.overlay = AlignedView(view: overlay, alignment: alignment)
        return view
    }
     
    
    /// Adds a border to this view with the specified style and width.
    ///
    /// By default, the border appears inside the bounds of this view. In this
    /// example, the four-point border covers the text:
    ///
    ///     Text("Artichokes")
    ///     .font(.title)
    ///     .border(Color.green, width: 4)
    ///
    /// To place a border around the outside of this view, apply padding of the
    /// same width before adding the border:
    ///
    ///     Text("Artichokes")
    ///     .font(.title)
    ///     .padding(4)
    ///     .border(Color.green, width: 4)
    ///
    /// - Parameters:
    ///   - content: The border style.
    ///   - width: The thickness of the border.
    /// - Returns: The view with a border with the specified style and width
    ///   to this view.
    public func border(_ content: Color, width: CGFloat = 1) -> Self {
        var view = self
        view.viewStore.border = Border(color: content.color, width: width)
        return view
    }
     
    /// Sets the view's content mode __only__ when it's resizable.
    ///
    ///     Image()
    ///     .resizable()
    ///     .aspectRatio(contentMode: .fit)
    ///     .frame(width: 200, height: 200)
    ///
    /// - Parameters:
    ///   - contentMode: A flag indicating whether this view should fit or
    ///     fill the parent context.
    /// - Returns: The view with modified content mode.
    public func aspectRatio(contentMode: ContentMode) -> Self {
        var view = self
        view.viewStore.aspectRatio = AspectRatio(contentMode: contentMode)
        return view
    }
    
    /// Scales this view to fit its parent.
    ///
    /// This view's aspect ratio is maintained as the view scales. This
    /// method is equivalent to calling `aspectRatio(contentMode: .fit)`.
    ///
    ///      Image()
    ///      .resizable()
    ///      .scaledToFit()
    ///      .frame(width: 200, height: 200)
    ///
    /// - Returns: The view with fit content mode.
    public func scaledToFit() -> Self {
        return aspectRatio(contentMode: .fit)
    }
    
    /// Scales this view to fill its parent.
    ///
    /// This view's aspect ratio is maintained as the view scales. This
    /// method is equivalent to calling `aspectRatio(contentMode: .fill)`.
    ///
    ///      Image()
    ///      .resizable()
    ///      .scaledToFill()
    ///      .frame(width: 200, height: 200)
    ///
    /// - Returns: The view with fill content mode.
    public func scaledToFill() -> Self {
        return aspectRatio(contentMode: .fill)
    }
     
    /// Set the foreground color within `self`.
    public func foregroundColor(_ color: Color?) -> Self {
        var view = self
        view.viewStore.foregroundColor = color?.color ?? .black
        return view
    }
     
    /// Changes the constraints of this view so that it matches the window
    /// on the specified edges. __Important__: Don't use this on views that
    /// don't touch the edges of the safe area on the edges that you want
    /// to ignore.
    ///
    /// - Parameter edges: The set of the edges in which to expand the size
    ///   proposed for this view.
    ///
    /// - Returns: The view with changed constraints.
    public func edgesIgnoringSafeArea(_ edges: Edge.Set) -> Self {
        var view = self
        view.viewStore.edgesIgnoringSafeArea = edges
        return view
    }
     
    /// Sets the accent color for this view and the views it contains.
    ///
    /// The system uses the accent color for common controls and containers.
    /// For example, a button's label might use the accent color for its text.
    ///
    /// - Parameter accentColor: The color to use as an accent color. If `nil`,
    ///   the accent color is the system default
    public func accentColor(_ accentColor: Color?) -> Self {
        var view = self
        view.viewStore.accentColor = accentColor?.color ?? .black
        return view
    }
    
     
    /// Adds a condition that controls whether users can interact with this
    /// view.
    ///
    /// Disabling a view will also disable all of its children, regardless of the
    /// children being disabled or not. For example, the following button is not
    /// interactable
    ///
    ///     HStack {
    ///         Button(Text("Action")) {}
    ///         .disabled(true)
    ///     }
    ///     .disabled(false)
    ///
    /// - Parameter disabled: A Boolean value that determines whether users can
    ///   interact with this view.
    public func disabled(_ disabled: Bool) -> Self {
        var view = self
        view.viewStore.disabled = disabled
        return view
    }
     
    /// Sets the transparency of this view.
    ///
    /// Apply opacity to reveal views that are behind another view or to
    /// de-emphasize a view.
    ///
    /// When applying the `opacity(_:)` modifier to a view that already has
    /// an opacity, the modifier supplements---rather than replaces---the view's
    /// opacity.
    ///
    /// - Parameter opacity: A value between 0 (fully transparent) and 1
    ///     (fully opaque).
    public func opacity(_ opacity: Double) -> Self {
        var view = self
        view.viewStore.opacity = opacity
        return view
    }
     
    /// Clips this view to its bounding rectangular frame.
    ///
    /// By default, a view's bounding frame is used only for layout, so any
    /// content that extends beyond the edges of the frame is still visible.
    /// Use the `clipped()` modifier to hide any content that extends beyond
    /// these edges.
    ///
    /// - Parameter antialiased: A Boolean value that indicates whether
    ///   smoothing is applied to the edges of the clipping rectangle.
    public func clipped(antialiased: Bool = false) -> Self {
        var view = self
        view.viewStore.antialiasClip = antialiased
        return view
    }


    /// Clips this view to its bounding frame, with the specified corner radius.
    ///
    /// By default, a view's bounding frame only affects its layout, so any
    /// content that extends beyond the edges of the frame remains visible.
    /// Use the `cornerRadius()` modifier to hide any content that extends
    /// beyond these edges while applying a corner radius.
    ///
    /// The following code applies a corner radius of 20 to a square image:
    ///
    ///     Image(name: "square")
    ///         .cornerRadius(20)
    ///
    /// - Parameter antialiased: A Boolean value that indicates whether
    ///   smoothing is applied to the edges of the clipping rectangle.
    public func cornerRadius(_ radius: CGFloat, antialiased: Bool = true) -> Self {
        var view = self
        view.viewStore.cornerRadius = radius
        view.viewStore.antialiasClip = antialiased
        return view
    }
    
    /// Adds a shadow to this view.
    ///
    /// __Tip__: If you want to apply a shadow on a clipped view, you must
    /// apply to its parent view instead. Example:
    ///
    ///     Image(name: "square")
    ///         .cornerRadius(20)
    ///         .padding(0)
    ///         .shadow(radius: 2)
    ///
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: The shadow's size.
    ///   - x: A horizontal offset you use to position the shadow relative to
    ///     this view.
    ///   - y: A vertical offset you use to position the shadow relative to
    ///     this view.
    public func shadow(color: Color = Color(white: 0, opacity: 0.33), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> Self {
        var view = self
        view.viewStore.shadow = Shadow(color: color.color, radius: radius, xOffset: x, yOffset: y)
        return view
    }
     
    
    /// Sets the default font for text in this view.
    ///
    /// - Parameter font: The default font to use in this view.
    public func font(_ font: Font?) -> Self {
        var view = self
        view.viewStore.font = font
        return view
    }
     
    /// Sets the keyboard type for text input controls in this view.
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public func keyboardType(_ type: UIKeyboardType) -> Self {
        var view = self
        view.viewStore.keyboardType = type
        return view
    }
     
    /// Hides the navigation bar for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - hidden: A Boolean value that indicates whether to hide the
    ///       navigation bar.
    public func navigationBarHidden(_ hidden: Bool) -> Self {
        var view = self
        view.viewStore.navigationBarHidden = hidden
        return view
    }
     
    /// Hides the status bar for this view.
    ///
    /// This modifier only takes effect when this view is visible.
    public func statusBar(hidden: Bool) -> Self {
        var view = self
        view.viewStore.statusBarHidden = hidden
        return view
    }
    
    /// Sets the status bar style for this view.
    ///
    /// __Note__: Not available in SwiftUI.
    public func statusBarStyle(_ style: UIStatusBarStyle) -> Self {
        var view = self
        view.viewStore.statusBarStyle = style
        return view
    }
     
    /// Sets the maximum number of lines that text can occupy in this view.
    ///
    /// The line limit applies to all `Text` instances within this view. For
    /// example, an `HStack` with multiple pieces of text longer than three
    /// lines caps each piece of text to three lines rather than capping the
    /// total number of lines across the `HStack`.
    ///
    /// - Parameter number: The line limit. If `nil`, no line limit applies.
    ///
    /// - Note: a non-nil `number` less than 1 will be treated as 1.
    public func lineLimit(_ number: Int?) -> Self {
        var view = self
        if let number = number {
            view.viewStore.lineLimit = max(1, number)
        } else {
            view.viewStore.lineLimit = nil
        }
        return view
    }
     
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a tap gesture.
    public func onTapGesture(perform action: @escaping () -> Void) -> Self {
        var view = self
        view.viewStore.tapAction = action
        return view
    }
     
    /// Sets the priority by which a parent layout should apportion
    /// space to this child.
    ///
    /// The default priority is `0`.  In a group of sibling views,
    /// raising a view's layout priority encourages that view to shrink
    /// later when the group is shrunk and stretch sooner when the group
    /// is stretched.
    ///
    /// A parent layout should offer the child(ren) with the highest
    /// layout priority all the space offered to the parent minus the
    /// minimum space required for all its lower-priority children, and
    /// so on for each lower priority value.
    public func layoutPriority(_ value: Double) -> Self {
        var view = self
        view.viewStore.layoutPriority = value
        return view
    }
    
    /// Hides labels for controls that contain a descriptive label by default.
    public func labelsHidden() -> Self {
        var view = self
        view.viewStore.labelsHidden = true
        return view
    }
    
    /// Sets the tag of the view, used for selecting from a list of `View`
    /// options.
    ///
    /// - SeeAlso: `List`, `Picker`, `TabView`
    public func tag(_ tag: Int) -> Self {
        var view = self
        view.viewStore.tag = tag
        return view
    }
    
    /// Sets the tab item information for the tab root view
    /// __Important__: You __must__ provide both one Text and Image only.
    public func tabItem(@ViewBuilder _ label: () -> View) -> Self {
        var view = self
        let subViews = label().subViews
        if let text = subViews.first(where: { $0 is Text }) as? Text, let image = subViews.first(where: { $0 is Image }) as? Image {
            let tabItem = TabItem(text: text.string, image: image.image)
            view.viewStore.tabItem = tabItem
        }
        return view
    }
    
    /// Sets the alignment on text when spanning multiple lines.
    public func multilineTextAlignment(_ alignment: TextAlignment) -> Self {
        var view = self
        view.viewStore.multilineTextAlignment = alignment
        return view
    }
    
    /// Executes the action when the view appears on screen.
    public func onAppear(perform action: (() -> Void)? = nil) -> Self {
        var view = self
        view.viewStore.onAppear = action
        return view
    }
    
    /// Executes the action when the view disappears from the screen.
    public func onDisappear(perform action: (() -> Void)? = nil) -> Self {
        var view = self
        view.viewStore.onDisappear = action
        return view
    }
    
    /// Returns a modified version of the view, which is modified by
    /// the `modifier` parameter.
    public func modifier(_ modifier: ViewModifier) -> View {
        modifier.body(content: self)
    }
    
    /// Masks the view with another view. The view passed as parameter
    /// will act as the mask.
    public func mask(_ mask: View) -> Self {
        var view = self
        view.viewStore.mask = mask
        return view
    }
    
    /// Sets the coordinate space name for this view.
    /// GeometryProxy types can identify this view's coordinate
    /// space by the name set, when resolving frames.
    public func coordinateSpace(_ name: String) -> Self {
        var view = self
        view.viewStore.coordinateSpace = name
        return view
    }
    
    /// Attaches `gesture` to `self` such that it has higher precedence
    /// than gestures defined by `self`.
    public func highPriorityGesture<T>(_ gesture: T) -> Self where T : Gesture {
        var view = self
        guard var priorityGesture = gesture.firstExecutableGesture() else {
            return view
        }
        
        priorityGesture.priority = .high
        if var gestures = view.viewStore.gestures {
            gestures.append(priorityGesture)
            view.viewStore.gestures = gestures
        } else {
            view.viewStore.gestures = [priorityGesture]
        }
        return view
    }

    /// Attaches `gesture` to self such that it will be processed
    /// simultaneously with gestures defined by `self`.
    public func simultaneousGesture<T>(_ gesture: T) -> Self where T : Gesture {
        var view = self
        guard var priorityGesture = gesture.firstExecutableGesture() else {
            return view
        }
        
        priorityGesture.priority = .simultaneous
        if var gestures = view.viewStore.gestures {
            gestures.append(priorityGesture)
            view.viewStore.gestures = gestures
        } else {
            view.viewStore.gestures = [priorityGesture]
        }
        return view
    }
    
    /// Updates the `listener` with the view's geometry proxy.
    ///
    /// Updates in the view layout will update the value contained in the
    /// `reader` binding. Use this when you want to reference the view's frame
    /// or size in any coordinate space.
    public func geometryListener(_ listener: Binding<GeometryProxy>) -> Self {
        var view = self
        view.viewStore.geometry = listener
        return view
    }
    
    /// Defines the edge insets of a List's cells.
    ///
    /// Pass an empty EdgeInsets value when you want to remove the default
    /// cell left padding.
    /// __Important__: You must
    /// set the `listRowInsets` in the topmost view element in the hierarchy
    /// of a List's cell.
    /// Example:
    ///
    ///     List(myData) { data in
    ///         VStack {
    ///             Text("Element \(data.name)")
    ///         }
    ///         .listRowInsets(EdgeInsets())
    ///     }
    public func listRowInsets(_ insets: EdgeInsets?) -> Self {
        var view = self
        view.viewStore.listRowInsets = insets
        return view
    }
    
    /// Sets the semantic meaning for all text entry elements
    /// in the hierarchy. Functions such as keyboard suggestions will show
    /// up depending on the content type and user data.
    public func textContentType(_ textContentType: UITextContentType?) -> Self {
        var view = self
        view.viewStore.textContentType = textContentType
        return view
    }
    
    /// DragBegan and DragEnd closures are added.
    /// Not in accordance with SwiftUI Compatibility.
    ///
    /// Activates this view as the source of a drag and drop operation.
    ///
    /// Applying the `onDrag(_:)` modifier adds the appropriate gestures for
    /// drag and drop to this view. When a drag operation begins, a rendering of
    /// this view is generated and used as the preview image.
    ///
    /// - Parameters:
    ///     - data: A closure that returns a single
    ///     <doc://com.apple.documentation/documentation/Foundation/NSItemProvider> that
    ///     represents the draggable data from this view.
    ///     - dragBegan: Called when a drag and drop gesture begins. **Not SwiftUI compatible**.
    ///     - dragEnded: Called when a drag and drop gesture ends. **Not SwiftUI compatible**.
    ///
    /// - Returns: A view that activates this view as the source of a drag and
    ///   drop operation, beginning with user gesture input.
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func onDrag(dragBegan: (() -> Void)? = nil, dragEnded: ((UIDropOperation) -> Void)? = nil, data: @escaping () -> NSItemProvider) -> Self {
        var view = self
        view.viewStore.onDrag = OnDragValues(provider: data, dragBegan: dragBegan, dragEnded: dragEnded)
        return view
    }
    
    /// Defines the destination for a drag and drop operation, using the same
    /// size and position as this view, handling dropped content with the given
    /// closure.
    ///
    /// - Parameters:
    ///   - supportedTypes: The uniform type identifiers that describe the
    ///     types of content this view can accept through drag and drop.
    ///     If the drag and drop operation doesn't contain any of the supported
    ///     types, then this drop destination doesn't activate and `isTargeted`
    ///     doesn't update.
    ///   - isTargeted: A binding that updates when a drag and drop operation
    ///     enters or exits the drop target area. The binding's value is `true`
    ///     when the cursor is inside the area, and `false` when the cursor is
    ///     outside.
    ///   - action: A closure that takes the dropped content and responds
    ///     appropriately. The parameter to `action` contains the dropped
    ///     items, with types specified by `supportedTypes`. Return `true`
    ///     if the drop operation was successful; otherwise, return `false`.
    /// - Returns: A view that provides a drop destination for a drag
    ///   operation of the specified types.
    public func onDrop(of supportedTypes: [String], isTargeted: Binding<Bool>?, perform action: @escaping ([NSItemProvider]) -> Bool) -> Self {
        var view = self
        view.viewStore.onDrop = OnDropValues(supportedTypes: supportedTypes, isTargeted: isTargeted, action: action)
        return view
    }
    
    /// Strict updates during high performance rendering will update
    /// this view but not its children views. This should be used for
    /// collection types when you want to get a slight performance
    /// gain by preventing children from updating.
    ///
    /// One example for using this, is if you want to modify the opacity
    /// of a collection of views. Setting this value will modify the opacity
    /// of the group, affecting all children views equally without updating
    /// them individually.
    ///
    ///     VStack {
    ///         Text("One")
    ///         Text("Two")
    ///     }
    ///     .opacity(offset.y)
    ///     .strictHighPerformanceUpdate()
    ///
    /// See `High Performance Updates` in the documentation for more information.
    ///
    /// - important: Not SwiftUI compatible.
    public func strictHighPerformanceUpdate() -> Self {
        var view = self
        view.viewStore.strictOnHighPerformance = true
        return view
    }
    
    /// Skip update rendering on this view completely during
    /// high performance rendering.
    ///
    /// See `High Performance Updates` in the documentation for more information.
    ///
    /// - important: Not SwiftUI compatible.
    public func skipHighPerformanceUpdate() -> Self {
        var view = self
        view.viewStore.skipOnHighPerformance = true
        return view
    }
    
    // MARK: - Navigation
    
    /// Sets the title of the navigation bar
    public func navigationBarTitle(_ title: String, displayMode: NavigationBarTitleDisplayMode) -> Self {
        var view = self
        view.viewStore.navigationTitle = NavigationTitle(title: title, displayMode: displayMode)
        return view
    }
    
    /// Sets leading and trailing views.
    /// __AltSwiftUI__: Only `Button<Text>`, `Button<Image>` and `HStack` with
    /// data of `Button` type is allowed.
    public func navigationBarItems(leading: View, trailing: View) -> Self {
        var view = self
        view.viewStore.navigationItems = NavigationButtons(leading: navigationButtonsForView(leading), trailing: navigationButtonsForView(trailing))
        return view
    }
    
    /// Sets leading view.
    /// __AltSwiftUI__: Only `Button<Text>`, `Button<Image>` and `HStack` with
    /// data of `Button` type is allowed.
    public func navigationBarItems(leading: View) -> Self {
        var view = self
        view.viewStore.navigationItems = NavigationButtons(leading: navigationButtonsForView(leading), trailing: nil)
        return view
    }
    
    /// Sets trailing view.
    /// __AltSwiftUI__: Only `Button<Text>`, `Button<Image>` and `HStack` with
    /// data of `Button` type is allowed.
    public func navigationBarItems(trailing: View) -> Self {
        var view = self
        view.viewStore.navigationItems = NavigationButtons(leading: nil, trailing: navigationButtonsForView(trailing))
        return view
    }
    
    /// Presents a sheet.
    ///
    /// - Parameters:
    ///     - isPresented: A `Binding` to whether the sheet is presented.
    ///     - onDismiss: A closure executed when the sheet dismisses.
    ///     - content: A closure returning the content of the sheet.
    public func sheet<Content: View>(isPresented: Binding<Bool>, isFullScreen: Bool = false, onDismiss: (() -> Void)? = nil, content: @escaping () -> Content) -> View {
        var view = self
        let id = "\(type(of: content))"
        if isPresented.wrappedValue {
            let content = content().subViews.first ?? EmptyView()
            let sheetDismiss = {
                isPresented.wrappedValue = false
                onDismiss?()
            }
            view.viewStore.sheetPresentation = SheetPresentation(sheetView: content, onDismiss: sheetDismiss, isPresented: isPresented, isFullScreen: isFullScreen, id: id)
        } else {
            view.viewStore.sheetPresentation = SheetPresentation(sheetView: EmptyView(), onDismiss: {}, isPresented: isPresented, isFullScreen: false, id: id)
        }
        return view
    }
    
    private func navigationButtonsForView(_ view: View) -> [UIBarButtonItem] {
        if let button = view as? Button {
            return [navigationButtonForButton(button)]
        } else if let hstack = view as? HStack {
            var barButtons = [UIBarButtonItem]()
            for content in hstack.viewContent {
                if let button = content as? Button {
                    barButtons.append(navigationButtonForButton(button))
                }
            }
            return barButtons
        } else {
            assert(false, "Please pass either a Button<Text>, Button<Image> or HStack containing these 2 types.")
        }
        return []
    }
    private func navigationButtonForButton(_ button: Button) -> UIBarButtonItem {
        if let text = button.labels.first as? Text {
            let style: UIBarButtonItem.Style = (text.viewStore.font?.weight == .bold) ? .done : .plain
            return SwiftUIBarButtonItem(title: text.string, style: style, buttonAction: button.action)
        } else if let image = button.labels.first as? Image {
            return SwiftUIBarButtonItem(image: image.image, style: .plain, buttonAction: button.action)
        } else { 
            assert(false, "Please pass either a Button<Text>, Button<Image> or HStack containing these 2 types.")
        }
        
        return UIBarButtonItem()
    }
    
    /// Presents an alert.
    ///
    /// - Parameters:
    ///     - isPresented: A `Binding` to whether the `Alert` should be shown.
    ///     - content: A closure returning the `Alert` to present.
    public func alert(isPresented: Binding<Bool>, content: () -> Alert) -> Self {
        var view = self
        if isPresented.wrappedValue {
            var alertContent = content()
            alertContent.alertIsPresented = isPresented
            view.viewStore.alert = alertContent
        }
        return view
    }
    
    /// Presents an action sheet.
    ///
    /// - Parameters:
    ///     - isPresented: A `Binding` to whether the action sheet should be
    ///     shown.
    ///     - content: A closure returning the `ActionSheet` to present.
    @available(OSX, unavailable)
    public func actionSheet(isPresented: Binding<Bool>, content: () -> ActionSheet) -> Self {
        var view = self
        if isPresented.wrappedValue {
            var actionSheetContent = content()
            actionSheetContent.actionSheetIsPresented = isPresented
            view.viewStore.actionSheet = actionSheetContent
        }
        return view
    }
    
    /// Presents a StoreKit overlay when a given condition is true.
    ///
    /// You use `appStoreOverlay` to display an overlay that recommends another
    /// app. The overlay enables users to instantly view the other app’s page on
    /// the App Store.
    ///
    /// When `isPresented` is true, the system will run `configuration` to
    /// determine how to configure the overlay. The overlay will automatically
    /// be presented over the current scene.
    ///
    /// - Parameters:
    ///   - isPresented: A Binding to a boolean value indicating whether the
    ///     overlay should be presented.
    ///   - configuration: A closure providing the configuration of the overlay.
    /// - SeeAlso: SKOverlay.Configuration.
    @available(iOS 14.0, *)
    @available(macCatalyst, unavailable)
    @available(OSX, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public func appStoreOverlay(isPresented: Binding<Bool>, configuration: @escaping () -> SKOverlay.Configuration) -> Self {
        var view = self
        
        view.viewStore.skOverlayPresentation = SKOverlayPresentation(
            isPresented: isPresented,
            configuration: configuration)

        return view
    }
    
    // MARK: - Environment
    
    /// Sets an environment object as a __global__ object.
    /// Views can access this object through the `EnvironmentObject` property
    /// wrapper and listen to changes in an `ObservableObject`.
    public func environmentObject<B>(_ bindable: B) -> Self where B : ObservableObject {
        EnvironmentHolder.environmentObjects[String(describing: B.self)] = bindable
        let view = self
        return view
    }
    
    // MARK: - Transform
    
    /// Applies a transform effect to the view
    public func transformEffect(_ transform: CGAffineTransform) -> Self {
        var view = self
        view.viewStore.transform = transform
        return view
    }
    
    /// Applies a location offset based on a size. Modifying a view's offset
    /// won't affect its layout or related views' layout.
    public func offset(_ offset: CGSize) -> Self {
        var view = self
        view.viewStore.transform = view.viewStore.transform?.translatedBy(x: offset.width, y: offset.height) ?? CGAffineTransform(translationX: offset.width, y: offset.height)
        return view
    }
    
    /// Applies a location offset based on a `x` and `y`. Modifying a view's offset
    /// won't affect its layout or related views' layout.
    public func offset(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        offset(CGSize(width: x, height: y))
    }
    
    /// Applies a rotation effect. Modifying a view's rotation
    /// won't affect its layout or related views' layout.
    public func rotationEffect(_ angle: Angle) -> Self {
        var view = self
        view.viewStore.rotation = angle
        return view
    }
    
    /// Applies a scale effect based on a size scale. Modifying a view's scale
    /// won't affect its layout or related views' layout.
    public func scaleEffect(_ scale: CGSize) -> Self {
        var view = self
        view.viewStore.scale = scale
        return view
    }
    
    /// Applies a scale effect based on a scale for both width and height.
    /// Modifying a view's scale won't affect its layout or related views' layout.
    public func scaleEffect(_ s: CGFloat) -> Self {
        var view = self
        view.viewStore.scale = CGSize(width: s, height: s)
        return view
    }
    
    // MARK: - Animation & Transition
    
    /// Sets the animation to affect all previously defined view properties.
    ///
    /// Setting a value of `nil` will impose impose no animation to the properties
    /// even if a value was changed inside a `withAnimation` closure.
    ///
    /// Animations can be set to different subset of properties. Example:
    ///
    ///     Text("Example")
    ///         .offset(x: 5)
    ///         .animation(nil)
    ///         .scale(0.5)
    ///         .animation(.default)
    ///
    public func animation(_ animation: Animation?) -> Self {
        var view = self
        view.viewStore = viewStore.withAnimatedValues(animation: animation)
        return view
    }
    
    /// Sets a transition for when a view appears and disappears.
    ///
    /// __Important__: In order for transitions to be animated, either modify a
    /// property inside a `withAnimation` closure or set a `.animation()` property
    /// to the view.
    ///
    /// Setting a custom animation as part of a custom transition
    /// definition will not trigger an animation, but will override existing `withAnimation`
    /// animations. This is the priority of animations applied to transitions:
    ///
    ///     .animation() -> AnyTransition.animation() -> withAnimation
    ///
    /// Appearing events happen when a view is conditionally not included in
    /// a hierarchy, and conditionally removed from it. Example:
    ///
    ///     VStack {
    ///         if showExample {
    ///             Text("Example")
    ///                 .transition(.opacity)
    ///         }
    ///     }
    ///
    public func transition(_ t: AnyTransition) -> Self {
        var view = self
        view.viewStore.transition = t
        return view
    }
}

/// Returns the result of executing `body` with `animation` installed
/// as the thread's current animation, by setting it as the animation
/// property of the thread's current transaction.
public func withAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    EnvironmentHolder.globalAnimation = animation
    let result = try body()
    EnvironmentHolder.globalAnimation = nil
    return result
}

/// Returns the result of executing `body` with _high performance_.
/// __High performance__: Views that have changes in transform or opacity
/// operations will __only__ update transform or opacity values, while
/// any children of the view won't be updated.
///
/// Also see: ```View.ignoreHighPerformance``` and ```View.skipHighPerformanceUpdate```.
func withHighPerformance<Result>(_ body: () throws -> Result) rethrows -> Result {
    EnvironmentHolder.highPerformanceMode = true
    let result = try body()
    EnvironmentHolder.highPerformanceMode = false
    return result
}
