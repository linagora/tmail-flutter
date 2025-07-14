
import 'package:flutter/cupertino.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxCategories {
  exchange,
  personalFolders,
  teamMailboxes
}

extension MailboxCategoriessExtension on MailboxCategories {

  String get keyValue {
    switch(this) {
      case MailboxCategories.exchange:
        return 'exchange';
      case MailboxCategories.personalFolders:
        return 'personalFolders';
      case MailboxCategories.teamMailboxes:
        return 'teamMailboxes';
    }
  }

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxCategories.exchange:
        return AppLocalizations.of(context).exchange;
      case MailboxCategories.personalFolders:
        return AppLocalizations.of(context).personalFolders;
      case MailboxCategories.teamMailboxes:
        return AppLocalizations.of(context).teamMailBoxes;
    }
  }

  ExpandMode getExpandMode(MailboxCategoriesExpandMode categoriesExpandMode) {
    switch(this) {
      case MailboxCategories.exchange:
        return categoriesExpandMode.defaultMailbox;
      case MailboxCategories.personalFolders:
        return categoriesExpandMode.personalFolders;
      case MailboxCategories.teamMailboxes:
        return categoriesExpandMode.teamMailboxes;
      }
  }
}