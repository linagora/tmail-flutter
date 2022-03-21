
import 'package:model/email/presentation_email.dart';

extension ListPresentationEmailExtension on List<PresentationEmail> {
  bool get isAllEmailRead => every((email) => email.isReadEmail());

  bool get isAllEmailStarred => every((email) => email.isFlaggedEmail());

  List<PresentationEmail> get allEmailUnread => where((email) => email.isUnReadEmail()).toList();
}