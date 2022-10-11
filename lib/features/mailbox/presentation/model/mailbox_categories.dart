
import 'package:flutter/cupertino.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxCategories {
  exchange,
  folders,
}

extension MailboxCategoriessExtension on MailboxCategories {

  String get keyValue {
    switch(this) {
      case MailboxCategories.exchange:
        return 'exchange';
      case MailboxCategories.folders:
        return 'folders';
    }
  }

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxCategories.exchange:
        return AppLocalizations.of(context).exchange;
      case MailboxCategories.folders:
        return AppLocalizations.of(context).myFolders;
    }
  }

  ExpandMode getExpandMode(MailboxCategoriesExpandMode categoriesExpandMode) {
    switch(this) {
      case MailboxCategories.exchange:
        return categoriesExpandMode.defaultMailbox;
      case MailboxCategories.folders:
        return categoriesExpandMode.folderMailbox;
    }
  }
}