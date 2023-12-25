import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    private let timeIntervalNotificationTriggerInSecond: Int = 2
    private let newEmailDefaultMessage: String = "You have new emails"

    private var handler: ((UNNotificationContent) -> Void)?
    private var modifiedContent: UNMutableNotificationContent?
    
    private lazy var keychainController = KeychainController(service: .sessions,
                                                             accessGroup: InfoPlistReader.main.keychainAccessGroupIdentifier)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        handler = contentHandler
        modifiedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        self.modifiedContent?.title = InfoPlistReader(bundle: .app).bundleDisplayName
        
        guard let payloadData = request.content.userInfo as? [String: Any],
              !keychainController.retrieveSharingSessions().isEmpty else {
            self.modifiedContent?.body = newEmailDefaultMessage
            self.modifiedContent?.badge = NSNumber(value: 1)
            return self.notify()
        }

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
            self.modifiedContent?.body = newEmailDefaultMessage
            self.modifiedContent?.badge = NSNumber(value: 1)
            return self.notify()
        } else {
            guard let currentAccountId = mapStateChanges.keys.first,
                  let keychainSharingSession = keychainController.retrieveSharingSessionFromKeychain(accountId: currentAccountId),
                  let listStateOfAccount = mapStateChanges[currentAccountId],
                  let newEmailState = listStateOfAccount[TypeName.EmailDelivery],
                  let oldEmailState = keychainSharingSession.emailState,
                  newEmailState != oldEmailState,
                  keychainSharingSession.tokenOIDC != nil || keychainSharingSession.basicAuth != nil else {
                self.modifiedContent?.body = newEmailDefaultMessage
                self.modifiedContent?.badge = NSNumber(value: 1)
                return self.notify()
            }
            
            JmapClient.shared.getNewEmails(
                apiUrl: keychainSharingSession.apiUrl,
                accountId: keychainSharingSession.accountId,
                sinceState: oldEmailState,
                authenticationType: keychainSharingSession.authenticationType,
                tokenOidc: keychainSharingSession.tokenOIDC,
                basicAuth: keychainSharingSession.basicAuth,
                tokenEndpointUrl: keychainSharingSession.tokenEndpoint,
                oidcScopes: keychainSharingSession.oidcScopes,
                onComplete: { (emails, errors) in
                    if emails.isEmpty {
                        self.modifiedContent?.body = self.newEmailDefaultMessage
                        self.modifiedContent?.badge = NSNumber(value: 1)
                        return self.notify()
                    } else {
                        self.keychainController.updateEmailStateToKeychain(accountId: keychainSharingSession.accountId, newState: newEmailState)

                        if (emails.count > 1) {
                            for email in emails {
                                if (email.id == emails.last?.id) {
                                    break
                                }
                                self.scheduleLocalNotification(email: email)
                            }

                            let delayTimeIntervalNotification: TimeInterval = TimeInterval(self.timeIntervalNotificationTriggerInSecond * (emails.count - 1))

                            DispatchQueue.main.asyncAfter(deadline: .now() + delayTimeIntervalNotification) {
                                self.modifiedContent?.subtitle = emails.last?.subject ?? ""
                                self.modifiedContent?.body = emails.last?.preview ?? ""
                                self.modifiedContent?.badge = NSNumber(value: emails.count)
                                self.modifiedContent?.userInfo[JmapConstants.EMAIL_ID] = emails.last?.id ?? ""
                                return self.notify()
                            }
                        } else {
                            self.modifiedContent?.subtitle = emails.first?.subject ?? ""
                            self.modifiedContent?.body = emails.first?.preview ?? ""
                            self.modifiedContent?.badge = NSNumber(value: 1)
                            self.modifiedContent?.userInfo[JmapConstants.EMAIL_ID] = emails.first?.id ?? ""
                            return self.notify()
                        }
                    }


                }
            )
        }
    }

    func scheduleLocalNotification(email: Email) {
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = InfoPlistReader(bundle: .app).bundleDisplayName
        content.subtitle = email.subject ?? ""
        content.body = email.preview ?? ""
        content.sound = .default
        content.userInfo[JmapConstants.EMAIL_ID] = "\(email.id)"

        // Create a notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeIntervalNotificationTriggerInSecond), repeats: false)

        // Create a notification request
        let request = UNNotificationRequest(identifier: "\(email.id)", content: content, trigger: trigger)

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                TwakeLogger.shared.log(message: "Error scheduling notification: \(error.localizedDescription)")
            } else {
                TwakeLogger.shared.log(message: "Notification scheduled successfully")
            }
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
