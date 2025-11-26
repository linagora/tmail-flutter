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
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/main/exceptions/chained_request_error.dart';
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
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    logError('AuthorizationInterceptors::onError(): DIO_ERROR = $err');
    try {
      final requestOptions = err.requestOptions;
      final extra = requestOptions.extra;

      // Decide whether we need to refresh or retry
      final shouldRefresh = validateToRefreshToken(
        responseStatusCode: err.response?.statusCode,
        tokenOIDC: _token,
      );
      final shouldRetryWithNewToken = validateToRetryTheRequestWithNewToken(
        authHeader: requestOptions.headers[HttpHeaders.authorizationHeader],
        tokenOIDC: _token,
      );

      if (!shouldRefresh && !shouldRetryWithNewToken) {
        return super.onError(err, handler);
      }

      // Refresh token if required
      if (shouldRefresh) {
        final newToken = await _refreshToken();
        if (newToken == null) {
          // Failed or duplicate token
          return super.onError(err, handler);
        }
      }

      // Retry request with updated token
      final updatedAuthHeader = _getTokenAsBearerHeader(_token!.token);
      requestOptions.headers[HttpHeaders.authorizationHeader] =
          updatedAuthHeader;

      final bool isUploadRequest =
          extra.containsKey(FileUploader.uploadAttachmentExtraKey);

      final response = isUploadRequest
          ? await _retryUploadRequest(requestOptions, extra)
          : await _retryNormalRequest(requestOptions);

      return handler.resolve(response);
    } catch (e) {
      return _handleRetryException(err, handler, e);
    }
  }

  Stream<List<int>>? _getDataUploadRequest(dynamic mapUploadExtra) {
    try {
      String? filePath = mapUploadExtra[FileUploader.filePathExtraKey];
      if (filePath?.isNotEmpty == true) {
        return File(filePath!).openRead();
      } else {
        return mapUploadExtra[FileUploader.streamDataExtraKey];
      }
    } catch(e) {
      log('AuthorizationInterceptors::_getDataUploadRequest: Exception = $e');
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

  Future<PersonalAccount?> _updateCurrentAccount({required TokenOIDC tokenOIDC}) async {
    try {
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
    } catch (e) {
      logError('AuthorizationInterceptors::_updateCurrentAccount: Exception = $e');
      return null;
    }
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

  Future<TokenOIDC?> _refreshToken() async {
    log('AuthorizationInterceptors::onError: Perform get New Token');

    final newToken = PlatformInfo.isIOS
        ? await _getNewTokenForIOSPlatform()
        : await _getNewTokenForOtherPlatform();

    // Skip if duplicated
    if (newToken.token == _token?.token) {
      log('AuthorizationInterceptors::onError: Token duplicated');
      return null;
    }

    _updateNewToken(newToken);

    final account = await _updateCurrentAccount(tokenOIDC: newToken);
    if (PlatformInfo.isIOS && account != null) {
      await _iosSharingManager.saveKeyChainSharingSession(account);
    }

    return newToken;
  }

  Future<Response<dynamic>> _retryNormalRequest(RequestOptions options) async {
    log('AuthorizationInterceptors::_retryNormalRequest: Retry request with TokenId = ${_token?.tokenIdHash}');
    return _dio.fetch(options);
  }

  Future<Response<dynamic>> _retryUploadRequest(
    RequestOptions options,
    Map<String, dynamic> extra,
  ) async {
    log('AuthorizationInterceptors::_retryUploadRequest: Retry upload request with TokenId = ${_token?.tokenIdHash}');
    final uploadExtra = extra[FileUploader.uploadAttachmentExtraKey];
    final newOptions = Options(
      method: options.method,
      headers: options.headers,
    );

    return _dio.request(
      options.path,
      data: _getDataUploadRequest(uploadExtra),
      queryParameters: options.queryParameters,
      options: newOptions,
    );
  }

  Future<void> _handleRetryException(
    DioError err,
    ErrorInterceptorHandler handler,
    Object e,
  ) async {
    logError('AuthorizationInterceptors::_handleRetryException:Exception: $e');
    final chainedError = ChainedRequestError(
      requestOptions: err.requestOptions,
      primaryError: err,
      secondaryError: e,
    );
    return super.onError(chainedError, handler);
  }

  void clear() {
    _authorization = null;
    _token = null;
    _configOIDC = null;
    _authenticationType = AuthenticationType.none;
  }
}