import 'dart:io';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final DownloadAttachmentsInteractor _downloadAttachmentsInteractor;
  final DeviceManager _deviceManager;

  final emailAddressExpandMode = ExpandMode.COLLAPSE.obs;
  EmailContent? emailContent;

  EmailController(this._getEmailContentInteractor, this._markAsEmailReadInteractor);
  EmailController(
    this._getEmailContentInteractor,
    this._downloadAttachmentsInteractor,
    this._deviceManager
  );

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedEmail.listen((presentationEmail) {
      toggleDisplayEmailAddressAction(expandMode: ExpandMode.COLLAPSE);
      final accountId = mailboxDashBoardController.accountId.value;
      if (accountId != null && presentationEmail != null) {
        _getEmailContentAction(accountId, presentationEmail.id);
        if (presentationEmail.isUnReadEmail()) {
          markAsEmailRead(presentationEmail, ReadActions.markAsRead);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    mailboxDashBoardController.selectedEmail.close();
  }

  void _getEmailContentAction(AccountId accountId, EmailId emailId) async {
    consumeState(_getEmailContentInteractor.execute(accountId, emailId));
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is MarkAsEmailReadFailure) {
          _markAsEmailReadFailure(failure);
        }
      },
      (success) {
        if (success is GetEmailContentSuccess) {
          emailContent = success.emailContent;
        } else if (success is MarkAsEmailReadSuccess) {
          _markAsEmailReadSuccess(success);
        }
      });
  }

  @override
  void onError(error) {
  }

  void toggleDisplayEmailAddressAction({required ExpandMode expandMode}) {
    emailAddressExpandMode.value = expandMode;
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(accountId, presentationEmail.id, readActions));
    }
  }

  void _markAsEmailReadSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    if (success is MarkAsEmailReadSuccess && success.readActions == ReadActions.markAsUnread) {
      backToThreadView();
    }
  }

  void _markAsEmailReadFailure(Failure failure) {
    backToThreadView();
  }

  void downloadAttachments(BuildContext context, List<Attachment> attachments) async {
    final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();

    if (Platform.isAndroid && needRequestPermission) {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted:
          _downloadAttachmentsAction(context, attachments);
          break;
        case PermissionStatus.permanentlyDenied:
          _appToast.showToast(AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments);
          break;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              _downloadAttachmentsAction(context, attachments);
              break;
            default:
              _appToast.showToast(AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments);
              break;
          }
        }
      }
    } else {
      _downloadAttachmentsAction(context, attachments);
    }
  }

  void _downloadAttachmentsAction(BuildContext context, List<Attachment> attachments) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl();
      await _downloadAttachmentsInteractor.execute(attachments, accountId, baseDownloadUrl)
        .then((result) => result.fold(
          (failure) => AppLocalizations.of(context).attachment_download_failed,
          (success) => AppLocalizations.of(context).attachment_download_successfully));
    }
  }

  bool canComposeEmail() => mailboxDashBoardController.sessionCurrent != null
      && mailboxDashBoardController.userProfile.value != null
      && mailboxDashBoardController.mapMailboxId.containsKey(PresentationMailbox.roleOutbox)
      && mailboxDashBoardController.selectedEmail.value != null;

  void backToThreadView() {
    popBack();
  }

  void pressEmailAction(EmailActionType emailActionType) {
    if (canComposeEmail()) {
      Get.toNamed(
        AppRoutes.COMPOSER,
        arguments: ComposerArguments(
          emailActionType: emailActionType,
          presentationEmail: mailboxDashBoardController.selectedEmail.value!,
          emailContent: emailContent,
          session: mailboxDashBoardController.sessionCurrent!,
          userProfile: mailboxDashBoardController.userProfile.value!,
          mapMailboxId: mailboxDashBoardController.mapMailboxId));
    }
  }
}