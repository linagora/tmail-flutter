import Foundation
import Alamofire

class JmapClient {
    static let shared: JmapClient = JmapClient()

    private let jmapHeader = HTTPHeader(name: "Accept", value: "application/json;jmapVersion=rfc-8621")

    private var authentication: Authentication?
    private var tokenRefreshManager: TokenRefreshManager?
    private var authenticationInterceptor: AuthenticationInterceptor?
    
    private var hasMoreChanges: Bool = true
    private var currentSinceState: String?
    private var totalListEmails = [Email]()
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
        onComplete: @escaping ([Email], [Error]) -> Void
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
        
        hasMoreChanges = true
        currentSinceState = sinceState
        totalListEmails = [Email]()
        listErrors = [Error]()
        
        self.handleGetEmailChanges(
            apiUrl: apiUrl,
            accountId: accountId,
            onComplete: onComplete
        )
    }
    
    private func handleGetEmailChanges(apiUrl: String, 
                                       accountId: String,
                                       onComplete: @escaping ([Email], [Error]) -> Void) {
        guard hasMoreChanges, let sinceState = currentSinceState else {
            if !self.totalListEmails.isEmpty {
                let sortedListEmails = self.sortListEmails(currentListEmails: self.totalListEmails)
                self.totalListEmails = sortedListEmails
            }
            
            return onComplete(self.totalListEmails, self.listErrors)
        }
        
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
                if let response = data.parsing(methodName: JmapConstants.EMAIL_GET_METHOD_NAME, methodCallId: "c1") {
                    if let listEmail = response.list, 
                       !listEmail.isEmpty {
                        self.totalListEmails.append(contentsOf: listEmail)
                    }
                    self.hasMoreChanges = response.hasMoreChanges ?? false
                    self.currentSinceState = response.newState
                    
                    self.handleGetEmailChanges(apiUrl: apiUrl, accountId: accountId, onComplete: onComplete)
                } else {
                    self.listErrors.append(JmapExceptions.notFoundNewEmails)
                    self.hasMoreChanges = false
                    self.currentSinceState = nil
                    
                    if !self.totalListEmails.isEmpty {
                        let sortedListEmails = self.sortListEmails(currentListEmails: self.totalListEmails)
                        self.totalListEmails = sortedListEmails
                    }
                    
                    onComplete(self.totalListEmails, self.listErrors)
                }
            },
            onFailure: { error in
                self.listErrors.append(error)
                self.hasMoreChanges = false
                self.currentSinceState = nil
                
                if !self.totalListEmails.isEmpty {
                    let sortedListEmails = self.sortListEmails(currentListEmails: self.totalListEmails)
                    self.totalListEmails = sortedListEmails
                }
                
                onComplete(self.totalListEmails, self.listErrors)
            }
        )
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
