import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:model/oidc/openid_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:saas/data/datasource/oauth_datasource.dart';
import 'package:saas/data/model/saas_authentication_type.dart';
import 'package:saas/data/model/token_request.dart';
import 'package:saas/domain/exception/can_not_get_authentication_code.dart';
import 'package:saas/domain/repository/saas_authentication_repository.dart';
import 'package:saas/domain/utils/code_challenge_generator.dart';
import 'package:saas/domain/utils/code_verifier_generator.dart';

class SaasAuthenticationRepositoryImpl extends SaasAuthenticationRepository {
  final _saasRedirectScheme = 'twake.mail';
  final _sessionStateUrlPath = 'loginToken';
  final _openIdDiscoveryEndpoint = '/.well-known/openid-configuration';
  final _postRegisteredRedirectUrlPath = 'post_registered_redirect_url';
  final _postLoginRedirectUrlPath = 'post_login_redirect_url';

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
    return _saasAuthenticate(registrationSiteUrl, clientId, redirectQueryParameter, SaasAuthenticationType.SignUp);
  }

  @override
  Future<TokenOIDC> signIn(Uri registrationSiteUrl, String clientId, String redirectQueryParameter) {
    return _saasAuthenticate(registrationSiteUrl, clientId, redirectQueryParameter, SaasAuthenticationType.SignIn);
  }

  Future<TokenOIDC> _saasAuthenticate(
    Uri registrationSiteUrl,
    String clientId,
    String redirectQueryParameter,
    SaasAuthenticationType authenticationType
  ) async {
    final verifierCode = _codeVerifierGenerator.generateCodeVerifier(Random.secure(), 64);
    log('SaasAuthenticationRepositoryImpl::_saasAuthenticate(): verifierCode: $verifierCode');
    final codeChallenge = _codeChallengeGenerator.generateCodeChallenge(verifierCode);
    log('SaasAuthenticationRepositoryImpl::_saasAuthenticate(): codeChallenge: $codeChallenge');

    final authenticationUrl = _generateAuthenticationUrl(
      registrationSiteUrl: registrationSiteUrl,
      clientId: clientId,
      redirectParameter: redirectQueryParameter,
      codeChallenge: codeChallenge,
      authenticationType: authenticationType
    );

    final uri = await FlutterWebAuth2.authenticate(
      url: authenticationUrl,
      callbackUrlScheme: _saasRedirectScheme,
      options: const FlutterWebAuth2Options(
        intentFlags: ephemeralIntentFlags,
      ),
    );

    log('SaasAuthenticationRepositoryImpl::_saasAuthenticate(): uri: $uri');

    final authenticationCode = Uri.parse(uri).queryParameters[_sessionStateUrlPath];
    if (authenticationCode == null || authenticationCode.isEmpty) {
      throw CanNotGetAuthenticationCodeException();
    }
    log('SaasAuthenticationRepositoryImpl::_saasAuthenticate(): authenticationCode: $authenticationCode');

    final openIdConfiguration = await discoverOpenIdConfiguration(registrationSiteUrl);
    log('SaasAuthenticationRepositoryImpl::_saasAuthenticate(): openIdConfiguration: $openIdConfiguration');

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

  String _generateAuthenticationUrl({
    required Uri registrationSiteUrl,
    required String clientId,
    required String redirectParameter,
    required String codeChallenge,
    required SaasAuthenticationType authenticationType
  }) {
    log('SaasAuthenticationRepositoryImpl::_generateAuthenticationUrl(): $registrationSiteUrl');
    _verifyRegistrationUrl(registrationSiteUrl);

    final authenticationUrl = '${_appendRedirectParam(registrationSiteUrl, redirectParameter, authenticationType)}'
        '&client_id=$clientId'
        '&challenge_code=$codeChallenge';
    log('SaasAuthenticationRepositoryImpl::_generateAuthenticationUrl(): AuthenticationUrl - $authenticationUrl');

    return authenticationUrl;
  }

  @override
  Future<OpenIdConfiguration> discoverOpenIdConfiguration(Uri registrationSiteUrl) {
    log('SaasAuthenticationRepositoryImpl::discoverOpenIdConfiguration(): registrationSiteUrl: $registrationSiteUrl');
    _verifyRegistrationUrl(registrationSiteUrl);
    final discoveryUrl = '${registrationSiteUrl.origin}$_openIdDiscoveryEndpoint';
    return _oAuthDataSource.discoverOpenIdConfiguration(discoveryUrl);
  }

  String _generateRedirectUrl(Uri registrationSiteUrl, String redirectQueryParameter) {
    if (PlatformInfo.isWeb) {
      _verifyRegistrationUrl(registrationSiteUrl);
      return 'dmm';
    } else {
      return redirectQueryParameter;
    }
  }

  void _verifyRegistrationUrl(Uri registrationSiteUrl) {
    if (!registrationSiteUrl.isScheme('https') && !registrationSiteUrl.isScheme('http')) {
      throw Exception('Login url must be https or http');
    }
  }

  String _appendRedirectParam(Uri registrationSiteUrl, String redirectParameter, SaasAuthenticationType authenticationType) {
    if (authenticationType == SaasAuthenticationType.SignUp) {
      return '${registrationSiteUrl.origin}?$_postRegisteredRedirectUrlPath=$redirectParameter';
    } else {
      return '${registrationSiteUrl.origin}?$_postLoginRedirectUrlPath=$redirectParameter';
    }
  }
}
