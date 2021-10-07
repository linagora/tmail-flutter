import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';

abstract class MailboxDataSource {
  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties});

  Future<List<Mailbox>> getAllMailboxCache();

  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState);

  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed});
}