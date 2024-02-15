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
        
        guard let payloadData = request.content.userInfo as? [String: Any],
              !keychainController.retrieveSharingSessions().isEmpty else {
            self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
            return self.notify()
        }

        if #available(iOSApplicationExtension 13.0, *) {
            Task {
                await handlePushNotificationForNewEmail(payloadData: payloadData)
            }
        } else {
            self.handleGetNewEmails(payloadData: payloadData)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
        self.notify()
    }
    
    @available(iOSApplicationExtension 13.0.0, *)
    private func handlePushNotificationForNewEmail(payloadData: [String: Any]) async {
        self.handleGetNewEmails(payloadData: payloadData)
    }
        
    private func handleGetNewEmails(payloadData: [String: Any]) {
        let mapStateChanges: [String: [TypeName: String]] = PayloadParser.shared.parsingPayloadNotification(payloadData: payloadData)
        
        if (mapStateChanges.isEmpty) {
            self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
            return self.notify()
        } else {
            guard let currentAccountId = mapStateChanges.keys.first,
                  let keychainSharingSession = keychainController.retrieveSharingSessionFromKeychain(accountId: currentAccountId),
                  keychainSharingSession.tokenOIDC != nil || keychainSharingSession.basicAuth != nil,
                  let listStateOfAccount = mapStateChanges[currentAccountId],
                  let newEmailDeliveryState = listStateOfAccount[TypeName.emailDelivery] else {
                self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
                return self.notify()
            }
            
            guard let oldEmailDeliveryState = keychainSharingSession.emailDeliveryState ?? keychainSharingSession.emailState,
                  newEmailDeliveryState != oldEmailDeliveryState else {
                self.showDefaultNotification(message: NSLocalizedString(self.newEmailDefaultMessageKey, comment: "Localizable"))
                return self.notify()
            }
            
            JmapClient.shared.getNewEmails(
                apiUrl: keychainSharingSession.apiUrl,
                accountId: keychainSharingSession.accountId,
                sinceState: oldEmailDeliveryState,
                authenticationType: keychainSharingSession.authenticationType,
                tokenOidc: keychainSharingSession.tokenOIDC,
                basicAuth: keychainSharingSession.basicAuth,
                tokenEndpointUrl: keychainSharingSession.tokenEndpoint,
                oidcScopes: keychainSharingSession.oidcScopes,
                onComplete: { (emails, errors) in
                    do {
                        if emails.isEmpty {
                            self.showDefaultNotification(message: NSLocalizedString(self.newEmailDefaultMessageKey, comment: "Localizable"))
                            return self.notify()
                        } else {
                            self.keychainController.updateEmailDeliveryStateToKeychain(
                                accountId: keychainSharingSession.accountId,
                                newEmailDeliveryState: newEmailDeliveryState
                            )

                            if (emails.count > 1) {
                                for email in emails {
                                    if (email.id == emails.last?.id) {
                                        self.showModifiedNotification(title: email.getSenderName(),
                                                                      subtitle: email.subject,
                                                                      body: email.preview,
                                                                      badgeCount: emails.count,
                                                                      userInfo: [JmapConstants.EMAIL_ID : email.id])
                                        return self.notify()
                                    }
                                    self.showNewNotification(title: email.getSenderName(),
                                                             subtitle: email.subject,
                                                             body: email.preview,
                                                             badgeCount: emails.count,
                                                             notificationId: email.id,
                                                             userInfo: [JmapConstants.EMAIL_ID : email.id])
                                }
                            } else {
                                self.showModifiedNotification(title: emails.first!.getSenderName(),
                                                              subtitle: emails.first!.subject,
                                                              body: emails.first!.preview,
                                                              badgeCount: 1,
                                                              userInfo: [JmapConstants.EMAIL_ID : emails.first!.id])
                                return self.notify()
                            }
                        }
                    } catch {
                        TwakeLogger.shared.log(message: "JmapClient.shared.getNewEmails: \(error)")
                        self.showDefaultNotification(message: NSLocalizedString(self.newEmailDefaultMessageKey, comment: "Localizable"))
                        return self.notify()
                    }
                }
            )
        }
    }

    private func showDefaultNotification(message: String) {
        self.modifiedContent?.title = InfoPlistReader(bundle: .app).bundleDisplayName
        self.modifiedContent?.body = message
        self.modifiedContent?.badge = NSNumber(value: 1)
        self.modifiedContent?.sound = .default
    }
    
    private func showModifiedNotification(title: String?,
                                          subtitle: String?,
                                          body: String?,
                                          badgeCount: Int,
                                          userInfo: [String: Any]) {
        self.modifiedContent?.title = title ?? InfoPlistReader(bundle: .app).bundleDisplayName
        self.modifiedContent?.subtitle = subtitle ?? ""
        self.modifiedContent?.body = body ?? ""
        self.modifiedContent?.badge = NSNumber(value: badgeCount)
        self.modifiedContent?.sound = .default
        self.modifiedContent?.userInfo = userInfo
    }
    
    private func showNewNotification(title: String?,
                                     subtitle: String?,
                                     body: String?,
                                     badgeCount: Int,
                                     notificationId: String,
                                     userInfo: [String: Any]) {
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = title ?? InfoPlistReader(bundle: .app).bundleDisplayName
        content.subtitle = subtitle ?? ""
        content.body = body ?? ""
        content.sound = .default
        content.badge = NSNumber(value: badgeCount)
        content.userInfo = userInfo

        // Create a notification trigger
        let triggerDateTime = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateTime, repeats: false)
        // Create a notification request
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

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
