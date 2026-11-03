import Foundation
import Alamofire

class JmapClient {
    static let shared: JmapClient = JmapClient()

    private let jmapHeader = HTTPHeader(name: "Accept", value: "application/json;jmapVersion=rfc-8621")

    private var authentication: Authentication?
    private var tokenRefreshManager: TokenRefreshManager?
    private var authenticationInterceptor: AuthenticationInterceptor?
    
    private var walker = EmailChangesWalker(sinceState: "")
    private var listErrors = [Error]()

    func getNewEmails(
        apiUrl: String,
        accountId: String,
        sinceState: String,
        authenticationType: AuthenticationType,
        tokenOidc: TokenOidc?,
        basicAuth: String?,
        tokenEndpointUrl: String?,
        oidcScopes: [String]?,
        isTWP: Bool?,
        onComplete: @escaping (NewEmailFetchResult) -> Void
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
                scopes: oidcScopes,
                isTWP: isTWP
            )
        }

        authenticationInterceptor = AuthenticationInterceptor(
            authentication: authentication,
            accountId: accountId,
            tokenRefreshManager: tokenRefreshManager
        )
        
        walker = EmailChangesWalker(sinceState: sinceState)
        listErrors = [Error]()
        
        self.handleGetEmailChanges(
            apiUrl: apiUrl,
            accountId: accountId,
            onComplete: onComplete
        )
    }
    
    private func handleGetEmailChanges(apiUrl: String,
                                       accountId: String,
                                       onComplete: @escaping (NewEmailFetchResult) -> Void) {
        guard walker.shouldFetch else {
            return finish(onComplete)
        }

        let sinceState = walker.sinceState
        walker.beginPage()

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
                guard let page = data.emailChangesPage() else {
                    self.listErrors.append(JmapExceptions.notFoundNewEmails)
                    self.walker.fail()
                    return self.finish(onComplete)
                }
                let fetchAnotherPage = self.walker.apply(page)
                if fetchAnotherPage {
                    self.handleGetEmailChanges(apiUrl: apiUrl, accountId: accountId, onComplete: onComplete)
                } else {
                    self.finish(onComplete)
                }
            },
            onFailure: { error in
                self.listErrors.append(error)
                self.walker.fail()
                self.finish(onComplete)
            }
        )
    }

    private func finish(_ onComplete: @escaping (NewEmailFetchResult) -> Void) {
        var emails = walker.emails
        if !emails.isEmpty {
            emails = sortListEmails(currentListEmails: emails)
        }
        onComplete(NewEmailFetchResult(
            emails: emails,
            errors: listErrors,
            latestState: walker.latestState,
            hasMoreChanges: walker.hasMoreChanges,
            failed: walker.failed
        ))
    }
    
    private func sortListEmails(currentListEmails: [Email]) -> [Email] {
        let sortedListEmails = currentListEmails.sorted(by: { (email1, email2) -> Bool in
            if let date1 = email1.receivedAt?.convertUTCDateToLocalDate(),
               let date2 = email2.receivedAt?.convertUTCDateToLocalDate() {
                return date1 < date2
            }
            return false
        })
        return sortedListEmails
    }
}
