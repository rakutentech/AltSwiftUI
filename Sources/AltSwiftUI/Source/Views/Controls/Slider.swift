//
//  Slider.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that displays a range of values, and a knob that allows selecting
/// a value in the range.
public struct Slider: View {
    public var viewStore = ViewValues()
    let value: Binding<Float>
    let bounds: ClosedRange<Float>
    var step: Float?
    public var body: View {
        EmptyView()
    }
    
    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>, in bounds: ClosedRange<Float> = 0...1) {
        self.value = value
        self.bounds = bounds
    }

    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - step: The distance between each valid value.
    ///     - label: A `View` that describes the purpose of the instance.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>, in bounds: ClosedRange<Float>, step: Float = 1) {
        self.value = value
        self.bounds = bounds
        if step != 0 {
            self.step = step
        }
    }
}

extension Slider: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUISlider().noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUISlider else { return }
        
        view.value = value.wrappedValue
        view.minimumValue = bounds.lowerBound
        view.maximumValue = bounds.upperBound
        view.valueChanged = { [weak view] in
            guard let view = view else { return }
            var value = view.value
            if let step = self.step {
                // Round the value up or down
                let remainder = value.remainder(dividingBy: step)
                if remainder > step / 2 {
                    value += remainder
                } else {
                    value += (remainder - step)
                }
            }
            self.value.wrappedValue = value
        }
    }
}
