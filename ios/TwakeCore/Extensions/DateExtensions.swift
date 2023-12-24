import Foundation

extension Date {
    func isBefore(_ otherDate: Date) -> Bool {
        return self < otherDate
    }
}
