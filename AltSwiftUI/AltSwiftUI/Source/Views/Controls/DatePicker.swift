//
//  DatePicker.swift
//  AltSwiftUI
//
//  Created by Chan, Chengwei on 2020/09/14.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that displays a wheel-style date picker that allows selecting
/// a date in the range.
public struct DatePicker: View {
    public var viewStore = ViewValues()

    var selection: Binding<Date>?
    var minimumDate = Date()
    var maximumDate: Date?
    var components: Components
    
    public enum DatePickerComponent {
        /// show date picker component
        case date
        
        /// show time picker component
        case hourAndMinute
    }
    
    public typealias Components = [DatePickerComponent]
    
    public var body: View {
        return EmptyView()
    }
    
    /// Creates an instance that selects a date from within a range.
    ///
    /// - Parameters:
    ///     - title: The title of view. We don't support it now. just keep it
    ///     so we can have same format as swiftUI's DatePicker.
    ///     - selection: The selected date within `range`.
    ///     - range: The close range of the valid dates.
    ///     - displayedComponents: The time components that composite the date
    ///     picker, now only supports [date, hourAndMinute], [date], [hourAndMinute].
    ///
    public init(_ title: String, selection: Binding<Date>, in range: ClosedRange<Date>, displayedComponents: Components) {
        self.selection = selection
        self.minimumDate = range.lowerBound
        self.maximumDate = range.upperBound
        self.components = displayedComponents
    }
   
    /// Creates an instance that selects a date from within a range.
    ///
    /// - Parameters:
    ///     - title: The title of view. We don't support it now. just keep it
    ///     so we can have same format as swiftUI's DatePicker.
    ///     - selection: The selected date within `range`.
    ///     - range: The partial range of the valid dates.
    ///     - displayedComponents: The time components that composite the date
    ///     picker, now only supports [date, hourAndMinute], [date], [hourAndMinute].
    ///
    public init(_ title: String, selection: Binding<Date>, in range: PartialRangeFrom<Date>, displayedComponents: Components) {
        self.selection = selection
        self.minimumDate = range.lowerBound
        self.components = displayedComponents
    }
}

extension DatePicker: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIDatePicker().noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIDatePicker else { return }
        view.dateBinding = selection
        
        if components.contains(.date) && components.contains(.hourAndMinute) {
            view.datePickerMode = .dateAndTime
        } else if components.contains(.date) {
            view.datePickerMode = .date
        } else if components.contains(.hourAndMinute) {
            view.datePickerMode = .time
        }
        
        view.minimumDate = minimumDate
        view.date = selection?.wrappedValue ?? Date()
        if let maximumDate = maximumDate {
            view.maximumDate = maximumDate
        }
    }
}

