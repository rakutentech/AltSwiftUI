//
//  TabView.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A tab view that is shown at the bottom of the screen.
///
/// __Important__: This view will add a tab view at the __root__
/// screen in the application.
@available(watchOS, unavailable)
public struct TabView : View {
    let selection: Binding<Int>?
    let content: [View]
    private var selectedIndex: Int? {
        guard let selectionValue = selection?.wrappedValue else {
            return nil
        }
        return content.firstIndex { $0.viewStore.tag == selectionValue }
    }

    public var viewStore: ViewValues = ViewValues()
    public var body: View {
        EmptyView()
    }
    
    /// Creates an instance that selects from content associated with
    /// `Selection` values.
    public init(selection: Binding<Int>? = nil, @ViewBuilder content: () -> View) {
        self.selection = selection
        self.content = content().subViews
    }
}

extension TabView: Renderable {
    public func createView(context: Context) -> UIView {
        let controller = UIHostingController.customRootTabBarController
        var viewControllers = [UIViewController]()
        for (index, view) in content.enumerated() {
            var modifiedView = view
            if view.viewStore.tag == nil {
                modifiedView.viewStore.tag = index
            }
            let screenController = ScreenViewController(contentView: modifiedView, parentContext: context)
            viewControllers.append(UIHostingController(rootViewController: screenController))
        }
        controller.viewControllers = viewControllers
        updateController(controller)
        UIApplication.shared.activeWindow?.rootViewController = controller
        return controller.view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let tabController = context.overwriteRootController as? SwiftUITabBarController else { return }
        updateController(tabController)
    }
    
    private func updateController(_ controller: SwiftUITabBarController) {
        controller.selectionChanged = { index in
            if self.content.count > index, let tag = self.content[index].viewStore.tag {
                self.selection?.wrappedValue = tag
            }
        }
        if let selectedIndex = self.selectedIndex, controller.currentSelectedIndex != selectedIndex {
            controller.selectedIndex = selectedIndex
        }
    }
}
