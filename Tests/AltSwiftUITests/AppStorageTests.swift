//
//  AppStorageTests.swift
//  AltSwiftUITests
//
//  Created by yang.q.wang on 2021/5/19.
//

import XCTest
@testable import AltSwiftUI

class AppStorageTests: XCTestCase {
    @AppStorage("username" , store:UserDefaults(suiteName: "com.rakuten.www")) var firstName =  "Test firstName"
    @AppStorage("username" , store:UserDefaults(suiteName: "com.rakuten.www")) var middleName = "Test lastName"
    @AppStorage("username" , store:UserDefaults(suiteName: "com.rakuten.www")) var lastName = "Test lastName"
    @AppStorage("optionUserName" , store:UserDefaults(suiteName: "com.rakuten.www")) var optionUserName:String?
    @AppStorage("lampswitchNil") var lampswitchNil: Bool?
    @AppStorage("lampswitch1") var lampswitch: Bool?
    func testAppStorage() {
        self.lastName = "Hello World"
        XCTAssert(self.firstName == self.lastName)
        XCTAssert(self.firstName == self.middleName)
        self.optionUserName = nil
        XCTAssert(self.optionUserName == nil)
        self.optionUserName = "Rakuten"
        XCTAssert(self.optionUserName == "Rakuten")
        XCTAssert(self.lampswitchNil == nil)
        self.lampswitch = true
        XCTAssert(self.lampswitch == true)
    }
}
