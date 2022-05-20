
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/extensions/authentication_token_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';

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
              StringQueryParameter('rel', oidcRequest.relUrl),
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

  Future<OIDCConfiguration> getOIDCConfiguration(Uri baseUri) async {
    return OIDCConfiguration.initial();
  }

  Future<TokenOIDC> getTokenOIDC(String clientId, String redirectUrl, String discoveryUrl, List<String> scopes) async {
    final tokenResponse = await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        scopes: scopes,
        preferEphemeralSession: true));

    log('OIDCHttpClient::getTokenOIDC(): token: ${tokenResponse?.accessToken}');

    if (tokenResponse != null) {
      final tokenOIDC = tokenResponse.toTokenOIDC();
      return tokenOIDC.isTokenValid() ? tokenOIDC : TokenOIDC.empty();
    } else {
      return TokenOIDC.empty();
    }
  }
}