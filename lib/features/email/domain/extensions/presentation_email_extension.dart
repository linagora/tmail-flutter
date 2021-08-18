import 'package:intl/intl.dart';
import 'package:model/model.dart';
import 'package:core/core.dart';

extension PresentationEmailExtension on PresentationEmail {

  String getTimeSentEmail(String locale) {
    if (sentAt != null) {
      if (sentAt!.value.isToday()) {
        return DateFormat('h:mm a', locale).format(sentAt!.value);
      } else if (sentAt!.value.isYesterday()) {
        return DateFormat('EEE', locale).format(sentAt!.value);
      } else if (sentAt!.value.isThisYear()) {
        return DateFormat('MMMd', locale).format(sentAt!.value);
      } else {
        return DateFormat('yMMMd', locale).format(sentAt!.value);
      }
    } else {
      return '';
    }
  }
}