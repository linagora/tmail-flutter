import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

/// Callback type for when a token is successfully refreshed
typedef TokenRefreshCallback = void Function(TokenOIDC newToken);

/// Manages automatic token refresh before expiration.
///
/// This class handles:
/// - Scheduling proactive token refresh before expiration
/// - Refreshing tokens when app resumes from background
/// - Retry logic for failed refresh attempts
class TokenRefreshManager {
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AccountCacheManager _accountCacheManager;
  final IOSSharingManager _iosSharingManager;

  /// Refresh token when 80% of its lifetime has passed
  static const double _refreshThresholdPercent = 0.8;

  /// Minimum buffer time before expiry to trigger refresh (60 seconds)
  static const Duration _minimumRefreshBuffer = Duration(seconds: 60);

  /// Retry delay when refresh fails
  static const Duration _retryDelay = Duration(seconds: 30);

  /// Maximum number of consecutive refresh failures before giving up
  static const int _maxRetryAttempts = 3;

  Timer? _refreshTimer;
  AppLifecycleListener? _appLifecycleListener;
  bool _isRefreshing = false;
  int _retryAttempts = 0;

  TokenOIDC? _currentToken;
  OIDCConfiguration? _oidcConfig;
  AuthenticationType _authenticationType = AuthenticationType.none;

  /// Callback invoked when token is successfully refreshed
  TokenRefreshCallback? onTokenRefreshed;

  TokenRefreshManager(
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._accountCacheManager,
    this._iosSharingManager,
  );

  /// Initialize the token refresh manager with current token and configuration.
  /// Starts the refresh timer and app lifecycle listener.
  void initialize({
    required TokenOIDC? token,
    required OIDCConfiguration? config,
    required AuthenticationType authenticationType,
    TokenRefreshCallback? onRefreshed,
  }) {
    _currentToken = token;
    _oidcConfig = config;
    _authenticationType = authenticationType;
    onTokenRefreshed = onRefreshed;

    log('TokenRefreshManager::initialize: token expiry = ${token?.expiredTime}');

    _scheduleRefresh();
    _startAppLifecycleListener();
  }

  /// Update the current token (e.g., after a reactive refresh in the interceptor)
  void updateToken(TokenOIDC newToken) {
    log('TokenRefreshManager::updateToken: new expiry = ${newToken.expiredTime}');
    _currentToken = newToken;
    _retryAttempts = 0;
    _scheduleRefresh();
  }

  /// Manually trigger a token refresh check (e.g., after network reconnection)
  Future<void> checkAndRefreshIfNeeded() async {
    if (!_canRefresh) return;

    final timeUntilExpiry = _timeUntilExpiry;
    if (timeUntilExpiry == null) return;

    if (timeUntilExpiry <= _minimumRefreshBuffer) {
      log('TokenRefreshManager::checkAndRefreshIfNeeded: Token expired or expiring soon');
      await _performRefresh();
    } else {
      _scheduleRefresh();
    }
  }

  /// Clean up resources
  void dispose() {
    _cancelRefreshTimer();
    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;
    _currentToken = null;
    _oidcConfig = null;
    _authenticationType = AuthenticationType.none;
    onTokenRefreshed = null;
    _isRefreshing = false;
    _retryAttempts = 0;
  }

  bool get _canRefresh =>
      _authenticationType == AuthenticationType.oidc &&
      _currentToken != null &&
      _currentToken!.refreshToken.isNotEmpty &&
      _oidcConfig != null;

  Duration? get _timeUntilExpiry {
    if (_currentToken?.expiredTime == null) return null;
    return _currentToken!.expiredTime!.difference(DateTime.now());
  }

  void _scheduleRefresh() {
    _cancelRefreshTimer();

    if (!_canRefresh) {
      log('TokenRefreshManager::_scheduleRefresh: Skipping - cannot refresh');
      return;
    }

    final timeUntilExpiry = _timeUntilExpiry;
    if (timeUntilExpiry == null || timeUntilExpiry.isNegative) {
      log('TokenRefreshManager::_scheduleRefresh: Token already expired');
      return;
    }

    final refreshDelay = _calculateRefreshDelay(timeUntilExpiry);

    if (refreshDelay.inSeconds <= 0) {
      log('TokenRefreshManager::_scheduleRefresh: Refreshing immediately');
      _performRefresh();
      return;
    }

    log('TokenRefreshManager::_scheduleRefresh: Scheduling in ${refreshDelay.inSeconds}s '
        '(expires in ${timeUntilExpiry.inSeconds}s)');

    _refreshTimer = Timer(refreshDelay, _performRefresh);
  }

