
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SendingEmailActionType {
  create,
  edit,
  resend,
  delete;

  String getButtonTitle(BuildContext context) {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppLocalizations.of(context).delete;
      case SendingEmailActionType.edit:
        return AppLocalizations.of(context).edit;
      case SendingEmailActionType.create:
        return '';
      case SendingEmailActionType.resend:
        return AppLocalizations.of(context).resend;
    }
  }

  String getButtonKey() {
    switch(this) {
      case SendingEmailActionType.delete:
        return 'button_delete_sending_email';
      case SendingEmailActionType.edit:
        return 'button_edit_sending_email';
      case SendingEmailActionType.create:
        return '';
      case SendingEmailActionType.resend:
        return 'button_resend_sending_email';
    }
  }

  Color getButtonIconColor(ButtonState buttonState) {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton.withValues(alpha: buttonState.opacity);
      case SendingEmailActionType.edit:
      case SendingEmailActionType.resend:
        return AppColor.primaryColor.withValues(alpha: buttonState.opacity);
      case SendingEmailActionType.create:
        return Colors.transparent.withValues(alpha: buttonState.opacity);
    }
  }

  Color getButtonTitleColor(ButtonState buttonState) {
    switch(this) {
      case SendingEmailActionType.delete:
        return AppColor.colorDeletePermanentlyButton.withValues(alpha: buttonState.opacity);
      case SendingEmailActionType.edit:
      case SendingEmailActionType.resend:
        return AppColor.primaryColor.withValues(alpha: buttonState.opacity);
      case SendingEmailActionType.create:
        return Colors.transparent.withValues(alpha: buttonState.opacity);
    }
  }
}