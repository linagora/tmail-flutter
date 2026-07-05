import Flutter
import UIKit
import receive_sharing_intent

class SceneDelegate: FlutterSceneDelegate {
    // Under the UIScene lifecycle (mandatory with the iOS 26 SDK) UIKit
    // delivers URL opens to the scene delegate — the AppDelegate's
    // application(_:open:options:) override is never called — so mailto
    // links must be bridged into receive_sharing_intent from here.
    // FlutterSceneDelegate's own forwarding only reaches plugins, and the
    // sharing plugin ignores every URL without its ShareMedia scheme prefix.

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let mailtoUrl = connectionOptions.urlContexts.first(
            where: { $0.url.scheme == "mailto" }
        )?.url,
           let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let shareUrl = appDelegate.handleMailtoUrl(open: mailtoUrl) {
            TwakeLogger.shared.log(message: "SceneDelegate::willConnectTo::bridging cold-start mailto share")
            // Cold start by a mailto tap: register it as the plugin's initial
            // media so Dart's getInitialMedia picks it up once the app is ready.
            _ = SwiftReceiveSharingIntentPlugin.instance.application(
                UIApplication.shared,
                didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey.url: shareUrl]
            )
        }
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts where context.url.scheme == "mailto" {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let shareUrl = appDelegate.handleMailtoUrl(open: context.url) {
                TwakeLogger.shared.log(message: "SceneDelegate::openURLContexts::bridging warm mailto share")
                // Warm mailto tap: emit on the plugin's live media stream.
                _ = SwiftReceiveSharingIntentPlugin.instance.application(
                    UIApplication.shared,
                    open: shareUrl,
                    options: [:]
                )
            }
        }
        super.scene(scene, openURLContexts: URLContexts)
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        removeAppBadger()
        updateApplicationStateInUserDefaults(true)
    }
    
    override func sceneDidEnterBackground(_ scene: UIScene) {
        updateApplicationStateInUserDefaults(false)
    }
    
    private func removeAppBadger() {
        TwakeLogger.shared.log(message: "SceneDelegate::removeAppBadger")
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    private func updateApplicationStateInUserDefaults(_ appIsActive: Bool) {
        let appGroupId = (Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String) ?? "group.\(Bundle.main.bundleIdentifier!)"
        let userDefaults = UserDefaults(suiteName: appGroupId)
        userDefaults?.set(appIsActive, forKey: CoreUtils.APPLICATION_STATE)
    }
}
