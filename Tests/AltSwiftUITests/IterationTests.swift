//
//  IterationTests.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/10/08.
//

import XCTest
@testable import AltSwiftUI

class IterationTests: XCTestCase {
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
    var exampleView: View {
        NestView {
            NestView {
                Text("First")
            }
        }
    }
    
    // MARK: Tests
    
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
    
    func testCollectionIterateDataDiffNoDyIndex() {
        var numberOfOperations = 0
        iterationNewForEach.data.iterateDataDiff(oldData: iterationOldForEach.data, id: { $0 }, startIndex: 0, dynamicIndex: false) { index, diffIndex, operation in
            switch index {
            case 0: XCTAssert(operation.equalsData(from: .delete(data: 0)))
                numberOfOperations += 1
            case 1: XCTAssert(operation.equalsData(from: .update(data: 1)))
                numberOfOperations += 1
            case 2: XCTAssert(operation.equalsData(from: .update(data: 3)))
                numberOfOperations += 1
            case 3: XCTAssert(operation.equalsData(from: .update(data: 2)))
                numberOfOperations += 1
            default: break
            }
            
            if case let .current(currentIndex) = diffIndex {
                if currentIndex == 3 {
                    XCTAssert(index == 4 && operation.equalsData(from: .insert(data: 4)))
                    numberOfOperations += 1
                } else if currentIndex == 4 {
                    XCTAssert(index == 4 && operation.equalsData(from: .insert(data: 5)))
                    numberOfOperations += 1
                }
            }
        }
        XCTAssert(numberOfOperations == 6)
    }
    
    // MARK: Private methods

    private func forEachIterationTest(baseIndex: Int = 0, index: Int, operation: DiffableViewSourceOperation) {
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

fileprivate extension DiffableDataSourceOperation where Data == Int {
    func equalsData(from operation: DiffableDataSourceOperation) -> Bool {
        switch (self, operation) {
        case let (.insert(a), .insert(b)),
             let (.delete(a), .delete(b)),
             let (.update(a), .update(b)):
            return a == b
        default: return false
        }
    }
}
