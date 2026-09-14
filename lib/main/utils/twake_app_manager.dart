
import 'package:model/oidc/response/oidc_user_info.dart';

class TwakeAppManager {
  bool _hasComposer = false;
  bool _isExecutingBeforeReconnect = false;
  OidcUserInfo? _oidcUserInfo;
  Future<void>? _clearingDataFuture;
  Future<void>? _forcedLogoutFuture;

  /// Serialises cache teardown so only one run is ever in flight.
  Future<void> runClearDataOnce(Future<void> Function() clearData) {
    return _clearingDataFuture ??= clearData().whenComplete(() {
      _clearingDataFuture = null;
    });
  }

  /// Serialises the forced-logout funnel so a fatal refresh reported by two
  /// independent callers (JMAP + Workplace/Drive) logs and navigates once.
  Future<void> runForcedLogoutOnce(Future<void> Function() forceLogout) {
    return _forcedLogoutFuture ??= forceLogout().whenComplete(() {
      _forcedLogoutFuture = null;
    });
  }

  void setHasComposer(bool value) => _hasComposer = value;

  bool get hasComposer => _hasComposer;

  void setExecutingBeforeReconnect(bool value) => _isExecutingBeforeReconnect = value;

  bool get isExecutingBeforeReconnect => _isExecutingBeforeReconnect;

  void setOidcUserInfo(OidcUserInfo value) => _oidcUserInfo = value;

  void clearOidcUserInfo() => _oidcUserInfo = null;

  OidcUserInfo? get oidcUserInfo => _oidcUserInfo;
}
