import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AdvancedSearchFilter {
  form,
  to,
  subject,
  hasKeyword,
  notKeyword,
  mailBox,
  date,
  hasAttachment
}

extension AdvancedSearchFilterExtension on AdvancedSearchFilter {
  String getTitle(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilter.form:
        return AppLocalizations.of(context).form;
      case AdvancedSearchFilter.to:
        return AppLocalizations.of(context).to;
      case AdvancedSearchFilter.subject:
        return AppLocalizations.of(context).subject;
      case AdvancedSearchFilter.hasKeyword:
        return AppLocalizations.of(context).hasTheWords;
      case AdvancedSearchFilter.notKeyword:
        return AppLocalizations.of(context).doesNotHave;
      case AdvancedSearchFilter.mailBox:
        return AppLocalizations.of(context).mailbox;
      case AdvancedSearchFilter.date:
        return AppLocalizations.of(context).date;
      case AdvancedSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  String getHintText(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilter.form:
      case AdvancedSearchFilter.to:
        return AppLocalizations.of(context).nameOrEmailAddress;
      case AdvancedSearchFilter.subject:
      case AdvancedSearchFilter.hasKeyword:
      case AdvancedSearchFilter.notKeyword:
        return AppLocalizations.of(context).enterSearchTerm;
      case AdvancedSearchFilter.mailBox:
        return AppLocalizations.of(context).allMails;
      case AdvancedSearchFilter.date:
        return AppLocalizations.of(context).allTime;
      case AdvancedSearchFilter.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  TextStyle getTextStyle() {
    return const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColor.colorContentEmail);
  }
}
