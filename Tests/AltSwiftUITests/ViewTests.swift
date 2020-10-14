//
//  ViewTests.swift
//  AltSwiftUITests
//
//  Created by Wong, Kevin a on 2019/08/26.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import XCTest
@testable import AltSwiftUI
@testable import protocol AltSwiftUI.ObservableObject
@testable import class AltSwiftUI.Published

struct NestView: View {
    var viewStore = ViewValues()
    
    let view: () -> View
    var body: View {
        view()
    }
}

struct ColorStateView: View {
    var viewStore = ViewValues()
    @State var background: UIColor
    
    var body: View {
        Button("") {}
            .background(Color(background))
    }
}

class ViewTests: XCTestCase {

    override func setUp() {
        condition = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    var condition = true
    @ViewBuilder var exampleSubviews: View {
        Text("First")
        if condition {
            Text("Condition 1")
            Text("Condition 2")
        }
        Group {
            Text("Group")
        }
        ForEach(0..<2) { index in
            Text("ForEach \(index)")
        }
    }
    var exampleView: View {
        NestView {
            NestView {
                Text("First")
            }
        }
    }
    
    // MARK: Tests
    
    func testFirstRenderableView() {
        let result = exampleView.firstRenderableView(parentContext: Context())
        XCTAssert(result is Text)
    }
    
    func testSubviews() {
        let result = exampleSubviews.subViews
        if result.count == 4 &&
            (result[0] as? Text)?.string == "First" &&
            result[1] is OptionalView &&
            (result[2] as? Text)?.string == "Group" &&
            result[3] is ForEach<Range<Int>, Int, Text> {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testMappedSubviews() {
        let views = exampleSubviews.mappedSubViews { _ in Button("") {} }
        var result = true
        for view in views where !(view is Button) {
            result = false
        }
        if views.count != 4 {
            result = false
        }
        XCTAssert(result)
    }
    
    func testTotallyFlatSubviews() {
        let result = exampleSubviews.totallyFlatSubViews
        if result.count == 6 &&
            (result[0] as? Text)?.string == "First" &&
            (result[1] as? Text)?.string == "Condition 1" &&
            (result[2] as? Text)?.string == "Condition 2" &&
            (result[3] as? Text)?.string == "Group" &&
            (result[4] as? Text)?.string == "ForEach 0" &&
            (result[5] as? Text)?.string == "ForEach 1" {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testTotallyFlatSubviewsNoOptional() {
        condition = false
        let result = exampleSubviews.totallyFlatSubViews
        if result.count == 4 &&
            (result[0] as? Text)?.string == "First" &&
            (result[1] as? Text)?.string == "Group" &&
            (result[2] as? Text)?.string == "ForEach 0" &&
            (result[3] as? Text)?.string == "ForEach 1" {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testOriginalSubviews() {
        let result = exampleSubviews.originalSubViews
        if result.count == 4 &&
            (result[0] as? Text)?.string == "First" &&
            result[1] is OptionalView &&
            result[2] is Group &&
            result[3] is ForEach<Range<Int>, Int, Text> {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testMigrateState() {
        let view = ColorStateView(background: .red)
        let secondView = ColorStateView(background: .blue)
        
        if let uiView = view.renderableView(parentContext: Context()) {
            XCTAssert(uiView.backgroundColor == .red)
            view.background = .green
            secondView.updateRender(uiView: uiView, parentContext: Context())
            // Background state is migrated from view to secondView, so blue won't apply.
            XCTAssert(uiView.backgroundColor == .green)
        } else {
            XCTAssert(false)
        }
    }
    
    class DynamicProp: DynamicProperty {
        var updated = false
        func update(context: Context) {
            updated = true
        }
    }
    struct DynamicPropView: View {
        var viewStore = ViewValues()
        var dynamicProp1 = DynamicProp()
        var dynamicProp2 = DynamicProp()
        var body: View { EmptyView() }
    }
    func testSetupDynamicProperties() {
        let view = DynamicPropView()
        view.setupDynamicProperties(context: Context())
        XCTAssert(view.dynamicProp1.updated && view.dynamicProp2.updated)
    }
}
