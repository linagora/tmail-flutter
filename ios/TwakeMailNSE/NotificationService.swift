import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    private var handler: ((UNNotificationContent) -> Void)?
    private var modifiedContent: UNMutableNotificationContent?
    
    private lazy var keychainController = KeychainController(service: .sessions,
                                                             accessGroup: InfoPlistReader.main.keychainAccessGroupIdentifier)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let payloadData = request.content.userInfo as? [String: Any],
              !keychainController.retrieveSharingSessions().isEmpty else {
            return self.discard()
        }
        
        handler = contentHandler
        modifiedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        self.modifiedContent?.title = InfoPlistReader(bundle: .app).bundleDisplayName
        
        Task {
            await handleGetNewEmails(payloadData: payloadData)
        }
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        notify()
    }
    
    private func handleGetNewEmails(payloadData: [String: Any]) async {
        let mapStateChanges: [String: [TypeName: String]] = PayloadParser.shared.parsingPayloadNotification(payloadData: payloadData)
        
        if (mapStateChanges.isEmpty) {
            return self.discard()
        } else {
            guard let currentAccountId = mapStateChanges.keys.first,
                  let keychainSharingSession = keychainController.retrieveSharingSessionFromKeychain(accountId: currentAccountId),
                  let listStateOfAccount = mapStateChanges[currentAccountId],
                  let newEmailState = listStateOfAccount[TypeName.EmailDelivery],
                  let oldEmailState = keychainSharingSession.emailState,
                  newEmailState != oldEmailState,
                  keychainSharingSession.tokenOIDC != nil || keychainSharingSession.basicAuth != nil else {
                return self.discard()
            }
            
            JmapClient.shared.getNewEmails(
                apiUrl: keychainSharingSession.apiUrl,
                accountId: keychainSharingSession.accountId,
                sinceState: oldEmailState,
                authenticationType: keychainSharingSession.authenticationType,
                tokenOidc: keychainSharingSession.tokenOIDC,
                basicAuth: keychainSharingSession.basicAuth,
                onSuccess: { emails in
                    self.keychainController.updateEmailStateToKeychain(accountId: keychainSharingSession.accountId, newState: newEmailState)
                    
                    self.modifiedContent?.subtitle = emails.first?.subject ?? ""
                    self.modifiedContent?.body = emails.first?.preview ?? ""
                    self.modifiedContent?.badge = NSNumber(value: emails.count)
                    return self.notify()
                },
                onFailure: { error in
                    if let errorJmap = error as? JmapExceptions, errorJmap == JmapExceptions.notFoundNewEmails {
                        return self.discard()
                    } else {
                        self.modifiedContent?.body = "You have new emails"
                        self.modifiedContent?.badge = NSNumber(value: 1)
                        return self.notify()
                    }
                }
            )
        }
    }
    
    private func notify() {
        guard let modifiedContent else {
            return discard()
        }
        
        handler?(modifiedContent)
        cleanUp()
    }
    
    private func discard() {
        handler?(UNMutableNotificationContent())
        cleanUp()
    }
    
    private func cleanUp() {
        handler = nil
        modifiedContent = nil
    }
    
    deinit {
        cleanUp()
    }
}
