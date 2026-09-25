/// Resolves whether Sentry reporting should run from configuration, ecosystem,
/// user consent, and temporary suspension state.
///
/// Reporting defaults to allowed until the runtime configuration is loaded so
/// platforms without an ecosystem override preserve their existing behavior.
class SentryReportingPolicy {
  bool _isAllowedByConfiguration;
  bool? _defaultOverride;
  bool? _userConsent;
  bool _isSuspended = false;

  SentryReportingPolicy({
    bool isAllowedByConfiguration = true,
  }) : _isAllowedByConfiguration = isAllowedByConfiguration;

  bool get isAllowed =>
      _userConsent ?? _defaultOverride ?? _isAllowedByConfiguration;

  bool get isSuspended => _isSuspended;

  bool get shouldRun => !_isSuspended && isAllowed;

  void setConfigurationDefault(bool isAllowed) {
    _isAllowedByConfiguration = isAllowed;
  }

  void setDefaultOverride(bool isAllowed) {
    _defaultOverride = isAllowed;
  }

  void clearDefaultOverride() {
    _defaultOverride = null;
  }

  void setUserConsent(bool? consent) {
    _userConsent = consent;
  }

  bool suspend() {
    if (_isSuspended) return false;
    _isSuspended = true;
    return true;
  }

  bool resume() {
    if (!_isSuspended) return false;
    _isSuspended = false;
    return true;
  }
}
