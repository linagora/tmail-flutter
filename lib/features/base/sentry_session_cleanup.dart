abstract interface class SentrySessionCleanup {
  /// Idempotently clears Sentry data that belongs to the ending session.
  Future<void> clearForSessionEnd();
}
