
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';

extension ListPresentationEmailExtension on List<PresentationEmail> {
  bool get isAllEmailRead => every((email) => email.isReadEmail());

  bool get isAllEmailStarred => every((email) => email.isFlaggedEmail());

  List<PresentationEmail> get allEmailUnread => where((email) => email.isUnReadEmail()).toList();

  PresentationEmail? findEmail(EmailId emailId) {
    try {
      return firstWhere((email) => email.id == emailId);
    } catch(e) {
      return null;
    }
  }

  List<PresentationEmail> combine(List<PresentationEmail> listEmailBefore)  {
    return map((presentationEmail) {
      final emailBefore = listEmailBefore.findEmail(presentationEmail.id);
      if (emailBefore != null) {
        return presentationEmail.toSelectedEmail(selectMode: emailBefore.selectMode);
      } else {
        return presentationEmail;
      }
    }).toList();
  }
}