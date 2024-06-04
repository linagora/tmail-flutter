import Foundation

extension Date {
    func isBefore(_ otherDate: Date) -> Bool {
        return self < otherDate
    }
    
    func convertDateToISO8601String() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CoreUtils.ISO8601_DATE_FORMAT
        dateFormatter.locale = Locale(identifier: CoreUtils.EN_US_POSIX_LOCALE)
        return dateFormatter.string(from: self)
    }
}
