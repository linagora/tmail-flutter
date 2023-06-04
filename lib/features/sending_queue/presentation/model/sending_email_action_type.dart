
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SendingEmailActionType {
  edit,
  delete;

  String getButtonTitle(BuildContext context) {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppLocalizations.of(context).delete;
      case SendingEmailActionType.edit:
        return AppLocalizations.of(context).edit;
    }
  }

  String getButtonKey() {
    switch(this) {
      case SendingEmailActionType.delete:
        return 'button_delete_sending_email';
      case SendingEmailActionType.edit:
        return 'button_edit_sending_email';
    }
  }

  Color getButtonIconColor() {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton;
      case SendingEmailActionType.edit:
        return AppColor.primaryColor;
    }
  }

  Color getButtonTitleColor() {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton;
      case SendingEmailActionType.edit:
        return AppColor.primaryColor;
    }
  }
}