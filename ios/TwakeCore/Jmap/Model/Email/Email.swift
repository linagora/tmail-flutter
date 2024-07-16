import Foundation

struct Email: Codable {
    let id: String
    let subject: String?
    let preview: String?
    let from: [EmailAddress]?
    let receivedAt: String?
    let mailboxIds: [String: Bool]?
    
    func getSenderName() -> String? {
        if (from == nil || from?.isEmpty == true) {
            return nil
        }
        return from?.first?.name ?? from?.first?.email
    }
}
