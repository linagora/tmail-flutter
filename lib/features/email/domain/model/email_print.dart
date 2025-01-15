import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/attachment.dart';

class EmailPrint with EquatableMixin {
  final String appName;
  final String userName;
  final String emailContent;
  final String locale;
  final String toPrefix;
  final String fromPrefix;
  final String ccPrefix;
  final String bccPrefix;
  final String replyToPrefix;
  final String titleAttachment;
  final String receiveTime;
  final List<Attachment>? attachments;
  final String? toAddress;
  final String? ccAddress;
  final String? bccAddress;
  final String? replyToAddress;
  final EmailAddress? sender;
  final String? subject;

  EmailPrint({
    required this.appName,
    required this.userName,
    required this.emailContent,
    required this.locale,
    required this.fromPrefix,
    required this.toPrefix,
    required this.ccPrefix,
    required this.bccPrefix,
    required this.replyToPrefix,
    required this.titleAttachment,
    required this.receiveTime,
    this.attachments,
    this.toAddress,
    this.ccAddress,
    this.bccAddress,
    this.replyToAddress,
    this.sender,
    this.subject,
  });

  @override
  List<Object?> get props => [
    appName,
    userName,
    emailContent,
    locale,
    fromPrefix,
    toPrefix,
    ccPrefix,
    bccPrefix,
    replyToPrefix,
    titleAttachment,
    receiveTime,
    attachments,
    toAddress,
    ccAddress,
    bccAddress,
    replyToAddress,
    sender,
    subject,
  ];
}

extension EmailPrintExtension on EmailPrint {
  EmailPrint fromEmailContent(String newEmailContent) {
    return EmailPrint(
      appName: appName,
      userName: userName,
      emailContent: newEmailContent,
      titleAttachment: titleAttachment,
      receiveTime: receiveTime,
      locale: locale,
      fromPrefix: fromPrefix,
      toPrefix: toPrefix,
      ccPrefix: ccPrefix,
      bccPrefix: bccPrefix,
      replyToPrefix: replyToPrefix,
      attachments: attachments,
      toAddress: toAddress,
      ccAddress: ccAddress,
      bccAddress: bccAddress,
      replyToAddress: replyToAddress,
      sender: sender,
      subject: subject,
    );
  }
}