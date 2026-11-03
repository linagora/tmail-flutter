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
        return .write(payloadState)
    }
}

extension JmapResponseObject where T == Email {
    func emailChangesPage() -> EmailChangesPage? {
        guard let emailGet = parsing(
            methodName: JmapConstants.EMAIL_GET_METHOD_NAME,
            methodCallId: "c1"
        ) else {
            return nil
        }
        let changes = parsing(
            methodName: JmapConstants.EMAIL_CHANGES_METHOD_NAME,
            methodCallId: "c0"
        )
        return EmailChangesPage(
            emails: emailGet.list ?? [],
            hasMoreChanges: changes?.hasMoreChanges ?? false,
            newState: changes?.newState
        )
    }
}
