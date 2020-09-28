//
//  AltSwiftUITests.swift
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
        Text("State")
            .background(Color(background))
    }
}

class AltSwiftUITests: XCTestCase {

    override func setUp() {
        condition = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    var exampleView: View {
        NestView {
            NestView {
                Text("First")
            }
        }
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
    
    func testFirstRenderableView() {
        let result = exampleView.firstRenderableView(context: Context())
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
    
    // Operation Queue**
    
    func testViewOperationQueue() {
        let queue = ViewOperationQueue()
        var index = 0
        
        queue.addOperation {
            index += 1
            XCTAssert(index == 1)
            queue.addOperation {
                index += 1
                XCTAssert(index == 3)
            }
            
            index += 1
            XCTAssert(index == 2)
            queue.addOperation {
                queue.addOperation {
                    index += 1
                    XCTAssert(index == 5)
                }
                
                index += 1
                XCTAssert(index == 4)
                queue.addOperation {
                    index += 1
                    XCTAssert(index == 6)
                }
            }
        }
        queue.drainRecursively()
    }
    
    // View Binder**
    
    class ViewBinderTestObject: ObservableObject {
        @Published var change = "Object"
    }
    struct ViewBinderStateTestView: View {
        var viewStore = ViewValues()
        @State var state = "test"
        var body: View { Text("\(state)") }
    }
    struct ViewBinderBindingTestView: View {
        var viewStore = ViewValues()
        @Binding var state: String
        var body: View { Text("\(state)") }
    }
    struct ViewBinderObservedObjTestView: View {
        var viewStore = ViewValues()
        @ObservedObject var object = ViewBinderTestObject()
        var body: View { Text("\(object.change)") }
    }
    struct ViewBinderStateObjTestView: View {
        var viewStore = ViewValues()
        @StateObject var object = ViewBinderTestObject()
        var body: View { Text("\(object.change)") }
    }
    struct ViewBinderEnvironmentObjTestView: View {
        var viewStore = ViewValues()
        var object: EnvironmentObject<ViewBinderTestObject> = {
            var obj = EnvironmentObject<ViewBinderTestObject>()
            obj._wrappedValue = ViewBinderTestObject()
            return obj
        }()
        var body: View { Text("\(object.wrappedValue.change)") }
    }
    
    class ViewBinderMock: ViewBinder {
        var registered = false
        
        override func registerStateNotification(origin: Any) {
            super.registerStateNotification(origin: origin)
            registered = true
        }
        func testStateNotificationSubscribe() {
            XCTAssert(registered)
            registered = false
        }
    }
    
    // Tests
    
    func testViewBinderStateSubscribe() {
        let view = ViewBinderStateTestView()
        executeTestViewBinder(view)
    }
    func testViewBinderBindingSubscribe() {
        let stateView = ViewBinderStateTestView()
        let view = ViewBinderBindingTestView(state: stateView.$state)
        executeTestViewBinder(view)
    }
    func testViewBinderObservedObjectSubscribe() {
        let view = ViewBinderObservedObjTestView()
        executeTestViewBinder(view)
    }
    func testViewBinderStateObjectSubscribe() {
        let view = ViewBinderStateObjTestView()
        executeTestViewBinder(view)
    }
    func testViewBinderEnvironmentObjectSubscribe() {
        let view = ViewBinderEnvironmentObjTestView()
        executeTestViewBinder(view)
    }
    func executeTestViewBinder(_ view: View) {
        let binder = ViewBinderMock(view: view, rootController: nil, bodyLevel: 0)
        EnvironmentHolder.currentBodyViewBinderStack.append(binder)
        _ = view.body
        EnvironmentHolder.currentBodyViewBinderStack.removeLast()
        binder.testStateNotificationSubscribe()
    }
    
    // Array**
    
    func testFlatIterate() {
        let content = (exampleView as? TupleView)?.viewContent
        var index = 0
        var result = true
        content?.flatIterate(viewValues: ViewValues(), action: { view in
            switch index {
            case 0: if (view as? Text)?.string != "First" { result = false }
            case 1: if !(view is OptionalView) { result = false }
            case 2: if (view as? Text)?.string != "Group" { result = false }
            case 3: if !(view is ForEach<Range<Int>, Int, Text>) { result = false }
            default: result = false
            }
            index += 1
        })
        XCTAssert(result)
    }
    
    func testTotallyFlatIterate() {
        let content = (exampleView as? TupleView)?.viewContent
        var index = 0
        var result = true
        content?.flatIterate(viewValues: ViewValues(), action: { view in
            switch index {
            case 0: if (view as? Text)?.string != "First" { result = false }
            case 1: if (view as? Text)?.string != "Condition 1" { result = false }
            case 2: if (view as? Text)?.string != "Condition 2" { result = false }
            case 3: if (view as? Text)?.string != "Group" { result = false }
            case 4: if (view as? Text)?.string != "ForEach 0" { result = false }
            case 5: if (view as? Text)?.string != "ForEach 1" { result = false }
            default: result = false
            }
            index += 1
        })
        XCTAssert(result)
    }
    
    func testTotallyFlatGroupedBySection() {
        let content: [View] = [
            Section { Text("") },
            Text("First"),
            Text("Second"),
            Section { Text("") },
            Text("Third")
        ]
        let result = content.totallyFlatGroupedBySection()
        if result.count == 4,
           (result[1].viewContent[0] as? Text)?.string == "First",
           (result[1].viewContent[1] as? Text)?.string == "Second",
           (result[3].viewContent[0] as? Text)?.string == "Third" {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    func testIterateFullViewInsert() {
        var index = 0
        var result = true
        (exampleView as? TupleView)?.viewContent.iterateFullViewInsert { view in
            switch index {
            case 0: if (view as? Text)?.string != "First" { result = false }
            case 1: if (view as? Text)?.string != "Condition 1" { result = false }
            case 2: if (view as? Text)?.string != "Condition 2" { result = false }
            case 3: if !(view is Group) { result = false }
            case 4: if (view as? Text)?.string != "ForEach 0" { result = false }
            case 5: if (view as? Text)?.string != "ForEach 1" { result = false }
            default: result = false
            }
            index += 1
        }
        XCTAssert(result)
    }
    
    var conditionIterateConstant = true
    @ViewBuilder func exampleIterateViews(old: Bool, new: Bool, iterateText: String = "") -> View {
        Text("First\(iterateText)")
        if conditionIterateConstant {
            Text("Condition 1\(iterateText)")
            Text("Condition 2\(iterateText)")
            if old {
                Text("Condition Delete")
            }
        }
        if new {
            Text("Condition Insert")
        }
        if new {
            Text("Condition Else Insert")
        } else {
            if old {
                Text("Condition Else Delete")
            }
        }
        Group {
            Text("Group\(iterateText)")
        }
        if old {
            ForEach(0..<2, id: \.self) { index in
                Text("ForEach Delete \(index)")
            }
        }
        if new {
            ForEach(0..<2) { index in
                Text("ForEach Insert \(index)")
            }
        }
        if old {
            iterationOldForEach
        } else {
            iterationNewForEach
        }
    }
    var iterationOldForEach: ForEach<[Int], Int, Text> {
        ForEach([0, 1, 2, 3], id: \.self) { index in
            Text("ForEach Update \(index)")
        }
    }
    var iterationNewForEach: ForEach<[Int], Int, Text> {
        ForEach([1, 3, 2, 4, 5], id: \.self) { index in
            Text("ForEach Update \(index)")
        }
    }
    
    func testIterateFullViewDiff() {
        let oldViews = exampleIterateViews(old: true, new: false).subViews
        let views = exampleIterateViews(old: false, new: true, iterateText: " Modify").subViews
        
        var iterateIndex = 0
        var ifElseOperations: [DiffableViewSourceOperation] = []
        views.iterateFullViewDiff(oldList: oldViews) { index, operation in
            switch iterateIndex {
            case 0: XCTAssert(operation.equalsText(from: .update(view: Text("First Modify"))))
            case 1: XCTAssert(operation.equalsText(from: .update(view: Text("Condition 1 Modify"))))
            case 2: XCTAssert(operation.equalsText(from: .update(view: Text("Condition 2 Modify"))))
            case 3: XCTAssert(operation.equalsText(from: .delete(view: Text("Condition Delete"))))
            case 4: XCTAssert(operation.equalsText(from: .insert(view: Text("Condition Insert"))))
            case 5, 6: ifElseOperations.append(operation)
            case 7: XCTAssert(operation.equalsText(from: .update(view: Text("Group Modify"))))
            case 8, 9: XCTAssert(operation.equalsText(from: .delete(view: Text("ForEach Delete \(iterateIndex-8)"))))
            case 10, 11: XCTAssert(operation.equalsText(from: .insert(view: Text("ForEach Insert \(iterateIndex-10)"))))
            default: forEachIterationTest(baseIndex: 12, index: index, operation: operation)
            }
            iterateIndex += 1
        }
        // If else
        XCTAssert(ifElseOperations.count == 2)
        XCTAssert(ifElseOperations.contains { $0.equalsText(from: .delete(view: Text("Condition Else Delete"))) })
        XCTAssert(ifElseOperations.contains { $0.equalsText(from: .insert(view: Text("Condition Else Insert"))) })
    }
    
    func testForEachIterateDiff() {
        var startDisplayIndex = 0
        var iterateIndex = 0
        iterationNewForEach.iterateDiff(oldViewGroup: iterationOldForEach, startDisplayIndex: &startDisplayIndex) { index, operation in
            forEachIterationTest(index: iterateIndex, operation: operation)
            iterateIndex += 1
        }
    }
    
    func forEachIterationTest(baseIndex: Int = 0, index: Int, operation: DiffableViewSourceOperation) {
        switch index - baseIndex {
        case 0: XCTAssert(operation.equalsText(from: .delete(view: Text("ForEach Update 0"))))
        case 1: XCTAssert(operation.equalsText(from: .update(view: Text("ForEach Update 1"))))
        case 2: XCTAssert(operation.equalsText(from: .update(view: Text("ForEach Update 3"))))
        case 3: XCTAssert(operation.equalsText(from: .update(view: Text("ForEach Update 2"))))
        case 4: XCTAssert(operation.equalsText(from: .insert(view: Text("ForEach Update 4"))))
        case 5: XCTAssert(operation.equalsText(from: .insert(view: Text("ForEach Update 5"))))
        default: XCTAssert(false)
        }
    }
}

fileprivate extension DiffableViewSourceOperation {
    func equalsText(from operation: DiffableViewSourceOperation) -> Bool {
        switch (self, operation) {
        case let (.insert(a), .insert(b)),
             let (.delete(a), .delete(b)),
             let (.update(a), .update(b)):
            return (a as? Text)?.string == (b as? Text)?.string
        default: return false
        }
    }
}
