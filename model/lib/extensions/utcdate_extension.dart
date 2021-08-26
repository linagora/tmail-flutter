import 'package:intl/intl.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';

extension UTCDateExtension on UTCDate? {

  String formatDate({String pattern = 'yMMMd', String locale = 'en_US'}) {
    if (this != null) {
      return DateFormat(pattern, locale).format(this!.value);
    } else {
      return '';
    }
  }
}