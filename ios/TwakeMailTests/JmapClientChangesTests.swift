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
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: false,
                hasMoreChanges: true,
                payloadState: "payload",
                latestState: nil
            ),
            .keep
        )
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: false,
                hasMoreChanges: true,
                payloadState: "payload",
                latestState: ""
            ),
            .keep
        )
    }

    func testEmptyPayloadStateKeepsBookmark() {
        XCTAssertEqual(
            DeliveryBookmarkUpdate.resolve(
                failed: false,
                hasMoreChanges: false,
                payloadState: "",
                latestState: "s2"
            ),
            .keep
        )
    }

    func testMissingEmailChangesReturnsNilPage() throws {
        XCTAssertNil(try makeResponse(changes: nil).emailChangesPage())
    }

    func testEmailChangesWithoutStateFieldsReturnsNilPage() throws {
        let changes = Self.changesArgs(newState: nil, hasMoreChanges: nil)
        XCTAssertNil(try makeResponse(changes: changes).emailChangesPage())
    }

    func testEmailChangesWithoutHasMoreChangesReturnsNilPage() throws {
        let changes = Self.changesArgs(hasMoreChanges: nil)
        XCTAssertNil(try makeResponse(changes: changes).emailChangesPage())
    }

    func testEmailChangesWithoutNewStateReturnsNilPage() throws {
        let changes = Self.changesArgs(newState: nil)
        XCTAssertNil(try makeResponse(changes: changes).emailChangesPage())
    }

    func testCreatedIdMissingFromListAndNotFoundReturnsNilPage() throws {
        let changes = Self.changesArgs(created: ["e1", "e2"])
        let emailGet = Self.emailGetArgs(list: [["id": "e1"]])
        XCTAssertNil(try makeResponse(changes: changes, emailGet: emailGet).emailChangesPage())
    }

    func testCreatedIdInNotFoundKeepsPage() throws {
        let changes = Self.changesArgs(created: ["e1", "e2"])
        let emailGet = Self.emailGetArgs(list: [["id": "e1"]], notFound: ["e2"])
        let page = try XCTUnwrap(try makeResponse(changes: changes, emailGet: emailGet).emailChangesPage())
        XCTAssertEqual(page.emails.map(\.id), ["e1"])
    }

    func testFailedResultHasNoPresentableEmails() {
        let email = Email(id: "e1", subject: "Hi", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        let failed = NewEmailFetchResult(emails: [email], errors: [], latestState: "s1", hasMoreChanges: false, failed: true)
        let succeeded = NewEmailFetchResult(emails: [email], errors: [], latestState: "s1", hasMoreChanges: false, failed: false)
        XCTAssertTrue(failed.presentableEmails.isEmpty)
        XCTAssertEqual(succeeded.presentableEmails.map(\.id), ["e1"])
    }

    func testEmptyNewStateReturnsNilPage() throws {
        let changes = Self.changesArgs(newState: "")
        XCTAssertNil(try makeResponse(changes: changes).emailChangesPage())
    }

    func testMissingEmailGetReturnsNilPage() throws {
        XCTAssertNil(try makeResponse(emailGet: nil).emailChangesPage())
    }

    func testEmailGetWithoutListReturnsNilPage() throws {
        let emailGet = Self.emailGetArgs(list: nil)
        XCTAssertNil(try makeResponse(emailGet: emailGet).emailChangesPage())
    }

    func testParsesNonEmptyEmailGetList() throws {
        let emailGet = Self.emailGetArgs(list: [["id": "e1", "subject": "Hi"]])
        let page = try XCTUnwrap(try makeResponse(emailGet: emailGet).emailChangesPage())
        XCTAssertEqual(page.emails.map(\.id), ["e1"])
        XCTAssertEqual(page.newState, "s1")
        XCTAssertFalse(page.hasMoreChanges)
    }

    func testEmptySinceStateDoesNotFetch() {
        let walker = EmailChangesWalker(sinceState: "")
        XCTAssertFalse(walker.shouldFetch)
        XCTAssertEqual(walker.pagesFetched, 0)
        XCTAssertNil(walker.latestState)
    }

    func testFailStopsFetchingAndKeepsPartialEmails() {
        var walker = EmailChangesWalker(sinceState: "s0")
        walker.beginPage()
        let email = Email(id: "e1", subject: "Hi", preview: nil, from: nil, receivedAt: nil, mailboxIds: nil)
        XCTAssertTrue(walker.apply(EmailChangesPage(emails: [email], hasMoreChanges: true, newState: "s1")))
        XCTAssertTrue(walker.shouldFetch)
        walker.fail()
        XCTAssertTrue(walker.failed)
        XCTAssertFalse(walker.shouldFetch)
        XCTAssertFalse(walker.hasMoreChanges)
        XCTAssertEqual(walker.emails.map(\.id), ["e1"])
        XCTAssertEqual(walker.latestState, "s1")
    }

    /// Builds an Email/changes (c0) + Email/get (c1) response; a nil argument omits that invocation.
    private func makeResponse(
        changes: [String: Any]? = JmapClientChangesTests.changesArgs(),
        emailGet: [String: Any]? = JmapClientChangesTests.emailGetArgs()
    ) throws -> JmapResponseObject<Email> {
        var invocations: [[Any]] = []
        if let changes { invocations.append(["Email/changes", changes, "c0"]) }
        if let emailGet { invocations.append(["Email/get", emailGet, "c1"]) }
        let json: [String: Any] = ["sessionState": "session", "methodResponses": invocations]
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(JmapResponseObject<Email>.self, from: data)
    }

    /// Email/changes arguments; a nil value omits that key.
    private static func changesArgs(
        newState: String? = "s1",
        hasMoreChanges: Bool? = false,
        created: [String] = []
    ) -> [String: Any] {
        var args: [String: Any] = ["accountId": "acc", "oldState": "s0", "created": created]
        args["newState"] = newState
        args["hasMoreChanges"] = hasMoreChanges
        return args
    }

    /// Email/get arguments; a nil list omits the key.
    private static func emailGetArgs(list: [[String: Any]]? = [], notFound: [String] = []) -> [String: Any] {
        var args: [String: Any] = ["accountId": "acc", "state": "s1", "notFound": notFound]
        args["list"] = list
        return args
    }
}
