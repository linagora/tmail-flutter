import 'dart:io';

import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_unread_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ToastManager {
  final AppToast appToast;

  const ToastManager(this.appToast);

  String? getMessageByException(AppLocalizations appLocalizations, dynamic exception) {
    if (exception is CanNotFoundBaseUrl) {
      return appLocalizations.requiredUrl;
    } else if (exception is CanNotFoundUserName) {
      return appLocalizations.requiredEmail;
    } else if (exception is CanNotFoundPassword) {
      return appLocalizations.requiredPassword;
    } else if (exception is CanNotFoundOIDCLinks) {
      return appLocalizations.ssoNotAvailable;
    }  else if (exception is CanNotFindToken) {
      return appLocalizations.canNotGetToken;
    } else if (exception is ConnectionTimeout || exception is BadGateway || exception is SocketError) {
      return appLocalizations.wrongUrlMessage;
    } else if (exception is BadCredentialsException) {
      return appLocalizations.badCredentials;
    } else if (exception is ConnectionError) {
      return appLocalizations.connectionError;
    } else if (exception is UnknownError && exception.message != null) {
      return '[${exception.code ?? ''}] ${exception.message}';
    } else if (exception is NotFoundSessionException) {
      return appLocalizations.notFoundSession;
    } else if (exception is NoNetworkError) {
      return appLocalizations.youAreOffline;
    } else if (exception is HandshakeException) {
      return appLocalizations.handshakeException(exception.osError?.message ?? '');
    } else {
      try {
        return appLocalizations.unexpectedError(exception.message);
      } catch(_) {
        return appLocalizations.unexpectedError(exception.toString());
      }
    }
  }

  String? _getMessageByViewStateSuccess({
    required AppLocalizations appLocalizations,
    required Success success,
  }) {
    return switch (success) {
      EmptyTrashFolderSuccess() || EmptySpamFolderSuccess() || DeleteAllPermanentlyEmailsSuccess() => appLocalizations.toast_message_empty_trash_folder_success,
      MarkAsMailboxReadAllSuccess() => appLocalizations.toastMessageMarkAsMailboxReadSuccess(success.mailboxDisplayName),
      MarkAsMailboxReadHasSomeEmailFailure() => appLocalizations.toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxDisplayName, success.countEmailsRead),
      MarkAllAsUnreadSelectionAllEmailsAllSuccess() => appLocalizations.toastMessageMarkAllAsUnreadSelectionAllEmailsSuccess,
      MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure() => appLocalizations.toastMessageMarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(success.countEmailsUnread),
      MoveAllSelectionAllEmailsAllSuccess() => appLocalizations.toastMessageMoveAllSelectionAllEmailsSuccess(success.destinationPath),
      MoveAllSelectionAllEmailsHasSomeEmailFailure() => appLocalizations.toastMessageMoveAllSelectionAllEmailsHasSomeEmailFailure(success.countEmailsMoved, success.destinationPath),
      MarkAllAsStarredSelectionAllEmailsAllSuccess() => appLocalizations.toastMessageMarkAllAsStarredSelectionAllEmailsSuccess,
      MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure() => appLocalizations.toastMessageMarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(success.countStarred),
      SendEmailLoading() => appLocalizations.your_email_being_sent,
      DeleteEmailPermanentlySuccess() => appLocalizations.toast_message_delete_a_email_permanently_success,
      MarkAllSearchAsReadSuccess() => appLocalizations.toastMessageMarkAllSearchAsReadSuccess,
      MarkAllSearchAsUnreadSuccess() => appLocalizations.toastMessageMarkAllSearchAsUnreadSuccess,
      MarkAllSearchAsStarredSuccess() => appLocalizations.toastMessageMarkAllSearchAsStarredSuccess,
      MoveAllEmailSearchedToFolderSuccess() => appLocalizations.toastMessageMoveAllEmailSearchedToFolderSuccess(success.destinationPath),
      _ => null
    };
  }

  String? _getMessageByViewStateFailure({
    required AppLocalizations appLocalizations,
    required Failure failure,
  }) {
    return switch (failure) {
      EmptyTrashFolderFailure() => appLocalizations.emptyTrashFolderFailed,
      EmptySpamFolderFailure() => appLocalizations.emptySpamFolderFailed,
      MarkAsMailboxReadFailure() => appLocalizations.toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName),
      MarkAsMailboxReadAllFailure() => appLocalizations.toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName),
      MarkAllAsUnreadSelectionAllEmailsFailure() => appLocalizations.toastMessageMarkAllAsUnreadSelectionAllEmailsFailureWithReason(failure.exception.toString()),
      MoveAllSelectionAllEmailsFailure() => appLocalizations.toastMessageMoveAllSelectionAllEmailsFailureWithReason(failure.destinationPath, failure.exception.toString()),
      MoveAllSelectionAllEmailsAllFailure() => appLocalizations.toastMessageMoveAllSelectionAllEmailsAllFailure(failure.destinationPath),
      DeleteAllPermanentlyEmailsFailure() => appLocalizations.toastMessageDeleteAllPermanentlyEmailsFailureWithReason(failure.exception.toString()),
      MarkAllAsStarredSelectionAllEmailsFailure() => appLocalizations.toastMessageMarkAllAsStarredSelectionAllEmailsFailureWithReason(failure.exception.toString()),
      GetSessionFailure() => getMessageByException(appLocalizations, failure.exception) ?? appLocalizations.unknownError,
      MoveMultipleEmailToMailboxFailure() => _getMessageForMoveMultipleEmailToMailboxFailure(appLocalizations, failure.emailActionType, failure.moveAction),
      SignInTwakeWorkplaceFailure() => _getMessageForSignInTwakeWorkplaceFailure(appLocalizations, failure.exception),
      SignUpTwakeWorkplaceFailure() => _getMessageForSignUpTwakeWorkplaceFailure(appLocalizations, failure.exception),
      ParseEmailByBlobIdFailure() => appLocalizations.parseEmailByBlobIdFailed,
      PreviewEmailFromEmlFileFailure() => _getMessageForPreviewEmailFromEmlFileFailure(appLocalizations, failure.exception),
      RestoreDeletedMessageFailure() => appLocalizations.restoreDeletedMessageFailed,
      MarkAllSearchAsReadFailure() => appLocalizations.toastMessageMarkAllSearchAsReadFailureWithReason(failure.exception.toString()),
      MarkAllSearchAsUnreadFailure() => appLocalizations.toastMessageMarkAllSearchAsUnreadFailureWithReason(failure.exception.toString()),
      MarkAllSearchAsStarredFailure() => appLocalizations.toastMessageMarkAllSearchAsStarredFailureWithReason(failure.exception.toString()),
      MoveAllEmailSearchedToFolderFailure() => appLocalizations.toastMessageMoveAllEmailSearchedToFolderFailureWithReason(failure.destinationPath, failure.exception.toString()),
      _ => null
    };
  }

  String? _getIconByViewStateSuccess({
    required AppLocalizations appLocalizations,
    required Success success,
  }) {
    return switch (success) {
      MarkAsMailboxReadAllSuccess() || MarkAsMailboxReadHasSomeEmailFailure() || MarkAllSearchAsReadSuccess() => appToast.imagePaths.icReadToast,
      MarkAllAsUnreadSelectionAllEmailsAllSuccess() || MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure() || MarkAllSearchAsUnreadSuccess() => appToast.imagePaths.icUnreadToast,
      MoveAllSelectionAllEmailsAllSuccess() || MoveAllSelectionAllEmailsHasSomeEmailFailure() || MoveAllEmailSearchedToFolderSuccess() => appToast.imagePaths.icFolderMailbox,
      MarkAllAsStarredSelectionAllEmailsAllSuccess() || MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure() || MarkAllSearchAsStarredSuccess() => appToast.imagePaths.icStar,
      SendEmailLoading() => appToast.imagePaths.icSendToast,
      DeleteEmailPermanentlySuccess() => appToast.imagePaths.icDeleteToast,
      _ => null
    };
  }

  String? _getMessageForSignInTwakeWorkplaceFailure(AppLocalizations appLocalizations, dynamic exception) {
    if (exception is PlatformException && exception.message?.isNotEmpty == true) {
      return exception.message;
    } else {
      return appLocalizations.sigInSaasFailed;
    }
  }

  String? _getMessageForSignUpTwakeWorkplaceFailure(AppLocalizations appLocalizations, dynamic exception) {
    if (exception is PlatformException && exception.message?.isNotEmpty == true) {
      return exception.message;
    } else {
      return appLocalizations.createTwakeIdFailed;
    }
  }

  String? _getMessageForMoveMultipleEmailToMailboxFailure(
    AppLocalizations appLocalizations,
    EmailActionType emailActionType,
    MoveAction moveAction,
  ) {
    if (emailActionType == EmailActionType.moveToSpam && moveAction == MoveAction.moving) {
      return appLocalizations.markAsSpamFailed;
    } else {
      return null;
    }
  }

  String? _getMessageForPreviewEmailFromEmlFileFailure(
    AppLocalizations appLocalizations,
    dynamic exception,
  ) {
    if (exception is CannotOpenNewWindowException) {
      return appLocalizations.cannotOpenNewWindow;
    } else {
      return appLocalizations.previewEmailFromEMLFileFailed;
    }
  }

  void show(dynamic viewState) {
    if (currentContext == null || currentOverlayContext == null) {
      logError('ToastManager::show: currentContext is null or currentOverlayContext is null');
      return;
    }

    final appLocalizations = AppLocalizations.of(currentContext!);

    String? message;
    String? icon;

    if (viewState is Success) {
      message = _getMessageByViewStateSuccess(
        appLocalizations: appLocalizations,
        success: viewState,
      );
      icon = _getIconByViewStateSuccess(
        appLocalizations: appLocalizations,
        success: viewState,
      );

      log('ToastManager::show: successMessage = $message');
      if (message?.isNotEmpty == true) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          message!,
          leadingSVGIcon: icon,
        );
      }
    } else if (viewState is Failure) {
      message = _getMessageByViewStateFailure(
        appLocalizations: appLocalizations,
        failure: viewState,
      );

      log('ToastManager::show: failureMessage = $message');
      if (message?.isNotEmpty == true) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          message!,
        );
      }
    }
  }
}
