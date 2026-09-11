import Foundation
import Sentry

class SentryManager {
    
    /// Singleton instance for easy access
    static let shared = SentryManager()
    
    /// Internal flag to prevent multiple initializations
    private var isInitialized: Bool = false

    /// Used to re-read consent because the NSE process can handle more than one notification.
    private var keychainController: KeychainController?

    private var isReportingAllowed: Bool {
        guard let config = keychainController?.retrieveSentryConfig() else { return false }
        return config.isAvailable &&
            config.isReportingAllowed == true &&
            !config.dsn.isEmpty
    }
    
    private init() {}
    
    /// Configures Sentry using the config stored in Keychain.
    func configure(with keychainController: KeychainController) {
        self.keychainController = keychainController

        if isInitialized {
            clearScope()
        }
        
        // Retrieve config and validate 'isAvailable' and DSN presence
        guard let config = keychainController.retrieveSentryConfig(),
              config.isAvailable,
              config.isReportingAllowed == true,
              !config.dsn.isEmpty else {
            TwakeLogger.shared.log(message: "Sentry is disabled or config is missing")
            return
        }

        // Prevent re-initialization after refreshing consent and clearing stale scope data.
        if isInitialized { return }
        
        // Start Sentry SDK with options mapped from the config
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
            options.beforeSend = { [weak self] event in
                self?.isReportingAllowed == true ? event : nil
            }
            options.beforeBreadcrumb = { [weak self] breadcrumb in
                self?.isReportingAllowed == true ? breadcrumb : nil
            }
        }
        
        isInitialized = true
        TwakeLogger.shared.log(message: "Sentry has been successfully initialized.")
    }
    
    /// Safely captures an error if Sentry is initialized.
    /// - Parameter flushTimeout: If provided, blocks until events are sent or the timeout elapses.
    ///   Use in critical paths (e.g. serviceExtensionTimeWillExpire) where the process may be
    ///   suspended before Sentry flushes its queue.
    func capture(error: Error, flushTimeout: TimeInterval? = nil) {
        guard isInitialized, isReportingAllowed else { return }
        SentrySDK.capture(error: error)
        if let flushTimeout {
            SentrySDK.flush(timeout: flushTimeout)
        }
    }

    /// Safely captures a message if Sentry is initialized.
    /// - Parameter flushTimeout: If provided, blocks until events are sent or the timeout elapses.
    ///   Use in critical paths (e.g. serviceExtensionTimeWillExpire) where the process may be
    ///   suspended before Sentry flushes its queue.
    func capture(message: String, flushTimeout: TimeInterval? = nil) {
        guard isInitialized, isReportingAllowed else { return }
        SentrySDK.capture(message: message)
        if let flushTimeout {
            SentrySDK.flush(timeout: flushTimeout)
        }
    }
    
    /// Adds a breadcrumb to the current Sentry scope.
    /// Breadcrumbs are accumulated in-memory and automatically attached to the next
    /// captured error event. Use this for diagnostic checkpoints that provide context
    /// for real errors — they are NOT sent as standalone events.
    func addBreadcrumb(message: String, category: String = "nse", level: SentryLevel = .info) {
        guard isInitialized, isReportingAllowed else { return }
        let crumb = Breadcrumb()
        crumb.message = message
        crumb.category = category
        crumb.level = level
        SentrySDK.addBreadcrumb(crumb)
    }

    /// Set user context for Sentry
    func setSentryUser(_ user: User) {
        guard isInitialized, isReportingAllowed else { return }
        SentrySDK.setUser(user)
    }
    
    /// Clear user
    func clearUser() {
        guard isInitialized else { return }
        SentrySDK.setUser(nil)
    }

    private func clearScope() {
        guard isInitialized else { return }
        SentrySDK.configureScope { scope in
            scope.clearBreadcrumbs()
        }
        SentrySDK.setUser(nil)
    }
}
