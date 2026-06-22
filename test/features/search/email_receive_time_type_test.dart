import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

void main() {
  final older = UTCDate(DateTime.parse('2026-01-01T00:00:00.000Z'));
  final newer = UTCDate(DateTime.parse('2026-06-01T00:00:00.000Z'));

  group('EmailReceiveTimeType::getAfterDate', () {
    group('WHEN startDate is explicitly provided', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is after startDate',
      () {
        final result = EmailReceiveTimeType.allTime.getAfterDate(older, newer);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return startDate WHEN loadMoreDate is before startDate',
      () {
        final result = EmailReceiveTimeType.allTime.getAfterDate(newer, older);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return startDate WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.allTime.getAfterDate(older, null);
        expect(result, equals(older));
      });
    });

    group('WHEN startDate is null AND receiveTimeType is allTime (no oldest bound)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided',
      () {
        final result = EmailReceiveTimeType.allTime.getAfterDate(null, newer);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.allTime.getAfterDate(null, null);
        expect(result, isNull);
      });
    });

    group('WHEN startDate is null AND receiveTimeType is last7Days', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is after the 7-day boundary (cursor within range)',
      () {
        // Yesterday is more recent than "7 days ago" → cursor wins
        final yesterday = UTCDate(DateTime.now().subtract(const Duration(days: 1)));
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, yesterday);
        expect(result, equals(yesterday));
      });

      test(
        'SHOULD return the 7-day boundary WHEN loadMoreDate is before it (cursor outside range)',
      () {
        // 30 days ago is older than the 7-day boundary → boundary is returned
        final thirtyDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 30)));
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, thirtyDaysAgo);
        expect(result, isNotNull);
        expect(result, isNot(equals(thirtyDaysAgo)));
        expect(result!.value.isAfter(thirtyDaysAgo.value), isTrue);
      });

      test(
        'SHOULD return the 7-day boundary WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, null);
        expect(result, isNotNull);
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        expect(result!.value.difference(sevenDaysAgo).abs(), lessThan(const Duration(seconds: 2)));
      });
    });

    group('WHEN startDate is null AND receiveTimeType is last30Days', () {
      test(
        'SHOULD return the 30-day boundary WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last30Days.getAfterDate(null, null);
        expect(result, isNotNull);
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        expect(result!.value.difference(thirtyDaysAgo).abs(), lessThan(const Duration(seconds: 2)));
      });

      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is after the 30-day boundary',
      () {
        final tenDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 10)));
        final result = EmailReceiveTimeType.last30Days.getAfterDate(null, tenDaysAgo);
        expect(result, equals(tenDaysAgo));
      });
    });
  });

  group('EmailReceiveTimeType::getBeforeDate', () {
    group('WHEN endDate is explicitly provided', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is before endDate',
      () {
        final result = EmailReceiveTimeType.allTime.getBeforeDate(newer, older);
        expect(result, equals(older));
      });

      test(
        'SHOULD return endDate WHEN loadMoreDate is after endDate',
      () {
        final result = EmailReceiveTimeType.allTime.getBeforeDate(older, newer);
        expect(result, equals(older));
      });

      test(
        'SHOULD return endDate WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.allTime.getBeforeDate(newer, null);
        expect(result, equals(newer));
      });
    });

    group('WHEN endDate is null AND receiveTimeType is allTime (no latest bound)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided',
      () {
        final result = EmailReceiveTimeType.allTime.getBeforeDate(null, older);
        expect(result, equals(older));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.allTime.getBeforeDate(null, null);
        expect(result, isNull);
      });
    });

    group('WHEN endDate is null AND receiveTimeType is last7Days', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is before today (cursor within range)',
      () {
        final yesterday = UTCDate(DateTime.now().subtract(const Duration(days: 1)));
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(null, yesterday);
        expect(result, equals(yesterday));
      });

      test(
        'SHOULD return today (latest bound) WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(null, null);
        expect(result, isNotNull);
        final now = DateTime.now();
        expect(result!.value.difference(now).abs(), lessThan(const Duration(seconds: 2)));
      });
    });

    group('WHEN endDate is null AND receiveTimeType is last30Days', () {
      test(
        'SHOULD return today (latest bound) WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last30Days.getBeforeDate(null, null);
        expect(result, isNotNull);
        final now = DateTime.now();
        expect(result!.value.difference(now).abs(), lessThan(const Duration(seconds: 2)));
      });

      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is before today',
      () {
        final fiveDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 5)));
        final result = EmailReceiveTimeType.last30Days.getBeforeDate(null, fiveDaysAgo);
        expect(result, equals(fiveDaysAgo));
      });
    });
  });
}
