import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

void main() {
  group(
    'ListEmailInThreadDetailInfoExtension.findCommonLabelsInThread',
    () {
      final seen = KeyWordIdentifier.emailSeen;
      final flagged = KeyWordIdentifier.emailFlagged;
      final answered = KeyWordIdentifier.emailAnswered;

      Label label(KeyWordIdentifier keyword) => Label(
            keyword: keyword,
            displayName: keyword.value,
          );

      EmailInThreadDetailInfo email({
        required Map<KeyWordIdentifier, bool>? keywords,
        bool isValidToDisplay = true,
      }) {
        return EmailInThreadDetailInfo(
          emailId: EmailId(Id('email-${keywords.hashCode}')),
          keywords: keywords,
          mailboxIds: {MailboxId(Id('inbox')): true},
          isValidToDisplay: isValidToDisplay,
        );
      }

      test(
        'returns empty list when email list is empty',
        () {
          final result = <EmailInThreadDetailInfo>[].findCommonLabelsInThread(
            labels: [label(seen)],
          );

          expect(result, isEmpty);
        },
      );

      test(
        'returns empty list when labels list is empty',
        () {
          final emails = [
            email(keywords: {seen: true}),
          ];

          final result = emails.findCommonLabelsInThread(labels: []);

          expect(result, isEmpty);
        },
      );

      test(
        'returns only labels whose keyword appears in all valid emails',
        () {
          final emails = [
            email(
              keywords: {
                seen: true,
                flagged: true,
              },
            ),
            email(
              keywords: {
                seen: true,
                flagged: false,
              },
            ),
            email(
              keywords: {
                seen: true,
              },
            ),
          ];

          final labels = [
            label(seen),
            label(flagged),
            label(answered),
          ];

          final result = emails.findCommonLabelsInThread(labels: labels);

          expect(
            result.map((l) => l.keyword),
            equals([seen]),
          );
        },
      );

      test(
        'ignores emails that are not valid to display',
        () {
          final emails = [
            email(
              keywords: {
                seen: true,
                flagged: true,
              },
            ),
            email(
              keywords: {
                flagged: true,
              },
              isValidToDisplay: false,
            ),
            email(
              keywords: {
                seen: true,
              },
            ),
          ];

          final labels = [
            label(seen),
            label(flagged),
          ];

          final result = emails.findCommonLabelsInThread(labels: labels);

          expect(
            result.map((l) => l.keyword),
            equals([seen]),
          );
        },
      );

      test(
        'returns empty list when no common keyword exists',
        () {
          final emails = [
            email(
              keywords: {
                seen: true,
              },
            ),
            email(
              keywords: {
                flagged: true,
              },
            ),
          ];

          final labels = [
            label(seen),
            label(flagged),
          ];

          final result = emails.findCommonLabelsInThread(labels: labels);

          expect(result, isEmpty);
        },
      );

      test(
        'returns empty list when first valid email has no enabled keywords',
        () {
          final emails = [
            email(
              keywords: {
                seen: false,
                flagged: false,
              },
            ),
            email(
              keywords: {
                seen: true,
              },
            ),
          ];

          final labels = [
            label(seen),
            label(flagged),
          ];

          final result = emails.findCommonLabelsInThread(labels: labels);

          expect(result, isEmpty);
        },
      );

      test(
        'ignores labels with null keyword',
        () {
          final emails = [
            email(
              keywords: {
                seen: true,
              },
            ),
            email(
              keywords: {
                seen: true,
              },
            ),
          ];

          final labels = [
            Label(displayName: 'No keyword'),
            label(seen),
          ];

          final result = emails.findCommonLabelsInThread(labels: labels);

          expect(result.length, 1);
          expect(result.first.keyword, seen);
        },
      );
    },
  );
}
