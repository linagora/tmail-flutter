import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';

class EmailPrint with EquatableMixin {
  final String appName;
  final String userName;
  final Email emailInformation;
  final String emailContent;
  final String locale;
  final String toPrefix;
  final String fromPrefix;
  final String ccPrefix;
  final String bccPrefix;
  final String replyToPrefix;
  final String titleAttachment;
  final List<Attachment>? attachments;
  final String? toAddress;
  final String? ccAddress;
  final String? bccAddress;
  final String? replyToAddress;

  EmailPrint({
    required this.appName,
    required this.userName,
    required this.emailInformation,
    required this.emailContent,
    required this.locale,
    required this.fromPrefix,
    required this.toPrefix,
    required this.ccPrefix,
    required this.bccPrefix,
    required this.replyToPrefix,
    required this.titleAttachment,
    this.attachments,
    this.toAddress,
    this.ccAddress,
    this.bccAddress,
    this.replyToAddress,
  });

  @override
  List<Object?> get props => [
    appName,
    userName,
    emailInformation,
    emailContent,
    locale,
    fromPrefix,
    toPrefix,
    ccPrefix,
    bccPrefix,
    replyToPrefix,
    titleAttachment,
    attachments,
    toAddress,
    ccAddress,
    bccAddress,
    replyToAddress,
  ];
}

extension EmailPrintExtension on EmailPrint {
  EmailPrint fromEmailContent(String newEmailContent) {
    return EmailPrint(
      appName: appName,
      userName: userName,
      emailInformation: emailInformation,
      emailContent: newEmailContent,
      titleAttachment: titleAttachment,
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
    );
  }
}