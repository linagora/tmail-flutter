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
        if let url = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            if url.scheme == "mailto" {
                if let url = handleEmailAndress(open: url) {
                    let corrected = launchOptions!.map { (key, value) in key != .url ? (key, value) : (key, url) }
                    
                    return sharingIntent.application(application, didFinishLaunchingWithOptions: Dictionary(uniqueKeysWithValues: corrected))
                }
            }
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
    ) -> Bool {
        if isForegroundFcmDataOnlyNotification(userInfo) {
            fcmMethodChannel?.invokeMethod(CoreUtils.FCM_ON_MESSAGE_METHOD_NAME, arguments: userInfo)
            completionHandler(.noData)
            return true
        }
        return super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
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
            if let url = handleEmailAndress(open: url) {
                return sharingIntent.application(app, open: url, options: options)
            }
        }
        
        return super.application(app, open: url, options:options)
    }
    
    private func handleEmailAndress(open url: URL) -> URL? {
        let appDomain = Bundle.main.bundleIdentifier!
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(Bundle.main.bundleIdentifier!)"
        let sharedKey = "ShareKey"
        var sharedText: [String] = []
        if let email = url.absoluteString.components(separatedBy: ":").last {
            sharedText.append(email)
        }
        let userDefaults = UserDefaults(suiteName: appGroupId)
        userDefaults?.set(sharedText, forKey: sharedKey)
        userDefaults?.synchronize()
        return URL(string: "ShareMedia-\(appDomain)://dataUrl=\(sharedKey)#text")
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
            completionHandler([.alert, .badge, .sound])
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
