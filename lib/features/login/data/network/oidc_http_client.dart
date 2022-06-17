
import 'dart:convert';

import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_response_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class OIDCHttpClient {

  final DioClient _dioClient;
  final FlutterAppAuth _appAuth;

  OIDCHttpClient(this._dioClient, this._appAuth);

  Future<OIDCResponse?> checkOIDCIsAvailable(OIDCRequest oidcRequest) async {
    final result = await _dioClient.get(
        Endpoint.webFinger
            .generateOIDCPath(Uri.parse(oidcRequest.baseUrl))
            .withQueryParameters([
              StringQueryParameter('resource', oidcRequest.resourceUrl),
              StringQueryParameter('rel', OIDCRequest.relUrl),
            ])
            .generateEndpointPath()
    );
    log('OIDCHttpClient::checkOIDCIsAvailable(): RESULT: $result');
    if (result is Map<String, dynamic>) {
      return OIDCResponse.fromJson(result);
    } else {
      return OIDCResponse.fromJson(jsonDecode(result));
    }
  }

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri, OIDCResponse oidcResponse) async {
    if (oidcResponse.links.isEmpty) {
      throw CanNotFoundOIDCAuthority();
    }
    log('OIDCHttpClient::getOIDCConfiguration(): href: ${oidcResponse.links[0].href}');
    return OIDCConfiguration(
      authority: oidcResponse.links[0].href.toString(),
      clientId: OIDCConstant.mobileOidcClientId,
      scopes: OIDCConstant.oidcScope
    );
  }

  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) async {
    final authorizationTokenResponse = await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
        preferEphemeralSession: true));

    log('OIDCHttpClient::getTokenOIDC(): token: ${authorizationTokenResponse?.accessToken}');

    if (authorizationTokenResponse != null) {
      final tokenOIDC = authorizationTokenResponse.toTokenOIDC();
      if (tokenOIDC.isTokenValid()) {
        return tokenOIDC;
      } else {
        throw AccessTokenInvalidException();
      }
    } else {
      throw NotFoundAccessTokenException();
    }
  }

  Future<TokenOIDC> refreshingTokensOIDC(String clientId, String redirectUrl,
      String discoveryUrl, List<String> scopes, String refreshToken) async {
    final tokenResponse = await _appAuth.token(TokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        refreshToken: refreshToken,
        scopes: scopes));

    log('OIDCHttpClient::refreshingTokensOIDC(): refreshToken: ${tokenResponse?.accessToken}');

    if (tokenResponse != null) {
      final tokenOIDC = tokenResponse.toTokenOIDC();
      if (tokenOIDC.isTokenValid()) {
        return tokenOIDC;
      } else {
        throw AccessTokenInvalidException();
      }
    } else {
      throw NotFoundAccessTokenException();
    }
  }
}