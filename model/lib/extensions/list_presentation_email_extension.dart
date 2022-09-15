
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListPresentationEmailExtension on List<PresentationEmail> {
  bool get isAllEmailRead => every((email) => email.hasRead);

  bool get isAllEmailStarred => every((email) => email.hasStarred);

  List<Email> get listEmail => map((presentationEmail) => presentationEmail.toEmail()).toList();

  List<PresentationEmail> get listEmailSelected {
    return where((email) => email.selectMode == SelectMode.ACTIVE).toList();
  }

  bool isAllCanDeletePermanently(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final listMailboxContain = map((email) => email.findMailboxContain(mapMailbox))
        .whereType<PresentationMailbox>()
        .toList();
    final stateDelete = listMailboxContain.every((mailbox) => mailbox.isTrash) ||
        listMailboxContain.every((mailbox) => mailbox.isDrafts);
    return stateDelete;
  }

  bool isAllCanSpamAndMove(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final listMailboxContain = map((email) => email.findMailboxContain(mapMailbox))
        .whereType<PresentationMailbox>()
        .toList();
    return listMailboxContain.every((mailbox) => !mailbox.isDrafts) &&
        isAllBelongToTheSameMailbox(mapMailbox);
  }

  bool isAllSpam(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final listMailboxContain = map((email) => email.findMailboxContain(mapMailbox))
        .whereType<PresentationMailbox>()
        .toList();
    return listMailboxContain.every((mailbox) => mailbox.isSpam);
  }

  bool isAllBelongToTheSameMailbox(Map<MailboxId, PresentationMailbox> mapMailbox) {
    if (isEmpty) {
      return false;
    }
    final firstEmail = first;
    final firstMailboxContain = firstEmail.findMailboxContain(mapMailbox);
    if (firstMailboxContain != null) {
      return every((email) {
        final mailboxContain = email.findMailboxContain(mapMailbox);
        return mailboxContain?.id == firstMailboxContain.id;
      });
    } else {
      return false;
    }
  }

  PresentationMailbox? getCurrentMailboxContain(Map<MailboxId, PresentationMailbox> mapMailbox) {
    return first.findMailboxContain(mapMailbox);
  }

  List<PresentationEmail> listEmailCanSpam(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final newListEmails = map((email) {
      final mailboxContain = email.findMailboxContain(mapMailbox);
      if (mailboxContain?.isSpam == false) {
        return email;
      } else {
        return null;
      }
    }).whereType<PresentationEmail>().toList();
    return newListEmails;
  }

  List<PresentationEmail> get allEmailUnread => where((email) => !email.hasRead).toList();

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