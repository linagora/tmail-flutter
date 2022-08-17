import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime? {

  String formatDate({String pattern = 'yyyy/MM/dd', String locale = 'en_US'}) {
    if (this != null) {
      return DateFormat(pattern, locale).format(this!.toLocal());
    } else {
      return '';
    }
  }
}

extension TimeOfDayExtension on TimeOfDay? {

  String formatTime(BuildContext context) {
    if (this != null) {
      return this!.format(context);
    }
    return '';
  }
}