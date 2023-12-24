import Foundation

protocol Authentication {
    var type: AuthenticationType { get }

    func getAuthenticationHeader() -> String
}
