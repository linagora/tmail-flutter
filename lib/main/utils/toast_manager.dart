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
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
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
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/error/error_method_response_exception_extension.dart';
import 'package:tmail_ui_user/main/exceptions/permission_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ToastManager {
  final AppToast appToast;

  ToastManager(this.appToast);

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
    } else if (exception is HandshakeException) {
      return AppLocalizations.of(context).handshakeException(exception.osError?.message ?? '');
    } else {
      try {
        return AppLocalizations.of(context).unexpectedError(exception.message);
      } catch(_) {
        return AppLocalizations.of(context).unexpectedError(exception.toString());
      }
    }
  }

  void showMessageFailure(FeatureFailure failure) {
    if (currentContext == null || currentOverlayContext == null) {
      logError('ToastManager::showMessageFailure: Context is null');
      return;
    }

    String? message;
    final exception = failure.exception;

    if (failure is GetSessionFailure) {
      message = getMessageByException(currentContext!, failure.exception)
        ?? AppLocalizations.of(currentContext!).unknownError;
    } else if (failure is EmptySpamFolderFailure ||
        (failure is ClearMailboxFailure && failure.mailboxRole == PresentationMailbox.roleSpam)) {
      if (exception is SetError) {
        message = exception.description?.trim().isNotEmpty == true
            ? exception.description
            : AppLocalizations.of(currentContext!).emptySpamFolderFailed;
      } else if (exception is ErrorMethodResponseException) {
        message = exception.errorMessage.isNotEmpty
            ? exception.errorMessage
            : AppLocalizations.of(currentContext!).emptySpamFolderFailed;
      } else if (exception is MethodLevelErrors) {
        message = exception.message != null
            ? exception.message.toString()
            : AppLocalizations.of(currentContext!).emptySpamFolderFailed;
      } else {
        message = AppLocalizations.of(currentContext!).emptySpamFolderFailed;
      }
    } else if (failure is EmptyTrashFolderFailure ||
        (failure is ClearMailboxFailure && failure.mailboxRole == PresentationMailbox.roleTrash)) {
      if (exception is SetError) {
        message = exception.description?.trim().isNotEmpty == true
            ? exception.description
            : AppLocalizations.of(currentContext!).emptyTrashFolderFailed;
      } else if (exception is MethodLevelErrors) {
        message = exception.message != null
            ? exception.message.toString()
            : AppLocalizations.of(currentContext!).emptyTrashFolderFailed;
      } else if (exception is ErrorMethodResponseException) {
        message = exception.errorMessage.isNotEmpty
            ? exception.errorMessage
            : AppLocalizations.of(currentContext!).emptyTrashFolderFailed;
      } else {
        message = AppLocalizations.of(currentContext!).emptyTrashFolderFailed;
      }
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
    } else if (failure is ParseEmailByBlobIdFailure) {
      message = AppLocalizations.of(currentContext!).parseEmailByBlobIdFailed;
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      if (failure.exception is CannotOpenNewWindowException) {
        message = AppLocalizations.of(currentContext!).cannotOpenNewWindow;
      } else {
        message = AppLocalizations.of(currentContext!).previewEmailFromEMLFileFailed;
      }
    } else if (failure is ExportTraceLogFailure) {
      if (failure.exception is NotGrantedPermissionStorageException) {
        message = AppLocalizations.of(currentContext!).youNeedToGrantFilesPermissionToExportFile;
      } else if (failure.exception is NotFoundFileInFolderException) {
        message = AppLocalizations.of(currentContext!).noLogsHaveBeenRecordedYet;
      } else {
        message = AppLocalizations.of(currentContext!).exportTraceLogFailed;
      }
    } else if (failure is AddRecipientsInForwardingFailure) {
      final exception = failure.exception;
      if (exception is SetMethodException && exception.mapErrors.isNotEmpty) {
        final firstError = exception.mapErrors.values.first;
        message = '[${firstError.type.value}] ${firstError.description}';
      } else if (exception is ErrorMethodResponseException &&
          exception.errorResponse is ErrorMethodResponse) {
        final errorResponse = exception.errorResponse as ErrorMethodResponse;
        message = '[${errorResponse.type.value}] ${errorResponse.description}';
      } else if (exception is MethodLevelErrors) {
        message = '[${exception.type.value}] ${exception.message}';
      } else {
        message = AppLocalizations.of(currentContext!).addRecipientsFailed;
      }
    } else if (failure is EditLocalCopyInForwardingFailure) {
      final exception = failure.exception;
      if (exception is SetMethodException && exception.mapErrors.isNotEmpty) {
        final firstError = exception.mapErrors.values.first;
        message = '[${firstError.type.value}] ${firstError.description}';
      } else if (exception is ErrorMethodResponseException &&
          exception.errorResponse is ErrorMethodResponse) {
        final errorResponse = exception.errorResponse as ErrorMethodResponse;
        message = '[${errorResponse.type.value}] ${errorResponse.description}';
      } else if (exception is MethodLevelErrors) {
        message = '[${exception.type.value}] ${exception.message}';
      } else {
        message = AppLocalizations.of(currentContext!).editLocalCopyInForwardFailed;
      }
    } else if (failure is DeleteRecipientInForwardingFailure) {
      final exception = failure.exception;
      if (exception is SetMethodException && exception.mapErrors.isNotEmpty) {
        final firstError = exception.mapErrors.values.first;
        message = '[${firstError.type.value}] ${firstError.description}';
      } else if (exception is ErrorMethodResponseException &&
          exception.errorResponse is ErrorMethodResponse) {
        final errorResponse = exception.errorResponse as ErrorMethodResponse;
        message = '[${errorResponse.type.value}] ${errorResponse.description}';
      } else if (exception is MethodLevelErrors) {
        message = '[${exception.type.value}] ${exception.message}';
      } else {
        message = AppLocalizations.of(currentContext!).deleteRecipientsFailed;
      }
    }

    if (message?.isNotEmpty == true) {
      appToast.showToastErrorMessage(currentOverlayContext!, message!);
    }
  }

  void showMessageSuccess(Success success) {
    if (currentContext == null || currentOverlayContext == null) {
      logError('ToastManager::showMessageSuccess: Context is null');
      return;
    }

    String? message;

    if (success is ClearMailboxSuccess ||
        success is EmptySpamFolderSuccess ||
        success is EmptyTrashFolderSuccess) {
      message = AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success;
    } else if (success is ExportTraceLogSuccess) {
      message = AppLocalizations.of(currentContext!).exportTraceLogSuccess(success.savePath);
    }

    if (message?.isNotEmpty == true) {
      appToast.showToastSuccessMessage(currentOverlayContext!, message!);
    }
  }
}
