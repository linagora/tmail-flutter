import Foundation

struct KeychainSharingSession: Codable {
    let accountId: String
    let userName: String
    let authenticationType: AuthenticationType
    let apiUrl: String
    let emailState: String?
    let tokenOIDC: TokenOidc?
    let basicAuth: String?
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
            basicAuth: self.basicAuth
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
