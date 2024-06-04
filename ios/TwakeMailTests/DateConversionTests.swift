import XCTest

@testable import Runner

class DateConversionTests: XCTestCase {
    
    func testConvertValidISO8601StringToDate() {
        let validDateString = "2024-05-20T22:54:57.958"
        
        let date = validDateString.convertISO8601StringToDate()
        XCTAssertNotNil(date, "Date should not be nil")
        
        let calendar = Calendar.current
        let expectedComponents = DateComponents(year: 2024, month: 5, day: 20, hour: 22, minute: 54, second: 57, nanosecond: 958000000)
        let expectedDate = calendar.date(from: expectedComponents)
        XCTAssertEqual(date, expectedDate, "Converted date does not match expected date")
    }
        
    func testInvalidISO8601String() {
        let invalidDateString = "Invalid Date String"
        
        let date = invalidDateString.convertISO8601StringToDate()
        XCTAssertNil(date, "The conversion should return nil for an invalid date string.")
    }
    
    func testConvertValidDateToISO8601String() {
        let validDate = Calendar.current.date(
            from: DateComponents(
                year: 2024,
                month: 5,
                day: 20,
                hour: 22,
                minute: 54,
                second: 57,
                nanosecond: 958000000
            )
        )
        
        
        let expectedDateString = "2024-05-20T22:54:57.958"
        let validDateString = validDate!.convertDateToISO8601String()
        
        XCTAssertEqual(validDateString, expectedDateString, "Converted date string does not match expected date string")
    }
}
