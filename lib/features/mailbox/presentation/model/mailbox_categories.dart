
import 'package:flutter/cupertino.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_category.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

export 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_category.dart';

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
    return categoriesExpandMode.getExpandMode(this);
  }

  MailboxCategoriesExpandMode withExpandMode(
    MailboxCategoriesExpandMode categoriesExpandMode,
    ExpandMode expandMode,
  ) {
    return categoriesExpandMode.withExpandMode(this, expandMode);
  }
}
