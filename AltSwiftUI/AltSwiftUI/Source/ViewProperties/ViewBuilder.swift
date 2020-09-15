//
//  ViewBuilder.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// A parameter and function attribute that can specify multiple views in the
/// form of a closure.
///
/// ViewBuilder is used when passing children views as parameter to a parent
/// view.
@_functionBuilder
public struct ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }
    
    public static func buildBlock(_ children: View) -> View {
        children
    }
    
    public static func buildBlock(_ c0: View, _ c1: View) -> TupleView {
        TupleView([c0, c1])
    }
    
    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View) -> TupleView {
        TupleView([c0, c1, c2])
    }


    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View) -> TupleView {
        TupleView([c0, c1, c2, c3])
    }
  
    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4])
    }

    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View, _ c5: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5])
    }

    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View, _ c5: View, _ c6: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6])
    }

    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View, _ c5: View, _ c6: View, _ c7: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7])
    }
 
    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View, _ c5: View, _ c6: View, _ c7: View, _ c8: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7, c8])
    }
 
    public static func buildBlock(_ c0: View, _ c1: View, _ c2: View, _ c3: View, _ c4: View, _ c5: View, _ c6: View, _ c7: View, _ c8: View, _ c9: View) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7, c8, c9])
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` view
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf(_ content: View?) -> OptionalView {
        OptionalView(content: content?.subViews)
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither(first: View) -> View {
        first
    }
    
    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither(second: View) -> View {
        second
    }
}
