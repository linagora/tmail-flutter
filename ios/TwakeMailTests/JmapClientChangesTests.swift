import XCTest

final class JmapClientChangesTests: XCTestCase {

    func testReadsHasMoreChangesFromEmailChangesNotEmailGet() throws {
        let json = """
        {
          "sessionState": "session",
          "methodResponses": [
            ["Email/changes", {
              "accountId": "acc",
              "oldState": "s0",
              "newState": "s1",
              "hasMoreChanges": true,
              "created": ["old-deleted"]
            }, "c0"],
            ["Email/get", {
              "accountId": "acc",
              "state": "s1",
              "hasMoreChanges": false,
              "newState": "from-get",
              "list": [],
              "notFound": ["old-deleted"]
            }, "c1"]
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(JmapResponseObject<Email>.self, from: json)
        let page = try XCTUnwrap(response.emailChangesPage())

        XCTAssertTrue(page.hasMoreChanges)
        XCTAssertEqual(page.newState, "s1")
        XCTAssertTrue(page.emails.isEmpty)
    }

    func testEmptyFirstPageThenSecondPageReturnsEmails() {
        var walker = EmailChangesWalker(sinceState: "s0")
        XCTAssertTrue(walker.shouldFetch)
        walker.beginPage()
        XCTAssertTrue(walker.apply(EmailChangesPage(emails: [], hasMoreChanges: true, newState: "s1")))

        walker.beginPage()
        let email = Email(id: "e2", subject: "Hello", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        XCTAssertFalse(walker.apply(EmailChangesPage(emails: [email], hasMoreChanges: false, newState: "s2")))

        XCTAssertEqual(walker.emails.map(\.id), ["e2"])
        XCTAssertFalse(walker.hasMoreChanges)
        XCTAssertEqual(walker.latestState, "s2")
        XCTAssertFalse(walker.failed)
    }

    func testUnchangedNewStateDoesNotFetchAgain() {
        var walker = EmailChangesWalker(sinceState: "s0")
        walker.beginPage()
        XCTAssertFalse(walker.apply(EmailChangesPage(emails: [], hasMoreChanges: true, newState: "s0")))
        XCTAssertTrue(walker.failed)
        XCTAssertFalse(walker.shouldFetch)
    }

    func testPageCapLeavesHasMoreChangesSet() {
        var walker = EmailChangesWalker(sinceState: "s0")
        var pages = 0
        while walker.shouldFetch {
            walker.beginPage()
            pages += 1
            let fetchAnother = walker.apply(EmailChangesPage(
                emails: [],
                hasMoreChanges: true,
                newState: "s\(pages)"
            ))
            if !fetchAnother {
                break
            }
        }

        XCTAssertEqual(pages, EmailChangesWalker.maxPages)
        XCTAssertTrue(walker.hasMoreChanges)
        XCTAssertEqual(walker.latestState, "s5")
        XCTAssertFalse(walker.failed)
        XCTAssertFalse(walker.shouldFetch)
    }

    func testErrorKeepsBookmarkAndPartialSuccessWritesConsumedState() {
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: true,
                hasMoreChanges: false,
                payloadState: "payload",
                latestState: "s2"
            ),
            .keep
        )
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: false,
                hasMoreChanges: false,
                payloadState: "payload",
                latestState: "s2"
            ),
            .write("payload")
        )
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: false,
                hasMoreChanges: true,
                payloadState: "payload",
                latestState: "s5"
            ),
            .write("s5")
        )
    }
}
