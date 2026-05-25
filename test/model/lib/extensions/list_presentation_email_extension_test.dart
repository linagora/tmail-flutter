import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';

PresentationEmail _makeEmail({
  required String id,
  DateTime? receivedAt,
}) {
  return PresentationEmail(
    id: EmailId(Id(id)),
    receivedAt: receivedAt != null ? UTCDate(receivedAt) : null,
  );
}

/// Generates [count] emails ordered oldest-to-newest (1 hour apart each).
List<PresentationEmail> _makeSequentialEmails(int count) {
  return List.generate(
    count,
    (i) => _makeEmail(
      id: 'e$i',
      receivedAt: DateTime(2024, 1, 1).add(Duration(hours: i)),
    ),
  );
}

void main() {
  group('selectEmailsForNotification:', () {
    test('returns empty list when input is empty', () {
      final result = <PresentationEmail>[].selectEmailsForNotification();
      expect(result, isEmpty);
    });

    test('returns empty list when maxNotifications is 0', () {
      final result = _makeSequentialEmails(5).selectEmailsForNotification(maxNotifications: 0);
      expect(result, isEmpty);
    });

    test('returns all emails when count is below maxNotifications', () {
      final result = _makeSequentialEmails(5).selectEmailsForNotification();
      expect(result.length, 5);
    });

    test('caps at maxNotifications and selects the newest emails', () {
      final emails = _makeSequentialEmails(50);
      final result = emails.selectEmailsForNotification();
      expect(result.length, 20);
      // highest-index emails are newest (e49..e30)
      final resultIds = result.map((e) => e.id?.id.value).toSet();
      for (var i = 30; i < 50; i++) {
        expect(resultIds, contains('e$i'));
      }
    });

    test('respects custom maxNotifications', () {
      final result = _makeSequentialEmails(30).selectEmailsForNotification(maxNotifications: 10);
      expect(result.length, 10);
    });

    test('returns emails sorted newest first', () {
      final older = _makeEmail(id: 'older', receivedAt: DateTime(2024, 1, 1));
      final newer = _makeEmail(id: 'newer', receivedAt: DateTime(2024, 1, 3));
      final middle = _makeEmail(id: 'middle', receivedAt: DateTime(2024, 1, 2));
      final result = [older, middle, newer].selectEmailsForNotification();
      expect(result.map((e) => e.id?.id.value).toList(), ['newer', 'middle', 'older']);
    });
  });
}
