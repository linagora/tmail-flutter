import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';

extension SendingEmailExtension on List<SendingEmail> {
  List<PresentationEmail> toPresentationEmailList() {
    return map((sendingEmail) => sendingEmail.email.sendingEmailToPresentationEmail(
      emailId: EmailId(Id(sendingEmail.sendingId)),
      createAt: UTCDate(sendingEmail.createTime)
    )).toList();
  }
}