
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailReceiveTimeType {
  allTime,
  last7Days,
  last15Days,
  last30Days,
  last6Months,
  last1Year,
  lastYear,
  customRange;

  static List<EmailReceiveTimeType> get valuesForSearch => [
    allTime,
    last7Days,
    last30Days,
    last6Months,
    lastYear,
    customRange,
  ];

  static List<EmailReceiveTimeType> get valuesForRecoverDeletionDateField => [
    last7Days,
    last15Days,
    last30Days,
    last6Months,
    last1Year,
  ];

  static List<EmailReceiveTimeType> get valuesForRecoverReceptionDateDateField => [
    allTime,
    last7Days,
    last30Days,
    last6Months,
    lastYear,
    customRange,
  ];

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
      case EmailReceiveTimeType.last15Days:
        return appLocalizations.last15Days;
      case EmailReceiveTimeType.last30Days:
        return appLocalizations.last30Days;
      case EmailReceiveTimeType.last6Months:
        return appLocalizations.last6Months;
      case EmailReceiveTimeType.last1Year:
        return appLocalizations.last1Year;
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

  ({UTCDate? start, UTCDate? end}) toDateRange() {
    final now = DateTime.now();
    final end = now.toUTCDate();

    switch (this) {
      case EmailReceiveTimeType.last7Days:
        return (start: now
            .subtract(const Duration(days: 7))
            .toUTCDate(), end: end);

      case EmailReceiveTimeType.last15Days:
        return (start: now
            .subtract(const Duration(days: 15))
            .toUTCDate(), end: end);

      case EmailReceiveTimeType.last30Days:
        return (start: now
            .subtract(const Duration(days: 30))
            .toUTCDate(), end: end);

      case EmailReceiveTimeType.last6Months:
        return (start: DateTime(now.year, now.month - 6, now.day)
            .toUTCDate(), end: end);

      case EmailReceiveTimeType.last1Year:
      case EmailReceiveTimeType.lastYear:
        return (start: DateTime(now.year - 1, now.month, now.day)
            .toUTCDate(), end: end);

      default:
        return (start: null, end: null);
    }
  }

  UTCDate? _pickCursorDate(
    UTCDate? bound,
    UTCDate? cursor,
    bool Function(DateTime, DateTime) cursorWins,
  ) {
    if (bound == null) return cursor;
    return (cursor != null && cursorWins(cursor.value, bound.value)) ? cursor : bound;
  }

  UTCDate? getAfterDate(UTCDate? startDate, UTCDate? loadMoreDate) =>
      _pickCursorDate(startDate, loadMoreDate, (a, b) => a.isAfter(b));

  UTCDate? getBeforeDate(UTCDate? endDate, UTCDate? loadMoreDate) =>
      _pickCursorDate(endDate, loadMoreDate, (a, b) => a.isBefore(b));
}
