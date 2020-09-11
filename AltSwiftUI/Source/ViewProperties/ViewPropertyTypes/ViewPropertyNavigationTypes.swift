//
//  ViewPropertyNavigationTypes.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Public Types

public enum NavigationBarTitleDisplayMode {
    /// Displays large title on the first view, while using
    /// inline title for the subsequent views in a navigation stack.
    case automatic
    
    case inline
    case large
}

public struct PresentationMode {

    weak var controller: ScreenViewController?
    
    /// Indicates whether a view is currently presented.
    public internal(set) var isPresented: Bool

    /// Dismisses the view if it is currently presented.
    ///
    /// If `isPresented` is false, `dismiss()` is a no-op.
    public func dismiss() {
        controller?.dismissPresentationMode()
    }
}

// MARK: - Internal Types

struct TabItem {
    let text: String
    let image: UIImage
}

struct NavigationButtons {
    let leading: [UIBarButtonItem]?
    let trailing: [UIBarButtonItem]?
}

struct SheetPresentation {
    let sheetView: View
    let onDismiss: () -> Void
    let isPresented: Binding<Bool>
    let isFullScreen: Bool
    let id: String
}
