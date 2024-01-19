import Foundation

struct KeychainSharingSession: Codable {
    let accountId: String
    let userName: String
    let authenticationType: AuthenticationType
    let apiUrl: String
    let emailState: String?
    let emailDeliveryState: String?
    let tokenOIDC: TokenOidc?
    let basicAuth: String?
    let tokenEndpoint: String?
    let oidcScopes: [String]?
}

extension KeychainSharingSession {
    func updateEmailDeliveryState(newEmailDeliveryState: String) -> KeychainSharingSession {
        return KeychainSharingSession(
            accountId: self.accountId,
            userName: self.userName,
            authenticationType: self.authenticationType,
            apiUrl: self.apiUrl,
            emailState: emailState,
            emailDeliveryState: newEmailDeliveryState,
            tokenOIDC: self.tokenOIDC,
            basicAuth: self.basicAuth,
            tokenEndpoint: self.tokenEndpoint,
            oidcScopes: self.oidcScopes
        )
    }

    func updateTokenOidc(newTokenOidc: TokenOidc) -> KeychainSharingSession {
        return KeychainSharingSession(
            accountId: self.accountId,
            userName: self.userName,
            authenticationType: self.authenticationType,
            apiUrl: self.apiUrl,
            emailState: self.emailState,
            emailDeliveryState: self.emailDeliveryState,
            tokenOIDC: TokenOidc(
                token: newTokenOidc.token,
                tokenId: newTokenOidc.tokenId,
                expiredTime: newTokenOidc.expiredTime,
                refreshToken: newTokenOidc.refreshToken
            ),
            basicAuth: self.basicAuth,
            tokenEndpoint: self.tokenEndpoint,
            oidcScopes: self.oidcScopes
        )
    }
    
    func toData() -> Data? {
        if let encodedData = try? JSONEncoder().encode(self) {
            return encodedData
        }
        return nil
    }
}
