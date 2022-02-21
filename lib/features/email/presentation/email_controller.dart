import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:share/share.dart' as share_library;

class EmailController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final DownloadAttachmentsInteractor _downloadAttachmentsInteractor;
  final DeviceManager _deviceManager;
  final AppToast _appToast;
  final ExportAttachmentInteractor _exportAttachmentInteractor;
  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;

  final emailAddressExpandMode = ExpandMode.COLLAPSE.obs;
  final attachmentsExpandMode = ExpandMode.COLLAPSE.obs;
  final emailContents = <EmailContent>[].obs;
  final attachments = <Attachment>[].obs;
  EmailId? _currentEmailId;
  List<Color>? _currentAvatarColor;

  EmailController(
    this._getEmailContentInteractor,
    this._markAsEmailReadInteractor,
    this._downloadAttachmentsInteractor,
    this._deviceManager,
    this._appToast,
    this._exportAttachmentInteractor,
    this._moveToMailboxInteractor,
    this._markAsStarEmailInteractor,
  );

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedEmail.listen((presentationEmail) {
      if (_currentEmailId != presentationEmail?.id) {
        _currentEmailId = presentationEmail?.id;
        _currentAvatarColor = presentationEmail?.avatarColors;
        _clearEmailContent();
        final accountId = mailboxDashBoardController.accountId.value;
        if (accountId != null && presentationEmail != null) {
          _getEmailContentAction(accountId, presentationEmail.id);
          if (presentationEmail.isUnReadEmail()) {
            markAsEmailRead(presentationEmail, ReadActions.markAsRead);
          }
        }
      }
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.selectedEmail.close();
    super.onClose();
  }

  void _getEmailContentAction(AccountId accountId, EmailId emailId) async {
    final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl();
    consumeState(_getEmailContentInteractor.execute(accountId, emailId, baseDownloadUrl));
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
        } else if (failure is DownloadAttachmentsFailure) {
          _downloadAttachmentsFailure(failure);
        } else if (failure is ExportAttachmentFailure) {
          _exportAttachmentFailureAction(failure);
        }
      },
      (success) {
        if (success is GetEmailContentSuccess) {
          _getEmailContentSuccess(success);
        } else if (success is MarkAsEmailReadSuccess) {
          _markAsEmailReadSuccess(success);
        } else if (success is ExportAttachmentSuccess) {
          _exportAttachmentSuccessAction(success);
        } else if (success is MoveToMailboxSuccess) {
          _moveToMailboxSuccess(success);
        } else if (success is MarkAsStarEmailSuccess) {
          _markAsEmailStarSuccess(success);
        }
      });
  }

  @override
  void onError(error) {
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailContents.value = success.emailContents;
    attachments.value = success.attachments;
  }

  void _clearEmailContent() {
    toggleDisplayEmailAddressAction(expandMode: ExpandMode.COLLAPSE);
    attachmentsExpandMode.value = ExpandMode.COLLAPSE;
    emailContents.clear();
    attachments.clear();
  }

  void toggleDisplayEmailAddressAction({required ExpandMode expandMode}) {
    emailAddressExpandMode.value = expandMode;
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(accountId, presentationEmail.toEmail(), readActions));
    }
  }

  void _markAsEmailReadSuccess(Success success) {
    if (success is MarkAsEmailReadSuccess) {
      mailboxDashBoardController.setSelectedEmail(success.updatedEmail.toPresentationEmail(selectMode: SelectMode.ACTIVE, avatarColors: _currentAvatarColor));
    }
    mailboxDashBoardController.dispatchState(Right(success));

    if (success is MarkAsEmailReadSuccess
        && success.readActions == ReadActions.markAsUnread
        && Get.context != null
        && !responsiveUtils.isDesktop(Get.context!)
        && !responsiveUtils.isTabletLarge(Get.context!)) {
      backToThreadView();
    }
  }

  void _markAsEmailReadFailure(Failure failure) {
    if (failure is MarkAsEmailReadFailure
        && failure.readActions == ReadActions.markAsUnread
        && Get.context != null
        && !responsiveUtils.isDesktop(Get.context!)
        && !responsiveUtils.isTabletLarge(Get.context!)) {
      backToThreadView();
    }
  }

  void toggleDisplayAttachmentsAction() {
    final newExpandMode = attachmentsExpandMode.value == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;
    attachmentsExpandMode.value = newExpandMode;
  }

  void downloadAttachments(BuildContext context, List<Attachment> attachments) async {
    final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();

    if (needRequestPermission) {
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
      consumeState(_downloadAttachmentsInteractor.execute(attachments, accountId, baseDownloadUrl));
    }
  }

  void _downloadAttachmentsFailure(Failure failure) {
    if (Get.context != null) {
      _appToast.showErrorToast(AppLocalizations.of(Get.context!).attachment_download_failed);
    }
  }

  void exportAttachment(BuildContext context, Attachment attachment) {
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, attachment, cancelToken);
    _exportAttachmentAction(attachment, cancelToken);
  }

  void _showDownloadingFileDialog(BuildContext context, Attachment attachment, CancelToken cancelToken) {
    showCupertinoDialog(
      context: context,
      builder: (_) => (DownloadingFileDialogBuilder()
          ..key(Key('downloading_file_dialog'))
          ..title(AppLocalizations.of(context).preparing_to_export)
          ..content(AppLocalizations.of(context).downloading_file(attachment.name ?? ''))
          ..actionText(AppLocalizations.of(context).cancel)
          ..addCancelDownloadActionClick(() {
              cancelToken.cancel([AppLocalizations.of(context).user_cancel_download_file]);
              popBack();
            }))
        .build());
  }

  void _exportAttachmentAction(Attachment attachment, CancelToken cancelToken) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl();
      consumeState(_exportAttachmentInteractor.execute(attachment, accountId, baseDownloadUrl, cancelToken));
    }
  }

  void _exportAttachmentFailureAction(Failure failure) {
    if (failure is ExportAttachmentFailure && !(failure.exception is CancelDownloadFileException)) {
      popBack();
    }
  }

  void _exportAttachmentSuccessAction(Success success) async {
    popBack();
    if (success is ExportAttachmentSuccess) {
      await share_library.Share.shareFiles([success.filePath]);
    }
  }

  void openDestinationPickerView(PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;

    if (currentMailbox != null && accountId != null) {
      final destinationMailbox = await push(
        AppRoutes.DESTINATION_PICKER,
        arguments: DestinationPickerArguments(accountId, MailboxActions.moveEmail)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        _moveToMailbox(accountId, MoveRequest(
            [email.id],
            currentMailbox.id,
            destinationMailbox.id,
            MoveAction.moveTo,
            destinationPath: destinationMailbox.mailboxPath));
      }
    }
  }

  void _moveToMailbox(AccountId accountId, MoveRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    if (success is MoveToMailboxSuccess
        && success.moveAction == MoveAction.moveTo
        && Get.context != null && Get.overlayContext != null) {
      _appToast.showToastWithAction(
          Get.overlayContext!,
          AppLocalizations.of(Get.context!).moved_to_mailbox(success.destinationPath ?? ''),
          AppLocalizations.of(Get.context!).undo_action,
          () {
            final newMoveRequest = MoveRequest(
                [success.emailId],
                success.destinationMailboxId,
                success.currentMailboxId,
                MoveAction.undo);
            _undoMoveToMailbox(newMoveRequest);
          }
      );
    }
  }

  void _undoMoveToMailbox(MoveRequest newMoveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      _moveToMailbox(accountId, newMoveRequest);
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      final markStarAction = presentationEmail.isFlaggedEmail() ? MarkStarAction.unMarkStar : MarkStarAction.markStar;
      consumeState(_markAsStarEmailInteractor.execute(accountId, presentationEmail.toEmail(), markStarAction));
    }
  }

  void _markAsEmailStarSuccess(Success success) {
    if (success is MarkAsStarEmailSuccess) {
      mailboxDashBoardController.setSelectedEmail(success.updatedEmail.toPresentationEmail(selectMode: SelectMode.ACTIVE));
    }
    mailboxDashBoardController.dispatchState(Right(success));
  }

  bool canComposeEmail() => mailboxDashBoardController.sessionCurrent != null
      && mailboxDashBoardController.userProfile.value != null
      && mailboxDashBoardController.mapDefaultMailboxId.isNotEmpty
      && mailboxDashBoardController.selectedEmail.value != null;

  void backToThreadView() {
    popBack();
  }

  void pressEmailAction(EmailActionType emailActionType) {
    if (canComposeEmail()) {
      push(
        AppRoutes.COMPOSER,
        arguments: ComposerArguments(
          emailActionType: emailActionType,
          presentationEmail: mailboxDashBoardController.selectedEmail.value!,
          emailContents: emailContents,
          attachments: attachments,
          mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role,
          session: mailboxDashBoardController.sessionCurrent!,
          userProfile: mailboxDashBoardController.userProfile.value!,
          mapMailboxId: mailboxDashBoardController.mapDefaultMailboxId));
    }
  }
}