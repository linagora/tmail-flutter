
import 'dart:convert';

import 'package:jmap_dart_client/http/converter/email_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/identities/identity_id_nullable_converter.dart';
import 'package:jmap_dart_client/http/converter/mailbox_id_nullable_converter.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

extension SendingEmailHiveCacheExtension on SendingEmailHiveCache {

  SendingEmail toSendingEmail() {
    return SendingEmail(
      sendingId: sendingId,
      email: Email.fromJson(jsonDecode(email)),
      emailActionType: EmailActionType.values.firstWhere((value) => value.name == emailActionType),
      createTime: createTime,
      sentMailboxId: const MailboxIdNullableConverter().fromJson(sentMailboxId),
      emailIdDestroyed: const EmailIdNullableConverter().fromJson(emailIdDestroyed),
      emailIdAnsweredOrForwarded: const EmailIdNullableConverter().fromJson(emailIdAnsweredOrForwarded),
      identityId: const IdentityIdNullableConverter().fromJson(identityId),
      sendingState: SendingState.values.firstWhere((value) => value.name == sendingState),
      previousEmailId: const EmailIdNullableConverter().fromJson(previousEmailId),
    );
  }
}