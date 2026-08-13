import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';

void main() {
  group('getLabelList', () {
    test('returns empty when keywords is null', () {
      final email = PresentationEmail(keywords: null);
      final labels = [Label(keyword: KeyWordIdentifier.emailFlagged)];

      final result = email.getLabelList(labels);

      expect(result, isEmpty);
    });

    test('returns empty when keywords is empty', () {
      final email = PresentationEmail(keywords: {});
      final labels = [Label(keyword: KeyWordIdentifier.emailFlagged)];

      final result = email.getLabelList(labels);

      expect(result, isEmpty);
    });

    test('returns empty when labels is empty AND keywords are system-only', () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier.emailFlagged: true,
      });

      final result = email.getLabelList([]);

      expect(result, isEmpty);
    });

    test('returns empty when no enabled keywords', () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier.emailFlagged: false,
        KeyWordIdentifier.emailDraft: false,
      });

      final labels = [
        Label(keyword: KeyWordIdentifier.emailFlagged),
        Label(keyword: KeyWordIdentifier.emailDraft),
      ];

      final result = email.getLabelList(labels);

      expect(result, isEmpty);
    });

    test('returns only labels with enabled keywords', () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier.emailFlagged: true,
        KeyWordIdentifier.emailSeen: false,
        KeyWordIdentifier.emailDraft: true,
      });

      final labels = [
        Label(keyword: KeyWordIdentifier.emailFlagged),
        Label(keyword: KeyWordIdentifier.emailSeen),
        Label(keyword: KeyWordIdentifier.emailDraft),
      ];

      final result = email.getLabelList(labels);

      expect(result.length, 2);
      expect(
        result.map((l) => l.keyword),
        contains(KeyWordIdentifier.emailFlagged),
      );
      expect(
        result.map((l) => l.keyword),
        contains(KeyWordIdentifier.emailDraft),
      );
      expect(
        result.map((l) => l.keyword),
        isNot(contains(KeyWordIdentifier.emailSeen)),
      );
    });

    test('ignores labels where keyword is null', () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier.emailFlagged: true,
      });

      final labels = [
        Label(),
        Label(keyword: KeyWordIdentifier.emailFlagged),
      ];

      final result = email.getLabelList(labels);

      expect(result.length, 1);
      expect(result.first.keyword, KeyWordIdentifier.emailFlagged);
    });
  });

  group('getLabelList — JMAP standard keywords (RFC 8621)', () {
    // Ensures keywords set via `Email/set keywords` by any JMAP-compliant
    // tool (mail sentinel, filter, IMAP client) surface as visual chips,
    // even without a registered server-side `Label` object.

    test('surfaces custom keyword as orphan label when no matching Label exists',
        () {
      final newsletter = KeyWordIdentifier('newsletter');
      final email = PresentationEmail(keywords: {newsletter: true});

      final result = email.getLabelList([]);

      expect(result.length, 1);
      expect(result.first.keyword, newsletter);
      expect(result.first.displayName, 'newsletter');
      expect(result.first.id, isNull);
      // Orphan labels get a deterministic hash-based color from the tmail
      // palette (see KeyWordIdentifierExtension.deterministicHexColor).
      expect(result.first.color, isNotNull);
      expect(result.first.color!.value, matches(RegExp(r'^#[0-9A-Fa-f]{6}$')));
    });

    test('orphan color is deterministic — same keyword always same color', () {
      final urgent = KeyWordIdentifier('urgent');
      final email = PresentationEmail(keywords: {urgent: true});

      final r1 = email.getLabelList([]);
      final r2 = email.getLabelList([]);

      expect(r1.first.color!.value, equals(r2.first.color!.value));
    });

    test('filters out system keywords ($seen, $flagged, $draft, $junk, …)',
        () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier.emailSeen: true,
        KeyWordIdentifier.emailFlagged: true,
        KeyWordIdentifier.emailDraft: true,
        KeyWordIdentifier.emailAnswered: true,
        KeyWordIdentifier.emailForwarded: true,
        KeyWordIdentifier.emailPhishing: true,
        KeyWordIdentifier.emailJunk: true,
        KeyWordIdentifier.emailNotJunk: true,
        KeyWordIdentifier.mdnSent: true,
      });

      final result = email.getLabelList([]);

      expect(result, isEmpty);
    });

    test('registered label wins over orphan synthesis for same keyword', () {
      final newsletter = KeyWordIdentifier('newsletter');
      final email = PresentationEmail(keywords: {newsletter: true});
      final registered = Label(
        keyword: newsletter,
        displayName: 'My Newsletter',
      );

      final result = email.getLabelList([registered]);

      expect(result.length, 1);
      expect(result.first.displayName, 'My Newsletter'); // not "newsletter"
    });

    test('mixes registered + orphan + system-filtered', () {
      final github = KeyWordIdentifier('github');
      final invoice = KeyWordIdentifier('invoice');
      final email = PresentationEmail(keywords: {
        github: true,
        invoice: true,
        KeyWordIdentifier.emailFlagged: true, // system, filtered out
        KeyWordIdentifier.emailSeen: true, // system, filtered out
      });
      final registered = Label(keyword: github, displayName: 'GitHub');

      final result = email.getLabelList([registered]);

      // github (registered) + invoice (orphan) = 2
      expect(result.length, 2);
      final registeredLabel =
          result.firstWhere((l) => l.keyword?.value == 'github');
      expect(registeredLabel.displayName, 'GitHub');
      final orphanLabel =
          result.firstWhere((l) => l.keyword?.value == 'invoice');
      expect(orphanLabel.displayName, 'invoice');
      expect(orphanLabel.id, isNull);
    });

    test('orphan labels ignore disabled keywords', () {
      final email = PresentationEmail(keywords: {
        KeyWordIdentifier('active-label'): true,
        KeyWordIdentifier('disabled-label'): false,
      });

      final result = email.getLabelList([]);

      expect(result.length, 1);
      expect(result.first.keyword?.value, 'active-label');
    });
  });
}
