import Foundation
import Alamofire

class JmapClient {
    static let shared: JmapClient = JmapClient()
    
    private let jmapHeader = HTTPHeader(name: "Accept", value: "application/json;jmapVersion=rfc-8621")
    
    private func getBasicAuthorization(basicAuth: String) -> String {
        return "Basic \(basicAuth)"
    }
    
    func getNewEmails(
        apiUrl: String,
        accountId: String,
        sinceState: String,
        authenticationType: AuthenticationType,
        tokenOidc: TokenOidc?,
        basicAuth: String?,
        onSuccess: @escaping ([Email]) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        let authenticationValue = authenticationType == AuthenticationType.basic
        ? getBasicAuthorization(basicAuth: basicAuth ?? "")
        : tokenOidc?.getAuthorization() ?? ""
        
        let headers = HTTPHeaders([
            jmapHeader,
            HTTPHeader(name: "Authorization", value: authenticationValue)
        ])
        
        let jmapRequestObject = JmapRequestGenerator.shared.createEmailChangesRequest(
            accountId: accountId,
            sinceState: sinceState
        )
        
        AlamofireService.shared.post(
            url: apiUrl,
            payloadData: jmapRequestObject?.toData(),
            headers: headers,
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
