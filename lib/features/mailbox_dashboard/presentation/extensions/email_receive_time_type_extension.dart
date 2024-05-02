
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension EmailReeiveTimeTypeExtension on EmailReceiveTimeType {

  String getTitle(BuildContext context, {DateTime? startDate, DateTime? endDate}) {
    switch(this) {
      case EmailReceiveTimeType.allTime:
        return AppLocalizations.of(context).allTime;
      case EmailReceiveTimeType.last7Days:
        return AppLocalizations.of(context).last7Days;
      case EmailReceiveTimeType.last30Days:
        return AppLocalizations.of(context).last30Days;
      case EmailReceiveTimeType.last6Months:
        return AppLocalizations.of(context).last6Months;
      case EmailReceiveTimeType.lastYear:
        return AppLocalizations.of(context).lastYears;
      case EmailReceiveTimeType.customRange:
        if (startDate != null && endDate != null) {
          final startDateString = startDate.formatDate(pattern: 'yyyy-dd-MM');
          final endDateString = endDate.formatDate(pattern: 'yyyy-dd-MM');
          return AppLocalizations.of(context).dateRangeAdvancedSearchFilter(
            startDateString,
            endDateString);
        } else {
          return AppLocalizations.of(context).customRange;
        }
    }
  }
}