import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

extension DateTimeExtension on DateTime? {

  String formatDate({String pattern = 'yyyy/MM/dd', String locale = 'en_US'}) {
    if (this != null) {
      return DateFormat(pattern, locale).format(this!);
    } else {
      return '';
    }
  }

  DateTime? applied(TimeOfDay? time) {
    if (this != null && time != null) {
      return DateTime(this!.year, this!.month, this!.day, time.hour, time.minute);
    }
    return null;
  }

  UTCDate? toUTCDate() {
    if (this != null) {
      return UTCDate(this!.toUtc());
    } else {
      return null;
    }
  }
}

extension TimeOfDayExtension on TimeOfDay? {

  String formatTime(BuildContext context) {
    if (this != null) {
      return MaterialLocalizations.of(context).formatTimeOfDay(this!);
    }
    return '';
  }
}