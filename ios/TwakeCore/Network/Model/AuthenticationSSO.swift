import Foundation

struct AuthenticationSSO: Authentication {
    var type: AuthenticationType
    
    let accessToken: String
    let refreshToken: String
    let expireTime: String?

    init(type: AuthenticationType, accessToken: String, refreshToken: String, expireTime: String?) {
        self.type = type
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expireTime = expireTime
    }

    func getAuthenticationHeader() -> String {
        return "Bearer \(accessToken)"
    }

    func isExpiredTime(currentDate: Date) -> Bool {
        guard let expireTime else {
            return false
        }
        
        if let expireDate = expireTime.convertISO8601StringToDate() {
            return expireDate.isBefore(currentDate)
        } else {
            return false
        }
    }
}
