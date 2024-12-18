//
//  AH_UN_Schedule_Tests.swift
//  AH-UN Schedule Tests
//
//  Created by ZoutigeWolf on 17/03/2024.
//

import XCTest

final class DateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditDateMWD() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        let calendar = Calendar(identifier: .iso8601)
        
        var dateComponents = DateComponents()
        dateComponents.day = 17
        dateComponents.month = 9
        dateComponents.year = 2024

        let date = calendar.date(from: dateComponents)!
                
        let editedDate = DateUtils.editDate(date, months: 1, weeks: 1, days: 1)
        
        XCTAssert(DateUtils.getDateComponent(editedDate, .year) == 2024)
        XCTAssert(DateUtils.getDateComponent(editedDate, .month) == 10)
        XCTAssert(DateUtils.getDateComponent(editedDate, .day) == 25)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
