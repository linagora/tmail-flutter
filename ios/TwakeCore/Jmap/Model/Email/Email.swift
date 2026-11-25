import Foundation

struct Email: Codable {
    let id: String
    let subject: String?
    let preview: String?
    let from: [EmailAddress]?
    let receivedAt: String?
    let mailboxIds: [String: Bool]?
    /// Set by the NSE for an email of a delegated account, never sent by the server.
    var owner: NotificationOwner? = nil
    
    func getSenderName() -> String? {
        if (from == nil || from?.isEmpty == true) {
            return nil
        }
        return from?.first?.name ?? from?.first?.email
    }
}

extension Email {
    /// The tap opens the email in its owner's account, so a delegated email carries that account id.
    var notificationUserInfo: [String: Any] {
        guard let owner else { return [JmapConstants.EMAIL_ID: id] }
        return [JmapConstants.EMAIL_ID: id, JmapConstants.ACCOUNT_ID: owner.accountId]
    }

    /// Email ids are unique per account only, and a request with the same identifier replaces a pending one.
    var notificationId: String {
        guard let owner else { return id }
        return "\(owner.accountId)/\(id)"
    }

    /// Names the owner after the sender, as on Android.
    var notificationTitle: String? {
        guard let ownerName = owner?.name, !ownerName.isEmpty else { return getSenderName() }
        guard let sender = getSenderName(), !sender.isEmpty else { return ownerName }
        return "\(sender) · \(ownerName)"
    }

    func ownedBy(_ owner: NotificationOwner?) -> Email {
        var email = self
        email.owner = owner
        return email
    }
}

struct NotificationOwner: Codable, Equatable {
    let accountId: String
    let name: String?
}
