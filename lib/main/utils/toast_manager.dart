import 'dart:io';

import 'package:core/domain/exceptions/file_exception.dart';
import 'package:core/domain/exceptions/web_session_exception.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
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

  ToastManager(this.appToast);

  String getDefaultMessageByException(BuildContext context, dynamic exception) {
    try {
      return AppLocalizations.of(context).unexpectedError(exception.message);
    } catch (_) {
      return AppLocalizations.of(context).unexpectedError(
        exception.toString(),
      );
    }
  }

  String? getMessageByException(
    BuildContext context,
    dynamic exception, {
    bool useDefaultMessage = false,
  }) {
    if (exception is CanNotFoundBaseUrl) {
      return AppLocalizations.of(context).requiredUrl;
    } else if (exception is CanNotFoundUserName) {
      return AppLocalizations.of(context).requiredEmail;
    } else if (exception is CanNotFoundPassword) {
      return AppLocalizations.of(context).requiredPassword;
    } else if (exception is CanNotFoundOIDCLinks) {
      return AppLocalizations.of(context).ssoNotAvailable;
    } else if (exception is CanNotFindToken) {
      return AppLocalizations.of(context).canNotGetToken;
    } else if (exception is ConnectionTimeout ||
        exception is BadGateway ||
        exception is SocketError) {
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
    } else if (exception is HandshakeException) {
      return AppLocalizations.of(context)
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
    }else if (exception is PlatformException &&
        exception.message?.isNotEmpty == true) {
      return exception.message!;
    } else if (exception is NotGrantedPermissionStorageException) {
      return AppLocalizations.of(context)
          .youNeedToGrantFilesPermissionToExportFile;
    } else if (exception is NotFoundFileInFolderException) {
      return AppLocalizations.of(context).noLogsHaveBeenRecordedYet;
    } else if (exception is CannotOpenNewWindowException) {
      return AppLocalizations.of(context).cannotOpenNewWindow;
    } else if (exception is CannotReplyCalendarEventException) {
      final mapErrors = exception.mapErrors ?? {};
      if (mapErrors.isNotEmpty) {
        final firstError = mapErrors.values.first;
        return '[${firstError.type.value}] ${firstError.description}';
      }
    }

    if (useDefaultMessage) {
      return getDefaultMessageByException(context, exception);
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
    String? message = getMessageByException(context, exception);

    if (failure is GetSessionFailure) {
      message = message ??
          getMessageByException(
            context,
            exception,
            useDefaultMessage: true,
          );
    } else if (_isEmptySpamFolderFailure(exception)) {
      message = message ?? AppLocalizations.of(context).emptySpamFolderFailed;
    } else if (_isEmptyTrashFolderFailure(failure)) {
      message = message ?? AppLocalizations.of(context).emptyTrashFolderFailed;
    } else if (_isMarkAsSpamFailure(failure)) {
      message = message ?? AppLocalizations.of(context).markAsSpamFailed;
    } else if (failure is SignInTwakeWorkplaceFailure) {
      message = message ?? AppLocalizations.of(context).sigInSaasFailed;
    } else if (failure is SignUpTwakeWorkplaceFailure) {
      message = message ?? AppLocalizations.of(context).createTwakeIdFailed;
    } else if (failure is ParseEmailByBlobIdFailure) {
      message =
          message ?? AppLocalizations.of(context).parseEmailByBlobIdFailed;
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      message =
          message ?? AppLocalizations.of(context).previewEmailFromEMLFileFailed;
    } else if (failure is ExportTraceLogFailure) {
      message = message ?? AppLocalizations.of(context).exportTraceLogFailed;
    } else if (failure is AddRecipientsInForwardingFailure) {
      message = message ?? AppLocalizations.of(context).addRecipientsFailed;
    } else if (failure is EditLocalCopyInForwardingFailure) {
      message =
          message ?? AppLocalizations.of(context).editLocalCopyInForwardFailed;
    } else if (failure is DeleteRecipientInForwardingFailure) {
      message = message ?? AppLocalizations.of(context).deleteRecipientsFailed;
    } else if (failure is CreateNewRuleFilterFailure) {
      message = message ?? AppLocalizations.of(context).createFilterRuleFailed;
    } else if (failure is CalendarEventReplyFailure) {
      message = message ??
          AppLocalizations.of(context).eventReplyWasSentUnsuccessfully;
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

  void showMessageSuccess(Success success) {
    final context = currentContext;
    final overlayContext = currentOverlayContext;
    if (context == null || overlayContext == null) {
      logError('ToastManager::showMessageSuccess: Context or OverlayContext is null');
      return;
    }

    String? message;

    if (success is ClearMailboxSuccess ||
        success is EmptySpamFolderSuccess ||
        success is EmptyTrashFolderSuccess) {
      message =
          AppLocalizations.of(context).toast_message_empty_trash_folder_success;
    } else if (success is ExportTraceLogSuccess) {
      message = AppLocalizations.of(context).exportTraceLogSuccess(
        success.savePath,
      );
    } else if (success is CreateNewRuleFilterSuccess) {
      message = AppLocalizations.of(context).newFilterWasCreated;
    }
    log('ToastManager::showMessageSuccess: Message: $message');
    if (message?.trim().isNotEmpty == true) {
      appToast.showToastSuccessMessage(overlayContext, message!);
    }
  }
}
