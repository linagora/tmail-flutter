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

    group('WHEN startDate is null (no snapshotted bound)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided (no bound to compare against)',
      () {
        final yesterday = UTCDate(DateTime.now().subtract(const Duration(days: 1)));
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, yesterday);
        expect(result, equals(yesterday));
      });

      test(
        'SHOULD return loadMoreDate even when it is very old (null bound never rejects cursor)',
      () {
        final thirtyDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 30)));
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, thirtyDaysAgo);
        expect(result, equals(thirtyDaysAgo));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.last7Days.getAfterDate(null, null);
        expect(result, isNull);
      });

      test(
        'SHOULD return null WHEN both startDate and loadMoreDate are null for last30Days',
      () {
        final result = EmailReceiveTimeType.last30Days.getAfterDate(null, null);
        expect(result, isNull);
      });

      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided for last30Days',
      () {
        final tenDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 10)));
        final result = EmailReceiveTimeType.last30Days.getAfterDate(null, tenDaysAgo);
        expect(result, equals(tenDaysAgo));
      });
    });

    group('WHEN startDate is explicitly provided for last7Days (snapshotted bound + cursor)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is after startDate',
      () {
        final result = EmailReceiveTimeType.last7Days.getAfterDate(older, newer);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return startDate WHEN loadMoreDate is before startDate',
      () {
        final result = EmailReceiveTimeType.last7Days.getAfterDate(newer, older);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return startDate WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last7Days.getAfterDate(older, null);
        expect(result, equals(older));
      });
    });

    group('WHEN customRange AND startDate is null', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided',
      () {
        final result = EmailReceiveTimeType.customRange.getAfterDate(null, newer);
        expect(result, equals(newer));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.customRange.getAfterDate(null, null);
        expect(result, isNull);
      });
    });
  });

  group('EmailReceiveTimeType::toDateRange', () {
    // Anchor expectations to `result.end`, which captures the same `now` that
    // `toDateRange()` used internally. Reading `DateTime.now()` independently
    // would make these tests flaky around day/month boundaries.
    void expectStartMonth(EmailReceiveTimeType type, int monthsAgo) {
      final result = type.toDateRange();
      final now = result.end!.value.toLocal();
      final startLocal = result.start!.value.toLocal();
      final expected = DateTime(now.year, now.month - monthsAgo, 1);
      expect(startLocal.month, equals(expected.month));
      expect(startLocal.year, equals(expected.year));
    }

    void expectClampedDay(EmailReceiveTimeType type) {
      final result = type.toDateRange();
      final now = result.end!.value.toLocal();
      final startLocal = result.start!.value.toLocal();
      final lastDay = DateTime(startLocal.year, startLocal.month + 1, 0).day;
      final expectedDay = now.day > lastDay ? lastDay : now.day;
      expect(startLocal.day, equals(expectedDay));
    }

    group('last6Months', () {
      test(
        'SHOULD place start in the correct month 6 months ago',
        () => expectStartMonth(EmailReceiveTimeType.last6Months, 6),
      );

      test(
        'SHOULD clamp day to last day of target month so it never overflows',
        () => expectClampedDay(EmailReceiveTimeType.last6Months),
      );
    });

    group('lastYear', () {
      test(
        'SHOULD place start in the correct month 12 months ago',
        () => expectStartMonth(EmailReceiveTimeType.lastYear, 12),
      );

      test(
        'SHOULD clamp day to last day of target month so it never overflows',
        () => expectClampedDay(EmailReceiveTimeType.lastYear),
      );
    });

    group('last1Year', () {
      test(
        'SHOULD place start in the correct month 12 months ago, same as lastYear',
        () => expectStartMonth(EmailReceiveTimeType.last1Year, 12),
      );

      test(
        'SHOULD clamp day to last day of target month so it never overflows',
        () => expectClampedDay(EmailReceiveTimeType.last1Year),
      );
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

    group('WHEN endDate is null (no snapshotted bound)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided (no bound to compare against)',
      () {
        final yesterday = UTCDate(DateTime.now().subtract(const Duration(days: 1)));
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(null, yesterday);
        expect(result, equals(yesterday));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(null, null);
        expect(result, isNull);
      });

      test(
        'SHOULD return null WHEN both endDate and loadMoreDate are null for last30Days',
      () {
        final result = EmailReceiveTimeType.last30Days.getBeforeDate(null, null);
        expect(result, isNull);
      });

      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided for last30Days',
      () {
        final fiveDaysAgo = UTCDate(DateTime.now().subtract(const Duration(days: 5)));
        final result = EmailReceiveTimeType.last30Days.getBeforeDate(null, fiveDaysAgo);
        expect(result, equals(fiveDaysAgo));
      });
    });

    group('WHEN endDate is explicitly provided for last7Days (snapshotted bound + cursor)', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is before endDate',
      () {
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(newer, older);
        expect(result, equals(older));
      });

      test(
        'SHOULD return endDate WHEN loadMoreDate is after endDate',
      () {
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(older, newer);
        expect(result, equals(older));
      });

      test(
        'SHOULD return endDate WHEN loadMoreDate is null',
      () {
        final result = EmailReceiveTimeType.last7Days.getBeforeDate(newer, null);
        expect(result, equals(newer));
      });
    });

    group('WHEN customRange AND endDate is null', () {
      test(
        'SHOULD return loadMoreDate WHEN loadMoreDate is provided',
      () {
        final result = EmailReceiveTimeType.customRange.getBeforeDate(null, older);
        expect(result, equals(older));
      });

      test(
        'SHOULD return null WHEN loadMoreDate is also null',
      () {
        final result = EmailReceiveTimeType.customRange.getBeforeDate(null, null);
        expect(result, isNull);
      });
    });
  });
}
