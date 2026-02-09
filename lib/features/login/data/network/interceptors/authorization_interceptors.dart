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
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
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
    logWarning('AuthorizationInterceptors::onError(): DIO_ERROR = $err');
    try {
      final requestOptions = err.requestOptions;
      final extraInRequest = requestOptions.extra;
      bool isRetryRequest = false;

      // Check if this request has already attempted a refresh/retry
      final hasAttemptedRefresh = extraInRequest[_refreshAttemptedKey] == true;

      // FIRST: Check if token was already updated by another request in the queue
      // If so, just retry with the new token - no refresh needed
      // But skip if we've already attempted (to prevent infinite loops)
      if (!hasAttemptedRefresh && validateToRetryTheRequestWithNewToken(
        authHeader: requestOptions.headers[HttpHeaders.authorizationHeader],
        tokenOIDC: _token
      )) {
        log('AuthorizationInterceptors::onError: Request using old token, retry with updated token');
        isRetryRequest = true;
      } else if (!hasAttemptedRefresh && validateToRefreshToken(
        responseStatusCode: err.response?.statusCode,
        tokenOIDC: _token
      )) {
        // SECOND: Check if we should attempt to refresh the token
        try {
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

          // Mark that we've attempted refresh for this request
          requestOptions.extra[_refreshAttemptedKey] = true;
          isRetryRequest = true;
        } on DioException catch (refreshError, st) {
          if (refreshError.response?.statusCode == 400) {
            logError(
              'AuthorizationInterceptors: Refresh Token Failed 400',
              exception: refreshError,
              stackTrace: st,
            );

            clear();

            final sessionExpiredError = DioException(
              requestOptions: err.requestOptions,
              error: RefreshTokenFailedException(),
              type: DioExceptionType.badResponse,
              response: refreshError.response,
            );

            return handler.reject(sessionExpiredError);
          }

          return super.onError(err, handler);
        }
      } else {
        logTrace(
          'AuthorizationInterceptors::onError: '
          '401 received but refresh skipped. '
          'statusCode = ${err.response?.statusCode} | '
          'authType = $_authenticationType | '
          'hasConfig = ${_configOIDC != null} | '
          'hasAttemptedRefresh = $hasAttemptedRefresh | '
          'url = ${err.requestOptions.uri}',
          webConsoleEnabled: true,
        );
        return super.onError(err, handler);
      }

      if (isRetryRequest) {
        if (extraInRequest.containsKey(FileUploader.uploadAttachmentExtraKey)) {
          log('AuthorizationInterceptors::onError: Retry upload request with TokenId = ${_token?.tokenIdHash}');
          final uploadExtra = extraInRequest[FileUploader.uploadAttachmentExtraKey];

          requestOptions.headers[HttpHeaders.authorizationHeader] = _getTokenAsBearerHeader(_token!.token);
          // Mark as attempted to prevent infinite retry loops
          requestOptions.extra[_refreshAttemptedKey] = true;

          final newOptions = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            extra: requestOptions.extra,
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
          // Mark as attempted to prevent infinite retry loops
          requestOptions.extra[_refreshAttemptedKey] = true;

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

  bool validateToRefreshToken(
      {required int? responseStatusCode, required TokenOIDC? tokenOIDC}) {
    final isStatusCode401 = responseStatusCode == 401;
    final isLoginWithOIDC = _isAuthenticationOidcValid();
    final hasAccessToken = _isTokenNotEmpty(tokenOIDC);
    final hasRefreshToken = _isRefreshTokenNotEmpty(tokenOIDC);

    // Note: We removed isExpired check. If server returns 401, we trust it
    // and attempt refresh regardless of local expiry time. This handles cases
    // where server clock is ahead or token was revoked server-side.
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
      {required String? authHeader, required TokenOIDC? tokenOIDC}) {
    final hasAuthHeader = authHeader != null;
    final hasAccessToken = _isTokenNotEmpty(tokenOIDC);
    final isTokenStillValid = !_isTokenExpired(tokenOIDC);
    final isTokenUpdated =
        tokenOIDC != null && authHeader?.contains(tokenOIDC.token) != true;

    // Note: We don't check isTokenExpired here. If another request already
    // refreshed the token, we should retry with the new token regardless of
    // its expiry status. The key check is isTokenUpdated.
    final shouldRetry =
        hasAuthHeader && hasAccessToken && isTokenStillValid && isTokenUpdated;

    logTrace(
      'AuthorizationInterceptors::validateToRetryWithNewToken: '
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

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}