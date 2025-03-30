import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ViewEntireMessageRequest with EquatableMixin {
  final UserName userName;
  final PresentationEmail presentationEmail;
  final List<Attachment> attachments;
  final String emailContent;
  final Locale locale;
  final AppLocalizations appLocalizations;

  ViewEntireMessageRequest({
    required this.userName,
    required this.presentationEmail,
    required this.attachments,
    required this.emailContent,
    required this.locale,
    required this.appLocalizations,
  });

  @override
  List<Object?> get props => [
    userName,
    presentationEmail,
    attachments,
    emailContent,
    locale,
    appLocalizations,
  ];
}