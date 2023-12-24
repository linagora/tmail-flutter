import Foundation

struct TokenOidc: Codable {
    let token: String
    let tokenId: String
    let expiredTime: String?
    let refreshToken: String
}

extension TokenOidc {
    func getAuthorization() -> String {
        return "Bearer \(token)"
    }
}
