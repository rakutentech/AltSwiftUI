//
//  OperationQueueTests.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/10/08.
//

import XCTest
@testable import AltSwiftUI

class OperationQueueTests: XCTestCase {
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
}
