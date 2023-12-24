import Foundation

struct TokenResponse: Codable {
    let accessToken: String?
    let refreshToken: String?
    let expiresTime: Int?
    let refreshExpiresIn: Int?
    let tokenId: String?
    let tokenType: String?
    let scope: String?
    let sessionState: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresTime = "expires_in"
        case refreshExpiresIn = "refresh_expires_in"
        case tokenId = "id_token"
        case tokenType = "token_type"
        case scope
        case sessionState = "session_state"
        case error
    }
}
