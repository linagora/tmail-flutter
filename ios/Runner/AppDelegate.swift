import UIKit
import Flutter
import flutter_downloader
import receive_sharing_intent
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
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
    
}
