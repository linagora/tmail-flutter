import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailReceiveTimeType {
  anyTime,
  last7Days,
  last30Days,
  last6Months,
  lastYears,
}

extension EmailReceiveTimeTypeExtension on EmailReceiveTimeType {

  String getTitle(BuildContext context) {
    switch(this) {
      case EmailReceiveTimeType.anyTime:
        return AppLocalizations.of(context).anyTime;
      case EmailReceiveTimeType.last7Days:
        return AppLocalizations.of(context).last7Days;
      case EmailReceiveTimeType.last30Days:
        return AppLocalizations.of(context).last30Days;
      case EmailReceiveTimeType.last6Months:
        return AppLocalizations.of(context).last6Months;
      case EmailReceiveTimeType.lastYears:
        return AppLocalizations.of(context).lastYear;
    }
  }

  UTCDate? toUTCDate() {
    switch(this) {
      case EmailReceiveTimeType.anyTime:
        return null;
      case EmailReceiveTimeType.last7Days:
        return UTCDate(DateTime.now().subtract(const Duration(days: 7)));
      case EmailReceiveTimeType.last30Days:
        return UTCDate(DateTime.now().subtract(const Duration(days: 30)));
      case EmailReceiveTimeType.last6Months:
        return UTCDate(DateTime.now().subtract(const Duration(days: 180)));
      case EmailReceiveTimeType.lastYears:
        return UTCDate(DateTime.now().subtract(const Duration(days: 365)));
    }
  }
}