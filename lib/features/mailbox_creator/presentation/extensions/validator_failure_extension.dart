
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension ValicatorFailureExtension on VerifyNameFailure {

  String getMessage(BuildContext context) {
    if (exception is EmptyNameException) {
      return AppLocalizations.of(context).name_of_mailbox_is_required;
    } else if (exception is DuplicatedNameException) {
      return AppLocalizations.of(context).this_folder_name_is_already_taken;
    } else if (exception is SpecialCharacterException) {
      return AppLocalizations.of(context).mailbox_name_cannot_contain_special_characters;
    } else {
      return '';
    }
  }
}