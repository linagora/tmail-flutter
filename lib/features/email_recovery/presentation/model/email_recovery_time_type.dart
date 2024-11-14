import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

enum EmailRecoveryTimeType {
  allTime,
  last7Days,
  last15Days,
  last30Days,
  last6Months,
  last1Year,
  lastYear,
  customRange;

  String getTitle(BuildContext context, {DateTime? startDate, DateTime? endDate}) {
    switch(this) {
      case EmailRecoveryTimeType.allTime:
        return AppLocalizations.of(context).allTime;
      case EmailRecoveryTimeType.last7Days:
        return AppLocalizations.of(context).last7Days;
      case EmailRecoveryTimeType.last15Days:
        return AppLocalizations.of(context).last15Days;
      case EmailRecoveryTimeType.last30Days:
        return AppLocalizations.of(context).last30Days;
      case EmailRecoveryTimeType.last6Months:
        return AppLocalizations.of(context).last6Months;
      case EmailRecoveryTimeType.last1Year:
        return AppLocalizations.of(context).last1Year;
      case EmailRecoveryTimeType.lastYear:
        return AppLocalizations.of(context).lastYears;
      case EmailRecoveryTimeType.customRange:
        if (startDate != null && endDate != null) {
          final startDateString = startDate.formatDate(pattern: 'yyyy-dd-MM');
          final endDateString = endDate.formatDate(pattern: 'yyyy-dd-MM');
          return AppLocalizations.of(context).dateRangeAdvancedSearchFilter(
            startDateString,
            endDateString
          );
        } else {
          return AppLocalizations.of(context).customRange;
        }
      
    }
  }

  UTCDate? toOldestUTCDate() {
    switch(this) {
      case EmailRecoveryTimeType.last7Days:
        final today = DateTime.now();
        final last7Days = today.subtract(const Duration(days: 7));
        return last7Days.toUTCDate();
      case EmailRecoveryTimeType.last15Days:
        final today = DateTime.now();
        final last15Days = today.subtract(const Duration(days: 15));
        return last15Days.toUTCDate();
      case EmailRecoveryTimeType.last30Days:
        final today = DateTime.now();
        final last30Days = today.subtract(const Duration(days: 30));
        return last30Days.toUTCDate();
      case EmailRecoveryTimeType.last6Months:
        final today = DateTime.now();
        final last6months = DateTime(today.year, today.month - 6, today.day);
        return last6months.toUTCDate();
      case EmailRecoveryTimeType.last1Year:
      case EmailRecoveryTimeType.lastYear:
        final today = DateTime.now();
        final lastYear = DateTime(today.year - 1, today.month, today.day);
        return lastYear.toUTCDate();
      default:
        return null;
    }
  }

  UTCDate? toLatestUTCDate() {
    switch(this) {
      case EmailRecoveryTimeType.last7Days:
      case EmailRecoveryTimeType.last15Days:
      case EmailRecoveryTimeType.last30Days:
      case EmailRecoveryTimeType.last6Months:
      case EmailRecoveryTimeType.last1Year:
      case EmailRecoveryTimeType.lastYear:
        final today = DateTime.now();
        return today.toUTCDate();
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

  UTCDate? getBeforeDate(UTCDate? endDate) {
    if (endDate != null) {
      return endDate;
    } else {
      return toLatestUTCDate();
    }
  }
}