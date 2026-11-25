import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

import 'jmap_test_client.dart';

/// Creates a `text/plain` email in the Inbox through `Email/set`.
///
/// The composer always produces an HTML body, so it never reaches the
/// plain-text rendering path.
class JmapTextPlainEmailProvisioner {
  static final _createId = Id('text-plain-email');

  Future<void> create({required String subject, required String body}) async {
    final client = await JmapTestClient.current();
    final inboxId = await client.mailboxIdByRole(PresentationMailbox.roleInbox);
    final partId = PartId('1');
    final method = SetEmailMethod(client.accountId)
      ..addCreate(
        _createId,
        Email(
          mailboxIds: {inboxId: true},
          from: {EmailAddress('sender', 'sender@example.com')},
          subject: subject,
          receivedAt: UTCDate(DateTime.now().toUtc()),
          textBody: {
            EmailBodyPart(partId: partId, type: MediaType('text', 'plain')),
          },
          bodyValues: {
            partId: EmailBodyValue(
              value: body,
              isEncodingProblem: false,
              isTruncated: false,
            ),
          },
        ),
      );
    final response = await client.execute(method, SetEmailResponse.deserialize);
    if (response.created?[_createId] == null) {
      throw StateError('provisioning failed: ${response.notCreated}');
    }
  }
}
