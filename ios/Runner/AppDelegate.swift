import UIKit
import Flutter
import receive_sharing_intent
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    var notificationInteractionChannel: FlutterMethodChannel?
    var fcmMethodChannel: FlutterMethodChannel?
    var currentEmailId: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let payload = launchOptions?[.remoteNotification] as? [AnyHashable : Any],
           let emailId = payload[JmapConstants.EMAIL_ID] as? String,
           !emailId.isEmpty {
            currentEmailId = emailId
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        let sharingIntent = SwiftReceiveSharingIntentPlugin.instance
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL,
           url.scheme == "mailto",
           let shareUrl = handleMailtoUrl(open: url) {
            // Buffer the mailto share as the plugin's initial media, then fall
            // through to the normal Flutter launch — returning the plugin's
            // result directly would skip FlutterAppDelegate's engine and window
            // setup when a mailto tap cold-starts the app.
            _ = sharingIntent.application(application, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: shareUrl])
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        
        createNotificationInteractionChannel(engineBridge.applicationRegistrar.messenger())
        createFcmMethodChannel(engineBridge.applicationRegistrar.messenger())
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        updateApplicationStateInUserDefaults(false)
    }

    // FCM data-only pushes (aps present, aps.alert absent) delivered when the app is
    // foreground/inactive trigger EXC_BAD_ACCESS in FLTFirebaseMessagingPlugin._channel
    // (KERN_INVALID_ADDRESS at 0x80) because the plugin's FlutterMethodChannel becomes a
    // dangling pointer after a scene disconnect tears down the Flutter engine.
    //
    // GULAppDelegateSwizzler holds the plugin via a weak reference; when the engine is
    // released the channel object is freed, but the swizzler still dispatches the next
    // notification to that stale pointer before the weak container is zeroed.
    //
    // Fix: intercept this exact combination (FCM, non-background, no alert) ourselves
    // and relay Messaging#onMessage via the AppDelegate's own fcmMethodChannel, which
    // is tied to the current engine. For background pushes we still delegate to super so
    // the headless Dart isolate (Messaging#onBackgroundMessage) continues to work.
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if isForegroundFcmDataOnlyNotification(userInfo) {
            fcmMethodChannel?.invokeMethod(CoreUtils.FCM_ON_MESSAGE_METHOD_NAME, arguments: userInfo)
            completionHandler(.noData)
            return
        }
        super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }

    private func isForegroundFcmDataOnlyNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard userInfo["gcm.message_id"] != nil else { return false }
        guard let aps = userInfo["aps"] as? [String: Any], aps["alert"] == nil else { return false }
        return UIApplication.shared.applicationState != .background
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sharingIntent = SwiftReceiveSharingIntentPlugin.instance
        if sharingIntent.hasMatchingSchemePrefix(url: url) {
            return sharingIntent.application(app, open: url, options: options)
        }
        
        if url.scheme == "mailto" {
            if let url = handleMailtoUrl(open: url) {
                return sharingIntent.application(app, open: url, options: options)
            }
        }

        return super.application(app, open: url, options:options)
    }

    // Bridges a tapped mailto: link into receive_sharing_intent's pipeline by
    // writing the same JSON-encoded [SharedMediaFile] blob the share extension
    // produces — the plugin's handleUrl only decodes that format — and
    // returning the plugin's ShareMedia redirect URL. The full mailto URI is
    // kept as the path so Dart can parse recipient, subject and body query
    // parameters from it.
    //
    // Internal (not private): under the UIScene lifecycle UIKit delivers URL
    // opens to the SceneDelegate, which reuses this bridge; the AppDelegate
    // paths below only run under the classic lifecycle.
    func handleMailtoUrl(open url: URL) -> URL? {
        let appDomain = Bundle.main.bundleIdentifier!
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: kAppGroupIdKey) as? String) ?? "group.\(appDomain)"
        let sharedFile = SharedMediaFile(path: url.absoluteString, type: .url)
        guard let json = try? JSONEncoder().encode([sharedFile]) else { return nil }
        let userDefaults = UserDefaults(suiteName: appGroupId)
        userDefaults?.set(json, forKey: kUserDefaultsKey)
        userDefaults?.removeObject(forKey: kUserDefaultsMessageKey)
        userDefaults?.synchronize()
        return URL(string: "\(kSchemePrefix)-\(appDomain):share")
    }
    
    // Receive displayed notifications for iOS 10 or later devices.
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        TwakeLogger.shared.log(message: "AppDelegate::userNotificationCenter::willPresent::notification: \(notification)")
        TwakeLogger.shared.log(message: "AppDelegate::userNotificationCenter::willPresent::notificationContent: \(notification.request.content.userInfo)")
        if let notificationBadgeCount = notification.request.content.badge?.intValue, notificationBadgeCount > 0 {
            let newBadgeCount = UIApplication.shared.applicationIconBadgeNumber + notificationBadgeCount
            TwakeLogger.shared.log(message: "AppDelegate::userNotificationCenter::willPresent:newBadgeCount: \(newBadgeCount)")
            updateAppBadger(newBadgeCount: newBadgeCount)
        }
        if UIApplication.shared.applicationState == .active {
            fcmMethodChannel?.invokeMethod(
                CoreUtils.FCM_ON_MESSAGE_METHOD_NAME,
                arguments: notification.request.content.userInfo)
            
            completionHandler([])
        } else if validateDisplayPushNotification(userInfo: notification.request.content.userInfo) {
            if #available(iOS 14.0, *) {
                // .banner + .list together replace the pre-iOS-14 .alert behavior
                completionHandler([.banner, .list, .badge, .sound])
            } else {
                completionHandler([.alert, .badge, .sound])
            }
        } else {
            completionHandler([])
        }
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        TwakeLogger.shared.log(message: "AppDelegate::userNotificationCenter::didReceive::response: \(response)")
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        let newBadgeCount = currentBadgeCount > 0 ? currentBadgeCount - 1 : 0
        updateAppBadger(newBadgeCount: newBadgeCount)
        
        
        let userInfo = response.notification.request.content.userInfo
        
        if let emailId = userInfo[JmapConstants.EMAIL_ID] as? String, !emailId.isEmpty {
            self.notificationInteractionChannel?.invokeMethod(
                CoreUtils.CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND,
                arguments: emailId)
        }
        
        completionHandler()
    }
    
    private func validateDisplayPushNotification(userInfo: [AnyHashable : Any]) -> Bool {
        if let emailId = userInfo[JmapConstants.EMAIL_ID] as? String, !emailId.isEmpty, UIApplication.shared.applicationState != .active {
            return true
        }
        return false
    }
}

