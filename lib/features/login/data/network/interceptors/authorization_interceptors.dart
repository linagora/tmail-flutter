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
import 'package:tmail_ui_user/features/base/extensions/object_extensions.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
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
      final hasAttemptedRefresh = requestOptions.extra[_refreshAttemptedKey] == true;

      if (!hasAttemptedRefresh && validateToRetryTheRequestWithNewToken(
        responseStatusCode: err.response?.statusCode,
        authHeader: requestOptions.headers[HttpHeaders.authorizationHeader],
        tokenOIDC: _token
      )) {
        log('AuthorizationInterceptors::onError: Request using old token, retry with updated token');
        return await _performRetry(requestOptions, err, handler);
      } else if (!hasAttemptedRefresh && validateToRefreshToken(
        responseStatusCode: err.response?.statusCode,
        tokenOIDC: _token
      )) {
        return await _refreshTokenThenRetry(err, requestOptions, handler);
      }

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
      return super.onError(err, handler);
    } catch (e, stackTrace) {
      logError(
        'AuthorizationInterceptors::onError:Exception: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      // Non-DioException types (e.g. FlutterAppAuthPlatformException from native
      // OIDC refresh) must not carry the stale 401 response forward, as
      // RemoteExceptionThrower would misclassify it as BadCredentialsException.
      return _handleThrownException(
        e,
        handler: handler,
        requestOptions: err.requestOptions,
      );
    }
  }

  void _handleThrownException(
    Object exception, {
    required ErrorInterceptorHandler handler,
    required RequestOptions requestOptions,
  }) {
    if (exception is DioException) {
      return super.onError(exception, handler);
    }
    return super.onError(
      exception.toDioException(requestOptions: requestOptions),
      handler,
    );
  }

  Future<void> _refreshTokenThenRetry(
    DioException err,
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      log('AuthorizationInterceptors::onError: Perform get New Token');
      final newTokenOidc = PlatformInfo.isIOS
        ? await _getNewTokenForIOSPlatform()
        : await _getNewTokenForOtherPlatform();

      if (newTokenOidc.token == _token?.token) {
        logError('AuthorizationInterceptors::onError: Token duplicated', exception: err);
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
      if (refreshError.response?.statusCode == 400) {
        logWarning(
          'AuthorizationInterceptors: Refresh Token Failed 400 - error=$refreshError | stackTrace=$st',
        );
        clear();
        return handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: RefreshTokenFailedException(),
          type: DioExceptionType.badResponse,
          response: refreshError.response,
        ));
      }
      logWarning(
        'AuthorizationInterceptors: Refresh token failed with '
        'statusCode=${refreshError.response?.statusCode} \n'
        'error=$refreshError | stackTrace=$st',
      );
      return _handleDioRefreshError(
        refreshError: refreshError,
        originalError: err,
        handler: handler,
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
      logError(
        'AuthorizationInterceptors::onError: '
        'Retry failed with error=$retryError',
      );
      // Pass retry errors directly so the stale 401 response is not preserved
      // via err.copyWith.
      return _handleThrownException(
        retryError,
        handler: handler,
        requestOptions: originalErr.requestOptions,
      );
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