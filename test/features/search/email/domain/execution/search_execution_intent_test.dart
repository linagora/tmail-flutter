import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';

void main() {
  final cursorDate = UTCDate(DateTime.parse('2021-08-10T04:00:59Z'));
  final lastId = EmailId(Id('last'));

  group('LoadMoreIntent', () {
    test('accepts a positive currentCount', () {
      final intent = LoadMoreIntent(
        currentCount: 20,
        lastEmailDate: cursorDate,
        lastEmailId: lastId,
      );

      expect(intent.currentCount, 20);
      expect(intent.lastEmailDate, cursorDate);
      expect(intent.lastEmailId, lastId);
    });

    test('allows a null date cursor (degenerate but safe)', () {
      expect(
        () => LoadMoreIntent(
          currentCount: 1,
          lastEmailDate: null,
          lastEmailId: lastId,
        ),
        returnsNormally,
      );
    });

    test('rejects a non-positive currentCount so it can never refetch page 1', () {
      for (final count in [0, -1]) {
        expect(
          () => LoadMoreIntent(
            currentCount: count,
            lastEmailDate: cursorDate,
            lastEmailId: lastId,
          ),
          throwsArgumentError,
          reason: 'currentCount=$count must be rejected',
        );
      }
    });
  });
}
