import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:model/oidc/openid_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:saas/data/datasource/oauth_datasource.dart';
import 'package:saas/data/model/token_request.dart';
import 'package:saas/domain/exception/can_not_get_authentication_code.dart';
import 'package:saas/domain/repository/saas_authentication_repository.dart';
import 'package:saas/domain/utils/code_challenge_generator.dart';
import 'package:saas/domain/utils/code_verifier_generator.dart';

class SaasAuthenticationRepositoryImpl extends SaasAuthenticationRepository {
  final _saasRedirectScheme = 'twake.mail';
  final _saasClientId = 'twakemail-mobile';
  final _sessionStateUrlPath = 'session_state';
  final _openIdDiscoveryEndpoint = '/.well-known/openid-configuration';

  final CodeVerifierGenerator _codeVerifierGenerator;
  final CodeChallengeGenerator _codeChallengeGenerator;
  final OAuthDataSource _oAuthDataSource;

  SaasAuthenticationRepositoryImpl(
    this._codeVerifierGenerator,
    this._codeChallengeGenerator,
    this._oAuthDataSource,
  );

  @override
  Future<TokenOIDC> signUp(
    Uri registrationSiteUrl,
    String clientId,
    String redirectQueryParameter,
  ) {
    return _saasAuthenticate(registrationSiteUrl, clientId, redirectQueryParameter);
  }

  @override
  Future<TokenOIDC> signIn(Uri registrationSiteUrl, String clientId, String redirectQueryParameter) {
    return _saasAuthenticate(registrationSiteUrl, clientId, redirectQueryParameter);
  }

  Future<TokenOIDC> _saasAuthenticate(Uri registrationSiteUrl, String clientId, String redirectQueryParameter) async {
    final verifierCode = _codeVerifierGenerator.generateCodeVerifier(Random.secure(), 64);
    final codeChallenge = _codeChallengeGenerator.generateCodeChallenge(verifierCode);

    final fullLoginUrl = _generateAuthenticationUrl(
        registrationSiteUrl, redirectQueryParameter, codeChallenge);

    final uri = await FlutterWebAuth2.authenticate(
      url: fullLoginUrl,
      callbackUrlScheme: _saasRedirectScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );

    final authenticationCode = Uri.parse(uri).queryParameters[_sessionStateUrlPath];
    if (authenticationCode == null || authenticationCode.isEmpty) {
      throw CanNotGetAuthenticationCodeException();
    }

    final openIdConfiguration = await discoverOpenIdConfiguration(registrationSiteUrl);
    final tokenRequest = TokenRequest(
      clientId: clientId,
      grantType: 'authorization_code',
      redirectUrl: _generateRedirectUrl(registrationSiteUrl, redirectQueryParameter),
      codeVerifier: verifierCode.value,
      authorizationCode: authenticationCode,
    );

    final oidcToken = await _oAuthDataSource.getOIDCToken(openIdConfiguration, tokenRequest);
    log('SaasAuthenticationRepositoryImpl::signUp(): oidcToken: $oidcToken');

    return oidcToken;
  }

  String _generateAuthenticationUrl(Uri registrationSiteUrl, String redirectParameter, String codeChallenge) {
    log('SaasAuthenticationRepositoryImpl::_generateAuthenticationUrl(): $registrationSiteUrl');
    _verifyRegistrationUrl(registrationSiteUrl);
    final authenticationUrl = '${registrationSiteUrl.origin}?client_id=$_saasClientId&$redirectParameter&code_challenge=$codeChallenge';
    return authenticationUrl;
  }

  @override
  Future<OpenIdConfiguration> discoverOpenIdConfiguration(Uri registrationSiteUrl) {
    _verifyRegistrationUrl(registrationSiteUrl);
    final discoveryUrl = '${registrationSiteUrl.origin}/$_openIdDiscoveryEndpoint';
    return _oAuthDataSource.discoverOpenIdConfiguration(discoveryUrl);
  }

  String _generateRedirectUrl(Uri registrationSiteUrl, String redirectQueryParameter) {
    _verifyRegistrationUrl(registrationSiteUrl);
    final redirectUrl = '${registrationSiteUrl.origin}?$redirectQueryParameter';
    return redirectUrl;
  }

  void _verifyRegistrationUrl(Uri registrationSiteUrl) {
    if (!registrationSiteUrl.isScheme('https') && !registrationSiteUrl.isScheme('http')) {
      throw Exception('Login url must be https or http');
    }
  }
}
