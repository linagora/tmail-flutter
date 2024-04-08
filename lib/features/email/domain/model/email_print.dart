import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/attachment.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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

  factory EmailPrint.generate({
    required PrintEmailAction printEmailAction,
    required EmailLoaded emailLoaded
  }) {
    return EmailPrint(
      appName: AppLocalizations.of(printEmailAction.context).app_name,
      userName: printEmailAction.userEmail,
      emailInformation: printEmailAction.email.toEmail(),
      attachments: emailLoaded.attachments,
      emailContent: emailLoaded.htmlContent,
      locale: Localizations.localeOf(printEmailAction.context).toLanguageTag(),
      fromPrefix: AppLocalizations.of(printEmailAction.context).from_email_address_prefix,
      toPrefix: AppLocalizations.of(printEmailAction.context).to_email_address_prefix,
      ccPrefix: AppLocalizations.of(printEmailAction.context).cc_email_address_prefix,
      bccPrefix: AppLocalizations.of(printEmailAction.context).bcc_email_address_prefix,
      replyToPrefix: AppLocalizations.of(printEmailAction.context).replyToEmailAddressPrefix,
      titleAttachment: AppLocalizations.of(printEmailAction.context).attachments.toLowerCase(),
      toAddress: printEmailAction.email.to?.listEmailAddressToString(isFullEmailAddress: true),
      ccAddress: printEmailAction.email.cc?.listEmailAddressToString(isFullEmailAddress: true),
      bccAddress: printEmailAction.email.bcc?.listEmailAddressToString(isFullEmailAddress: true),
      replyToAddress: printEmailAction.email.replyTo?.listEmailAddressToString(isFullEmailAddress: true),
    );
  }

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