  Duration _calculateRefreshDelay(Duration timeUntilExpiry) {
    // Calculate refresh at 80% of lifetime
    final refreshAt80Percent = Duration(
      milliseconds: (timeUntilExpiry.inMilliseconds * _refreshThresholdPercent).round()
    );

    // Calculate refresh with minimum buffer
    final refreshWithBuffer = timeUntilExpiry - _minimumRefreshBuffer;

    // Use whichever is sooner
    return refreshAt80Percent < refreshWithBuffer ? refreshAt80Percent : refreshWithBuffer;
  }

  Future<void> _performRefresh() async {
    if (_isRefreshing) {
      log('TokenRefreshManager::_performRefresh: Already refreshing');
      return;
    }

    if (!_canRefresh) {
      log('TokenRefreshManager::_performRefresh: Cannot refresh');
      return;
    }

    _isRefreshing = true;
    log('TokenRefreshManager::_performRefresh: Starting proactive refresh');

    try {
      final newToken = await _refreshToken();

      if (newToken.token == _currentToken?.token) {
        log('TokenRefreshManager::_performRefresh: Token unchanged');
        _isRefreshing = false;
        _scheduleRefresh();
        return;
      }

      log('TokenRefreshManager::_performRefresh: Got new token, expiry = ${newToken.expiredTime}');

      _currentToken = newToken;
      _retryAttempts = 0;

      await _persistToken(newToken);

      onTokenRefreshed?.call(newToken);

      _scheduleRefresh();
    } catch (e, stackTrace) {
      logError(
        'TokenRefreshManager::_performRefresh: Failed: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      _handleRefreshFailure();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<TokenOIDC> _refreshToken() async {
    if (PlatformInfo.isIOS) {
      return _refreshTokenForIOS();
    }
    return _refreshTokenFromServer();
  }

  Future<TokenOIDC> _refreshTokenForIOS() async {
    final tokenInKeychain = await _getTokenFromKeychain();

    if (tokenInKeychain != null && !tokenInKeychain.isExpired) {
      log('TokenRefreshManager::_refreshTokenForIOS: Using keychain token');
      return tokenInKeychain;
    }

    return _refreshTokenFromServer();
  }

  Future<TokenOIDC?> _getTokenFromKeychain() async {
    try {
      final currentAccount = await _accountCacheManager.getCurrentAccount();
      if (currentAccount.accountId == null) return null;

      final keychainSession = await _iosSharingManager.getKeychainSharingSession(
        currentAccount.accountId!
      );

      if (keychainSession?.tokenOIDC != null &&
          keychainSession!.tokenOIDC!.token != _currentToken?.token) {
        return keychainSession.tokenOIDC;
      }
    } catch (e) {
      logWarning('TokenRefreshManager::_getTokenFromKeychain: Error: $e');
    }
    return null;
  }

  Future<TokenOIDC> _refreshTokenFromServer() {
    log('TokenRefreshManager::_refreshTokenFromServer: Calling server');
    return _authenticationClient.refreshingTokensOIDC(
      _oidcConfig!.clientId,
      _oidcConfig!.redirectUrl,
      _oidcConfig!.discoveryUrl,
      _oidcConfig!.scopes,
      _currentToken!.refreshToken,
    );
  }

  Future<void> _persistToken(TokenOIDC token) async {
    try {
      final currentAccount = await _accountCacheManager.getCurrentAccount();

      await _accountCacheManager.deleteCurrentAccount(currentAccount.id);
      await _tokenOidcCacheManager.persistOneTokenOidc(token);

      final newAccount = PersonalAccount(
        token.tokenIdHash,
        AuthenticationType.oidc,
        isSelected: true,
        accountId: currentAccount.accountId,
        apiUrl: currentAccount.apiUrl,
        userName: currentAccount.userName,
      );

      await _accountCacheManager.setCurrentAccount(newAccount);

      if (PlatformInfo.isIOS) {
        await _iosSharingManager.saveKeyChainSharingSession(newAccount);
      }
    } catch (e) {
      logError('TokenRefreshManager::_persistToken: Failed to persist: $e');
    }
  }

  void _handleRefreshFailure() {
    _retryAttempts++;

    if (_retryAttempts >= _maxRetryAttempts) {
      logWarning('TokenRefreshManager::_handleRefreshFailure: Max retries reached');
      _retryAttempts = 0;
      return;
    }

    log('TokenRefreshManager::_handleRefreshFailure: Scheduling retry $_retryAttempts/$_maxRetryAttempts');
    _refreshTimer = Timer(_retryDelay, _performRefresh);
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _startAppLifecycleListener() {
    _appLifecycleListener ??= AppLifecycleListener(
      onStateChange: _handleAppLifecycleChange,
    );
  }

  void _handleAppLifecycleChange(AppLifecycleState state) {
    log('TokenRefreshManager::_handleAppLifecycleChange: state = $state');

    if (state == AppLifecycleState.resumed) {
      checkAndRefreshIfNeeded();
    }
  }
}
