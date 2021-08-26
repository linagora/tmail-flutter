import 'package:model/model.dart';

extension PresentationEmailExtension on PresentationEmail {

  int numberOfAllEmailAddress() => to.numberEmailAddress() + cc.numberEmailAddress() + bcc.numberEmailAddress();

  String getSentTime(String locale) => sentAt.formatDate(pattern: 'dd/MM/yyyy h:mm a', locale: locale);
}