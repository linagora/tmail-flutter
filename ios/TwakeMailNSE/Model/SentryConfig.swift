import Foundation

struct SentryConfig: Codable {
    /// DSN (Data Source Name) endpoint for the Sentry project
    let dsn: String
    
    /// Running environment (production/staging/dev)
    let environment: String
    
    /// Current app release version
    let release: String
    
    /// Performance monitoring: Set to 1.0 to capture 100% of transactions for tracing.
    /// High values in NSE might impact extension memory limit (24MB).
    let tracesSampleRate: Double
    
    /// Optional profiling sample rate.
    let profilesSampleRate: Double
    
    /// Release Health: The sampling rate for sessions (0.0 to 1.0).
    let sessionSampleRate: Double
    
    /// Error tracking: The sampling rate for errors (0.0 to 1.0).
    /// If set to 0.1, only 10% of errors are sent.
    let onErrorSampleRate: Double
    
    /// Enable logs to be sent to Sentry (or internal console logging).
    let enableLogs: Bool
    
    /// Debug logs during development.
    let isDebug: Bool
    
    /// Automatically attaches a screenshot when capturing an error.
    /// Ignored in NSE as there is no UI to screenshot.
    let attachScreenshot: Bool
    
    /// Master switch to check if Sentry integration is allowed/available.
    let isAvailable: Bool
    
    /// Performance: Tracks UI rendering performance.
    /// Ignored in NSE as there is no UI rendering.
    let enableFramesTracking: Bool
}
