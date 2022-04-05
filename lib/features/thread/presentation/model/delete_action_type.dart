
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum DeleteActionType {
  all,
  multiple,
  single,
}

extension DeleteActionTypeExtension on DeleteActionType {

  String getTitleDialog(BuildContext context) {
    switch(this) {
      case DeleteActionType.all:
        return AppLocalizations.of(context).empty_trash_folder;
      case DeleteActionType.multiple:
        return AppLocalizations.of(context).delete_messages_forever;
      case DeleteActionType.single:
        return AppLocalizations.of(context).delete_message_forever;
    }
  }

  String getContentDialog(BuildContext context, {int? count}) {
    switch(this) {
      case DeleteActionType.all:
        return AppLocalizations.of(context).empty_trash_dialog_message;
      case DeleteActionType.multiple:
        return AppLocalizations.of(context).delete_multiple_messages_dialog(count ?? 0);
      case DeleteActionType.single:
        return AppLocalizations.of(context).delete_single_message_dialog;
    }
  }

  String getConfirmActionName(BuildContext context) {
    switch(this) {
      case DeleteActionType.all:
        return AppLocalizations.of(context).delete_all;
      case DeleteActionType.multiple:
        return AppLocalizations.of(context).delete;
      case DeleteActionType.single:
        return AppLocalizations.of(context).delete;
    }
  }
}