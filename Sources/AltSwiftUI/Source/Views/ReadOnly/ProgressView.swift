//
//  ProgressView.swift
//  AltSwiftUI
//
//  Created by Tsuchiya, Hiroma | Hiroma | TID on 2021/05/27.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that shows the progress towards completion of a task.
public struct ProgressView: View {
    public var viewStore = ViewValues()
    public var body: View {
        self
    }
    
    var title: String?
    var label: View?
    var progress: Float?
    var total: Float?
    
    public init() {}
    
    public init(_ title: String) {
        self.title = title
    }
    
    public init(label: View) {
        self.label = label
    }
    
    public init(_ progress: Float) {
        self.progress = progress
    }
    
    public init(value: Float?, total: Float? = 1.0) {
        self.progress = (value ?? 0) / (total ?? 1.0)
    }
    
    public init(_ title: String, value: Float?, total: Float?) {
        self.title = title
        self.progress = (value ?? 0) / (total ?? 1.0)
    }
}

extension ProgressView: Renderable {
    public func createView(context: Context) -> UIView {
        if (progress != nil) {
            /// Determinate Progress View
            if (title != nil) {
                let titleView = UITextView()
                titleView.text = title
                titleView.isScrollEnabled = false
                titleView.textColor = .gray
                let progressView = UIProgressView(progressViewStyle: .default)
                updateView(progressView, context: context)
                let view = UIStackView()
                view.axis = .vertical
                view.alignment = .leading
                view.addArrangedSubview(titleView)
                view.addArrangedSubview(progressView)
                progressView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
                return view
            } else {
                let view = UIProgressView(progressViewStyle: UIProgressView.Style.default)
                updateView(view, context: context)
                return view
            }
            
        } else {
            /// Indeterminate Progress View
            if (title != nil) {
                let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
                indicatorView.color = .gray
                indicatorView.startAnimating()
                let titleView = UITextView()
                titleView.text = title
                titleView.isScrollEnabled = false
                titleView.textColor = .gray
                let view = UIStackView()
                view.axis = .vertical
                view.alignment = .center
                view.addArrangedSubview(indicatorView)
                view.addArrangedSubview(titleView)
                return view
            } else {
                let view = UIActivityIndicatorView(style: .whiteLarge)
                view.color = .gray
                view.startAnimating()
                return view
            }
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let progressView = view as? UIProgressView {
            progressView.setProgress(progress ?? 0, animated: true)
        }
        
        if let uiStackView = view as? UIStackView {
            if let progressView = uiStackView.subviews.last as? UIProgressView {
                progressView.setProgress(progress ?? 0, animated: true)
            }
        }
    }
}
