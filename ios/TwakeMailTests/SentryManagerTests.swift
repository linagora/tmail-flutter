import XCTest
import Sentry

final class SentryManagerTests: XCTestCase {

    func testOptOutPreventsInitializationAndAllReportingOperations() throws {
        let provider = TestSentryConfigProvider(config: try makeConfig(isReportingAllowed: false))
        let sentryClient = TestSentrySDKClient()
        let manager = SentryManager(sentryClient: sentryClient)

        manager.configure(with: provider)

        XCTAssertEqual(sentryClient.startCalls, 0)

        provider.config = try makeConfig(isReportingAllowed: true)
        manager.configure(with: provider)
        XCTAssertEqual(sentryClient.startCalls, 1)

        provider.config = try makeConfig(isReportingAllowed: false)
        manager.capture(error: TestError.failure)
        manager.capture(message: "message")
        manager.addBreadcrumb(message: "breadcrumb")
        manager.setSentryUser(User())

        XCTAssertEqual(sentryClient.errorCaptureCalls, 0)
        XCTAssertEqual(sentryClient.messageCaptureCalls, 0)
        XCTAssertEqual(sentryClient.breadcrumbCalls, 0)
        XCTAssertEqual(sentryClient.nonNilUserCalls, 0)
    }

    func testReconfigureClearsPreviousUserAndBreadcrumbs() throws {
        let provider = TestSentryConfigProvider(config: try makeConfig(isReportingAllowed: true))
        let sentryClient = TestSentrySDKClient()
        let manager = SentryManager(sentryClient: sentryClient)

        manager.configure(with: provider)
        manager.setSentryUser(User())
        manager.addBreadcrumb(message: "breadcrumb")
        manager.configure(with: provider)

        XCTAssertEqual(sentryClient.startCalls, 1)
        XCTAssertEqual(sentryClient.nonNilUserCalls, 1)
        XCTAssertEqual(sentryClient.breadcrumbCalls, 1)
        XCTAssertEqual(sentryClient.clearBreadcrumbCalls, 1)
        XCTAssertEqual(sentryClient.nilUserCalls, 1)
    }

    func testBeforeSendAndBeforeBreadcrumbReadLatestConsent() throws {
        let provider = TestSentryConfigProvider(config: try makeConfig(isReportingAllowed: true))
        let sentryClient = TestSentrySDKClient()
        let manager = SentryManager(sentryClient: sentryClient)

        manager.configure(with: provider)

        XCTAssertEqual(sentryClient.beforeSend?(), true)
        XCTAssertEqual(sentryClient.beforeBreadcrumb?(), true)

        provider.config = try makeConfig(isReportingAllowed: false)

        XCTAssertEqual(sentryClient.beforeSend?(), false)
        XCTAssertEqual(sentryClient.beforeBreadcrumb?(), false)
    }

    func testConfigWithoutReportingConsentFailsClosed() throws {
        let provider = TestSentryConfigProvider(
            config: try makeConfig(isReportingAllowed: nil)
        )
        let sentryClient = TestSentrySDKClient()
        let manager = SentryManager(sentryClient: sentryClient)

        manager.configure(with: provider)

        XCTAssertNil(provider.config?.isReportingAllowed)
        XCTAssertEqual(sentryClient.startCalls, 0)
    }

    private func makeConfig(isReportingAllowed: Bool?) throws -> SentryConfig {
        var json: [String: Any] = [
            "dsn": "https://test@sentry.io/123",
            "environment": "test",
            "release": "1.0.0",
            "tracesSampleRate": 0.1,
            "profilesSampleRate": 0.1,
            "enableLogs": true,
            "isDebug": false,
            "attachScreenshot": false,
            "isAvailable": true,
            "enableFramesTracking": true
        ]
        if let isReportingAllowed {
            json["isReportingAllowed"] = isReportingAllowed
        }
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(SentryConfig.self, from: data)
    }
}

private enum TestError: Error {
    case failure
}

private final class TestSentryConfigProvider: SentryConfigProvider {
    var config: SentryConfig?

    init(config: SentryConfig?) {
        self.config = config
    }

    func retrieveSentryConfig() -> SentryConfig? {
        config
    }
}

private final class TestSentrySDKClient: SentrySDKClient {
    var startCalls = 0
    var errorCaptureCalls = 0
    var messageCaptureCalls = 0
    var breadcrumbCalls = 0
    var nonNilUserCalls = 0
    var nilUserCalls = 0
    var clearBreadcrumbCalls = 0
    var beforeSend: (() -> Bool)?
    var beforeBreadcrumb: (() -> Bool)?

    func start(
        config: SentryConfig,
        beforeSend: @escaping () -> Bool,
        beforeBreadcrumb: @escaping () -> Bool
    ) {
        startCalls += 1
        self.beforeSend = beforeSend
        self.beforeBreadcrumb = beforeBreadcrumb
    }

    func capture(error: Error) {
        errorCaptureCalls += 1
    }

    func capture(message: String) {
        messageCaptureCalls += 1
    }

    func flush(timeout: TimeInterval) {}

    func addBreadcrumb(message: String, category: String, level: SentryLevel) {
        breadcrumbCalls += 1
    }

    func setUser(_ user: User?) {
        if user == nil {
            nilUserCalls += 1
        } else {
            nonNilUserCalls += 1
        }
    }

    func clearBreadcrumbs() {
        clearBreadcrumbCalls += 1
    }
}
