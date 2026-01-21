import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class AuthorizationInterceptors extends QueuedInterceptorsWrapper {

  final Dio _dio;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AccountCacheManager _accountCacheManager;
  final IOSSharingManager _iosSharingManager;

  AuthenticationType _authenticationType = AuthenticationType.none;
  OIDCConfiguration? _configOIDC;
  TokenOIDC? _token;
  String? _authorization;
  Timer? _tokenRefreshTimer;
  bool _isRefreshing = false;

  /// Refresh token when 80% of its lifetime has passed, or 60 seconds before expiry
  static const double _refreshThresholdPercent = 0.8;
  static const Duration _minimumRefreshBuffer = Duration(seconds: 60);

  AuthorizationInterceptors(
    this._dio,
    this._authenticationClient,
    this._tokenOidcCacheManager,
    this._accountCacheManager,
    this._iosSharingManager,
  );

  void setBasicAuthorization(UserName userName, Password password) {
    _authorization = base64Encode(utf8.encode('${userName.value}:${password.value}'));
    _authenticationType = AuthenticationType.basic;
  }

  void setTokenAndAuthorityOidc({TokenOIDC? newToken, OIDCConfiguration? newConfig}) {
    _token = newToken;
    _configOIDC = newConfig;
    _authenticationType = AuthenticationType.oidc;
    log('AuthorizationInterceptors::setTokenAndAuthorityOidc: INITIAL_TOKEN = ${newToken?.token} | EXPIRED_TIME = ${newToken?.expiredTime}');
    _scheduleTokenRefresh();
  }

  void _updateNewToken(TokenOIDC newToken) {
    log('AuthorizationInterceptors::_updateNewToken: NEW_TOKEN = ${newToken.token} | EXPIRED_TIME = ${newToken.expiredTime}');
    _token = newToken;
    _scheduleTokenRefresh();
  }

  OIDCConfiguration? get oidcConfig => _configOIDC;

  AuthenticationType get authenticationType => _authenticationType;

  /// Returns the current access token for WebSocket authentication.
  /// Returns null if not using OIDC or token is invalid.
  String? get currentToken {
    if (_authenticationType == AuthenticationType.oidc && _token?.isTokenValid() == true) {
      return _token?.token;
    }
    return null;
  }

  /// Returns the base64-encoded basic auth credentials for WebSocket authentication.
  /// Returns null if not using basic auth.
  String? get basicAuthCredentials {
    if (_authenticationType == AuthenticationType.basic) {
      return _authorization;
    }
    return null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    switch(_authenticationType) {
      case AuthenticationType.basic:
        if (_authorization != null) {
          options.headers[HttpHeaders.authorizationHeader] = _getAuthorizationAsBasicHeader(_authorization);
        }
        break;
      case AuthenticationType.oidc:
        if (_token != null && _token?.isTokenValid() == true) {
          options.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
        }
        break;
      case AuthenticationType.none:
        break;
    }
    log('AuthorizationInterceptors::onRequest(): URL = ${options.uri} | DATA = ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    logWarning('AuthorizationInterceptors::onError(): DIO_ERROR = $err');
    try {
      final requestOptions = err.requestOptions;
      final extraInRequest = requestOptions.extra;
      bool isRetryRequest = false;

      if (validateToRefreshToken(
        responseStatusCode: err.response?.statusCode,
        tokenOIDC: _token
      )) {
        log('AuthorizationInterceptors::onError: Perform get New Token');
        final newTokenOidc = PlatformInfo.isIOS
          ? await _getNewTokenForIOSPlatform()
          : await _getNewTokenForOtherPlatform();

        if (newTokenOidc.token == _token?.token) {
          log('AuthorizationInterceptors::onError: Token duplicated');
          return super.onError(err, handler);
        }
        _updateNewToken(newTokenOidc);

        final personalAccount = await _updateCurrentAccount(tokenOIDC: newTokenOidc);

        if (PlatformInfo.isIOS) {
          await _iosSharingManager.saveKeyChainSharingSession(personalAccount);
        }

        isRetryRequest = true;
      } else if (validateToRetryTheRequestWithNewToken(
        authHeader: requestOptions.headers[HttpHeaders.authorizationHeader],
        tokenOIDC: _token
      )) {
        log('AuthorizationInterceptors::onError: Request using old token');
        isRetryRequest = true;
      } else {
        return super.onError(err, handler);
      }

      if (isRetryRequest) {
        if (extraInRequest.containsKey(FileUploader.uploadAttachmentExtraKey)) {
          log('AuthorizationInterceptors::onError: Retry upload request with TokenId = ${_token?.tokenIdHash}');
          final uploadExtra = extraInRequest[FileUploader.uploadAttachmentExtraKey];

          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);

          final newOptions = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          );

          final response = await _dio.request(
            requestOptions.path,
            data: _getDataUploadRequest(uploadExtra),
            queryParameters: requestOptions.queryParameters,
            options: newOptions,
          );

          return handler.resolve(response);
        } else {
          log('AuthorizationInterceptors::onError: Retry request with TokenId = ${_token?.tokenIdHash}');
          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);

          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        }
      } else {
        return super.onError(err, handler);
      }
    } catch (e, stackTrace) {
      logError(
        'AuthorizationInterceptors::onError:Exception: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      if (e is ServerError || e is TemporarilyUnavailable) {
        return super.onError(
          DioException(requestOptions: err.requestOptions, error: e),
          handler,
        );
      } else {
        return super.onError(err.copyWith(error: e), handler);
      }
    }
  }

  Stream<List<int>>? _getDataUploadRequest(dynamic mapUploadExtra) {
    try {
      if (mapUploadExtra is! Map) return null;
      final filePath = mapUploadExtra[FileUploader.filePathExtraKey] as String?;
      if (filePath?.isNotEmpty == true) {
        return File(filePath!).openRead();
      } else {
        return mapUploadExtra[FileUploader.streamDataExtraKey] as Stream<List<int>>?;
      }
    } catch(e) {
      logWarning(
        'AuthorizationInterceptors::_getDataUploadRequest: Exception = $e',
      );
      return null;
    }
  }

  bool _isTokenExpired(TokenOIDC? tokenOIDC) => tokenOIDC?.isExpired == true;

  bool _isAuthenticationOidcValid() => _authenticationType == AuthenticationType.oidc && _configOIDC != null;

  bool _isTokenNotEmpty(TokenOIDC? tokenOIDC) => tokenOIDC?.token.isNotEmpty == true;

  bool _isRefreshTokenNotEmpty(TokenOIDC? tokenOIDC) => tokenOIDC?.refreshToken.isNotEmpty == true;

  bool validateToRefreshToken({
    required int? responseStatusCode,
    required TokenOIDC? tokenOIDC
  }) {
    return responseStatusCode == 401
      && _isAuthenticationOidcValid()
      && _isTokenNotEmpty(tokenOIDC)
      && _isRefreshTokenNotEmpty(tokenOIDC)
      && _isTokenExpired(tokenOIDC);
  }

  bool validateToRetryTheRequestWithNewToken({
    required String? authHeader,
    required TokenOIDC? tokenOIDC
  }) {
    return authHeader != null
      && _isTokenNotEmpty(tokenOIDC)
      && !_isTokenExpired(tokenOIDC)
      && !authHeader.contains(tokenOIDC!.token);
  }

  String _getAuthorizationAsBasicHeader(String? authorization) => 'Basic $authorization';

  String _getTokenAsBearerHeader(String token) => 'Bearer $token';

  Future<PersonalAccount> _updateCurrentAccount({required TokenOIDC tokenOIDC}) async {
    final currentAccount = await _accountCacheManager.getCurrentAccount();

    await _accountCacheManager.deleteCurrentAccount(currentAccount.id);

    await _tokenOidcCacheManager.persistOneTokenOidc(tokenOIDC);

    final personalAccount = PersonalAccount(
      tokenOIDC.tokenIdHash,
      AuthenticationType.oidc,
      isSelected: true,
      accountId: currentAccount.accountId,
      apiUrl: currentAccount.apiUrl,
      userName: currentAccount.userName
    );
    await _accountCacheManager.setCurrentAccount(personalAccount);

    return personalAccount;
  }

  Future<TokenOIDC?> _getTokenInKeychain(TokenOIDC currentTokenOidc) async {
    final currentAccount = await _accountCacheManager.getCurrentAccount();
    if (currentAccount.accountId == null) {
      return null;
    }

    final keychainSharingSession = await _iosSharingManager.getKeychainSharingSession(currentAccount.accountId!);
    if (keychainSharingSession == null) {
      return null;
    }

    if (keychainSharingSession.tokenOIDC != null &&
        currentTokenOidc.token != keychainSharingSession.tokenOIDC!.token) {
      return keychainSharingSession.tokenOIDC!;
    }

    return null;
  }

  Future<TokenOIDC> _invokeRefreshTokenFromServer() {
    log('AuthorizationInterceptors::_invokeRefreshTokenFromServer:');
    return _authenticationClient.refreshingTokensOIDC(
      _configOIDC!.clientId,
      _configOIDC!.redirectUrl,
      _configOIDC!.discoveryUrl,
      _configOIDC!.scopes,
      _token!.refreshToken
    );
  }

  Future<TokenOIDC> _getNewTokenForIOSPlatform() async {
    final tokenInKeychain = await _getTokenInKeychain(_token!);
    log('AuthorizationInterceptors::_handleRefreshTokenOnIOSPlatform: KeychainTokenId = ${tokenInKeychain?.tokenIdHash} | isTokenExpired = ${_isTokenExpired(tokenInKeychain)}');
    if (tokenInKeychain == null || _isTokenExpired(tokenInKeychain)) {
      return _invokeRefreshTokenFromServer();
    } else {
      return tokenInKeychain;
    }
  }

  Future<TokenOIDC> _getNewTokenForOtherPlatform() {
    return _invokeRefreshTokenFromServer();
  }

  /// Schedules a proactive token refresh before the token expires.
  /// Refreshes at 80% of token lifetime or 60 seconds before expiry, whichever is sooner.
  void _scheduleTokenRefresh() {
    _cancelTokenRefreshTimer();

    if (_authenticationType != AuthenticationType.oidc ||
        _token == null ||
        _token!.expiredTime == null ||
        _token!.refreshToken.isEmpty) {
      log('AuthorizationInterceptors::_scheduleTokenRefresh: Skipping - not OIDC or missing token/expiry/refreshToken');
      return;
    }

    final now = DateTime.now();
    final expiryTime = _token!.expiredTime!;

    if (expiryTime.isBefore(now)) {
      log('AuthorizationInterceptors::_scheduleTokenRefresh: Token already expired, not scheduling');
      return;
    }

    final totalLifetime = expiryTime.difference(now);
    final refreshAt80Percent = Duration(
      milliseconds: (totalLifetime.inMilliseconds * _refreshThresholdPercent).round()
    );
    final refreshWithBuffer = totalLifetime - _minimumRefreshBuffer;

    // Use whichever is sooner: 80% of lifetime or buffer before expiry
    final refreshDelay = refreshAt80Percent < refreshWithBuffer
        ? refreshAt80Percent
        : refreshWithBuffer;

    // Ensure we don't schedule with negative or zero delay
    if (refreshDelay.inSeconds <= 0) {
      log('AuthorizationInterceptors::_scheduleTokenRefresh: Token about to expire, refreshing immediately');
      _proactivelyRefreshToken();
      return;
    }

    log('AuthorizationInterceptors::_scheduleTokenRefresh: Scheduling refresh in ${refreshDelay.inSeconds} seconds (token expires in ${totalLifetime.inSeconds} seconds)');

    _tokenRefreshTimer = Timer(refreshDelay, _proactivelyRefreshToken);
  }

  /// Proactively refreshes the token before it expires.
  Future<void> _proactivelyRefreshToken() async {
    if (_isRefreshing) {
      log('AuthorizationInterceptors::_proactivelyRefreshToken: Already refreshing, skipping');
      return;
    }

    if (_authenticationType != AuthenticationType.oidc ||
        _token == null ||
        _token!.refreshToken.isEmpty ||
        _configOIDC == null) {
      log('AuthorizationInterceptors::_proactivelyRefreshToken: Cannot refresh - missing configuration');
      return;
    }

    _isRefreshing = true;
    log('AuthorizationInterceptors::_proactivelyRefreshToken: Starting proactive token refresh');

    try {
      final newTokenOidc = PlatformInfo.isIOS
          ? await _getNewTokenForIOSPlatform()
          : await _getNewTokenForOtherPlatform();

      if (newTokenOidc.token == _token?.token) {
        log('AuthorizationInterceptors::_proactivelyRefreshToken: Token unchanged after refresh');
        _isRefreshing = false;
        _scheduleTokenRefresh();
        return;
      }

      log('AuthorizationInterceptors::_proactivelyRefreshToken: Got new token, updating');
      _token = newTokenOidc;

      final personalAccount = await _updateCurrentAccount(tokenOIDC: newTokenOidc);

      if (PlatformInfo.isIOS) {
        await _iosSharingManager.saveKeyChainSharingSession(personalAccount);
      }

      log('AuthorizationInterceptors::_proactivelyRefreshToken: Token refresh successful, new expiry: ${newTokenOidc.expiredTime}');
      _scheduleTokenRefresh();
    } catch (e, stackTrace) {
      logError(
        'AuthorizationInterceptors::_proactivelyRefreshToken: Failed to refresh token: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      // Schedule retry after a short delay if refresh fails
      _tokenRefreshTimer = Timer(const Duration(seconds: 30), _proactivelyRefreshToken);
    } finally {
      _isRefreshing = false;
    }
  }

  void _cancelTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Manually trigger a token refresh check (e.g., when app resumes from background)
  Future<void> checkAndRefreshTokenIfNeeded() async {
    if (_authenticationType != AuthenticationType.oidc ||
        _token == null ||
        _token!.refreshToken.isEmpty) {
      return;
    }

    // If token is expired or will expire within the buffer, refresh immediately
    if (_token!.expiredTime != null) {
      final now = DateTime.now();
      final expiryTime = _token!.expiredTime!;
      final timeUntilExpiry = expiryTime.difference(now);

      if (timeUntilExpiry <= _minimumRefreshBuffer) {
        log('AuthorizationInterceptors::checkAndRefreshTokenIfNeeded: Token expired or expiring soon, refreshing');
        await _proactivelyRefreshToken();
      } else {
        // Reschedule the timer in case it was cancelled
        _scheduleTokenRefresh();
      }
    }
  }

  void clear() {
    _cancelTokenRefreshTimer();
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
    _isRefreshing = false;
  }
}