import UIKit
import Flutter
import flutter_downloader
import receive_sharing_intent
import flutter_local_notifications
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    /// Registers all pubspec-referenced Flutter plugins in the given registry.
    static func registerPlugins(with registry: FlutterPluginRegistry) {
        GeneratedPluginRegistrant.register(with: registry)
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        /// Register the app's plugins in the context of a normal run
        AppDelegate.registerPlugins(with: self)
        
        UNUserNotificationCenter.current().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
        
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            AppDelegate.registerPlugins(with: registry)
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
        
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            AppDelegate.registerPlugins(with: registry)
        }
        
        WorkmanagerPlugin.registerTask(withIdentifier: "com.linagora.ios.teammail.sendingQueue")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
         // For example load MSALPublicClientApplication
         // return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[.sourceApplication] as? String)

         // Cancel url handling
         // return false

         // Proceed url handling for other Flutter libraries like uni_links
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
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert) // shows banner even if app is in foreground
    }
}
