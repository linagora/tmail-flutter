import Foundation

class CoreUtils {
    static let shared: CoreUtils = CoreUtils()
    
    static let ISO8601_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    static let EN_US_POSIX_LOCALE = "en_US_POSIX"

    func getCurrentDate() -> Date {
        if #available(iOS 15, *) {
            return Date.now
        } else {
            return Date()
        }
    }
}

