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
}
