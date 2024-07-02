import XCTest

@testable import Runner

class DateConversionTests: XCTestCase {
    
    func testConvertValidISO8601StringToDate() {
        // Arrange
        let validDateString = "2024-05-20T22:54:57.958"
        
        // Act
        let date = validDateString.convertISO8601StringToDate()
        
        // Assert
        XCTAssertNotNil(date, "Date should not be nil")
        
        // Arrange
        let calendar = Calendar.current
        let expectedComponents = DateComponents(year: 2024, month: 5, day: 20, hour: 22, minute: 54, second: 57, nanosecond: 958000000)
        
        // Act
        let expectedDate = calendar.date(from: expectedComponents)
        
        // Assert
        XCTAssertEqual(date, expectedDate, "Converted date does not match expected date")
    }
        
    func testInvalidISO8601String() {
        // Arrange
        let invalidDateString = "Invalid Date String"
        
        // Act
        let date = invalidDateString.convertISO8601StringToDate()
        
        // Assert
        XCTAssertNil(date, "The conversion should return nil for an invalid date string.")
    }
    
    func testConvertValidDateToISO8601String() {
        // Arrange
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
        
        // Act
        let validDateString = validDate!.convertDateToISO8601String()
        
        // Assert
        XCTAssertEqual(validDateString, expectedDateString, "Converted date string does not match expected date string")
    }
    
    func testAddingSeconds() {
        // Arrange
        let initialDate = Date()
        let secondsToAdd = 60
        let expectedDate = initialDate.addingTimeInterval(TimeInterval(secondsToAdd))
        
        // Act
        let resultDate = initialDate.adding(seconds: secondsToAdd)
        
        // Assert
        XCTAssertEqual(resultDate, expectedDate, "The date after adding seconds should be correct.")
    }
    
    func testAddingNegativeSeconds() {
        // Arrange
        let initialDate = Date()
        let secondsToSubtract = -60
        let expectedDate = initialDate.addingTimeInterval(TimeInterval(secondsToSubtract))
        
        // Act
        let resultDate = initialDate.adding(seconds: secondsToSubtract)
        
        // Assert
        XCTAssertEqual(resultDate, expectedDate, "The date after subtracting seconds should be correct.")
    }
}
