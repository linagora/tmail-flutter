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
        SentryManager.shared.clearUser()

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

        SentryManager.shared.addBreadcrumb(message: "NSE: Received push notification", level: .info)

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
        SentryManager.shared.capture(message: "NSE: Service Extension Time Expired (Timeout)", flushTimeout: 0.3)
        self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
        self.notify()
    }
    
    @available(iOSApplicationExtension 13.0.0, *)
    private func handlePushNotificationForNewEmail(payloadData: [String: Any]) async {
        self.handleGetNewEmails(payloadData: payloadData)
    }
        
    private func handleGetNewEmails(payloadData: [String: Any]) {
        let mapStateChanges: [String: [TypeName: String]] = PayloadParser.shared.parsingPayloadNotification(payloadData: payloadData)

        if mapStateChanges.isEmpty {
            SentryManager.shared.capture(message: "NSE: Payload parsing returned empty state changes")
            self.showDefaultNotification(message: NSLocalizedString(self.newNotificationDefaultMessageKey, comment: "Localizable"))
            return self.notify()
        }

        let accountIds = Array(mapStateChanges.keys)
        let batch = MultiAccountEmailFetchBatch(accountCount: accountIds.count) {
            emails, sawResolvableAccount, sawFetchedEmails, hadMissingDelivery in
            self.finishMultiAccountFetch(
                emails: emails,
                sawResolvableAccount: sawResolvableAccount,
                sawFetchedEmails: sawFetchedEmails,
                hadMissingDelivery: hadMissingDelivery
            )
        }
        fetchNextAccount(
            accountIds: accountIds,
            mapStateChanges: mapStateChanges,
            index: 0,
            batch: batch
        )
    }

    private func fetchNextAccount(
        accountIds: [String],
        mapStateChanges: [String: [TypeName: String]],
        index: Int,
        batch: MultiAccountEmailFetchBatch
    ) {
        guard index < accountIds.count else { return }

        let accountId = accountIds[index]
        let typeStates = mapStateChanges[accountId] ?? [:]
        let continueNext: () -> Void = {
            self.fetchNextAccount(
                accountIds: accountIds,
                mapStateChanges: mapStateChanges,
                index: index + 1,
                batch: batch
            )
        }

        guard let newEmailDeliveryState = typeStates[TypeName.emailDelivery] else {
            SentryManager.shared.capture(message: "NSE: Missing emailDelivery state in payload")
            batch.markMissingDelivery()
            finishAccountStep(batch: batch, emails: [], then: continueNext)
            return
        }

        // Resolve at the start of each account so a prior refresh is visible.
        guard let resolved = keychainController.resolveSharingSession(for: accountId),
              resolved.personalSession.tokenOIDC != nil || resolved.personalSession.basicAuth != nil else {
            finishAccountStep(batch: batch, emails: [], then: continueNext)
            return
        }

        batch.markResolvable()
        SentryManager.shared.setSentryUser(resolved.personalSession.sentryUser)

        guard let oldEmailDeliveryState = resolved.emailDeliveryState else {
            SentryManager.shared.capture(message: "NSE: No stored email state for account: \(accountId)")
            finishAccountStep(batch: batch, emails: [], then: continueNext)
            return
        }
        guard newEmailDeliveryState != oldEmailDeliveryState else {
            SentryManager.shared.capture(message: "NSE: Email delivery state unchanged, skipping fetch")
            finishAccountStep(batch: batch, emails: [], then: continueNext)
            return
        }

        startEmailFetch(
            accountId: accountId,
            resolved: resolved,
            sinceState: oldEmailDeliveryState,
            newEmailDeliveryState: newEmailDeliveryState,
            batch: batch,
            then: continueNext
        )
    }

    private func finishAccountStep(
        batch: MultiAccountEmailFetchBatch,
        emails: [Email],
        then continueNext: @escaping () -> Void
    ) {
        batch.accountFinished(emails: emails)
        continueNext()
    }

    private func startEmailFetch(
        accountId: String,
        resolved: ResolvedSharingSession,
        sinceState: String,
        newEmailDeliveryState: String,
        batch: MultiAccountEmailFetchBatch,
        then continueNext: @escaping () -> Void
    ) {
        let personalSession = resolved.personalSession
        JmapClient.shared.getNewEmails(
            apiUrl: personalSession.apiUrl,
            accountId: accountId,
            sinceState: sinceState,
            authenticationType: personalSession.authenticationType,
            tokenOidc: personalSession.tokenOIDC,
            basicAuth: personalSession.basicAuth,
            tokenEndpointUrl: personalSession.tokenEndpoint,
            oidcScopes: personalSession.oidcScopes,
            isTWP: personalSession.isTWP,
            keychainAccountId: resolved.personalAccountId,
            onComplete: { result in
                result.errors.forEach { SentryManager.shared.capture(error: $0) }

                let bookmark = DeliveryBookmarkUpdate.resolve(
                    failed: result.failed || !result.errors.isEmpty,
                    hasMoreChanges: result.hasMoreChanges,
                    payloadState: newEmailDeliveryState,
                    latestState: result.latestState
                )
                self.persist(bookmark, accountId: accountId, resolved: resolved)

                // A failed fetch keeps the bookmark, so presenting its partial emails would repeat them on the next push.
                let emails = result.presentableEmails
                guard !emails.isEmpty else {
                    self.reportEmptyResult(result, bookmark: bookmark)
                    self.finishAccountStep(batch: batch, emails: [], then: continueNext)
                    return
                }

                batch.markFetchedEmails()
                let filtered = self.filterEmailsToPushNotification(
                    emails: emails,
                    mailboxIdsBlockNotification: resolved.mailboxIdsBlockNotification ?? []
                )
                self.finishAccountStep(batch: batch, emails: filtered, then: continueNext)
            }
        )
    }

    private func finishMultiAccountFetch(
        emails: [Email],
        sawResolvableAccount: Bool,
        sawFetchedEmails: Bool,
        hadMissingDelivery: Bool
    ) {
        if !emails.isEmpty {
            showListNotification(emails: emails)
            return
        }

        if !sawResolvableAccount {
            if !hadMissingDelivery {
                SentryManager.shared.capture(message: "NSE: Session missing or invalid credential for every account in the payload")
            }
            showDefaultNotification(message: NSLocalizedString(newNotificationDefaultMessageKey, comment: "Localizable"))
            return notify()
        }

        // HEAD: fetched but all blocked → notify() with original content, no default banner.
        if sawFetchedEmails {
            showListNotification(emails: [])
            return
        }

        showDefaultNotification(message: NSLocalizedString(newEmailDefaultMessageKey, comment: "Localizable"))
        notify()
    }

    private func persist(
        _ bookmark: DeliveryBookmarkUpdate,
        accountId: String,
        resolved: ResolvedSharingSession
    ) {
        guard case .write(let state) = bookmark else { return }

        let persisted: Bool
        if resolved.isDelegated {
            persisted = keychainController.updateDelegatedAccountEmailDeliveryStateToKeychain(
                personalAccountId: resolved.personalAccountId,
                delegatedAccountId: accountId,
                newEmailDeliveryState: state
            )
        } else {
            persisted = keychainController.updateEmailDeliveryStateToKeychain(
                accountId: resolved.personalAccountId,
                newEmailDeliveryState: state
            )
        }
        // On failure the emails are still presented: a possible repeat on the next push beats losing a new-mail alert.
        if !persisted {
            SentryManager.shared.capture(message: "NSE: Failed to persist emailDelivery state")
        }
    }

    /// Sends at most one Sentry event per fetch: a failure whose cause was already captured only adds a breadcrumb.
    private func reportEmptyResult(_ result: NewEmailFetchResult, bookmark: DeliveryBookmarkUpdate) {
        if result.failed {
            return result.errors.isEmpty
                ? SentryManager.shared.capture(message: "NSE: getNewEmails failed without error")
                : SentryManager.shared.addBreadcrumb(message: "NSE: getNewEmails failed")
        }
        if case .write = bookmark {
            SentryManager.shared.addBreadcrumb(message: "NSE: getNewEmails returned empty list")
        } else {
            SentryManager.shared.capture(message: "NSE: getNewEmails returned empty list")
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
        guard !emails.isEmpty else {
            SentryManager.shared.capture(message: "NSE: All emails filtered by block list, no notification shown")
            return self.notify()
        }

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
        SentryManager.shared.capture(message: "NSE: modifiedContent nil, notification discarded")
        handler?(UNNotificationContent())
        cleanUp()
    }
    
    private func cleanUp() {
        SentryManager.shared.clearUser()
        handler = nil
        modifiedContent = nil
    }
    
    deinit {
        cleanUp()
    }
}