extension AppDelegate {
    private func updateAppBadger(newBadgeCount: Int) {
        TwakeLogger.shared.log(message: "AppDelegate::updateAppBadger::newBadgeCount: \(newBadgeCount)")
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(newBadgeCount)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = newBadgeCount
            
        }
    }
    
    private func createNotificationInteractionChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        self.notificationInteractionChannel = FlutterMethodChannel(
            name: CoreUtils.NOTIFICATION_INTERACTION_CHANNEL_NAME,
            binaryMessenger: binaryMessenger
        )
        
        self.notificationInteractionChannel?.setMethodCallHandler { (call, result) in
            switch call.method {
            case CoreUtils.CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED:
                result(self.currentEmailId)
                self.currentEmailId = nil
            default:
                break
            }
        }
    }
    
    private func createFcmMethodChannel(_ binaryMessenger: FlutterBinaryMessenger) {
        self.fcmMethodChannel = FlutterMethodChannel(
            name: CoreUtils.FCM_METHOD_CHANNEL_NAME,
            binaryMessenger: binaryMessenger
        )
    }
    
    private func updateApplicationStateInUserDefaults(_ appIsActive: Bool) {
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(Bundle.main.bundleIdentifier!)"
        let userDefaults = UserDefaults(suiteName: appGroupId)
        userDefaults?.set(appIsActive, forKey: CoreUtils.APPLICATION_STATE)
    }
}
