import XCTest

final class MultiAccountEmailFetchBatchTests: XCTestCase {

    func testSequentialCollectorFinishesOnceAfterNAccountsAndKeepsOrder() {
        var completionCount = 0
        var collected: [Email] = []
        let expectation = expectation(description: "batch finishes once")

        let batch = MultiAccountEmailFetchBatch(accountCount: 3) { emails, _, _, _ in
            completionCount += 1
            collected = emails
            expectation.fulfill()
        }

        let first = Email(id: "e1", subject: "one", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        let second = Email(id: "e2", subject: "two", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        let third = Email(id: "e3", subject: "three", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)

        batch.accountFinished(emails: [first])
        batch.accountFinished(emails: [second])
        XCTAssertEqual(completionCount, 0)

        batch.accountFinished(emails: [third])

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(completionCount, 1)
        XCTAssertEqual(collected.map(\.id), ["e1", "e2", "e3"])
    }

    func testCompletionFlagsReflectMarkedStates() {
        let expectation = expectation(description: "flags delivered")
        var received: (Bool, Bool, Bool)?
        let batch = MultiAccountEmailFetchBatch(accountCount: 1) { _, resolvable, fetched, missing in
            received = (resolvable, fetched, missing)
            expectation.fulfill()
        }
        batch.markResolvable()
        batch.markFetchedEmails()
        batch.markMissingDelivery()
        batch.accountFinished(emails: [])

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(received?.0, true)
        XCTAssertEqual(received?.1, true)
        XCTAssertEqual(received?.2, true)
    }

    func testFinishEarlyDeliversEmailsCollectedSoFarAndIgnoresLaterAccounts() {
        let expectation = expectation(description: "early finish")
        var completionCount = 0
        var collected: [Email] = []
        let batch = MultiAccountEmailFetchBatch(accountCount: 3) { emails, _, _, _ in
            completionCount += 1
            collected = emails
            expectation.fulfill()
        }
        let first = Email(id: "e1", subject: "one", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        let late = Email(id: "late", subject: "late", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)

        batch.accountFinished(emails: [first])
        XCTAssertTrue(batch.finishEarly())
        XCTAssertFalse(batch.finishEarly())
        batch.accountFinished(emails: [late])

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(completionCount, 1)
        XCTAssertEqual(collected.map(\.id), ["e1"])
    }

    private func makeEmail(sender: String? = "Bob") -> Email {
        Email(
            id: "e1",
            subject: "hello",
            preview: nil,
            from: sender.map { [EmailAddress(name: $0, email: "bob@example.com")] },
            receivedAt: nil,
            mailboxIds: nil
        )
    }

    func testOwnEmailUserInfoHasOnlyTheEmailId() {
        let userInfo = makeEmail().notificationUserInfo

        XCTAssertEqual(userInfo as? [String: String], [JmapConstants.EMAIL_ID: "e1"])
    }

    func testDelegatedEmailUserInfoCarriesTheOwnerAccountId() {
        let email = makeEmail().ownedBy(NotificationOwner(accountId: "delegated-1", name: "Owner One"))

        XCTAssertEqual(
            email.notificationUserInfo as? [String: String],
            [JmapConstants.EMAIL_ID: "e1", JmapConstants.ACCOUNT_ID: "delegated-1"]
        )
    }

    func testOwnEmailTitleIsTheSender() {
        XCTAssertEqual(makeEmail().notificationTitle, "Bob")
    }

    func testDelegatedEmailTitleNamesTheOwnerAfterTheSender() {
        let email = makeEmail().ownedBy(NotificationOwner(accountId: "delegated-1", name: "Owner One"))

        XCTAssertEqual(email.notificationTitle, "Bob · Owner One")
    }

    func testDelegatedEmailTitleIsTheOwnerWithoutASender() {
        let email = makeEmail(sender: nil).ownedBy(NotificationOwner(accountId: "delegated-1", name: "Owner One"))

        XCTAssertEqual(email.notificationTitle, "Owner One")
    }

    func testDelegatedEmailWithoutOwnerNameKeepsTheSenderTitle() {
        let email = makeEmail().ownedBy(NotificationOwner(accountId: "delegated-1", name: nil))

        XCTAssertEqual(email.notificationTitle, "Bob")
        XCTAssertEqual(email.notificationUserInfo[JmapConstants.ACCOUNT_ID] as? String, "delegated-1")
    }

    func testDecodedEmailHasNoOwner() throws {
        let email = try JSONDecoder().decode(Email.self, from: Data(#"{"id":"e1"}"#.utf8))

        XCTAssertNil(email.owner)
    }

    func testNotificationOfTheDelegatedMailboxShowsItsAccount() {
        let email = makeEmail().ownedBy(NotificationOwner(accountId: "delegated-1", name: "Owner One"))

        XCTAssertTrue(CoreUtils.notificationShowsAccount(email.notificationUserInfo, accountId: "delegated-1"))
    }

    func testNotificationShouldNotShowAnotherAccount() {
        let delegated = makeEmail().ownedBy(NotificationOwner(accountId: "delegated-11", name: "Owner One"))

        XCTAssertFalse(CoreUtils.notificationShowsAccount(delegated.notificationUserInfo, accountId: "delegated-1"))
        XCTAssertFalse(CoreUtils.notificationShowsAccount(makeEmail().notificationUserInfo, accountId: "delegated-1"))
        XCTAssertFalse(CoreUtils.notificationShowsAccount(makeEmail().notificationUserInfo, accountId: ""))
    }
}
