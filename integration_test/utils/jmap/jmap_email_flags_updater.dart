import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/query/query_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:model/model.dart';

import 'jmap_test_client.dart';

/// Changes read/star flags of emails found by subject, as another client would.
class JmapEmailFlagsUpdater {
  Future<void> update({
    required List<String> subjects,
    bool? isRead,
    bool? isStar,
  }) async {
    final client = await JmapTestClient.current();
    final emailIds = await _findEmailIds(client, subjects);
    // One Set per flag: updates are keyed by email id, so a second flag would overwrite the first.
    if (isRead != null) {
      await _set(client, emailIds.generateMapUpdateObjectMarkAsRead(
        isRead ? ReadActions.markAsRead : ReadActions.markAsUnread,
      ));
    }
    if (isStar != null) {
      await _set(client, emailIds.generateMapUpdateObjectMarkAsStar(
        isStar ? MarkStarAction.markStar : MarkStarAction.unMarkStar,
      ));
    }
  }

  Future<void> _set(JmapTestClient client, Map<Id, PatchObject> updates) async {
    final response = await client.execute(
      SetEmailMethod(client.accountId)..addUpdates(updates),
      SetEmailResponse.deserialize,
    );
    if (!(response.updated?.keys.toSet() ?? {}).containsAll(updates.keys)) {
      throw StateError('flags: not updated: ${response.notUpdated}');
    }
  }

  Future<List<EmailId>> _findEmailIds(JmapTestClient client, List<String> subjects) async {
    // The current mailbox in these scenarios is the Inbox; a self-sent mail also has a Sent copy.
    final inboxId = await client.mailboxIdByRole(PresentationMailbox.roleInbox);
    final emailIds = <EmailId>[];
    for (final subject in subjects.toSet()) {
      final query = await client.execute(
        QueryEmailMethod(client.accountId)
          ..addFilters(EmailFilterCondition(inMailbox: inboxId, subject: subject))
          ..addLimit(UnsignedInt(50)),
        QueryEmailResponse.deserialize,
      );
      final get = await client.execute(
        GetEmailMethod(client.accountId)
          ..addIds(query.ids)
          ..addProperties(Properties({'id', 'subject'})),
        GetEmailResponse.deserialize,
      );
      // The filter matches substrings, so keep exact subjects only.
      final matched = get.list.where((email) => email.subject == subject);
      if (matched.isEmpty) {
        throw StateError('flags: subject not found: "$subject"');
      }
      emailIds.addAll(matched.map((email) => email.id!));
    }
    return emailIds;
  }
}
