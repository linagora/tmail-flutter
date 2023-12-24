import Foundation

struct AuthenticationCredential: Authentication {
    var type: AuthenticationType
    
    let basicAuth: String
    
    init(type: AuthenticationType, basicAuth: String) {
        self.type = type
        self.basicAuth = basicAuth
    }

    func getAuthenticationHeader() -> String {
        return "Basic \(basicAuth)"
    }
}
