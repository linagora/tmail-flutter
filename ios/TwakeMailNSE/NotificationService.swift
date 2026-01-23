import UserNotifications
import Sentry
import SwiftUI

class NotificationService: UNNotificationServiceExtension {

    private let newEmailDefaultMessageKey: String = "newMessageInTwakeMail"
    private let newNotificationDefaultMessageKey: String = "newNotificationInTwakeMail"

    private var handler: ((UNNotificationContent) -> Void)?
    private var modifiedContent: UNMutableNotificationContent?
    
    private lazy var keychainController = KeychainController(service: .sessions,
                                                             accessGroup: InfoPlistReader.main.keychainAccessGroupIdentifier)
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        SentryManager.shared.configure(with: keychainController)
        
        handler = contentHandler
        modifiedContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(Bundle.main.bundleIdentifier!)"
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let isAppActive = userDefaults?.value(forKey: CoreUtils.APPLICATION_STATE) as? Bool
        if isAppActive == true {
            self.modifiedContent?.userInfo = request.content.userInfo.merging(["data": request.content.userInfo], uniquingKeysWith: {(_, new) in new})
            contentHandler(self.modifiedContent ?? request.content)
            return
        }
        
        guard let payloadData = request.content.userInfo as? [String: Any],
              !keychainController.retrieveSharingSessions().isEmpty else {
            SentryManager.shared.capture(message: "NSE: Payload invalid or No Session found in Keychain")
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
        SentryManager.shared.capture(message: "NSE: Service Extension Time Expired (Timeout)")
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
            SentryManager.shared.capture(message: "NSE: Payload parsing returned empty state changes")
            self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
            return self.notify()
        } else {
            guard let currentAccountId = mapStateChanges.keys.first,
                  let keychainSharingSession = keychainController.retrieveSharingSessionFromKeychain(accountId: currentAccountId),
                  keychainSharingSession.tokenOIDC != nil || keychainSharingSession.basicAuth != nil else {
                SentryManager.shared.capture(message: "NSE: Session missing or invalid credential for account: \(mapStateChanges.keys.first ?? "unknown")")
                self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
                return self.notify()
            }

            SentryManager.shared.setSentryUser(keychainSharingSession.sentryUser)
            
            guard let listStateOfAccount = mapStateChanges[currentAccountId],
                  let newEmailDeliveryState = listStateOfAccount[TypeName.emailDelivery] else {
                SentryManager.shared.capture(message: "NSE: Missing emailDelivery state in payload")
                self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
                return self.notify()
            }
            
            guard let oldEmailDeliveryState = keychainSharingSession.emailDeliveryState ?? keychainSharingSession.emailState,
                  newEmailDeliveryState != oldEmailDeliveryState else {
                SentryManager.shared.capture(message: "NSE: Email state unchanged (No new emails)")
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
                isTWP: keychainSharingSession.isTWP,
                onComplete: { (emails, errors) in
                    do {
                        if emails.isEmpty {
                            SentryManager.shared.capture(message: "NSE: GetNewEmails returned empty list despite state change")
                            self.showDefaultNotification(message: NSLocalizedString(self.newEmailDefaultMessageKey, comment: "Localizable"))
                            return self.notify()
                        } else {
                            self.keychainController.updateEmailDeliveryStateToKeychain(
                                accountId: keychainSharingSession.accountId,
                                newEmailDeliveryState: newEmailDeliveryState
                            )

                            let mailboxIdsBlockNotification = keychainSharingSession.mailboxIdsBlockNotification ?? []

                            if (mailboxIdsBlockNotification.isEmpty) {
                                return self.showListNotification(emails: emails)
                            } else {
                                let emailFiltered = self.filterEmailsToPushNotification(
                                    emails: emails,
                                    mailboxIdsBlockNotification: mailboxIdsBlockNotification)
                                return self.showListNotification(emails: emailFiltered)
                            }
                        }
                    } catch {
                        TwakeLogger.shared.log(message: "Error processing emails: \(error)")
                        SentryManager.shared.capture(error: error)
                        self.showDefaultNotification(message: NSLocalizedString(self.newEmailDefaultMessageKey, comment: "Localizable"))
                        return self.notify()
                    }
                }
            )
        }
    }
    
    private func filterEmailsToPushNotification(emails: [Email], mailboxIdsBlockNotification: [String]) -> [Email] {
        return emails.filter { email in
            guard let mailboxIds = email.mailboxIds else { return true }
            for id in mailboxIds.keys {
                if mailboxIdsBlockNotification.contains(id) {
                    return false
                }
            }
            return true
        }
    }
    
    private func showListNotification(emails: [Email]) {
        for email in emails {
            if (email.id == emails.last?.id) {
                self.showModifiedNotification(title: email.getSenderName(),
                                              subtitle: email.subject,
                                              body: email.preview,
                                              badgeCount: emails.count,
                                              userInfo: [JmapConstants.EMAIL_ID : email.id])
                return self.notify()
            } else {
                self.showNewNotification(title: email.getSenderName(),
                                         subtitle: email.subject,
                                         body: email.preview,
                                         badgeCount: emails.count,
                                         notificationId: email.id,
                                         userInfo: [JmapConstants.EMAIL_ID : email.id])
            }
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
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        // Create a notification request
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                TwakeLogger.shared.log(message: "Error scheduling notification: \(error.localizedDescription)")
                SentryManager.shared.capture(error: error)
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
