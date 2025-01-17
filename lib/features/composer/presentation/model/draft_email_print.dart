
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';

class DraftEmailPrint extends EmailPrint {
  DraftEmailPrint({
    required super.appName,
    required super.userName,
    required super.emailContent,
    required super.fromPrefix,
    required super.toPrefix,
    required super.ccPrefix,
    required super.bccPrefix,
    required super.replyToPrefix,
    required super.titleAttachment,
    required super.receiveTime,
    super.attachments,
    super.toAddress,
    super.ccAddress,
    super.bccAddress,
    super.replyToAddress,
    super.sender,
    super.subject,
  });
}