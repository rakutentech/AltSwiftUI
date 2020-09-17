//
//  Picker.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that displays a list of values, from which one can be selected.
///
/// By Default a picker view style will be used. If you want to use a different
/// style, modify the view with the `.pickerStyle(_)` method.
public struct Picker : View {
    public var viewStore: ViewValues = ViewValues()
    let selection: Binding<Int>
    let views: [View]
    var style: PickerStyle?
    
    public var body: View {
        return EmptyView()
    }
    
    /// Initializes a picker with a selected index and content. The title
    /// is onlt to identify the picker but won't be visible.
    public init(_ title: String, selection: Binding<Int>, @ViewBuilder content: () -> View) {
        self.selection = selection
        views = content().totallyFlatSubViews.enumerated().map { index, view in
            if view.viewStore.tag == nil {
                var newView = view
                newView.viewStore.tag = index
                return newView
            } else {
                return view
            }
        }
    }
    
    /// Sets the picker style. By setting nil or not setting it,
    /// the picker will use the default view style.
    public func pickerStyle(_ style: PickerStyle?) -> Self {
        var view = self
        if let style = style {
            view.style = style
        }
        return view
    }
}

extension Picker: Renderable {
    public func createView(context: Context) -> UIView {
        if style is SegmentedPickerStyle {
            let items = segmentItems()
            let picker = SwiftUISegmentedControl(items:items).noAutoresizingMask()
            
            updateView(picker, context: context)
            return picker
        }
        let picker = UIPickerView().noAutoresizingMask()
        updateView(picker, context: context)
        return picker
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let view = view as? UIPickerView {
            let delegate = SwiftUIPickerDelegate(views: views, context: context, selection: selection)
            view.ownedSwiftUIDelegate = delegate
            view.delegate = delegate
            view.dataSource = delegate
            let oldSelection = view.selectedRow(inComponent: 0)
            let newSelection = views.firstIndex { $0.viewStore.tag == selection.wrappedValue } ?? 0
            let animated = oldSelection != newSelection
            
            view.reloadAllComponents()
            view.selectRow(newSelection, inComponent: 0, animated: animated)
            
        } else if let view = view as? SwiftUISegmentedControl {
            view.selectionBinding = selection
            view.selectedSegmentIndex = selection.wrappedValue
            updateSegmentedPickerContent(view: view, context: context)
        }
    }
    
    func segmentItems() -> [Any] {
        let items: [Any] = views.compactMap { view in
            if let view = view as? Text {
                return view.string
            } else if let view = view as? Image {
                return view.image
            }
            return nil
        }
        return items
    }
    
    private func updateSegmentedPickerContent(view: SwiftUISegmentedControl, context: Context) {
        let oldPicker = view.lastRenderableView?.view as? Picker
        guard views.count != oldPicker?.views.count else { return }
        
        let items = segmentItems()
        let oldItems = oldPicker?.segmentItems()
        let animate = context.transaction?.animation != nil
        for (index, item) in items.enumerated() {
            if let string = item as? String {
                if string == (oldItems?[safe: index] as? String) {
                    continue
                }
                
                if view.numberOfSegments <= index {
                    view.insertSegment(withTitle: string, at: index, animated: animate)
                } else {
                    view.setTitle(string, forSegmentAt: index)
                }
            } else if let image = item as? UIImage {
                if image == (oldItems?[safe: index] as? UIImage) {
                    continue
                }
                
                if view.numberOfSegments <= index {
                    view.insertSegment(with: image, at: index, animated: animate)
                } else {
                    view.setImage(image, forSegmentAt: index)
                }
            }
        }
        if items.count < view.numberOfSegments {
            for i in items.count..<view.numberOfSegments {
                view.removeSegment(at: i, animated: animate)
            }
        }
    }
}

/// Type that represents the appearance and functionality of a Picker.
public protocol PickerStyle {}

/// A `Picker` style that renders a segmented control view.
public struct SegmentedPickerStyle: PickerStyle {
    public init() {}
}

class SwiftUIPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let views: [View]
    let context: Context
    let selection: Binding<Int>
    
    init(views: [View], context: Context, selection: Binding<Int>) {
        self.views = views
        self.context = context
        self.selection = selection
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        views.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let viewData = views[row]
        if let viewData = viewData as? Text {
            let newView = (view as? SwiftUIAlignmentView<UILabel>) ?? SwiftUIAlignmentView(content: UILabel())
            newView.content.text = viewData.string
            return newView
        } else {
            return SwiftUIAlignmentView(content: viewData.renderableView(parentContext: context) ?? UIView())
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection.wrappedValue = views[row].viewStore.tag ?? row
    }
}
