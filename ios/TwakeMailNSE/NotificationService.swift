import UserNotifications
import SwiftUI

class NotificationService: UNNotificationServiceExtension {

    private let newEmailDefaultMessageKey: String = "newMessageInTwakeMail"
    private let newNotificationDefaultMessageKey: String = "newNotificationInTwakeMail"

    private var handler: ((UNNotificationContent) -> Void)?
    private var modifiedContent: UNMutableNotificationContent?
    
    private lazy var keychainController = KeychainController(service: .sessions,
                                                             accessGroup: InfoPlistReader.main.keychainAccessGroupIdentifier)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        handler = contentHandler
        modifiedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        self.modifiedContent?.title = InfoPlistReader(bundle: .app).bundleDisplayName
        self.modifiedContent?.badge = NSNumber(value: 1)
        
        guard let payloadData = request.content.userInfo as? [String: Any],
              !keychainController.retrieveSharingSessions().isEmpty else {
            self.modifiedContent?.body = NSLocalizedString(newEmailDefaultMessageKey, comment: "Localizable")
            return self.notify()
        }

        if #available(iOSApplicationExtension 13.0, *) {
            Task {
                await handleGetNewEmails(payloadData: payloadData)
            }
        } else {
            self.modifiedContent?.body = NSLocalizedString(newEmailDefaultMessageKey, comment: "Localizable")
            return self.notify()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        notify()
    }
    
    @available(iOSApplicationExtension 13.0.0, *)
    private func handleGetNewEmails(payloadData: [String: Any]) async {
        let mapStateChanges: [String: [TypeName: String]] = PayloadParser.shared.parsingPayloadNotification(payloadData: payloadData)
        
        if (mapStateChanges.isEmpty) {
            self.modifiedContent?.body = NSLocalizedString(newEmailDefaultMessageKey, comment: "Localizable")
            return self.notify()
        } else {
            guard let currentAccountId = mapStateChanges.keys.first,
                  let keychainSharingSession = keychainController.retrieveSharingSessionFromKeychain(accountId: currentAccountId),
                  let listStateOfAccount = mapStateChanges[currentAccountId],
                  let newEmailState = listStateOfAccount[TypeName.emailDelivery],
                  let oldEmailState = keychainSharingSession.emailState,
                  newEmailState != oldEmailState,
                  keychainSharingSession.tokenOIDC != nil || keychainSharingSession.basicAuth != nil else {
                self.modifiedContent?.body = NSLocalizedString(newNotificationDefaultMessageKey, comment: "Localizable")
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
                        self.modifiedContent?.body = NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable")
                        return self.notify()
                    } else {
                        self.keychainController.updateEmailStateToKeychain(accountId: keychainSharingSession.accountId, newState: newEmailState)

                        if (emails.count > 1) {
                            for email in emails {
                                if (email.id == emails.last?.id) {
                                    self.modifiedContent?.subtitle = email.subject ?? ""
                                    self.modifiedContent?.body = email.preview ?? ""
                                    self.modifiedContent?.sound = .default
                                    self.modifiedContent?.badge = NSNumber(value: emails.count)
                                    self.modifiedContent?.userInfo[JmapConstants.EMAIL_ID] = email.id
                                    return self.notify()
                                }
                                self.scheduleLocalNotification(email: email)
                            }
                        } else {
                            self.modifiedContent?.subtitle = emails.first?.subject ?? ""
                            self.modifiedContent?.body = emails.first?.preview ?? ""
                            self.modifiedContent?.badge = NSNumber(value: 1)
                            self.modifiedContent?.sound = .default
                            self.modifiedContent?.userInfo[JmapConstants.EMAIL_ID] = emails.first?.id ?? ""
                            return self.notify()
                        }
                    }
                }
            )
        }
    }

    private func scheduleLocalNotification(email: Email) {
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = InfoPlistReader(bundle: .app).bundleDisplayName
        content.subtitle = email.subject ?? ""
        content.body = email.preview ?? ""
        content.sound = .default
        content.badge = 1
        content.userInfo[JmapConstants.EMAIL_ID] = "\(email.id)"

        // Create a notification trigger
        let triggerDateTime = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateTime, repeats: false)
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
        handler?(UNNotificationContent())
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
