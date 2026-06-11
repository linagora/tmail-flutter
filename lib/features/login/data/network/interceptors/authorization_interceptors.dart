import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/extensions/object_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/web_refresh_token_error_classifier.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class AuthorizationInterceptors extends QueuedInterceptorsWrapper {
  static const String _refreshAttemptedKey = '_authInterceptorRefreshAttempted';

  final Dio _dio;
  final AuthenticationClientBase _authenticationClient;
  final TokenOidcCacheManager _tokenOidcCacheManager;
  final AccountCacheManager _accountCacheManager;
  final IOSSharingManager _iosSharingManager;

  AuthenticationType _authenticationType = AuthenticationType.none;
  OIDCConfiguration? _configOIDC;
  TokenOIDC? _token;
  String? _authorization;

  final _webErrorClassifier = WebRefreshTokenErrorClassifier();

  late final void Function(
    Object error,
    DioException originalError,
    ErrorInterceptorHandler handler,
  ) _handleRefreshError =
      PlatformInfo.isWeb ? _handleRefreshErrorOnWeb : _handleRefreshErrorOnMobile;

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
  }

  void _updateNewToken(TokenOIDC newToken) {
    log('AuthorizationInterceptors::_updateNewToken: NEW_TOKEN = ${newToken.token} | EXPIRED_TIME = ${newToken.expiredTime}');
    _token = newToken;
  }

  OIDCConfiguration? get oidcConfig => _configOIDC;

  AuthenticationType get authenticationType => _authenticationType;

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
    logWarning(
      'AuthorizationInterceptors::onError(): DIO_ERROR = $err | '
      'statusCode=${err.response?.statusCode} | authType=$_authenticationType',
      webConsoleEnabled: true,
    );
    try {
      final requestOptions = err.requestOptions;
      final hasAttemptedRefresh = requestOptions.extra[_refreshAttemptedKey] == true;

      if (!hasAttemptedRefresh && validateToRetryTheRequestWithNewToken(
        responseStatusCode: err.response?.statusCode,
        authHeader: requestOptions.headers[HttpHeaders.authorizationHeader],
        tokenOIDC: _token
      )) {
        log(
          'AuthorizationInterceptors::onError: Request using old token, retry with updated token',
          webConsoleEnabled: true,
        );
        return await _performRetry(requestOptions, err, handler);
      } else if (!hasAttemptedRefresh && validateToRefreshToken(
        responseStatusCode: err.response?.statusCode,
        tokenOIDC: _token
      )) {
        return await _refreshTokenThenRetry(err, requestOptions, handler);
      }

      if (err.response?.statusCode == 401) {
        _logForcedLogoutFor401(
          authErrorType: _classifySkippedRefresh401(hasAttemptedRefresh),
          err: err,
          hasAttemptedRefresh: hasAttemptedRefresh,
        );
      } else {
        logTrace(
          'AuthorizationInterceptors::onError: '
          'No retry or refresh applicable. '
          'statusCode = ${err.response?.statusCode} | '
          'authType = $_authenticationType | '
          'hasConfig = ${_configOIDC != null} | '
          'hasAttemptedRefresh = $hasAttemptedRefresh | '
          'url = ${err.requestOptions.uri}',
          webConsoleEnabled: true,
        );
      }
      return super.onError(err, handler);
    } catch (e, stackTrace) {
      logError(
        'AuthorizationInterceptors::onError:Exception: $e',
        exception: e,
        stackTrace: stackTrace,
        webConsoleEnabled: true,
      );
      return _handleRefreshError(e, err, handler);
    }
  }

  String _classifySkippedRefresh401(bool hasAttemptedRefresh) {
    if (hasAttemptedRefresh) {
      return 'forced_logout_401_after_refresh_attempted';
    }
    if (_authenticationType != AuthenticationType.oidc) {
      return 'forced_logout_401_non_oidc_session';
    }
    if (_configOIDC == null) {
      return 'forced_logout_401_oidc_config_missing';
    }
    return 'forced_logout_401_refresh_preconditions_unmet';
  }

  void _logForcedLogoutFor401({
    required String authErrorType,
    required DioException err,
    required bool hasAttemptedRefresh,
  }) {
    logError(
      'AuthorizationInterceptors: auth_error_type=$authErrorType | will_logout=true | '
      'authType=$_authenticationType | hasConfig=${_configOIDC != null} | '
      'hasToken=${_isTokenNotEmpty(_token)} | hasRefreshToken=${_isRefreshTokenNotEmpty(_token)} | '
      'tokenExpired=${_isTokenExpired(_token)} | hasAttemptedRefresh=$hasAttemptedRefresh | '
      'statusCode=${err.response?.statusCode} | url=${err.requestOptions.uri}',
      exception: err,
      stackTrace: err.stackTrace,
      webConsoleEnabled: true,
    );
  }

  /// A failure with NO server response (network/transport drop, timeout) keeps
  /// the session and is propagated WITHOUT the stale 401 — same as mobile — so
  /// a flaky connection does not log the web user out.
  ///
  /// Error routing delegates RFC 6749 classification to [WebRefreshTokenErrorClassifier]:
  /// - Server rejection (400/401 or RFC 6749 bad-grant code) → logout.
  /// - [ArgumentError] with unknown OAuth2 code → Sentry trace, keep session.
  /// - Network/transport failure → keep session silently.
  void _handleRefreshErrorOnWeb(
    Object error,
    DioException originalError,
    ErrorInterceptorHandler handler,
  ) {
    final isRejected = _webErrorClassifier.isServerRejection(error);

    if (isRejected) {
      logError(
        'AuthorizationInterceptors::_handleRefreshErrorOnWeb: '
        'will_logout=true — error=$error',
        exception: error,
        stackTrace: StackTrace.current,
        extras: _webErrorClassifier.buildSentryExtras(error),
        webConsoleEnabled: true,
      );
      clear();
      return handler.reject(DioException(
        requestOptions: originalError.requestOptions,
        error: RefreshTokenFailedException(),
        type: DioExceptionType.badResponse,
      ));
    }

    if (error is ArgumentError) {
      // Non-standard OAuth2 code — log to Sentry for investigation, keep session.
      logError(
        'AuthorizationInterceptors::_handleRefreshErrorOnWeb: '
        'will_logout=false — error=$error',
        exception: error,
        stackTrace: StackTrace.current,
        extras: _webErrorClassifier.buildSentryExtras(error),
        webConsoleEnabled: true,
      );
      return _handleRefreshErrorOnMobile(error, originalError, handler);
    }

    logWarning(
      'AuthorizationInterceptors::_handleRefreshErrorOnWeb: '
      'web refresh network/transient failure, keeping session — error=$error',
      webConsoleEnabled: true,
    );
    return _handleRefreshErrorOnMobile(error, originalError, handler);
  }

  void _handleRefreshErrorOnMobile(
    Object error,
    DioException originalError,
    ErrorInterceptorHandler handler,
  ) {
    if (error is DioException) {
      return super.onError(error, handler);
    }
    return super.onError(
      error.toDioException(requestOptions: originalError.requestOptions),
      handler,
    );
  }

  /// A retry that comes back 401 then surfaces downstream as
  /// [BadCredentialsException]; a 5xx/network retry failure is propagated
  /// without forcing a logout.
  void _handleRetryError(
    Object retryError,
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) {
    logWarning(
      'AuthorizationInterceptors::_handleRetryError: '
      'retry with new token failed — error=$retryError',
      webConsoleEnabled: true,
    );
    if (retryError is DioException) {
      if (retryError.response?.statusCode == 401) {
        // Retried with a fresh/updated token and STILL got 401 → server rejects
        // the new token. Genuine auth failure heading to logout; tag it.
        _logForcedLogoutFor401(
          authErrorType: 'forced_logout_401_retry_rejected',
          err: retryError,
          hasAttemptedRefresh: requestOptions.extra[_refreshAttemptedKey] == true,
        );
      }
      return super.onError(retryError, handler);
    }
    return super.onError(
      retryError.toDioException(requestOptions: requestOptions),
      handler,
    );
  }

  Future<void> _refreshTokenThenRetry(
    DioException err,
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      log(
        'AuthorizationInterceptors::onError: Perform get New Token',
        webConsoleEnabled: true,
      );
      final newTokenOidc = PlatformInfo.isIOS
        ? await _getNewTokenForIOSPlatform()
        : await _getNewTokenForOtherPlatform();

      if (newTokenOidc.token == _token?.token) {
        // Refresh returned the SAME token — retrying cannot clear the 401, so it
        // propagates to logout. Real auth death, but tag it for forensics.
        _logForcedLogoutFor401(
          authErrorType: 'forced_logout_401_refreshed_token_duplicated',
          err: err,
          hasAttemptedRefresh: true,
        );
        return super.onError(err, handler);
      }
      _updateNewToken(newTokenOidc);

      final personalAccount = await _updateCurrentAccount(tokenOIDC: newTokenOidc);

      if (PlatformInfo.isIOS) {
        await _iosSharingManager.saveKeyChainSharingSession(personalAccount);
      }

      requestOptions.extra[_refreshAttemptedKey] = true;
      return await _performRetry(requestOptions, err, handler);
    } on DioException catch (refreshError, st) {
      // Web routes ALL refresh failures (Dio or non-Dio) through the single
      // web handler, so the session decision is uniform regardless of how the
      // failure surfaced. (In practice flutter_appauth_web throws a non-Dio
      // ArgumentError, but a Dio-based refresh must behave identically.)
      if (PlatformInfo.isWeb) {
        return _handleRefreshError(refreshError, err, handler);
      }
      // Mobile: 400 → session dead (RefreshTokenFailedException); other
      // statuses / no-response → network-tolerant via _handleDioRefreshError.
      if (refreshError.response?.statusCode == 400) {
        logError(
          'AuthorizationInterceptors: auth_error_type=token_endpoint_400 | '
          'will_logout=true — error=$refreshError',
          exception: refreshError,
          stackTrace: st,
        );
        clear();
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: RefreshTokenFailedException(),
          type: DioExceptionType.badResponse,
          response: refreshError.response,
        ));
      }
      logError(
        'AuthorizationInterceptors: auth_error_type=token_endpoint_other | '
        'statusCode=${refreshError.response?.statusCode} | '
        'will_logout=false — error=$refreshError',
        exception: refreshError,
        stackTrace: st,
      );
      return _handleDioRefreshError(
        refreshError: refreshError,
        originalError: err,
        handler: handler,
      );
    } on PlatformException catch (e, st) {
      // flutter_appauth throws PlatformException when the native token request
      // fails at the OS level (e.g. DNS resolution failure, no network to SSO).
      // This is a connectivity failure, NOT a server rejection — keep the
      // session alive and surface a connection-error toast instead of logging out.
      logError(
        'AuthorizationInterceptors: auth_error_type=token_refresh_platform_network_failure | '
        'platformCode=${e.code} | '
        'will_logout=false — error=$e',
        exception: e,
        stackTrace: st,
      );
      return super.onError(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          type: DioExceptionType.connectionError,
        ),
        handler,
      );
    }
  }

  Future<void> _performRetry(
    RequestOptions requestOptions,
    DioException originalErr,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _retryRequest(requestOptions, requestOptions.extra);
      return handler.resolve(response);
    } catch (retryError) {
      return _handleRetryError(retryError, originalErr.requestOptions, handler);
    }
  }

  void _handleDioRefreshError({
    required DioException refreshError,
    required DioException originalError,
    required ErrorInterceptorHandler handler,
  }) {
    // Network failure during refresh — don't carry the original 401 response
    // forward, as that would make RemoteExceptionThrower classify this as
    // BadCredentialsException and log the user out.
    if (refreshError.response == null) {
      return super.onError(
        refreshError.error.toDioException(
          requestOptions: originalError.requestOptions,
          type: refreshError.type,
          message: refreshError.message,
        ),
        handler,
      );
    }
    return super.onError(refreshError, handler);
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

  bool validateToRefreshToken(
      {required int? responseStatusCode, required TokenOIDC? tokenOIDC}) {
    final isStatusCode401 = responseStatusCode == 401;
    final isLoginWithOIDC = _isAuthenticationOidcValid();
    final hasAccessToken = _isTokenNotEmpty(tokenOIDC);
    final hasRefreshToken = _isRefreshTokenNotEmpty(tokenOIDC);

    final canProceedRefresh = isStatusCode401 &&
        isLoginWithOIDC &&
        hasAccessToken &&
        hasRefreshToken;

    logTrace(
      'AuthorizationInterceptors::validateToRefreshToken: '
      'isStatusCode401 = $isStatusCode401 | '
      'isLoginWithOIDC = $isLoginWithOIDC | '
      'hasAccessToken = $hasAccessToken | '
      'hasRefreshToken = $hasRefreshToken | '
      'canProceedRefresh = $canProceedRefresh',
      webConsoleEnabled: true,
    );

    return canProceedRefresh;
  }

  bool validateToRetryTheRequestWithNewToken(
      {required int? responseStatusCode,
      required String? authHeader,
      required TokenOIDC? tokenOIDC}) {
    final isStatusCode401 = responseStatusCode == 401;
    final hasAuthHeader = authHeader != null;
    final hasAccessToken = _isTokenNotEmpty(tokenOIDC);
    final isTokenStillValid = !_isTokenExpired(tokenOIDC);
    final isTokenUpdated =
        tokenOIDC != null && authHeader?.contains(tokenOIDC.token) != true;

    final shouldRetry = isStatusCode401 &&
        hasAuthHeader &&
        hasAccessToken &&
        isTokenStillValid &&
        isTokenUpdated;

    logTrace(
      'AuthorizationInterceptors::validateToRetryWithNewToken: '
      'isStatusCode401 = $isStatusCode401 | '
      'hasHeader = $hasAuthHeader | '
      'hasAccessToken = $hasAccessToken | '
      'isTokenValid = $isTokenStillValid | '
      'isNewToken = $isTokenUpdated | '
      'shouldRetry = $shouldRetry',
      webConsoleEnabled: true,
    );

    return shouldRetry;
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

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    Map<String, dynamic> extraInRequest,
  ) {
    requestOptions.headers[HttpHeaders.authorizationHeader] =
        _getTokenAsBearerHeader(_token!.token);
    requestOptions.extra[_refreshAttemptedKey] = true;

    final retryDio = _createRetryDio();

    if (extraInRequest.containsKey(FileUploader.uploadAttachmentExtraKey)) {
      log('AuthorizationInterceptors::_retryRequest: '
          'Retry upload request with TokenId = ${_token?.tokenIdHash}');
      final uploadExtra =
          extraInRequest[FileUploader.uploadAttachmentExtraKey];

      return retryDio.request(
        requestOptions.path,
        data: _getDataUploadRequest(uploadExtra),
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          extra: requestOptions.extra,
        ),
      );
    } else {
      log('AuthorizationInterceptors::_retryRequest: '
          'Retry request with TokenId = ${_token?.tokenIdHash}');
      return retryDio.fetch(requestOptions);
    }
  }

  /// Creates a separate Dio instance without interceptors for retry requests.
  /// This avoids deadlock when retrying inside [onError] of [QueuedInterceptorsWrapper].
  Dio _createRetryDio() => Dio(_dio.options)
    ..httpClientAdapter = _dio.httpClientAdapter;

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}