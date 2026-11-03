import Foundation

/// Collects per-account NSE fetches in call order and invokes [onComplete] once.
final class MultiAccountEmailFetchBatch {
    private var remaining: Int
    private var collectedEmails: [Email] = []
    private var sawResolvableAccount = false
    private var sawFetchedEmails = false
    private var hadMissingDelivery = false
    private let onComplete: ([Email], Bool, Bool, Bool) -> Void

    init(accountCount: Int, onComplete: @escaping ([Email], Bool, Bool, Bool) -> Void) {
        self.remaining = accountCount
        self.onComplete = onComplete
    }

    func markResolvable() {
        sawResolvableAccount = true
    }

    func markMissingDelivery() {
        hadMissingDelivery = true
    }

    func markFetchedEmails() {
        sawFetchedEmails = true
    }

    func accountFinished(emails: [Email]) {
        collectedEmails.append(contentsOf: emails)
        remaining -= 1
        guard remaining == 0 else { return }
        onComplete(collectedEmails, sawResolvableAccount, sawFetchedEmails, hadMissingDelivery)
    }
}
