import Foundation

extension String {
    func convertISO8601StringToDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return nil
    }
    
    func convertUTCDateToLocalDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        if let utcDate = dateFormatter.date(from: self) {
            TwakeLogger.shared.log(message: "UTC Date: \(utcDate)")
            dateFormatter.timeZone = TimeZone.current
            let localDateString = dateFormatter.string(from: utcDate)
            TwakeLogger.shared.log(message: "Local Date: \(localDateString)")
            if let localDate = dateFormatter.date(from: localDateString) {
                return localDate
            }
            return nil
        } else {
            TwakeLogger.shared.log(message: "Error converting UTC date string to Date.")
            return nil
        }
    }
}
