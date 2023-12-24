import Foundation
import Alamofire

class TokenRefreshManager {
    private let MOBIE_CLIENT_ID = "teammail-mobile"
    private let MOBIE_REDIRECT_URL = "teammail.mobile://oauthredirect"
    private let OIDC_SCOPES = ["openid", "profile", "email", "offline_access"]

    private let GRANT_TYPE = "grant_type"
    private let REFRESH_TOKEN = "refresh_token"
    private let CLIENT_ID = "client_id"
    private let REDIRECT_URI = "redirect_uri"
    private let SCOPES = "scopes"

    let refreshToken: String
    let tokenEndpoint: String
    let scopes: [String]?

    init(refreshToken: String, tokenEndpoint: String, scopes: [String]?) {
        self.refreshToken = refreshToken
        self.tokenEndpoint = tokenEndpoint
        self.scopes = scopes
    }

    private func getScopes() -> String {
        if let scopes, !scopes.isEmpty {
            return scopes.joined(separator: " ")
        }
        return OIDC_SCOPES.joined(separator: " ")
    }

    func handleRefreshAccessToken(
        onSuccess: @escaping (TokenResponse) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        guard let tokenEndpointUrl = URL(string: tokenEndpoint),
              var request = try? URLRequest(url: tokenEndpointUrl, method: .post) else {
            return onFailure(NetworkExceptions.requestUrlInvalid)
        }

        let params = [
            CLIENT_ID: MOBIE_CLIENT_ID,
            GRANT_TYPE: REFRESH_TOKEN,
            REDIRECT_URI: MOBIE_REDIRECT_URL,
            REFRESH_TOKEN: refreshToken,
            SCOPES: getScopes(),
        ]

        let data = params
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)

        request.httpBody = data

        AF.request(request).responseDecodable(of: TokenResponse.self) { response in
            if (response.response?.statusCode != 200) {
                onFailure(NetworkExceptions(value: "Failed to get token: \(response.error?.localizedDescription ?? "Unknown Error")"))
            } else {
                switch(response.result) {
                case .success(let data):
                    onSuccess(data)
                case .failure(let error):
                    onFailure(NetworkExceptions(value: "Failed to get token \(error.localizedDescription)"))
                }
            }
        }
    }
}
