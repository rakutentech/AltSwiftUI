//
//  AltPreviewProvider.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/01/15.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Public Types

/// A type that produces AltSwiftUI view previews in Xcode.
///
/// Xcode statically discovers types that conform to the ``AltPreviewProvider``
/// protocol in your app, and generates previews for each provider it discovers.
///
/// __Note__: In case you can't get the preview window to show, make sure
/// `Editor -> Canvas` is enabled. Additionally, you can access another file
/// whose canvas is properly showing, and then pin it so that it is visible
/// in all files.
@available(iOS 13.0.0, *)
public protocol AltPreviewProvider: PreviewProvider {
    /// Generates a preview of one view.
    ///
    /// The following code shows how to create a preview provider for previewing
    /// a `MyText` view:
    ///
    ///     #if DEBUG && canImport(SwiftUI)
    ///
    ///     import protocol SwiftUI.PreviewProvider
    ///     import protocol RakutenTravelCore.View
    ///
    ///     struct MyTextPreview : AltPreviewProvider, PreviewProvider {
    ///         static var previewView: View {
    ///             MyText()
    ///         }
    ///     }
    ///
    ///     #endif
    static var previewView: View { get }
}

@available(iOS 13.0.0, *)
public extension AltPreviewProvider {
    static var previews: some SwiftUI.View {
        PreviewProviderViewCRepresentable(contentView: previewView)
    }
}

// MARK: - Private Types

typealias RakuContext = Context

@available(iOS 13.0, *)
struct PreviewProviderViewCRepresentable: SwiftUI.UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    public func makeUIViewController(context: SwiftUI.UIViewControllerRepresentableContext<PreviewProviderViewCRepresentable>) -> UIViewController {
        UIHostingController(rootView: contentView)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: SwiftUI.UIViewControllerRepresentableContext<PreviewProviderViewCRepresentable>) {
    }
       
    let contentView: View
}
