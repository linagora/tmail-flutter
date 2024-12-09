
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

extension KeychainSharingSessionExtension on KeychainSharingSession {

  KeychainSharingSession updating({String? emailState, List<MailboxId>? mailboxIdsBlockNotification}) {
    return KeychainSharingSession(
      accountId: accountId,
      userName: userName,
      authenticationType: authenticationType,
      apiUrl: apiUrl,
      emailState: emailState ?? this.emailState,
      emailDeliveryState: emailDeliveryState,
      tokenOIDC: tokenOIDC,
      basicAuth: basicAuth,
      tokenEndpoint: tokenEndpoint,
      oidcScopes: oidcScopes,
      mailboxIdsBlockNotification: mailboxIdsBlockNotification ?? this.mailboxIdsBlockNotification,
      isTWP: isTWP,
    );
  }
}