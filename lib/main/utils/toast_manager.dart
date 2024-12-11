import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ToastManager {
  final AppToast _appToast;
  final ImagePaths _imagePaths;

  ToastManager(this._appToast, this._imagePaths);

  String? getMessageByException(BuildContext context, dynamic exception) {
    if (exception is CanNotFoundBaseUrl) {
      return AppLocalizations.of(context).requiredUrl;
    } else if (exception is CanNotFoundUserName) {
      return AppLocalizations.of(context).requiredEmail;
    } else if (exception is CanNotFoundPassword) {
      return AppLocalizations.of(context).requiredPassword;
    } else if (exception is CanNotFoundOIDCLinks) {
      return AppLocalizations.of(context).ssoNotAvailable;
    }  else if (exception is CanNotFindToken) {
      return AppLocalizations.of(context).canNotGetToken;
    } else if (exception is ConnectionTimeout || exception is BadGateway || exception is SocketError) {
      return AppLocalizations.of(context).wrongUrlMessage;
    } else if (exception is BadCredentialsException) {
      return AppLocalizations.of(context).badCredentials;
    } else if (exception is ConnectionError) {
      return AppLocalizations.of(context).connectionError;
    } else if (exception is UnknownError && exception.message != null) {
      return '[${exception.code ?? ''}] ${exception.message}';
    } else if (exception is NotFoundSessionException) {
      return AppLocalizations.of(context).notFoundSession;
    } else if (exception is NoNetworkError) {
      return AppLocalizations.of(context).youAreOffline;
    } else {
      return null;
    }
  }

  void showMessageFailure(Failure failure) {
    if (currentContext == null || currentOverlayContext == null) {
      logError('ToastManager::showMessageFailure: Context is null');
      return;
    }

    String? message;

    if (failure is GetSessionFailure) {
      message = getMessageByException(currentContext!, failure.exception)
        ?? AppLocalizations.of(currentContext!).unknownError;
    } else if (failure is EmptySpamFolderFailure) {
      message = AppLocalizations.of(currentContext!).emptySpamFolderFailed;
    } else if (failure is MoveMultipleEmailToMailboxFailure
        && failure.emailActionType == EmailActionType.moveToSpam
        && failure.moveAction == MoveAction.moving) {
      message = AppLocalizations.of(currentContext!).markAsSpamFailed;
    } else if (failure is SignInTwakeWorkplaceFailure) {
      final exception = failure.exception;
      if (exception is PlatformException && exception.message?.isNotEmpty == true) {
        message = exception.message;
      } else {
        message = AppLocalizations.of(currentContext!).sigInSaasFailed;
      }
    } else if (failure is SignUpTwakeWorkplaceFailure) {
      final exception = failure.exception;
      if (exception is PlatformException && exception.message?.isNotEmpty == true) {
        message = exception.message;
      } else {
        message = AppLocalizations.of(currentContext!).createTwakeIdFailed;
      }
    }

    if (message?.isNotEmpty == true) {
      _appToast.showToastErrorMessage(currentOverlayContext!, message!);
    }
  }

  void showSuccessMessage({
    required BuildContext context,
    required BuildContext overlayContext,
    required Success success
  }) {
    if (success is MarkAsMailboxReadAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsMailboxReadSuccess(success.mailboxDisplayName),
        leadingSVGIcon: _imagePaths.icReadToast,
      );
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxDisplayName, success.countEmailsRead),
        leadingSVGIcon: _imagePaths.icReadToast,
      );
    } else if (success is MarkAllAsUnreadSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsSuccess,
        leadingSVGIcon: _imagePaths.icUnreadToast,
      );
    } else if (success is MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(success.countEmailsUnread),
        leadingSVGIcon: _imagePaths.icUnreadToast,
      );
    } else if (success is MoveAllSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsSuccess(success.destinationPath),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox,
      );
    } else if (success is MoveAllSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsHasSomeEmailFailure(success.countEmailsMoved, success.destinationPath),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox,
      );
    } else if (success is DeleteAllPermanentlyEmailsSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toast_message_empty_trash_folder_success,
      );
    } else if (success is MarkAllAsStarredSelectionAllEmailsAllSuccess) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsSuccess,
        leadingSVGIcon: _imagePaths.icUnreadToast,
      );
    } else if (success is MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(success.countStarred),
        leadingSVGIcon: _imagePaths.icUnreadToast,
      );
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
          failure.exception.toString(),
        ),
      );
    } else if (failure is MarkAsMailboxReadAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName),
      );
    } else if (failure is MarkAllAsUnreadSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsFailureWithReason(
          failure.exception.toString(),
        ),
      );
    } else if (failure is MarkAllAsUnreadSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsUnreadSelectionAllEmailsAllFailure,
      );
    } else if (failure is MoveAllSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsFailureWithReason(
          failure.destinationPath,
          failure.exception.toString(),
        ),
      );
    } else if (failure is MoveAllSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMoveAllSelectionAllEmailsAllFailure(
          failure.destinationPath,
        ),
      );
    } else if (failure is DeleteAllPermanentlyEmailsFailure) {
      _appToast.showToastSuccessMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageDeleteAllPermanentlyEmailsFailureWithReason(
          failure.exception.toString(),
        ),
      );
    } else if (failure is MarkAllAsStarredSelectionAllEmailsFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsFailureWithReason(
          failure.exception.toString(),
        ),
      );
    } else if (failure is MarkAllAsStarredSelectionAllEmailsAllFailure) {
      _appToast.showToastErrorMessage(
        overlayContext,
        AppLocalizations.of(context).toastMessageMarkAllAsStarredSelectionAllEmailsAllFailure,
      );
    }
  }
}
