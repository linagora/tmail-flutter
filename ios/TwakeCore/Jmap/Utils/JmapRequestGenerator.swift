import Foundation

class JmapRequestGenerator {
    static let shared: JmapRequestGenerator = JmapRequestGenerator()
    
    func createEmailChangesRequest(accountId: String, sinceState: String) -> JmapRequestObject? {
        return JmapRequestObject(
            using: [
                JmapConstants.JMAP_CORE_CAPABILITY,
                JmapConstants.JMAP_MAIL_CAPABILITY
            ],
            methodCalls: [
                [
                    RequestInvocation.string(JmapConstants.EMAIL_CHANGES_METHOD_NAME),
                    RequestInvocation.methodRequest(
                        MethodRequest(
                            accountId: accountId,
                            sinceState: sinceState,
                            ids: nil,
                            properties: nil
                        )
                    ),
                    RequestInvocation.string("c0"),
                ],
                [
                    RequestInvocation.string(JmapConstants.EMAIL_GET_METHOD_NAME),
                    RequestInvocation.methodRequest(
                        MethodRequest(
                            accountId: accountId,
                            sinceState: nil,
                            ids: ResultReference(
                                resultOf: "c0",
                                name: JmapConstants.EMAIL_CHANGES_METHOD_NAME,
                                path: JmapConstants.CREATED_REFERENCE_PATH
                            ),
                            properties: JmapConstants.EMAIL_PUSH_NOTIFICATION_PROPERTIES
                        )
                    ),
                    RequestInvocation.string("c1"),
                ]
            ]
        )
    }
}
