import 'package:model/model.dart';
import 'package:core/core.dart';

extension PresentationEmailExtension on PresentationEmail {

  String getTimeSentEmail(String newLocale) {
    final dateTime = sentAt?.value;
    return sentAt.formatDate(pattern: dateTime.toPattern(), locale: newLocale);
  }
}