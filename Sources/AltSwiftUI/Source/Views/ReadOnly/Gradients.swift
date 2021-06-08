//
//  Gradients.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/5/26.
//

import UIKit
import CoreGraphics

public struct Gradient {

    /// One color stop in the gradient.
    public struct Stop  {

        /// The color for the stop.
        public var color: Color

        /// The parametric location of the stop.
        ///
        /// This value must be in the range `[0, 1]`.
        public var location: CGFloat

        /// Creates a color stop with a color and location.
        public init(color: Color, location: CGFloat){
            self.color = color
            self.location = location
        }
    }

    /// The array of color stops.
    public var stops: [Gradient.Stop]

    /// Creates a gradient from an array of color stops.
    public init(stops: [Gradient.Stop]){
        self.stops = stops
    }

    /// Creates a gradient from an array of colors.
    ///
    /// The gradient synthesizes its location values to evenly space the colors
    /// along the gradient.
    public init(colors: [Color]){
        self.stops = []
        let count = colors.count
        for (index, color) in colors.enumerated() {
            let stop = Stop(color: color, location: CGFloat(index) * (1 / CGFloat(count - 1)))
            self.stops.append(stop)
        }
    }
}

class SwiftUIGradientView<T: View>: UIView, UIKitViewHandler, GradientProtocol {
    open class override var layerClass: AnyClass {
        return GradientLayer.self
    }
    var gradientLayer : GradientLayer {
        return self.layer as! GradientLayer
    }
    var content: UIView? {
        willSet {
            content?.translatesAutoresizingMaskIntoConstraints = false
            content?.removeFromSuperview()
        }
        didSet {
            setupView()
        }
    }
    var insets = UIEdgeInsets() {
        didSet {
            updateInsets()
        }
    }
    var gradient: T
    var path: CGPath?
    var edgeConstraints: [NSLayoutConstraint] = []
    init(gradient: T, path: CGPath?) {
        self.gradient = gradient
        self.path = path
        super.init(frame: .zero)
        if T.self is LinearGradient.Type {
            setUpLinearGradient(gradient: gradient as! LinearGradient)
        }
        if T.self is RadialGradient.Type {
            setUpRadialGradient(gradient: gradient as! RadialGradient)
        }
    }
    public func updateGradient(gradient: T, path: CGPath?){
        if T.self is LinearGradient.Type {
            setUpLinearGradient(gradient: gradient as! LinearGradient)
        }
        if T.self is RadialGradient.Type {
            setUpRadialGradient(gradient: gradient as! RadialGradient)
        }
    }
    func setUpLinearGradient(gradient: LinearGradient){
        self.gradientLayer.type = .axial
        self.gradientLayer.startPoint = gradient.startPoint
        self.gradientLayer.endPoint = gradient.endPoint
        var locations: [CGFloat] = []
        for stop in gradient.gradient.stops {
            locations.append(CGFloat(stop.location))
        }
        self.gradientLayer.colors = getColorComponents(gradient: gradient.gradient)
        self.gradientLayer.locations = locations
        self.gradientLayer.path = path
        setupView()
    }
    func setUpRadialGradient(gradient: RadialGradient){
        self.gradientLayer.type = .radial
        var locations: [CGFloat] = []
        for stop in gradient.gradient.stops {
            locations.append(CGFloat(stop.location))
        }
        self.gradientLayer.colors = getColorComponents(gradient: gradient.gradient)
        self.gradientLayer.locations = locations
        self.gradientLayer.startRadius = gradient.startRadius
        self.gradientLayer.endRadius = gradient.endRadius
        self.gradientLayer.startPoint = gradient.center
        self.gradientLayer.path = path
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        executeDisappearHandler()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        notifyGeometryListener(frame: frame)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateOnTraitChange(previousTrait: previousTraitCollection)
    }
    private func setupView() {
        guard let content = self.content else { return }
        addSubview(content)
        edgeConstraints = content.edgesAnchorEqualTo(destinationView: self).activate()
    }
    private func updateInsets() {
        if edgeConstraints.count != 4 {
            return
        }
        edgeConstraints[UIView.EdgeAnchorIndex.top.rawValue].constant = insets.top
        edgeConstraints[UIView.EdgeAnchorIndex.left.rawValue].constant = insets.left
        edgeConstraints[UIView.EdgeAnchorIndex.right.rawValue].constant = -insets.right
        edgeConstraints[UIView.EdgeAnchorIndex.bottom.rawValue].constant = -insets.bottom
    }
}
protocol GradientProtocol {
    
}
extension GradientProtocol {
    func performUpdate<Value: Equatable>(layer: CALayer, keyPath: String, newValue: Value?, animation: Animation?, oldValue: Value? = nil) {
        guard newValue != oldValue else {
            return
        }
        let basicAnimation = layer.animation(forKey: keyPath) as! CABasicAnimation
        basicAnimation.fromValue = oldValue
        basicAnimation.toValue = newValue
        if let animation = animation {
            animation.performCALayerCustomAnimation(layer: layer, keyPath:keyPath, newValue: newValue, animation: basicAnimation)
        } else {
            layer.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    func getColorComponents(gradient: Gradient) -> [CGFloat]{
        var components: [CGFloat] = []
        for stop in gradient.stops {
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var green: CGFloat = 0
            var alpha: CGFloat = 0
            stop.color.rawColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            components.append(red)
            components.append(green)
            components.append(blue)
            components.append(alpha)
        }
        return components
    }
}
public struct  GradientView<T: View>: View {
    public var viewStore = ViewValues()
    public var body: View {
        EmptyView()
    }
    var contentView: View
    var gradient: T
}
extension GradientView : Renderable, GradientProtocol{
    public func createView(context: Context) -> UIView {
        let view = SwiftUIGradientView<T>(gradient: gradient, path: self.viewStore.path).noAutoresizingMask()
        context.viewOperationQueue.addOperation {
            guard let renderedContentView = self.contentView.renderableView(parentContext: context, drainRenderQueue: false) else { return }
            view.content = renderedContentView
            self.setupView(view, context: context)
        }
        updateView(view, context: context)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIGradientView<T> else { return }
        view.updateGradient(gradient: gradient, path: gradient.viewStore.path)
        if let content = view.content {
            context.viewOperationQueue.addOperation {
                self.contentView.updateRender(uiView: content, parentContext: context, drainRenderQueue: false)
                self.setupView(view, context: context)
            }
        }
        guard let animation = context.transaction?.animation , let oldView = view.lastRenderableView?.view as? GradientView else {
            return
        }
        
        if let linear = gradient as? LinearGradient, let oldLinear = oldView.gradient as? LinearGradient{
            self.performUpdate(layer: view.layer, keyPath: "startPoint", newValue: linear.startPoint, animation: animation, oldValue: oldLinear.startPoint)
            self.performUpdate(layer: view.layer, keyPath: "endPoint", newValue: linear.endPoint, animation: animation,oldValue: oldLinear.endPoint)
            self.performUpdate(layer: view.layer, keyPath: "colors", newValue: getColorComponents(gradient: linear.gradient), animation: animation,oldValue: getColorComponents(gradient: oldLinear.gradient))
        }
        if let radial = gradient as? RadialGradient, let oldRadial = oldView.gradient as? RadialGradient {
            self.performUpdate(layer: view.layer, keyPath: "startPoint", newValue: radial.center, animation: animation, oldValue: oldRadial.center)
            self.performUpdate(layer: view.layer, keyPath: "startRadius", newValue: radial.startRadius, animation: animation,oldValue: oldRadial.startRadius)
            self.performUpdate(layer: view.layer, keyPath: "endRadius", newValue: radial.endRadius, animation: animation,oldValue: oldRadial.endRadius)
            self.performUpdate(layer: view.layer, keyPath: "colors", newValue: getColorComponents(gradient: radial.gradient), animation: animation,oldValue: getColorComponents(gradient: oldRadial.gradient))
        }
        
    }
    
    private func setupView(_ view: SwiftUIGradientView<T>, context: Context) {
        view.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if context.transaction?.animation != nil {
            view.setNeedsLayout()
        }
        if self.viewStore.background != nil{
            view.backgroundColor = self.viewStore.background
            view.layer.backgroundColor = self.viewStore.background?.cgColor
        }
        else{
            view.backgroundColor = Color.clear.rawColor
            view.layer.backgroundColor = Color.clear.rawColor.cgColor
        }
    }
    
}
extension CGPoint {
   
    public static let center = CGPoint(x: 0.5, y: 0.5)

    public static let leading = CGPoint(x: 0, y: 0)

    public static let trailing = CGPoint(x: 1, y: 0)

    public static let top = CGPoint(x: 0.5, y: 0)

    public static let bottom = CGPoint(x: 0.5, y: 1)

    public static let topLeading = CGPoint(x: 0.5, y: 0)

    public static let topTrailing = CGPoint(x: 1, y: 0)

    public static let bottomLeading = CGPoint(x: 0, y: 1)

    public static let bottomTrailing = CGPoint(x: 1, y: 1)
}
