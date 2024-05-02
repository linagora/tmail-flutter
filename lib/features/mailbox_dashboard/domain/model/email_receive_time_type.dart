import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';

enum EmailReceiveTimeType {
  allTime,
  last7Days,
  last30Days,
  last6Months,
  lastYear,
  customRange;

  UTCDate? toOldestUTCDate() {
    switch(this) {
      case EmailReceiveTimeType.last7Days:
        final today = DateTime.now();
        final last7Days = today.subtract(const Duration(days: 7));
        return last7Days.toUTCDate();
      case EmailReceiveTimeType.last30Days:
        final today = DateTime.now();
        final last30Days = today.subtract(const Duration(days: 30));
        return last30Days.toUTCDate();
      case EmailReceiveTimeType.last6Months:
        final today = DateTime.now();
        final last6months = DateTime(today.year, today.month - 6, today.day);
        return last6months.toUTCDate();
      case EmailReceiveTimeType.lastYear:
        final today = DateTime.now();
        final lastYear = DateTime(today.year - 1, today.month, today.day);
        return lastYear.toUTCDate();
      default:
        return null;
    }
  }

  UTCDate? toLatestUTCDate() {
    switch(this) {
      case EmailReceiveTimeType.last7Days:
      case EmailReceiveTimeType.last30Days:
      case EmailReceiveTimeType.last6Months:
      case EmailReceiveTimeType.lastYear:
        return DateTime.now().toUTCDate();
      default:
        return null;
    }
  }

  UTCDate? getAfterDate(UTCDate? startDate) {
    if (startDate != null) {
      return startDate;
    } else {
      return toOldestUTCDate();
    }
  }

  UTCDate? getBeforeDate(UTCDate? endDate, UTCDate? loadMoreDate) {
    if (endDate != null) {
      if (loadMoreDate != null && loadMoreDate.value.isBefore(endDate.value)) {
        return loadMoreDate;
      } else {
        return endDate;
      }
    } else {
      final latestDate = toLatestUTCDate();
      if (latestDate != null) {
        if (loadMoreDate != null && loadMoreDate.value.isBefore(latestDate.value)) {
          return loadMoreDate;
        } else {
          return latestDate;
        }
      } else {
        return loadMoreDate;
      }
    }
  }
}
