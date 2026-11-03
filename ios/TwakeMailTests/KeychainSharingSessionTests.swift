import XCTest

final class KeychainSharingSessionTests: XCTestCase {

    private func makeSession(
        delegatedAccounts: [KeychainDelegatedAccount]? = [
            KeychainDelegatedAccount(
                accountId: "delegated-1",
                emailDeliveryState: "delivery-1",
                mailboxIdsBlockNotification: ["mb-1"]
            ),
            KeychainDelegatedAccount(
                accountId: "delegated-2",
                emailDeliveryState: "delivery-2",
                mailboxIdsBlockNotification: nil
            ),
        ]
    ) -> KeychainSharingSession {
        KeychainSharingSession(
            accountId: "personal-1",
            userName: "user@example.com",
            authenticationType: .oidc,
            apiUrl: "https://jmap.example/jmap",
            emailState: "email-state",
            emailDeliveryState: "personal-delivery",
            tokenOIDC: TokenOidc(
                token: "access",
                tokenId: "tid",
                expiredTime: "2099-01-01T00:00:00Z",
                refreshToken: "refresh"
            ),
            basicAuth: nil,
            tokenEndpoint: "https://auth.example/token",
            oidcScopes: ["openid"],
            mailboxIdsBlockNotification: ["personal-mb"],
            delegatedAccounts: delegatedAccounts,
            isTWP: false
        )
    }

    func testUpdateDelegatedAccountEmailDeliveryStateChangesOnlyMatchingItem() {
        let updated = makeSession().updateDelegatedAccountEmailDeliveryState(
            accountId: "delegated-1",
            newEmailDeliveryState: "delivery-1-new"
        )

        XCTAssertEqual(updated.accountId, "personal-1")
        XCTAssertEqual(updated.userName, "user@example.com")
        XCTAssertEqual(updated.apiUrl, "https://jmap.example/jmap")
        XCTAssertEqual(updated.emailState, "email-state")
        XCTAssertEqual(updated.emailDeliveryState, "personal-delivery")
        XCTAssertEqual(updated.tokenOIDC?.token, "access")
        XCTAssertEqual(updated.tokenEndpoint, "https://auth.example/token")
        XCTAssertEqual(updated.oidcScopes, ["openid"])
        XCTAssertEqual(updated.mailboxIdsBlockNotification, ["personal-mb"])
        XCTAssertEqual(updated.isTWP, false)
        XCTAssertEqual(updated.delegatedAccounts?.count, 2)
        XCTAssertEqual(updated.delegatedAccounts?[0].accountId, "delegated-1")
        XCTAssertEqual(updated.delegatedAccounts?[0].emailDeliveryState, "delivery-1-new")
        XCTAssertEqual(updated.delegatedAccounts?[0].mailboxIdsBlockNotification, ["mb-1"])
        XCTAssertEqual(updated.delegatedAccounts?[1].accountId, "delegated-2")
        XCTAssertEqual(updated.delegatedAccounts?[1].emailDeliveryState, "delivery-2")
    }

    func testUpdateTokenOidcKeepsDelegatedAccounts() {
        let delegated = makeSession().delegatedAccounts
        let updated = makeSession().updateTokenOidc(
            newTokenOidc: TokenOidc(
                token: "access-2",
                tokenId: "tid-2",
                expiredTime: "2099-02-01T00:00:00Z",
                refreshToken: "refresh-2"
            )
        )

        XCTAssertEqual(updated.tokenOIDC?.token, "access-2")
        XCTAssertEqual(updated.delegatedAccounts?.count, delegated?.count)
        XCTAssertEqual(updated.delegatedAccounts?[0].accountId, delegated?[0].accountId)
        XCTAssertEqual(updated.delegatedAccounts?[0].emailDeliveryState, delegated?[0].emailDeliveryState)
        XCTAssertEqual(updated.delegatedAccounts?[1].emailDeliveryState, delegated?[1].emailDeliveryState)
    }

    func testUpdateEmailDeliveryStateKeepsDelegatedAccounts() {
        let delegated = makeSession().delegatedAccounts
        let updated = makeSession().updateEmailDeliveryState(newEmailDeliveryState: "personal-delivery-2")

        XCTAssertEqual(updated.emailDeliveryState, "personal-delivery-2")
        XCTAssertEqual(updated.delegatedAccounts?.count, delegated?.count)
        XCTAssertEqual(updated.delegatedAccounts?[0].emailDeliveryState, "delivery-1")
        XCTAssertEqual(updated.delegatedAccounts?[1].emailDeliveryState, "delivery-2")
    }

    func testDecodeWithoutDelegatedAccounts() throws {
        let json = """
        {
          "accountId": "personal-1",
          "userName": "user@example.com",
          "authenticationType": "oidc",
          "apiUrl": "https://jmap.example/jmap"
        }
        """.data(using: .utf8)!

        let session = try JSONDecoder().decode(KeychainSharingSession.self, from: json)

        XCTAssertEqual(session.accountId, "personal-1")
        XCTAssertNil(session.delegatedAccounts)
    }
}
