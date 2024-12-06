import UIKit
import Flutter
import flutter_downloader
import receive_sharing_intent
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    var notificationInteractionChannel: FlutterMethodChannel?
    var fcmMethodChannel: FlutterMethodChannel?
    var currentEmailId: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        createNotificationInteractionChannel()
        createFcmMethodChannel()
        
        if let payload = launchOptions?[.remoteNotification] as? [AnyHashable : Any],
           let emailId = payload[JmapConstants.EMAIL_ID] as? String,
           !emailId.isEmpty {
            currentEmailId = emailId
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
            if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
                FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
            }
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
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        updateApplicationStateInUserDefaults(false)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        updateApplicationStateInUserDefaults(false)
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
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        removeAppBadger()
        updateApplicationStateInUserDefaults(true)
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
    
    private func removeAppBadger() {
        TwakeLogger.shared.log(message: "AppDelegate::removeAppBadger")
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            
        }
    }
    
    private func createNotificationInteractionChannel() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        self.notificationInteractionChannel = FlutterMethodChannel(
            name: CoreUtils.NOTIFICATION_INTERACTION_CHANNEL_NAME,
            binaryMessenger: controller.binaryMessenger
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
    
    private func createFcmMethodChannel() {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        self.fcmMethodChannel = FlutterMethodChannel(
            name: CoreUtils.FCM_METHOD_CHANNEL_NAME,
            binaryMessenger: controller.binaryMessenger
        )
    }
    
    private func updateApplicationStateInUserDefaults(_ appIsActive: Bool) {
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(Bundle.main.bundleIdentifier!)"
        let userDefaults = UserDefaults(suiteName: appGroupId)
        userDefaults?.set(appIsActive, forKey: CoreUtils.APPLICATION_STATE)
    }
}
