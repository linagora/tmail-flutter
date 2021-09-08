import 'package:core/core.dart';
import 'package:model/model.dart';

extension PresentationEmailExtension on PresentationEmail {

  int numberOfAllEmailAddress() => to.numberEmailAddress() + cc.numberEmailAddress() + bcc.numberEmailAddress();

  String getEmailDateTime(String newLocale, {String? pattern}) {
    final emailTime = sentAt ?? receivedAt;
    if (emailTime != null) {
      return emailTime.formatDate(pattern: pattern ?? emailTime.value.toPattern(), locale: newLocale);
    }
    return '';
  }
}