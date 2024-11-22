import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_action_type.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class OpenAppDeepLinkData extends DeepLinkData {
  final String registrationUrl;
  final String jmapUrl;
  final String username;
  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiresIn;

  OpenAppDeepLinkData({
    super.actionType = DeepLinkActionType.openApp,
    required this.registrationUrl,
    required this.jmapUrl,
    required this.username,
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresIn,
  });

  bool isValidAuthentication() =>
      accessToken.isNotEmpty &&
      username.isNotEmpty &&
      registrationUrl.isNotEmpty &&
      jmapUrl.isNotEmpty;

  DateTime? _getExpiredTime() {
    return expiresIn != null
        ? DateTime.now().add(Duration(seconds: expiresIn!))
        : null;
  }

  bool isLoggedInWith(String currentUsername) => username == currentUsername;

  TokenOIDC get tokenOIDC {
    return TokenOIDC(
      accessToken,
      TokenId(idToken ?? ''),
      refreshToken ?? '',
      expiredTime: _getExpiredTime(),
    );
  }

  Uri get baseUri => Uri.parse(jmapUrl);

  OIDCConfiguration get oidcConfiguration => OIDCConfiguration(
    authority: registrationUrl,
    clientId: OIDCConstant.clientId,
    scopes: AppConfig.oidcScopes,
    isTWP: true,
  );

  @override
  List<Object?> get props => [
    ...super.props,
    registrationUrl,
    jmapUrl,
    username,
    accessToken,
    refreshToken,
    idToken,
    expiresIn,
  ];
}
