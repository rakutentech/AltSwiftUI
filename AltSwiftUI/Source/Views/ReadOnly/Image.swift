//
//  Image.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that renders an image.
public struct Image: View {
    public var viewStore: ViewValues = ViewValues()
    public var body: View {
        return EmptyView()
    }
    let image: UIImage
    var isResizable: Bool = false
    var renderingMode: Image.TemplateRenderingMode?
    
    /// Initializes an `Image` with a `UIImage`.
    public init(uiImage image: UIImage) {
        self.image = image
    }
    
    /// Initializes an `Image` by looking up a image asset by name.
    /// Optionally specify a bundle to search in, if not, the app's main
    /// bundle will be used.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.image = UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
    }
    
    /// Specify if the image should dynamically stretch its contents.
    ///
    /// When resizable, the image will expand both horizontally and
    /// vertically infinitely as much as its parent allows it to.
    /// Also, when specifying a `frame`, the image contents will stretch
    /// to the dimensions of the specified `frame`.
    ///
    /// Use `.scaledToFit()` and `.scaledToFill()` to modify how the aspect
    /// ratio of the image varies when stretching.
    public func resizable() -> Self {
        var view = self
        view.isResizable = true
        return view.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Sets the rendering mode of the image.
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Image {
        var view = self
        view.renderingMode = renderingMode
        return view
    }
}

extension Image {
    public enum TemplateRenderingMode {
        case template, original
    }
}

extension Image: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIImageView(image: image).noAutoresizingMask()
        updateView(view, context: context)
        return view
    }
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIImageView else { return }
        
        if let renderingMode = renderingMode {
            switch renderingMode {
            case .original:
                view.image = image.withRenderingMode(.alwaysOriginal)
            case .template:
                view.image = image.withRenderingMode(.alwaysTemplate)
            }
        } else {
            view.image = image
        }
        if !isResizable {
            view.contentMode = .center
        } else if let aspectRatioMode = context.viewValues?.aspectRatio?.contentMode {
            view.contentMode = aspectRatioMode.uiviewContentMode()
        } else {
            view.contentMode = .scaleToFill
        }
    }
}

extension ContentMode {
    func uiviewContentMode() -> UIView.ContentMode {
        switch self {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleAspectFill
        }
    }
}
