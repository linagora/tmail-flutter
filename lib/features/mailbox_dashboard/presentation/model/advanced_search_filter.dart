import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AdvancedSearchFilterField {
  form,
  to,
  subject,
  hasKeyword,
  notKeyword,
  mailBox,
  date,
  hasAttachment
}

extension AdvancedSearchFilterFieldExtension on AdvancedSearchFilterField {
  String getTitle(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilterField.form:
        return AppLocalizations.of(context).form;
      case AdvancedSearchFilterField.to:
        return AppLocalizations.of(context).to;
      case AdvancedSearchFilterField.subject:
        return AppLocalizations.of(context).subject;
      case AdvancedSearchFilterField.hasKeyword:
        return AppLocalizations.of(context).hasTheWords;
      case AdvancedSearchFilterField.notKeyword:
        return AppLocalizations.of(context).doesNotHave;
      case AdvancedSearchFilterField.mailBox:
        return AppLocalizations.of(context).mailbox;
      case AdvancedSearchFilterField.date:
        return AppLocalizations.of(context).date;
      case AdvancedSearchFilterField.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  String getHintText(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilterField.form:
      case AdvancedSearchFilterField.to:
        return AppLocalizations.of(context).nameOrEmailAddress;
      case AdvancedSearchFilterField.subject:
      case AdvancedSearchFilterField.hasKeyword:
      case AdvancedSearchFilterField.notKeyword:
        return AppLocalizations.of(context).enterSearchTerm;
      case AdvancedSearchFilterField.mailBox:
        return AppLocalizations.of(context).allMails;
      case AdvancedSearchFilterField.date:
        return AppLocalizations.of(context).allTime;
      case AdvancedSearchFilterField.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  TextStyle getTitleTextStyle() {
    return const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColor.colorContentEmail);
  }

  TextStyle getHintTextStyle() {
    return const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.colorHintSearchBar);
  }
}
