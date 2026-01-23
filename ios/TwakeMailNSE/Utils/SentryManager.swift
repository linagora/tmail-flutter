import Foundation
import Sentry

class SentryManager {
    
    /// Singleton instance for easy access
    static let shared = SentryManager()
    
    /// Internal flag to prevent multiple initializations
    private var isInitialized: Bool = false
    
    private init() {}
    
    /// Configures Sentry using the config stored in Keychain.
    func configure(with keychainController: KeychainController) {
        // Prevent re-initialization
        if isInitialized { return }
        
        // Retrieve config and validate 'isAvailable' and DSN presence
        guard let config = keychainController.retrieveSentryConfig(),
              config.isAvailable,
              !config.dsn.isEmpty else {
            TwakeLogger.shared.log(message: "Sentry is disabled or config is missing")
            return
        }
        
        // Start Sentry SDK with options mapped from the config
        SentrySDK.start { options in
            options.dsn = config.dsn
            options.environment = config.environment
            options.releaseName = config.release
            options.debug = config.isDebug
            // Map enableLogs to diagnostic level if needed
            options.diagnosticLevel = config.isDebug ? .debug : .none
            // Maps 'onErrorSampleRate' (Dart) to 'sampleRate' (iOS)
            options.sampleRate = NSNumber(value: config.onErrorSampleRate)
            // Disable App Hang tracking: NSE execution is short, this causes false positives.
            options.enableAppHangTracking = false
            // Disable Watchdog tracking: Prevent OOM reports specific to extensions.
            options.enableWatchdogTerminationTracking = false
            // Disable UI/Interaction tracing: NSE has no UI.
            options.enableUserInteractionTracing = false
            options.enableAutoPerformanceTracing = false
            options.enablePreWarmedAppStartTracing = false
        }
        
        isInitialized = true
        TwakeLogger.shared.log(message: "Sentry has been successfully initialized.")
    }
    
    /// Safely captures an error if Sentry is initialized.
    func capture(error: Error) {
        guard isInitialized else { return }
        SentrySDK.capture(error: error)
    }
    
    /// Safely captures a message if Sentry is initialized.
    func capture(message: String) {
        guard isInitialized else { return }
        SentrySDK.capture(message: message)
    }
    
    /// Set user context cho Sentry
    func setSentryUser(_ user: User) {
        guard isInitialized else { return }
        SentrySDK.setUser(user)
    }
    
    /// Clear user
    func clearUser() {
        guard isInitialized else { return }
        SentrySDK.setUser(nil)
    }
}
