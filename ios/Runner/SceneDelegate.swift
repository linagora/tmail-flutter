import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
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
