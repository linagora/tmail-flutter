import Foundation

extension Int {
    func convertMillisecondsToDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000)
    }
    
    func convertMillisecondsToISO8601String() -> String {
        return convertMillisecondsToDate().convertDateToISO8601String()
    }
}
