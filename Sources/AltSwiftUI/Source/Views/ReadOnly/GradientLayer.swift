//
//  GradientLayer.swift
//  AltSwiftUI
//
//  Created by yang.q.wang on 2021/6/2.
//

import UIKit
import CoreGraphics
class GradientLayer: CALayer {
    enum animationKey {
        case startPoint,endPoint,colors,startRadius,endRadius
    }
    struct AnimationKeys: OptionSet {
        var rawValue: UInt8
        static let startPoint = AnimationKeys(rawValue: 1 << 0)
        static let endPoint = AnimationKeys(rawValue: 1 << 1)
        static let colors = AnimationKeys(rawValue: 1 << 2)
        static let startRadius = AnimationKeys(rawValue: 1 << 3)
        static let endRadius = AnimationKeys(rawValue: 1 << 4)
    }
    var animatableKeys: AnimationKeys = []
    @objc dynamic var startPoint: CGPoint = .zero{
        didSet{
            refreshLayer()
        }
    }
    @objc dynamic var endPoint: CGPoint = .zero{
        didSet{
            refreshLayer()
        }
    }
    @objc dynamic var colors: [CGFloat] = []{
        didSet{
            refreshLayer()
        }
    }
    var locations: [CGFloat]  = []
    var type: CAGradientLayerType = .axial
    @objc dynamic var startRadius: CGFloat = 0{
        didSet{
            refreshLayer()
        }
    }
    @objc dynamic var endRadius: CGFloat = 0{
        didSet{
            refreshLayer()
        }
    }
    var path: CGPath?
    
    override init() {
        super.init()
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "startPoint" {
            return true
        }
        if key == "endPoint" {
            return true
        }
        if key == "startRadius" {
            return true
        }
        if key == "endRadius" {
            return true
        }
        if key == "colors" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    func drawLayer(context: CGContext){
        
        context.saveGState()
        //path
        if let path = self.path {
            context.addPath(path)
            context.clip()
        }
        if animatableKeys.contains(.colors) {
            self.colors = self.presentation()?.colors ?? []
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let count = self.colors.count / 4        
        guard let grad = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: locations, count: count) else {
            return
        }
        switch type {
        case .axial:
            if animatableKeys.contains(.startPoint) {
                self.startPoint = self.presentation()?.startPoint ?? .zero
            }
            if animatableKeys.contains(.endPoint) {
                self.endPoint = self.presentation()?.endPoint ?? .zero
            }
            context.drawLinearGradient(grad, start:  CGPoint(x: startPoint.x * bounds.maxX, y: startPoint.y * bounds.maxY), end:  CGPoint(x: endPoint.x * bounds.maxX, y: endPoint.y * bounds.maxY), options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        case .radial:
            if animatableKeys.contains(.startRadius) {
                self.startRadius = self.presentation()?.startRadius ?? .zero
            }
            if animatableKeys.contains(.endRadius) {
                self.endRadius = self.presentation()?.endRadius ?? .zero
            }
            if animatableKeys.contains(.startPoint) {
                self.startPoint = self.presentation()?.startPoint ?? .zero
            }
            context.drawRadialGradient(grad, startCenter: CGPoint(x: startPoint.x * bounds.maxX, y: startPoint.y * bounds.maxY), startRadius: startRadius, endCenter:  CGPoint(x: startPoint.x * bounds.maxX, y: startPoint.y * bounds.maxY), endRadius: endRadius, options: [.drawsAfterEndLocation, .drawsBeforeStartLocation])
        default:
            break
        }
        context.restoreGState()
    }
    override func display() {
        UIGraphicsBeginImageContext(self.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        self.drawLayer(context: context)
        self.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
    }
    override func removeAnimation(forKey key: String) {
        if key == "startPoint"
        {
            animatableKeys.remove(.startPoint)
        }
        if key == "endPoint"
        {
            animatableKeys.remove(.endPoint)
        }
        if key == "startRadius"
        {
            animatableKeys.remove(.startRadius)
        }
        if key == "endRadius"
        {
            animatableKeys.remove(.endRadius)
        }
        if key == "colors"
        {
            animatableKeys.remove(.colors)
        }
        super.removeAnimation(forKey: key)
    }
    override func animation(forKey key: String) -> CAAnimation? {
        if key == "startPoint"
        {
            let animation = CABasicAnimation(keyPath: key)
            animatableKeys.insert(.startPoint)
            return animation
        }
        if key == "endPoint"
        {
            let animation = CABasicAnimation(keyPath: key)
            animatableKeys.insert(.endPoint)
            return animation
        }
        if key == "startRadius"
        {
            let animation = CABasicAnimation(keyPath: key)
            animatableKeys.insert(.startRadius)
            return animation
        }
        if key == "endRadius"
        {
            let animation = CABasicAnimation(keyPath: key)
            animatableKeys.insert(.endRadius)
            return animation
        }
        if key == "colors"
        {
            let animation = CABasicAnimation(keyPath: key)
            animatableKeys.insert(.colors)
            return animation
        }
        return super.animation(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "startPoint"
        {
            let animation = CABasicAnimation(keyPath: event)
            animatableKeys.insert(.startPoint)
            return animation
        }
        if event == "endPoint"
        {
            let animation = CABasicAnimation(keyPath: event)
            
            animatableKeys.insert(.endPoint)
            return animation
        }
        if event == "startRadius"
        {
            let animation = CABasicAnimation(keyPath: event)
            animatableKeys.insert(.startRadius)
            return animation
        }
        if event == "endRadius"
        {
            let animation = CABasicAnimation(keyPath: event)
            animatableKeys.insert(.endRadius)
            return animation
        }
        if event == "colors"
        {
            let animation = CABasicAnimation(keyPath: event)
            animatableKeys.insert(.colors)
            return animation
        }
        return super.action(forKey: event)
    }
    
    private func refreshLayer(){
        setNeedsDisplay()
    }
}

