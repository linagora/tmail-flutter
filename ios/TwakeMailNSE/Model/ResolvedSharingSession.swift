import Foundation

struct ResolvedSharingSession {
    let personalSession: KeychainSharingSession
    let personalAccountId: String
    let emailDeliveryState: String?
    let mailboxIdsBlockNotification: [String]?
    let isDelegated: Bool
}
