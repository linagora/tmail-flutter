
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SendingEmailActionType {
  delete;

  String getButtonTitle(BuildContext context) {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppLocalizations.of(context).delete;
    }
  }

  String getButtonKey() {
    switch(this) {
      case SendingEmailActionType.delete:
        return 'button_delete_sending_email';
    }
  }

  Color getButtonIconColor() {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton;
    }
  }

  Color getButtonTitleColor() {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton;
    }
  }
}