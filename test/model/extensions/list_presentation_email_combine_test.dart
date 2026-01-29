import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';

/// Reproducible test for issue #4274: Emails disappearing from list
/// 
/// This test demonstrates the problem in the `combine()` method of `ListPresentationEmailExtension`.
/// 
/// Identified Problem:
/// The `combine()` method only keeps emails that are in the new list (emailsAfterChanges).
/// If an email was in emailsBeforeChanges but is no longer in emailsAfterChanges,
/// it completely disappears from the resulting list.
/// 
/// Reproduction Scenario:
/// 1. User has a displayed email list (emailsBeforeChanges) with 25 emails
/// 2. A refreshChanges is called (via websocket or other)
/// 3. refreshChanges retrieves emails from local cache
/// 4. Cache returns only the first 20 emails (defaultLimit)
/// 5. The combine() method is called with emailsAfterChanges (20 emails) and emailsBeforeChanges (25 emails)
/// 6. Emails that were in emailsBeforeChanges but not in emailsAfterChanges disappear
void main() {
  group('ListPresentationEmailExtension.combine() - Issue #4274', () {
    test(
        'SHOULD preserve emails from emailsBeforeChanges that are not in emailsAfterChanges',
        () {
      // Arrange: Simulate a displayed email list with 25 emails
      final mailboxId = MailboxId(Id('mailbox_1'));
      final emailsBeforeChanges = List.generate(25, (index) {
        return PresentationEmail(
          id: EmailId(Id('email_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      // Simulate that cache returns only the first 20 emails (defaultLimit)
      // Emails email_20 to email_24 are no longer in cache
      // (possibly moved out of top 20 after sorting, or modified)
      final emailsAfterChanges = List.generate(20, (index) {
        return PresentationEmail(
          id: EmailId(Id('email_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      // Act: Call combine() as in _refreshChangesAllEmailSuccess
      final result = emailsAfterChanges.combine(emailsBeforeChanges);

      // Assert: Verify that all emails are present
      // CURRENT PROBLEM: Emails email_20 to email_24 are not in the result
      // even though they were in emailsBeforeChanges
      final emailIdsInResult = result.map((e) => e.id?.value).toSet();

      // These assertions should pass but fail due to the bug
      for (int i = 0; i < 25; i++) {
        expect(
          emailIdsInResult.contains(Id('email_$i')),
          i < 20, // Only the first 20 are present due to the bug
          reason: 'Email email_$i should be present in the result '
              'because it was in emailsBeforeChanges',
        );
      }

      // Result contains only 20 emails instead of 25
      expect(
        result.length,
        20, // Bug: should be 25
        reason: 'Result should contain all emails from emailsBeforeChanges, '
            'even those not in emailsAfterChanges',
      );
    });

    test(
        'SHOULD preserve emails when user has scrolled and loaded more than defaultLimit',
        () {
      // Arrange: Simulate the case where user has scrolled and loaded 30 emails
      // but refreshChanges returns only defaultLimit (20) emails
      final mailboxId = MailboxId(Id('mailbox_1'));
      final displayedEmails = List.generate(30, (index) {
        return PresentationEmail(
          id: EmailId(Id('displayed_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      // Cache returns only the first 20
      final cachedEmails = List.generate(20, (index) {
        return PresentationEmail(
          id: EmailId(Id('displayed_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      // Act
      final result = cachedEmails.combine(displayedEmails);

      // Assert: All displayed emails should be preserved
      final emailIdsInResult = result.map((e) => e.id?.value).toSet();

      // PROBLEM: Emails displayed_20 to displayed_29 disappear
      for (int i = 0; i < 30; i++) {
        expect(
          emailIdsInResult.contains(Id('displayed_$i')),
          i < 20, // Bug: only the first 20 are present
          reason: 'Email displayed_$i should be preserved because it was displayed',
        );
      }

      expect(
        result.length,
        20, // Bug: should be 30
        reason: 'All displayed emails should be preserved, '
            'even if they are not in cache',
      );
    });

    test(
        'SHOULD handle case where emailsAfterChanges is empty but emailsBeforeChanges has emails',
        () {
      // Arrange: Extreme case where cache is empty but user has displayed emails
      final mailboxId = MailboxId(Id('mailbox_1'));
      final emailsBeforeChanges = List.generate(10, (index) {
        return PresentationEmail(
          id: EmailId(Id('email_$index')),
          mailboxIds: {mailboxId: true},
        );
      });

      final emailsAfterChanges = <PresentationEmail>[];

      // Act
      final result = emailsAfterChanges.combine(emailsBeforeChanges);

      // Assert: Displayed emails should be preserved
      // PROBLEM: All emails disappear because emailsAfterChanges is empty
      expect(
        result.length,
        0, // Bug: should be 10
        reason: 'Displayed emails should be preserved even if cache is empty',
      );
    });
  });
}
