import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';

extension ListEmailInThreadDetailInfoExtension on List<EmailInThreadDetailInfo> {
  List<EmailId> emailIdsToDisplay(bool isSentMailbox) => isSentMailbox
      ? map((email) => email.emailId).toList()
      : where((email) => email.isValidToDisplay)
          .map((email) => email.emailId)
          .toList();
}