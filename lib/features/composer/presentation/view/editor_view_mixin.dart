
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin EditorViewMixin {
  String getEmailContentQuotedAsHtml({
    required Locale locale,
    required AppLocalizations appLocalizations,
    required String emailContent,
    required EmailActionType emailActionType,
    required PresentationEmail presentationEmail,
  }) {
    final headerEmailQuoted = emailActionType.getHeaderEmailQuoted(
      locale: locale,
      appLocalizations: appLocalizations,
      presentationEmail: presentationEmail
    );
    log('EditorViewMixin::getEmailContentQuotedAsHtml:headerEmailQuoted: $headerEmailQuoted');
    final headerEmailQuotedAsHtml = headerEmailQuoted != null
      ? headerEmailQuoted.addCiteTag()
      : '';
    final emailQuotedHtml = '${HtmlExtension.editorStartTags}$headerEmailQuotedAsHtml${emailContent.addBlockQuoteTag()}';
    return emailQuotedHtml;
  }
}