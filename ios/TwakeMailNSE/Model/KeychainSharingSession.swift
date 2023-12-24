import Foundation

struct KeychainSharingSession: Codable {
    let accountId: String
    let userName: String
    let authenticationType: AuthenticationType
    let apiUrl: String
    let emailState: String?
    let tokenOIDC: TokenOidc?
    let basicAuth: String?
    let tokenEndpoint: String?
    let oidcScopes: [String]?
}

extension KeychainSharingSession {
    func updateEmailState(newState: String) -> KeychainSharingSession {
        return KeychainSharingSession(
            accountId: self.accountId,
            userName: self.userName,
            authenticationType: self.authenticationType,
            apiUrl: self.apiUrl,
            emailState: newState,
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
    
    func toJson() -> String? {
        if let data = toData(), let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
