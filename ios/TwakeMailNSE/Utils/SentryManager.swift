import Foundation
import Sentry

protocol SentryConfigProvider: AnyObject {
    func retrieveSentryConfig() -> SentryConfig?
}

struct SentryBreadcrumbData {
    let message: String
    let category: String
    let level: SentryLevel
}

protocol SentrySDKClient {
    func start(
        config: SentryConfig,
        beforeSend: @escaping () -> Bool,
        beforeBreadcrumb: @escaping () -> Bool
    )
    func capture(error: Error)
    func capture(message: String)
    func flush(timeout: TimeInterval)
    func addBreadcrumb(_ data: SentryBreadcrumbData)
    func setUser(_ user: User?)
    func clearBreadcrumbs()
}

final class DefaultSentrySDKClient: SentrySDKClient {
    func start(
        config: SentryConfig,
        beforeSend: @escaping () -> Bool,
        beforeBreadcrumb: @escaping () -> Bool
    ) {
        SentrySDK.start { options in
            options.dsn = config.dsn
            options.environment = config.environment
            options.releaseName = config.release
            options.dist = config.dist
            options.debug = config.isDebug
            // Map enableLogs to diagnostic level if needed
            options.diagnosticLevel = config.isDebug ? .debug : .none
            // Maps 'onErrorSampleRate' (Dart) to 'sampleRate' (iOS).
            // tracesSampleRate, profilesSampleRate, sessionSampleRate are intentionally not applied:
            // NSE has no UI and its lifecycle is too short for performance/session tracking.
            if let onErrorSampleRate = config.onErrorSampleRate {
                options.sampleRate = NSNumber(value: onErrorSampleRate)
            }
            options.enableAutoSessionTracking = false
            options.enableCrashHandler = false
            options.sendClientReports = false
            // Disable App Hang tracking: NSE execution is short, this causes false positives.
            options.enableAppHangTracking = false
            // Disable Watchdog tracking: Prevent OOM reports specific to extensions.
            options.enableWatchdogTerminationTracking = false
            // Disable UI/Interaction tracing: NSE has no UI.
            options.enableUserInteractionTracing = false
            options.enableAutoPerformanceTracing = false
            options.enablePreWarmedAppStartTracing = false
            options.beforeSend = { event in
                beforeSend() ? event : nil
            }
            options.beforeBreadcrumb = { breadcrumb in
                beforeBreadcrumb() ? breadcrumb : nil
            }
        }
    }

    func capture(error: Error) {
        SentrySDK.capture(error: error)
    }

    func capture(message: String) {
        SentrySDK.capture(message: message)
    }

    func flush(timeout: TimeInterval) {
        SentrySDK.flush(timeout: timeout)
    }

    func addBreadcrumb(_ data: SentryBreadcrumbData) {
        let crumb = Breadcrumb()
        crumb.message = data.message
        crumb.category = data.category
        crumb.level = data.level
        SentrySDK.addBreadcrumb(crumb)
    }

    func setUser(_ user: User?) {
        SentrySDK.setUser(user)
    }

    func clearBreadcrumbs() {
        SentrySDK.configureScope { scope in
            scope.clearBreadcrumbs()
        }
    }
}

class SentryManager {

    /// Singleton instance for easy access
    static let shared = SentryManager(sentryClient: DefaultSentrySDKClient())

    /// Internal flag to prevent multiple initializations
    private var isInitialized: Bool = false

    /// Routing used by the active SDK instance. A later Keychain update must not
    /// authorize events that would still be sent through this stale routing.
    private var activeDsn: String?
    private var activeEnvironment: String?

    /// Used to re-read consent because the NSE process can handle more than one notification.
    private var configProvider: SentryConfigProvider?

    private let sentryClient: SentrySDKClient

    private var isReportingAllowed: Bool {
        guard let config = configProvider?.retrieveSentryConfig(),
              config.isAvailable,
              config.isReportingAllowed == true,
              !config.dsn.isEmpty else { return false }
        return matchesActiveRouting(config)
    }

    init(sentryClient: SentrySDKClient) {
        self.sentryClient = sentryClient
    }

    /// Configures Sentry using the config stored in Keychain.
    func configure(with configProvider: SentryConfigProvider) {
        self.configProvider = configProvider

        if isInitialized {
            clearScope()
        }

        // Retrieve config and validate 'isAvailable' and DSN presence
        guard let config = configProvider.retrieveSentryConfig(),
              config.isAvailable,
              config.isReportingAllowed == true,
              !config.dsn.isEmpty else {
            TwakeLogger.shared.log(message: "Sentry is disabled or config is missing")
            return
        }

        // Prevent re-initialization after refreshing consent and clearing stale scope data.
        if isInitialized { return }

        // Start Sentry SDK with options mapped from the config
        activeDsn = config.dsn
        activeEnvironment = config.environment
        sentryClient.start(
            config: config,
            beforeSend: { [weak self] in self?.isReportingAllowed == true },
            beforeBreadcrumb: { [weak self] in self?.isReportingAllowed == true }
        )
        
        isInitialized = true
        TwakeLogger.shared.log(message: "Sentry has been successfully initialized.")
    }
    
    /// Safely captures an error if Sentry is initialized.
    /// - Parameter flushTimeout: If provided, blocks until events are sent or the timeout elapses.
    ///   Use in critical paths (e.g. serviceExtensionTimeWillExpire) where the process may be
    ///   suspended before Sentry flushes its queue.
    func capture(error: Error, flushTimeout: TimeInterval? = nil) {
        guard isInitialized, isReportingAllowed else { return }
        sentryClient.capture(error: error)
        if let flushTimeout {
            sentryClient.flush(timeout: flushTimeout)
        }
    }

    /// Safely captures a message if Sentry is initialized.
    /// - Parameter flushTimeout: If provided, blocks until events are sent or the timeout elapses.
    ///   Use in critical paths (e.g. serviceExtensionTimeWillExpire) where the process may be
    ///   suspended before Sentry flushes its queue.
    func capture(message: String, flushTimeout: TimeInterval? = nil) {
        guard isInitialized, isReportingAllowed else { return }
        sentryClient.capture(message: message)
        if let flushTimeout {
            sentryClient.flush(timeout: flushTimeout)
        }
    }
    
    /// Adds a breadcrumb to the current Sentry scope.
    /// Breadcrumbs are accumulated in-memory and automatically attached to the next
    /// captured error event. Use this for diagnostic checkpoints that provide context
    /// for real errors — they are NOT sent as standalone events.
    func addBreadcrumb(message: String, category: String = "nse", level: SentryLevel = .info) {
        guard isInitialized, isReportingAllowed else { return }
        sentryClient.addBreadcrumb(SentryBreadcrumbData(
            message: message,
            category: category,
            level: level
        ))
    }

    /// Set user context for Sentry
    func setSentryUser(_ user: User) {
        guard isInitialized, isReportingAllowed else { return }
        sentryClient.setUser(user)
    }
    
    /// Clear user
    func clearUser() {
        guard isInitialized else { return }
        sentryClient.setUser(nil)
    }

    private func clearScope() {
        guard isInitialized else { return }
        sentryClient.clearBreadcrumbs()
        sentryClient.setUser(nil)
    }

    private func matchesActiveRouting(_ config: SentryConfig) -> Bool {
        config.dsn == activeDsn &&
            config.environment == activeEnvironment
    }
}
