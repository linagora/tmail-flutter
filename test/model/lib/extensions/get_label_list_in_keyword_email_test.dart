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

    test('returns empty when labels is empty', () {
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
}
