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
}
