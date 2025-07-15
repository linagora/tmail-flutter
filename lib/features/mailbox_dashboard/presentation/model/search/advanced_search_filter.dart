import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum AdvancedSearchFilterField {
  from,
  to,
  subject,
  hasKeyword,
  notKeyword,
  mailBox,
  date,
  sortBy,
  hasAttachment;

  String getTitle(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilterField.from:
        return AppLocalizations.of(context).from_email_address_prefix;
      case AdvancedSearchFilterField.to:
        return AppLocalizations.of(context).to_email_address_prefix;
      case AdvancedSearchFilterField.subject:
        return AppLocalizations.of(context).subject;
      case AdvancedSearchFilterField.hasKeyword:
        return AppLocalizations.of(context).hasTheWords;
      case AdvancedSearchFilterField.notKeyword:
        return AppLocalizations.of(context).doesNotHave;
      case AdvancedSearchFilterField.mailBox:
        return AppLocalizations.of(context).folder;
      case AdvancedSearchFilterField.date:
        return AppLocalizations.of(context).date;
      case AdvancedSearchFilterField.sortBy:
        return AppLocalizations.of(context).sortBy;
      case AdvancedSearchFilterField.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  String getHintText(BuildContext context) {
    switch (this) {
      case AdvancedSearchFilterField.from:
      case AdvancedSearchFilterField.to:
        return AppLocalizations.of(context).nameOrEmailAddress;
      case AdvancedSearchFilterField.subject:
        return AppLocalizations.of(context).enterASubject;
      case AdvancedSearchFilterField.hasKeyword:
      case AdvancedSearchFilterField.notKeyword:
        return AppLocalizations.of(context).enterSomeSuggestions;
      case AdvancedSearchFilterField.mailBox:
        return AppLocalizations.of(context).allFolders;
      case AdvancedSearchFilterField.date:
        return AppLocalizations.of(context).allTime;
      case AdvancedSearchFilterField.sortBy:
        return AppLocalizations.of(context).mostRecent;
      case AdvancedSearchFilterField.hasAttachment:
        return AppLocalizations.of(context).hasAttachment;
    }
  }

  TextStyle getTitleTextStyle() {
    return ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColor.colorContentEmail);
  }

  PrefixEmailAddress getPrefixEmailAddress() {
    switch (this) {
      case AdvancedSearchFilterField.from:
        return PrefixEmailAddress.from;
      case AdvancedSearchFilterField.to:
        return PrefixEmailAddress.to;
      default:
        return PrefixEmailAddress.cc;
    }
  }

  TextStyle getHintTextStyle() {
    return ThemeUtils.defaultTextStyleInterFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColor.colorHintSearchBar);
  }
}
