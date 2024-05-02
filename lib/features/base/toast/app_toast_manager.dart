
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_unread_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppToastManager {
  final AppToast _appToast;
  final ImagePaths _imagePaths;

  AppToastManager(this._appToast, this._imagePaths);

  void showSuccessMessage({
    required BuildContext context,
    required BuildContext overlayContext,
    required Success success
  }) {
    if (success is MarkAsMailboxReadAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsMailboxReadSuccess(success.mailboxDisplayName),
        leadingSVGIcon: _imagePaths.icReadToast);
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxDisplayName, success.countEmailsRead),
        leadingSVGIcon: _imagePaths.icReadToast);
    } else if (success is MarkAllAsUnreadSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsSuccess,
        leadingSVGIcon: _imagePaths.icUnreadToast);
    } else if (success is MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(success.countEmailsUnread),
        leadingSVGIcon: _imagePaths.icUnreadToast);
    } else if (success is MoveAllSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsSuccess(success.destinationPath),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox);
    } else if (success is MoveAllSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsHasSomeEmailFailure(success.countEmailsMoved, success.destinationPath),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox);
    } else if (success is DeleteAllPermanentlyEmailsSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toast_message_empty_trash_folder_success);
    } else if (success is MarkAllAsStarredSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsSuccess,
        leadingSVGIcon: _imagePaths.icStar);
    } else if (success is MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(success.countStarred),
        leadingSVGIcon: _imagePaths.icStar);
    } else if (success is MarkAllSearchAsReadSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsReadSuccess,
        leadingSVGIcon: _imagePaths.icReadToast);
    } else if (success is MarkAllSearchAsUnreadSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsUnreadSuccess,
        leadingSVGIcon: _imagePaths.icUnreadToast);
    } else if (success is MarkAllSearchAsStarredSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsStarredSuccess,
        leadingSVGIcon: _imagePaths.icStar);
    } else if (success is MoveAllEmailSearchedToFolderSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllEmailSearchedToFolderSuccess(success.destinationPath),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox);
    }
  }

  void showFailureMessage({
    required BuildContext context,
    required BuildContext overlayContext,
    required Failure failure
  }) {
    if (failure is MarkAsMailboxReadFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsReadFolderFailureWithReason(
          failure.mailboxDisplayName,
          failure.exception.toString()
        ));
    } else if (failure is MarkAsMailboxReadAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName));
    } else if (failure is MarkAllAsUnreadSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MarkAllAsUnreadSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsAllFailure);
    } else if (failure is MoveAllSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsFailureWithReason(
          failure.destinationPath,
          failure.exception.toString()
        ));
    } else if (failure is MoveAllSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsAllFailure(failure.destinationPath));
    } else if (failure is DeleteAllPermanentlyEmailsFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageDeleteAllPermanentlyEmailsFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MarkAllAsStarredSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MarkAllAsStarredSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsAllFailure);
    } else if (failure is MarkAllSearchAsReadFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsReadFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MarkAllSearchAsUnreadFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsUnreadFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MarkAllSearchAsStarredFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllSearchAsStarredFailureWithReason(
          failure.exception.toString()
        ));
    } else if (failure is MoveAllEmailSearchedToFolderFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllEmailSearchedToFolderFailureWithReason(
          failure.destinationPath,
          failure.exception.toString()
        ));
    }
  }
}