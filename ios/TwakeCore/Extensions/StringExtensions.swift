import Foundation

extension String {
    func convertISO8601StringToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CoreUtils.ISO8601_DATE_FORMAT
        dateFormatter.locale = Locale(identifier: CoreUtils.EN_US_POSIX_LOCALE)
        return dateFormatter.date(from: self)
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
