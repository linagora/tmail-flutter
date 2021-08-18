import 'package:intl/intl.dart';
import 'package:model/model.dart';

extension PresentationEmailExtension on PresentationEmail {

  int numberOfAllEmailAddress() => to.numberEmailAddress() + cc.numberEmailAddress() + bcc.numberEmailAddress();

  String getSentTime() => sentAt != null ? DateFormat('dd/MM/yyyy h:mm a', 'en_US').format(sentAt!.value) : '';
}