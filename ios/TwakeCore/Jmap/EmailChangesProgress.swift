import Foundation

struct EmailChangesPage {
    let emails: [Email]
    let hasMoreChanges: Bool
    let newState: String?
}

struct EmailChangesWalker {
    static let maxPages = 5

    private(set) var emails: [Email] = []
    private(set) var sinceState: String
    private(set) var hasMoreChanges = true
    private(set) var pagesFetched = 0
    private(set) var latestState: String?
    private(set) var failed = false

    init(sinceState: String) {
        self.sinceState = sinceState
    }

    var shouldFetch: Bool {
        !failed && hasMoreChanges && pagesFetched < Self.maxPages && !sinceState.isEmpty
    }

    mutating func beginPage() {
        pagesFetched += 1
    }

    mutating func fail() {
        failed = true
        hasMoreChanges = false
    }

    mutating func apply(_ page: EmailChangesPage) -> Bool {
        emails.append(contentsOf: page.emails)
        guard let newState = page.newState, !newState.isEmpty, newState != sinceState else {
            if page.hasMoreChanges {
                failed = true
            }
            hasMoreChanges = false
            return false
        }
        latestState = newState
        sinceState = newState
        hasMoreChanges = page.hasMoreChanges
        return shouldFetch
    }
}

struct NewEmailFetchResult {
    let emails: [Email]
    let errors: [Error]
    let latestState: String?
    let hasMoreChanges: Bool
    let failed: Bool

    /// A failed fetch keeps the bookmark, so its partial emails would repeat on the next push.
    var presentableEmails: [Email] { failed ? [] : emails }
}

enum DeliveryBookmarkUpdate: Equatable {
    case keep
    case write(String)

    static func resolve(
        failed: Bool,
        hasMoreChanges: Bool,
        payloadState: String,
        latestState: String?
    ) -> DeliveryBookmarkUpdate {
        guard !failed else { return .keep }
        if hasMoreChanges {
            guard let latestState, !latestState.isEmpty else { return .keep }
            return .write(latestState)
        }
        guard !payloadState.isEmpty else { return .keep }
        return .write(payloadState)
    }
}

extension JmapResponseObject where T == Email {
    func emailChangesPage() -> EmailChangesPage? {
        // A missing Email/get list must also fail the page, or the bookmark skips the created emails.
        guard let emailGet = parsing(
            methodName: JmapConstants.EMAIL_GET_METHOD_NAME,
            methodCallId: "c1"
        ),
        let emailList = emailGet.list else {
            return nil
        }
        // An incomplete Email/changes must fail the page so the bookmark is kept.
        guard let changes = parsing(
            methodName: JmapConstants.EMAIL_CHANGES_METHOD_NAME,
            methodCallId: "c0"
        ),
        let hasMoreChanges = changes.hasMoreChanges,
        let newState = changes.newState,
        !newState.isEmpty else {
            return nil
        }
        // Every created id must come back in the list or notFound, or the bookmark would skip it.
        guard Self.accountsForCreated(changes.created, emails: emailList, notFound: emailGet.notFound) else {
            return nil
        }
        return EmailChangesPage(
            emails: emailList,
            hasMoreChanges: hasMoreChanges,
            newState: newState
        )
    }

    private static func accountsForCreated(_ created: [String]?, emails: [Email], notFound: [String]?) -> Bool {
        let returned = Set(emails.map(\.id)).union(notFound ?? [])
        return Set(created ?? []).isSubset(of: returned)
    }
}
