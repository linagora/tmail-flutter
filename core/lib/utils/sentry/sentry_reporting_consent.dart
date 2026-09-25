/// Whether Sentry is allowed to transmit. The runtime starts or closes the SDK
/// when this effective permission changes.
abstract interface class SentryReportingConsent {
  /// Whether a valid runtime configuration is available for the resolved
  /// ecosystem. This remains true while an opted-out user has the SDK stopped.
  bool get isSentryConfigured;

  /// Whether the SDK started successfully.
  bool get isSentryAvailable;

  /// The user's choice, or the effective default while they have not chosen.
  /// Temporary runtime suspension does not change this preference value.
  bool get isSentryReportingAllowed;

  /// Overrides the runtime configuration default for this instance.
  void setSentryReportingDefault(bool allowed);

  /// The user's explicit choice; `null` while they have not made one.
  void setSentryReportingConsent(bool? consent);
}
