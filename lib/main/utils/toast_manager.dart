import 'dart:io';

import 'package:core/domain/exceptions/file_exception.dart';
import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth_web/authorization_exception.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_thread_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/create_new_label_state.dart';
import 'package:tmail_ui_user/features/labels/domain/state/delete_a_label_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_identity_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/exceptions/permission_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ToastManager {
  final AppToast appToast;
  final ImagePaths imagePaths;

  ToastManager(this.appToast, this.imagePaths);

  String getDefaultMessageByException(
    AppLocalizations appLocalizations,
    dynamic exception,
  ) {
    try {
      return appLocalizations.unexpectedError(exception.message);
    } catch (_) {
      return appLocalizations.unexpectedError(exception.toString());
    }
  }

  String? getMessageByException(
    AppLocalizations appLocalizations,
    dynamic exception, {
    bool useDefaultMessage = false,
  }) {
    if (exception is CanNotFoundBaseUrl) {
      return appLocalizations.requiredUrl;
    } else if (exception is CanNotFoundUserName) {
      return appLocalizations.requiredEmail;
    } else if (exception is CanNotFoundPassword) {
      return appLocalizations.requiredPassword;
    } else if (exception is CanNotFoundOIDCLinks) {
      return appLocalizations.ssoNotAvailable;
    } else if (exception is CanNotFindToken) {
      return appLocalizations.canNotGetToken;
    } else if (exception is ConnectionTimeout ||
        exception is BadGateway ||
        exception is SocketError) {
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
      return appLocalizations
          .handshakeException(exception.osError?.message ?? '');
    } else if (exception is SetMethodException &&
        exception.mapErrors.isNotEmpty) {
      final firstError = exception.mapErrors.values.first;
      return '[${firstError.type.value}] ${firstError.description}';
    } else if (exception is ErrorMethodResponseException &&
        exception.errorResponse is ErrorMethodResponse) {
      final errorResponse = exception.errorResponse as ErrorMethodResponse;
      return '[${errorResponse.type.value}] ${errorResponse.description}';
    } else if (exception is MethodLevelErrors) {
      return '[${exception.type.value}] ${exception.message}';
    } else if (exception is SetError) {
      return '[${exception.type.value}] ${exception.description}';
    } else if (exception is PlatformException &&
        exception.message?.isNotEmpty == true) {
      return exception.message!;
    } else if (exception is NotGrantedPermissionStorageException) {
      return appLocalizations.youNeedToGrantFilesPermissionToExportFile;
    } else if (exception is NotFoundFileInFolderException) {
      return appLocalizations.noLogsHaveBeenRecordedYet;
    } else if (exception is CannotOpenNewWindowException) {
      return appLocalizations.cannotOpenNewWindow;
    } else if (exception is CannotReplyCalendarEventException) {
      final mapErrors = exception.mapErrors ?? {};
      if (mapErrors.isNotEmpty) {
        final firstError = mapErrors.values.first;
        return '[${firstError.type.value}] ${firstError.description}';
      }
    } else if (exception is ServerError) {
      return '[${exception.error}] ${exception.errorDescription}';
    } else if (exception is TemporarilyUnavailable) {
      return '[${exception.error}] ${exception.errorDescription}';
    } else if (exception is AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException) {
      return '';
    }

    if (useDefaultMessage) {
      return getDefaultMessageByException(appLocalizations, exception);
    } else {
      return null;
    }
  }

  void showMessageFailure(FeatureFailure failure) {
    final context = currentContext;
    final overlayContext = currentOverlayContext;
    if (context == null || overlayContext == null) {
      logError('ToastManager::showMessageFailure: Context or OverlayContext is null');
      return;
    }

    final exception = failure.exception;
    final appLocalizations = AppLocalizations.of(context);
    String? message = getMessageByException(appLocalizations, exception);
    
    if (failure is GetSessionFailure) {
      message = message ??
          getMessageByException(
            appLocalizations,
            exception,
            useDefaultMessage: true,
          );
    } else if (_isEmptySpamFolderFailure(failure)) {
      message = message ?? appLocalizations.emptySpamFolderFailed;
    } else if (_isEmptyTrashFolderFailure(failure)) {
      message = message ?? appLocalizations.emptyTrashFolderFailed;
    } else if (_isMarkAsSpamFailure(failure)) {
      message = message ??appLocalizations.markAsSpamFailed;
    } else if (_isArchiveMessagesFailure(failure)) {
      message = message ?? appLocalizations.archiveMessagesFailed;
    } else if (failure is SignInTwakeWorkplaceFailure) {
      message = message ?? appLocalizations.sigInSaasFailed;
    } else if (failure is SignUpTwakeWorkplaceFailure) {
      message = message ?? appLocalizations.createTwakeIdFailed;
    } else if (failure is ParseEmailByBlobIdFailure) {
      message =
          message ?? appLocalizations.parseEmailByBlobIdFailed;
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      message =
          message ?? appLocalizations.previewEmailFromEMLFileFailed;
    } else if (failure is ExportTraceLogFailure) {
      message = message ?? appLocalizations.exportTraceLogFailed;
    } else if (failure is AddRecipientsInForwardingFailure ||
        failure is AddRecipientsInForwardingSuccessWithSomeCaseFailure) {
      message = message ?? appLocalizations.addRecipientsFailed;
    } else if (failure is EditLocalCopyInForwardingFailure ||
        failure is EditLocalCopyInForwardingSuccessWithSomeCaseFailure) {
      message =
          message ?? appLocalizations.editLocalCopyInForwardFailed;
    } else if (failure is DeleteRecipientInForwardingFailure ||
        failure is DeleteRecipientInForwardingSuccessWithSomeCaseFailure) {
      message = message ?? appLocalizations.deleteRecipientsFailed;
    } else if (failure is CreateNewRuleFilterFailure) {
      message = message ?? appLocalizations.createFilterRuleFailed;
    } else if (failure is CalendarEventReplyFailure) {
      message = message ??
          appLocalizations.eventReplyWasSentUnsuccessfully;
    } else if (failure is MoveFolderContentFailure) {
      message = message ??
          appLocalizations.moveFolderContentToastMessage;
    } else if (failure is CreateNewLabelFailure) {
      message = message ??
          appLocalizations.createNewLabelFailure;
    } else if (failure is AddALabelToAnEmailFailure) {
      message = message ??
          appLocalizations.addLabelToEmailFailureMessage(failure.labelDisplay);
    } else if (failure is AddALabelToAThreadFailure) {
      message = message ??
          appLocalizations.addLabelToThreadFailureMessage(failure.labelDisplay);
    } else if (failure is DeleteALabelFailure) {
      message = message ?? appLocalizations.deleteALabelFailure;
    }
    log('ToastManager::showMessageFailure: Message: $message');
    if (message?.trim().isNotEmpty == true) {
      appToast.showToastErrorMessage(overlayContext, message!);
    }
  }

  bool _isEmptySpamFolderFailure(FeatureFailure failure) {
    return failure is EmptySpamFolderFailure ||
        (failure is ClearMailboxFailure &&
            failure.mailboxRole == PresentationMailbox.roleSpam);
  }

  bool _isEmptyTrashFolderFailure(FeatureFailure failure) {
    return failure is EmptyTrashFolderFailure ||
        (failure is ClearMailboxFailure &&
            failure.mailboxRole == PresentationMailbox.roleTrash);
  }

  bool _isMarkAsSpamFailure(FeatureFailure failure) {
    return failure is MoveMultipleEmailToMailboxFailure &&
        failure.emailActionType == EmailActionType.moveToSpam &&
        failure.moveAction == MoveAction.moving;
  }

  bool _isArchiveMessagesFailure(FeatureFailure failure) {
    return failure is MoveMultipleEmailToMailboxFailure &&
        failure.emailActionType == EmailActionType.archiveMessage &&
        failure.moveAction == MoveAction.moving;
  }

  void showMessageSuccess(Success success) {
    final context = currentContext;
    final overlayContext = currentOverlayContext;
    if (context == null || overlayContext == null) {
      logError('ToastManager::showMessageSuccess: Context or OverlayContext is null');
      return;
    }

    String? message;
    final appLocalizations = AppLocalizations.of(context);

    if (success is ClearMailboxSuccess ||
        success is EmptySpamFolderSuccess ||
        success is EmptyTrashFolderSuccess) {
      message =
          appLocalizations.toast_message_empty_trash_folder_success;
    } else if (success is ExportTraceLogSuccess) {
      message = appLocalizations.exportTraceLogSuccess(
        success.savePath,
      );
    } else if (success is CreateNewRuleFilterSuccess) {
      message = appLocalizations.newFilterWasCreated;
    } else if (success is EditIdentitySuccess) {
      if (success.isSetAsDefault) {
        message = appLocalizations.defaultIdentitySetupSuccessful;
      } else {
        message = appLocalizations.you_are_changed_your_identity_successfully;
      }
    } else if (success is MarkAsStarEmailSuccess) {
      message = success.markStarAction == MarkStarAction.markStar
          ? appLocalizations.mailHasBeenStarred
          : appLocalizations.mailHasBeenUnstarred;
    } else if (success is CreateNewLabelSuccess) {
      message = appLocalizations.createLabelSuccessfullyMessage(
        success.newLabel.safeDisplayName,
      );
    } else if (success is AddALabelToAnEmailSuccess) {
      message = appLocalizations.addLabelToEmailSuccessfullyMessage(
        success.labelDisplay,
      );
    } else if (success is AddALabelToAThreadSuccess) {
      message = appLocalizations.addLabelToThreadSuccessfullyMessage(
        success.labelDisplay,
      );
    } else if (success is DeleteALabelSuccess) {
      message = appLocalizations.deleteLabelSuccessfullyMessage(
        success.deletedLabel.safeDisplayName,
      );
    }
    log('ToastManager::showMessageSuccess: Message: $message');
    if (message?.trim().isNotEmpty == true) {
      appToast.showToastSuccessMessage(overlayContext, message!);
    }
  }

  void showMessageSuccessWithAction({
    required Success success,
    required VoidCallback onActionCallback,
  }) {
    final context = currentContext;
    final overlayContext = currentOverlayContext;
    if (context == null || overlayContext == null) {
      logError('$runtimeType::showMessageSuccessWithAction: Context or OverlayContext is null');
      return;
    }

    String? message;
    final appLocalizations = AppLocalizations.of(context);
    if (success is MoveFolderContentSuccess) {
      message = appLocalizations.movedToFolder(
        success.request.destinationMailboxDisplayName,
      );
    }
    log('$runtimeType::showMessageSuccessWithAction: Message: $message');
    if (message?.trim().isNotEmpty == true) {
      appToast.showToastMessage(
        overlayContext,
        message!,
        actionName: appLocalizations.undo,
        onActionClick: onActionCallback,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }
}
