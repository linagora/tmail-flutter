import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class PreviewEmailEMLRequest with EquatableMixin {
  final AccountId accountId;
  final Session session;
  final String ownEmailAddress;
  final Id blobId;
  final Email email;
  final Locale locale;
  final AppLocalizations appLocalizations;
  final String baseDownloadUrl;
  final bool isShared;

  PreviewEmailEMLRequest({
    required this.accountId,
    required this.session,
    required this.ownEmailAddress,
    required this.blobId,
    required this.email,
    required this.locale,
    required this.appLocalizations,
    required this.baseDownloadUrl,
    this.isShared = true,
  });

  String get keyStored => blobId.value;

  String get title => '${email.subject?.trim().isNotEmpty == true
      ? email.subject
      : appLocalizations.app_name} - $ownEmailAddress';

  @override
  List<Object?> get props => [
    accountId,
    session,
    ownEmailAddress,
    blobId,
    email,
    locale,
    appLocalizations,
    baseDownloadUrl,
    isShared,
  ];
}