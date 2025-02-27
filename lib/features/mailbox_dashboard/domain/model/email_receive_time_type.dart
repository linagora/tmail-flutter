
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailReceiveTimeType {
  allTime,
  last7Days,
  last30Days,
  last6Months,
  lastYear,
  customRange;

  String getTitle(BuildContext context, {DateTime? startDate, DateTime? endDate}) {
    return getTitleByAppLocalizations(
      AppLocalizations.of(context),
      startDate: startDate,
      endDate: endDate,
    );
  }

  String getTitleByAppLocalizations(
    AppLocalizations appLocalizations,
    {
      DateTime? startDate,
      DateTime? endDate,
    }
  ) {
    switch(this) {
      case EmailReceiveTimeType.allTime:
        return appLocalizations.allTime;
      case EmailReceiveTimeType.last7Days:
        return appLocalizations.last7Days;
      case EmailReceiveTimeType.last30Days:
        return appLocalizations.last30Days;
      case EmailReceiveTimeType.last6Months:
        return appLocalizations.last6Months;
      case EmailReceiveTimeType.lastYear:
        return appLocalizations.lastYears;
      case EmailReceiveTimeType.customRange:
        if (startDate != null && endDate != null) {
          final startDateString = startDate.formatDate(pattern: 'yyyy-dd-MM');
          final endDateString = endDate.formatDate(pattern: 'yyyy-dd-MM');
          return appLocalizations.dateRangeAdvancedSearchFilter(
            startDateString,
            endDateString,
          );
        } else {
          return appLocalizations.customRange;
        }
    }
  }

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
