
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

extension KeychainSharingSessionExtension on KeychainSharingSession {

  KeychainSharingSession updating({String? emailState}) {
    return KeychainSharingSession(
      accountId: accountId,
      userName: userName,
      authenticationType: authenticationType,
      apiUrl: apiUrl,
      emailState: emailState ?? emailState,
      emailDeliveryState: emailDeliveryState,
      tokenOIDC: tokenOIDC,
      basicAuth: basicAuth,
      tokenEndpoint: tokenEndpoint,
      oidcScopes: oidcScopes,
    );
  }
}