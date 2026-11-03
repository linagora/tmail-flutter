import Foundation
import KeychainAccess

enum KeychainControllerService: String {
    case sessions
    
    var identifier: String {
        InfoPlistReader.main.baseBundleIdentifier + "." + rawValue
    }
}

class KeychainController: KeychainControllerDelegate, SentryConfigProvider {
    private let keychain: Keychain
    
    init(service: KeychainControllerService,
         accessGroup: String) {
        keychain = Keychain(service: service.identifier,
                            accessGroup: accessGroup).accessibility(.afterFirstUnlock)
    }
    
    func retrieveSharingSessionFromKeychain(accountId: String) -> KeychainSharingSession? {
        do {
            guard let sessionData = try keychain.getData(accountId) else {
                return nil
            }
            
            return try JSONDecoder().decode(KeychainSharingSession.self, from: sessionData)
        } catch {
            return nil
        }
    }
    
    func retrieveSharingSessions() -> [KeychainCredentials] {
        keychain.allKeys().compactMap { accountId in
            guard let sharingSession = retrieveSharingSessionFromKeychain(accountId: accountId) else {
                return nil
            }

            return KeychainCredentials(accountId: accountId, sharingSession: sharingSession)
        }
    }
    
    /// Returns false when the session is missing, cannot be encoded, or the keychain write throws.
    @discardableResult
    func updateEmailDeliveryStateToKeychain(accountId: String, newEmailDeliveryState: String) -> Bool {
        guard let sharingSession = retrieveSharingSessionFromKeychain(accountId: accountId),
              let newSharingSessionData = sharingSession.updateEmailDeliveryState(newEmailDeliveryState: newEmailDeliveryState).toData() else {
            return false
        }
        do {
            try keychain.set(newSharingSessionData, key: accountId)
            return true
        } catch {
            return false
        }
    }

    /// Returns false when the personal session is missing, cannot be encoded, or the keychain write throws.
    @discardableResult
    func updateDelegatedAccountEmailDeliveryStateToKeychain(
        personalAccountId: String,
        delegatedAccountId: String,
        newEmailDeliveryState: String
    ) -> Bool {
        guard let sharingSession = retrieveSharingSessionFromKeychain(accountId: personalAccountId),
              let newSharingSessionData = sharingSession.updateDelegatedAccountEmailDeliveryState(
                    accountId: delegatedAccountId,
                    newEmailDeliveryState: newEmailDeliveryState
               ).toData() else {
            return false
        }
        do {
            try keychain.set(newSharingSessionData, key: personalAccountId)
            return true
        } catch {
            return false
        }
    }
    
    func updateTokenOidc(accountId: String, newTokenOidc: TokenOidc) {
        do {
            if let sharingSession = retrieveSharingSessionFromKeychain(accountId: accountId),
               let newSharingSessionData = sharingSession.updateTokenOidc(newTokenOidc: newTokenOidc).toData() {
                try keychain.set(newSharingSessionData, key: accountId)
            }
        } catch {}
    }

    /// Own keychain entry, or an item of `delegatedAccounts` on the personal entry.
    func resolveSharingSession(for accountId: String) -> ResolvedSharingSession? {
        if let ownSession = retrieveSharingSessionFromKeychain(accountId: accountId) {
            return ResolvedSharingSession(
                personalSession: ownSession,
                personalAccountId: accountId,
                emailDeliveryState: ownSession.emailDeliveryState ?? ownSession.emailState,
                mailboxIdsBlockNotification: ownSession.mailboxIdsBlockNotification,
                isDelegated: false
            )
        }

        for credentials in retrieveSharingSessions() {
            guard let delegated = credentials.sharingSession.delegatedAccounts?
                .first(where: { $0.accountId == accountId }) else {
                continue
            }
            return ResolvedSharingSession(
                personalSession: credentials.sharingSession,
                personalAccountId: credentials.accountId,
                emailDeliveryState: delegated.emailDeliveryState,
                mailboxIdsBlockNotification: delegated.mailboxIdsBlockNotification,
                isDelegated: true
            )
        }
        return nil
    }
}

extension KeychainController {
    /// The key used in Dart to store the Sentry configuration JSON
    private var sentryConfigKey: String { "sentry_config_data" }
    
    /// Retrieves and decodes the SentryConfig from Keychain
    func retrieveSentryConfig() -> SentryConfig? {
        do {
            guard let configData = try keychain.getData(sentryConfigKey) else {
                return nil
            }
            return try JSONDecoder().decode(SentryConfig.self, from: configData)
        } catch {
            TwakeLogger.shared.log(message: "SentryConfig could not be decoded from Keychain: \(error)")
            return nil
        }
    }
}
