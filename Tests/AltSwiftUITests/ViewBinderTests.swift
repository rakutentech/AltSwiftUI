//
//  ViewBinderTests.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/10/08.
//

import XCTest
@testable import AltSwiftUI
@testable import protocol AltSwiftUI.ObservableObject
@testable import class AltSwiftUI.Published

class ViewBinderTests: XCTestCase {
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
        let binder = ViewBinderMock(view: view, rootController: nil, bodyLevel: 0, isInsideButton: false, overwriteTransaction: nil)
        EnvironmentHolder.currentBodyViewBinderStack.append(binder)
        _ = view.body
        EnvironmentHolder.currentBodyViewBinderStack.removeLast()
        binder.testStateNotificationSubscribe()
    }
}
