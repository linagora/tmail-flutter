import Foundation
import Alamofire

class JmapClient {
    static let shared: JmapClient = JmapClient()

    private let jmapHeader = HTTPHeader(name: "Accept", value: "application/json;jmapVersion=rfc-8621")

    private var authentication: Authentication?
    private var tokenRefreshManager: TokenRefreshManager?
    private var authenticationInterceptor: AuthenticationInterceptor?

    func getNewEmails(
        apiUrl: String,
        accountId: String,
        sinceState: String,
        authenticationType: AuthenticationType,
        tokenOidc: TokenOidc?,
        basicAuth: String?,
        tokenEndpointUrl: String?,
        oidcScopes: [String]?,
        onSuccess: @escaping ([Email]) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        if (authenticationType == AuthenticationType.basic) {
            authentication = AuthenticationCredential(
                type: AuthenticationType.basic,
                basicAuth: basicAuth ?? ""
            )
        } else {
            authentication = AuthenticationSSO(
                type: AuthenticationType.oidc,
                accessToken: tokenOidc?.token ?? "",
                refreshToken: tokenOidc?.refreshToken ?? "",
                expireTime: tokenOidc?.expiredTime
            )

            tokenRefreshManager = TokenRefreshManager(
                refreshToken: tokenOidc?.refreshToken ?? "",
                tokenEndpoint: tokenEndpointUrl ?? "",
                scopes: oidcScopes
            )
        }

        authenticationInterceptor = AuthenticationInterceptor(
            authentication: authentication,
            accountId: accountId,
            tokenRefreshManager: tokenRefreshManager
        )

        let jmapRequestObject = JmapRequestGenerator.shared.createEmailChangesRequest(
            accountId: accountId,
            sinceState: sinceState
        )

        AlamofireService.shared.post(
            url: apiUrl,
            payloadData: jmapRequestObject?.toData(),
            headers: HTTPHeaders([jmapHeader]),
            interceptor: authenticationInterceptor,
            onSuccess: { (data: JmapResponseObject<Email>) in
                if let listEmail = data.parsing(methodName: JmapConstants.EMAIL_GET_METHOD_NAME, methodCallId: "c1"), !listEmail.isEmpty {
                    onSuccess(listEmail)
                } else {
                    onFailure(JmapExceptions.notFoundNewEmails)
                }
            },
            onFailure: onFailure
        )
    }
}
