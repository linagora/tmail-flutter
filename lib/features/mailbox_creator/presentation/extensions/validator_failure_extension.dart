
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/exceptions/verify_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension ValicatorFailureExtension on VerifyNameFailure {

  String getMessage(BuildContext context, {MailboxActions? actions}) {
    if (exception is EmptyNameException) {
      if (actions == MailboxActions.rename) {
        return AppLocalizations.of(context).this_field_cannot_be_blank;
      }
      return AppLocalizations.of(context).nameOfFolderIsRequired;
    } else if (exception is DuplicatedNameException) {
      if (actions == MailboxActions.rename) {
        return AppLocalizations.of(context).there_is_already_folder_with_the_same_name;
      }
      return AppLocalizations.of(context).this_folder_name_is_already_taken;
    } else if (exception is SpecialCharacterException) {
      return AppLocalizations.of(context).folderNameCannotContainSpecialCharacters;
    } else if (exception is NameWithSpaceOnlyException) {
      return AppLocalizations.of(context).thisFieldCannotContainOnlySpaces;
    } else {
      return '';
    }
  }

  String getMessageIdentity(BuildContext context) {
    if (exception is EmptyNameException) {
      return AppLocalizations.of(context).this_field_cannot_be_blank;
    } else if (exception is NameWithSpaceOnlyException) {
      return AppLocalizations.of(context).thisFieldCannotContainOnlySpaces;
    } else if (exception is EmailAddressInvalidException) {
      return AppLocalizations.of(context).thisEmailAddressInvalid;
    } else {
      return '';
    }
  }

  String getMessageRulesFilter(BuildContext context) {
    if (exception is EmptyNameException) {
      return AppLocalizations.of(context).this_field_cannot_be_blank;
    } else if (exception is NameWithSpaceOnlyException) {
      return AppLocalizations.of(context).thisFieldCannotContainOnlySpaces;
    } else {
      return '';
    }
  }
}