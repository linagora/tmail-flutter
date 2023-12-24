import Foundation

class JmapConstants {
    static let EMAIL_GET_METHOD_NAME = "Email/get"
    static let EMAIL_CHANGES_METHOD_NAME = "Email/changes"
    
    static let CREATED_REFERENCE_PATH = "/created/*"
    
    static let JMAP_CORE_CAPABILITY = "urn:ietf:params:jmap:core"
    static let JMAP_MAIL_CAPABILITY = "urn:ietf:params:jmap:mail"
    
    static let EMAIL_PUSH_NOTIFICATION_PROPERTIES = [
        "id",
        "subject",
        "preview",
        "from"
    ]
    
    static let EMAIL_ID = "email_id"
}
