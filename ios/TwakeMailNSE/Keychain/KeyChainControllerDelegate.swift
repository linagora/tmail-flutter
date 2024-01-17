import Foundation

struct KeychainCredentials {
    let accountId: String
    let sharingSession: KeychainSharingSession
}

protocol KeychainControllerDelegate: AnyObject {
    func retrieveSharingSessionFromKeychain(accountId: String) -> KeychainSharingSession?
    func retrieveSharingSessions() -> [KeychainCredentials]
    func updateEmailDeliveryStateToKeychain(accountId: String, newEmailDeliveryState: String)
}
