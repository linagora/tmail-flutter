
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';

extension ListPresentationEmailExtension on List<PresentationEmail> {
  bool get isAllEmailRead => every((email) => email.hasRead);

  bool get isAllEmailUnread => every((email) => !email.hasRead);

  bool get isAllEmailStarred => every((email) => email.hasStarred);

  bool get isAllSelectionInActive {
    return every((email) => email.selectMode == SelectMode.INACTIVE);
  }

  bool get isAnySelectionInActive {
    return any((email) => email.selectMode == SelectMode.INACTIVE);
  }

  List<Email> get listEmail => map((presentationEmail) => presentationEmail.toEmail()).toList();

  List<PresentationEmail> get listEmailSelected {
    return where((email) => email.selectMode == SelectMode.ACTIVE).toList();
  }

  List<EmailId> get listEmailIds => map((email) => email.id).nonNulls.toList();

  List<ThreadId> get uniqueThreadIds =>
      map((email) => email.threadId).toSet().nonNulls.toList();

  Map<MailboxId, List<EmailId>> get emailIdsByMailboxId {
    final Map<MailboxId, List<EmailId>> result = {};
    for (final email in this) {
      final mailboxId = email.mailboxContain?.mailboxId;
      final emailId = email.id;
      if (mailboxId != null && emailId != null) {
        (result[mailboxId] ??= []).add(emailId);
      }
    }
    return result;
  }

  bool isDeletePermanentlyDisabled(
    Map<MailboxId, PresentationMailbox> mapMailbox,
  ) {
    return any((email) {
      final mailboxContain = email.findMailboxContain(mapMailbox);
      return mailboxContain?.isDeletePermanentlyEnabled != true;
    });
  }

  bool isArchiveMessageEnabled(
    Map<MailboxId, PresentationMailbox> mapMailbox,
  ) {
    return any((email) {
      final mailboxContain = email.findMailboxContain(mapMailbox);
      return mailboxContain?.isArchive != true;
    });
  }

  bool isMarkAsSpamEnabled(
    Map<MailboxId, PresentationMailbox> mapMailbox,
  ) {
    return any((email) {
      final mailboxContain = email.findMailboxContain(mapMailbox);
      return mailboxContain?.isSpam != true;
    });
  }

  PresentationMailbox? getCurrentMailboxContain(Map<MailboxId, PresentationMailbox> mapMailbox) {
    return first.findMailboxContain(mapMailbox);
  }

  List<PresentationEmail> listEmailCanSpam(Map<MailboxId, PresentationMailbox> mapMailbox) {
    final newListEmails = map((email) {
      final mailboxContain = email.findMailboxContain(mapMailbox);
      if (mailboxContain?.isSpam != true) {
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
      if (presentationEmail.id != null) {
        final emailBefore = listEmailBefore.findEmail(presentationEmail.id!);
        if (emailBefore != null) {
          return presentationEmail.toSelectedEmail(selectMode: emailBefore.selectMode);
        } else {
          return presentationEmail;
        }
      } else {
        return presentationEmail;
      }
    }).toList();
  }

  int matchedIndex(EmailId emailId) => indexWhere((email) => email.id == emailId);

  List<PresentationEmail> toEmailsAvailablePushNotification({List<MailboxId>? mailboxIdsNotPutNotifications}) {
    log('ListPresentationEmailExtension::toEmailsAvailablePushNotification():mailboxIdsNotPutNotifications: $mailboxIdsNotPutNotifications');
    if (mailboxIdsNotPutNotifications?.isNotEmpty == true) {
      return where((email) => !email.isBelongToOneOfTheMailboxes(mailboxIdsNotPutNotifications!) && email.pushNotificationActivated).toList();
    } else {
      return where((email) => email.pushNotificationActivated).toList();
    }
  }
}