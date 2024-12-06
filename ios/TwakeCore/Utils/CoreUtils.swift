import Foundation

class CoreUtils {
    static let shared: CoreUtils = CoreUtils()
    
    static let ISO8601_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    static let EN_US_POSIX_LOCALE = "en_US_POSIX"
    static let NOTIFICATION_INTERACTION_CHANNEL_NAME = "notification_interaction_channel"
    static let CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_FOREGROUND_OR_BACKGROUND = "current_email_id_in_notification_click_when_app_foreground_or_background"
    static let CURRENT_EMAIL_ID_IN_NOTIFICATION_CLICK_WHEN_APP_TERMINATED = "current_email_id_in_notification_click_when_app_terminated"
    static let FCM_METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_messaging"
    static let FCM_ON_MESSAGE_METHOD_NAME = "Messaging#onMessage"
    static let APPLICATION_STATE = "applicationState"

    func getCurrentDate() -> Date {
        if #available(iOS 15, *) {
            return Date.now
        } else {
            return Date()
        }
    }
}

