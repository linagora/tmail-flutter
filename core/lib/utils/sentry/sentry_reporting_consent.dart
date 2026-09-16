/// Whether Sentry is allowed to transmit. The runtime starts or closes the SDK
/// when this effective permission changes.
abstract interface class SentryReportingConsent {
  /// Whether the SDK started successfully.
  bool get isSentryAvailable;

  /// The user's choice, or the instance default while they have not chosen.
  bool get isSentryReportingAllowed;

  /// Instance-wide default, served by the Linagora ecosystem config.
  void setSentryReportingDefault(bool allowed);

  /// The user's explicit choice; `null` while they have not made one.
  void setSentryReportingConsent(bool? consent);
}
