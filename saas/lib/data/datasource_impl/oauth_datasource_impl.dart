import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:model/oidc/openid_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:saas/data/datasource/oauth_datasource.dart';
import 'package:saas/data/model/token_request.dart';
import 'package:saas/data/model/token_response.dart';

class OAuthDataSourceImp extends OAuthDataSource {
  final Dio _dio;

  OAuthDataSourceImp(this._dio);

  @override
  Future<OpenIdConfiguration> discoverOpenIdConfiguration(String discoveryUrl) async {
    log('OAuthDataSourceImp::discoverOpenIdConfiguration(): discoveryUrl: $discoveryUrl');
    // return await _dio.get(discoveryUrl)
    //   .then((value) => value.data)
    //   .then((body) => OpenIdConfigurationDto.fromJson(body))
    //   .then((dto) => dto.toOpenIdConfiguration());
    return OpenIdConfiguration(
        issuer: 'https://auth.tom-dev.xyz',
        tokenEndpoint: 'https://auth.tom-dev.xyz/oauth2/token',
        endSessionEndpoint: 'https://auth.tom-dev.xyz/oauth2/logout'
    );
  }

  @override
  Future<TokenOIDC> getOIDCToken(OpenIdConfiguration openIdConfiguration, TokenRequest tokenRequest) async {
    log('OAuthDataSourceImp::getOIDCToken(): $openIdConfiguration');
    log('OAuthDataSourceImp::getOIDCToken(): tokenRequest: $tokenRequest');
    final tokenEndpoint = openIdConfiguration.tokenEndpoint;

    var body = {'client_id': tokenRequest.clientId};
    if (tokenRequest.authorizationCode != null) {
      body['code'] = tokenRequest.authorizationCode;
      body['grant_type'] = tokenRequest.grantType;
      body['redirect_uri'] = Uri.encodeComponent(tokenRequest.redirectUrl!);
    }

    if (tokenRequest.refreshToken != null) {
      body['refresh_token'] = tokenRequest.refreshToken;
      body['grant_type'] = 'refresh_token';
    }

    if (tokenRequest.codeVerifier != null) {
      body['code_verifier'] = tokenRequest.codeVerifier;
    }

    log('OAuthDataSourceImp::getOIDCToken(): post get token');
    return await _dio.post(
      tokenEndpoint!,
      data: body,
      options: Options(contentType: Headers.formUrlEncodedContentType)
    )
      .then((value) => value.data)
      .then((body) => TokenResponse.fromJson(body))
      .then((tokenResponse) => tokenResponse.toTokenOidc(authority: openIdConfiguration.issuer!));
  }

}