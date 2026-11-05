import Foundation

func emailsSortedByReceivedAt(_ emails: [Email]) -> [Email] {
    emails.sorted { email1, email2 in
        if let date1 = email1.receivedAt?.convertUTCDateToLocalDate(),
           let date2 = email2.receivedAt?.convertUTCDateToLocalDate() {
            return date1 < date2
        }
        return false
    }
}
