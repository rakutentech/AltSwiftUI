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
                return makeDeterminateProgressViewWithTitle(title: title!, context: context)
            } else {
                return makeDeterminateProgressView(context: context)
            }
        } else {
            /// Indeterminate Progress View
            if (title != nil) {
                return makeIndeterminateProgressViewWithTitle(title: title!)
            } else {
                return makeIndeterminateProgressView()
            }
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let progressView = view as? UIProgressView {
            progressView.setProgress(progress ?? 0, animated: true)
        } else if let uiStackView = view as? UIStackView {
            if let progressView = uiStackView.subviews.last as? UIProgressView {
                progressView.setProgress(progress ?? 0, animated: true)
            }
        }
    }
    
    func makeDeterminateProgressViewWithTitle(title: String, context: Context) -> UIStackView {
        let titleView = UILabel()
        titleView.text = title
        titleView.textColor = .gray
        titleView.font = .systemFont(ofSize: 14)
        let progressView = UIProgressView(progressViewStyle: .default)
        updateView(progressView, context: context)
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.addArrangedSubview(titleView)
        view.addArrangedSubview(progressView)
        progressView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }
    
    func makeDeterminateProgressView(context: Context) -> UIProgressView {
        let view = UIProgressView(progressViewStyle: .default)
        updateView(view, context: context)
        return view
    }
    
    func makeIndeterminateProgressViewWithTitle(title: String) -> UIStackView {
        let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.color = .gray
        indicatorView.startAnimating()
        let titleView = UILabel()
        titleView.text = title
        titleView.font = .systemFont(ofSize: 14)
        titleView.textColor = .gray
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.addArrangedSubview(indicatorView)
        view.addArrangedSubview(titleView)
        return view
    }
    
    func makeIndeterminateProgressView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.color = .gray
        view.startAnimating()
        return view
    }
}
