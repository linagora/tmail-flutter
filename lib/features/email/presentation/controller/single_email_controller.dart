import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mdn/disposition.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:model/model.dart';
import 'package:better_open_file/better_open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:share/share.dart' as share_library;
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/send_receipt_to_sender_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/send_receipt_to_sender_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_dialog_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:uuid/uuid.dart';

class SingleEmailController extends BaseController with AppLoaderMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final emailSupervisorController = Get.find<EmailSupervisorController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();
  final _uuid = Get.find<Uuid>();
  final _downloadManager = Get.find<DownloadManager>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final DownloadAttachmentsInteractor _downloadAttachmentsInteractor;
  final DeviceManager _deviceManager;
  final ExportAttachmentInteractor _exportAttachmentInteractor;
  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  SendReceiptToSenderInteractor? _sendReceiptToSenderInteractor;

  final emailAddressExpandMode = ExpandMode.COLLAPSE.obs;
  final attachmentsExpandMode = ExpandMode.COLLAPSE.obs;
  final emailContents = <EmailContent>[].obs;
  final attachments = <Attachment>[].obs;
  EmailId? _currentEmailId;
  Identity? _identitySelected;
  List<EmailContent>? initialEmailContents;
  late Worker emailWorker, accountIdWorker;
  final Debouncer<int?> _getEmailDeBouncer = Debouncer<int?>(
    const Duration(milliseconds: 800),
    initialValue: null,
  );
  final StreamController<Either<Failure, Success>> _downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get downloadProgressState => _downloadProgressStateController.stream;

  PresentationEmail? get currentEmail => emailSupervisorController.selectedEmail.value;

  bool get isDisplayFullEmailAddress => emailAddressExpandMode.value == ExpandMode.EXPAND;

  bool get isDisplayFullAttachments => attachmentsExpandMode.value == ExpandMode.EXPAND;

  SingleEmailController(
    this._getEmailContentInteractor,
    this._markAsEmailReadInteractor,
    this._downloadAttachmentsInteractor,
    this._deviceManager,
    this._exportAttachmentInteractor,
    this._moveToMailboxInteractor,
    this._markAsStarEmailInteractor,
    this._downloadAttachmentForWebInteractor,
    this._getAllIdentitiesInteractor,
  );

  @override
  void onInit() {
    _initializeDebounceTimeIndexPageViewChange();
    _registerListenerWorker();
    _listenDownloadAttachmentProgressState();
    super.onInit();
  }

  @override
  void onClose() {
    _downloadProgressStateController.close();
    _getEmailDeBouncer.cancel();
    _unregisterListenerWorker();
    super.onClose();
  }

  void _initializeDebounceTimeIndexPageViewChange() {
    _getEmailDeBouncer.values.listen((value) async {
      if(value !=null) {
        _getEmailContentAction(emailSupervisorController.listEmail[value].id);
      }
    });
  }

  void _registerListenerWorker() {
    accountIdWorker = ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _injectAndGetInteractorBindings(
          mailboxDashBoardController.sessionCurrent,
          accountId
        );
      }
    });

    emailWorker = ever(emailSupervisorController.selectedEmail, (presentationEmail) {
      log('SingleEmailController::_initWorker(): $presentationEmail');
      if (presentationEmail is PresentationEmail) {
        if (_currentEmailId != presentationEmail.id) {
          _currentEmailId = presentationEmail.id;
          if (emailSupervisorController.listEmail.isNotEmpty) {
            emailSupervisorController.supportedPageView.value = true;
            emailSupervisorController.setCurrentPositionEmailInListEmail(_currentEmailId);
            _getEmailDeBouncer.value = emailSupervisorController.currentIndexPageView;
          } else {
            emailSupervisorController.supportedPageView.value = false;
            _getEmailContentAction(presentationEmail.id);
          }
          _resetToOriginalValue();
          if (!presentationEmail.hasRead) {
            markAsEmailRead(presentationEmail, ReadActions.markAsRead);
          }
          if(_identitySelected == null) {
            _getAllIdentities();
          }
        }
      }
    });
  }

  void _unregisterListenerWorker() {
    emailWorker.dispose();
  }

  void _listenDownloadAttachmentProgressState() {
    downloadProgressState.listen((state) {
        log('SingleEmailController::_listenDownloadAttachmentProgressState(): $state');
        state.fold(
          (failure) => null,
          (success) {
            if (success is StartDownloadAttachmentForWeb) {
              emailSupervisorController.mailboxDashBoardController.addDownloadTask(
                  DownloadTaskState(
                    taskId: success.taskId,
                    attachment: success.attachment));

              if (currentOverlayContext != null &&  currentContext != null) {
                _appToast.showToastWithIcon(currentOverlayContext!,
                    message: AppLocalizations.of(currentContext!).your_download_has_started,
                    iconColor: AppColor.primaryColor,
                    icon: imagePaths.icDownload);
              }
            } else if (success is DownloadingAttachmentForWeb) {
              final percent = success.progress.round();
              log('SingleEmailController::DownloadingAttachmentForWeb(): $percent%');

              emailSupervisorController.mailboxDashBoardController.updateDownloadTask(
                  success.taskId,
                  (currentTask) {
                      final newTask = currentTask.copyWith(
                        progress: success.progress,
                        downloaded: success.downloaded,
                        total: success.total);

                      return newTask;
                  });
            }
          });
    });
  }

  void _injectAndGetInteractorBindings(Session? session, AccountId accountId) {
    injectRuleFilterBindings(session, accountId);
    injectMdnBindings(session, accountId);

    if (Get.isRegistered<CreateNewEmailRuleFilterInteractor>()) {
      _createNewEmailRuleFilterInteractor = Get.find<CreateNewEmailRuleFilterInteractor>();
    }
    if (Get.isRegistered<SendReceiptToSenderInteractor>()) {
      _sendReceiptToSenderInteractor = Get.find<SendReceiptToSenderInteractor>();
    }
  }

  void _getAllIdentities() {
    final accountId = emailSupervisorController.accountId;
    if (accountId != null) {
      consumeState(_getAllIdentitiesInteractor.execute(accountId));
    }
  }

  void _getAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      try {
        final identityDefault = success.identities!
            .firstWhere((identity) => identity.mayDelete == false);
        _identitySelected = identityDefault;
      } catch (e) {
        logError('SingleEmailController::_getAllIdentitiesSuccess(): ${e.toString()}');
        _identitySelected = success.identities!.first;
      }
    }
  }

  void _getEmailContentAction(EmailId emailId) async {
    final accountId = emailSupervisorController.accountId;
    final baseDownloadUrl = emailSupervisorController.sessionCurrent?.getDownloadUrl();
    final currentEmail = emailSupervisorController.presentationEmailsLoaded.where((e) => e.emailCurrent!.id == emailId);
    EmailLoaded? emailLoaded;
    if(currentEmail.isNotEmpty) {
      emailLoaded = currentEmail.first;
      dispatchState(Right<Failure, Success>(GetEmailContentLoading()));
      await Future.delayed(const Duration(milliseconds: 300));
      consumeState(Stream.value(Right<Failure, Success>(GetEmailContentSuccess(
        emailLoaded.emailContents,
        emailLoaded.emailContentsDisplayed,
        emailLoaded.attachments,
        emailLoaded.emailCurrent))));
    } else if (accountId != null && baseDownloadUrl != null) {
      consumeState(_getEmailContentInteractor.execute(accountId, emailId, baseDownloadUrl));
    }
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
        } else if (failure is DownloadAttachmentForWebFailure) {
          _downloadAttachmentForWebFailureAction(failure);
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
        } else if (success is DownloadAttachmentForWebSuccess) {
          _downloadAttachmentForWebSuccessAction(success);
        } else if (success is GetAllIdentitiesSuccess) {
          _getAllIdentitiesSuccess(success);
        } else if (success is SendReceiptToSenderSuccess) {
          _sendReceiptToSenderSuccess(success);
        } else if (success is CreateNewRuleFilterSuccess) {
          _createNewRuleFilterSuccess(success);
        }
      });
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    if(emailSupervisorController.presentationEmailsLoaded.length > ThreadConstants.defaultLimit.value.toInt()) {
      emailSupervisorController.presentationEmailsLoaded.removeFirst();
    }
    final emailLoaded = EmailLoaded(
      success.emailContents.toList(),
      success.emailContentsDisplayed.toList(),
      success.attachments.toList(),
      success.emailCurrent,
    );
    emailSupervisorController.presentationEmailsLoaded.removeWhere((e) => e.emailCurrent!.id == emailLoaded.emailCurrent!.id);
    emailSupervisorController.presentationEmailsLoaded.add(emailLoaded);
    if(success.emailCurrent?.id == mailboxDashBoardController.selectedEmail.value?.id) {
      emailContents.value = success.emailContentsDisplayed;
      initialEmailContents = success.emailContents;
      attachments.value = success.attachments;

      final isShowMessageReadReceipt = success.emailCurrent
          ?.hasReadReceipt(mailboxDashBoardController.mapMailboxById) == true;
      if (isShowMessageReadReceipt) {
        _handleReadReceipt();
      }
    }
  }

  void _handleReadReceipt() {
    if (currentContext != null) {
      showConfirmDialogAction(currentContext!,
        AppLocalizations.of(currentContext!).subTitleReadReceiptRequestNotificationMessage,
        AppLocalizations.of(currentContext!).yes,
        onConfirmAction: () => _handleSendReceiptToSenderAction(currentContext!),
        showAsBottomSheet: true,
        title: AppLocalizations.of(currentContext!).titleReadReceiptRequestNotificationMessage,
        cancelTitle: AppLocalizations.of(currentContext!).no,
        icon: SvgPicture.asset(imagePaths.icReadReceiptMessage, fit: BoxFit.fill),
      );
    }
  }

  void _resetToOriginalValue() {
    attachmentsExpandMode.value = ExpandMode.COLLAPSE;
    emailAddressExpandMode.value = ExpandMode.COLLAPSE;
    emailContents.clear();
    initialEmailContents?.clear();
    attachments.clear();
  }

  PresentationMailbox? getMailboxContain(PresentationEmail email) {
    if (mailboxDashBoardController.selectedMailbox.value == null) {
      return email.findMailboxContain(mailboxDashBoardController.mapMailboxById);
    } else {
      return mailboxDashBoardController.searchController.isSearchEmailRunning
        ? email.findMailboxContain(mailboxDashBoardController.mapMailboxById)
        : mailboxDashBoardController.selectedMailbox.value;
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = getMailboxContain(presentationEmail);
    if (accountId != null && mailboxCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(accountId, presentationEmail.toEmail(), readActions));
    }
  }

  void _markAsEmailReadSuccess(Success success) {
    log('SingleEmailController::_markAsEmailReadSuccess(): $success');
    mailboxDashBoardController.dispatchState(Right(success));

    if (success is MarkAsEmailReadSuccess
        && success.readActions == ReadActions.markAsUnread
        && currentContext != null) {
      closeEmailView(currentContext!);
    }
  }

  void _markAsEmailReadFailure(Failure failure) {
    if (failure is MarkAsEmailReadFailure
        && failure.readActions == ReadActions.markAsUnread
        && currentContext != null) {
      closeEmailView(currentContext!);
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
          _downloadAttachmentsAction(attachments);
          break;
        case PermissionStatus.permanentlyDenied:
          _appToast.showToast(AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments);
          break;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              _downloadAttachmentsAction(attachments);
              break;
            default:
              _appToast.showToast(AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments);
              break;
          }
        }
      }
    } else {
      _downloadAttachmentsAction(attachments);
    }
  }

  void _downloadAttachmentsAction(List<Attachment> attachments) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl();
      consumeState(_downloadAttachmentsInteractor.execute(attachments, accountId, baseDownloadUrl));
    }
  }

  void _downloadAttachmentsFailure(DownloadAttachmentsFailure failure) {
    if (currentContext != null) {
      _appToast.showErrorToast(AppLocalizations.of(currentContext!).attachment_download_failed);
    }
  }

  void exportAttachment(BuildContext context, Attachment attachment) {
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, attachment, cancelToken: cancelToken);
    _exportAttachmentAction(attachment, cancelToken);
  }

  void _showDownloadingFileDialog(BuildContext context, Attachment attachment, {CancelToken? cancelToken}) {
    if (cancelToken != null) {
      showCupertinoDialog(
          context: context,
          builder: (_) =>
              PointerInterceptor(child: (DownloadingFileDialogBuilder()
                    ..key(const Key('downloading_file_dialog'))
                    ..title(AppLocalizations.of(context).preparing_to_export)
                    ..content(AppLocalizations.of(context).downloading_file(attachment.name ?? ''))
                    ..actionText(AppLocalizations.of(context).cancel)
                    ..addCancelDownloadActionClick(() {
                      cancelToken.cancel([AppLocalizations.of(context).user_cancel_download_file]);
                      popBack();
                    }))
                .build()));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) =>
              PointerInterceptor(child: (DownloadingFileDialogBuilder()
                  ..key(const Key('downloading_file_for_web_dialog'))
                  ..title(AppLocalizations.of(context).preparing_to_save)
                  ..content(AppLocalizations.of(context).downloading_file(attachment.name ?? '')))
                .build()));
    }
  }

  void _exportAttachmentAction(Attachment attachment, CancelToken cancelToken) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl();
      consumeState(_exportAttachmentInteractor.execute(attachment, accountId, baseDownloadUrl, cancelToken));
    }
  }

  void _exportAttachmentFailureAction(ExportAttachmentFailure failure) {
    if (failure.exception is! CancelDownloadFileException) {
      popBack();
      if (currentContext != null) {
        _appToast.showErrorToast(AppLocalizations.of(currentContext!).attachment_download_failed);
      }
    }
  }

  void _exportAttachmentSuccessAction(ExportAttachmentSuccess success) async {
    popBack();
    _openDownloadedPreviewWorkGroupDocument(success.downloadedResponse);
  }

  void _openDownloadedPreviewWorkGroupDocument(DownloadedResponse downloadedResponse) async {
    log('SingleEmailController::_openDownloadedPreviewWorkGroupDocument(): $downloadedResponse');
    if (downloadedResponse.mediaType == null) {
      await share_library.Share.shareFiles([downloadedResponse.filePath]);
    }

    final openResult = await open_file.OpenFile.open(
        downloadedResponse.filePath,
        type: Platform.isAndroid ? downloadedResponse.mediaType!.mimeType : null,
        uti: Platform.isIOS ? downloadedResponse.mediaType!.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      logError('SingleEmailController::_openDownloadedPreviewWorkGroupDocument(): no preview available');
      if (currentContext != null) {
        _appToast.showErrorToast(AppLocalizations.of(currentContext!).noPreviewAvailable);
      }
    }
  }

  void downloadAttachmentForWeb(BuildContext context, Attachment attachment) {
    _downloadAttachmentForWebAction(context, attachment);
  }

  void _downloadAttachmentForWebAction(BuildContext context, Attachment attachment) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl();
      final generateTaskId = DownloadTaskId(_uuid.v4());
      consumeState(_downloadAttachmentForWebInteractor.execute(
          generateTaskId,
          attachment,
          accountId,
          baseDownloadUrl,
          _downloadProgressStateController));
    }
  }

  void _downloadAttachmentForWebSuccessAction(DownloadAttachmentForWebSuccess success) {
    log('SingleEmailController::_downloadAttachmentForWebSuccessAction():');
    mailboxDashBoardController.deleteDownloadTask(success.taskId);

    _downloadManager.createAnchorElementDownloadFileWeb(
        success.bytes,
        success.attachment.generateFileName());
  }

  void _downloadAttachmentForWebFailureAction(DownloadAttachmentForWebFailure failure) {
    log('SingleEmailController::_downloadAttachmentForWebFailureAction(): $failure');
    mailboxDashBoardController.deleteDownloadTask(failure.taskId);

    if (currentOverlayContext != null &&  currentContext != null) {
      _appToast.showToastWithIcon(currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).attachment_download_failed,
          bgColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          iconColor: Colors.white,
          icon: imagePaths.icDownload);
    }
  }

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    final currentMailbox = getMailboxContain(email);
    final accountId = mailboxDashBoardController.accountId.value;

    if (currentMailbox != null && accountId != null) {
      final arguments = DestinationPickerArguments(accountId, MailboxActions.moveEmail);
      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              if (mailboxDashBoardController.sessionCurrent != null) {
                _dispatchMoveToAction(
                    context,
                    accountId,
                    mailboxDashBoardController.sessionCurrent!,
                    email,
                    currentMailbox,
                    destinationMailbox);
              }
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox != null &&
            destinationMailbox is PresentationMailbox &&
            mailboxDashBoardController.sessionCurrent != null) {
          _dispatchMoveToAction(
              context,
              accountId,
              mailboxDashBoardController.sessionCurrent!,
              email,
              currentMailbox,
              destinationMailbox);
        }
      }
    }
  }

  void _dispatchMoveToAction(
      BuildContext context,
      AccountId accountId,
      Session session,
      PresentationEmail emailSelected,
      PresentationMailbox currentMailbox,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      _moveToTrashAction(context, accountId, MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveToSpamAction(context, accountId, MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveToMailbox(context, accountId, MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveToMailbox(BuildContext context, AccountId accountId, MoveToMailboxRequest moveRequest) {
    closeEmailView(context);
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showBottomToast(
        currentOverlayContext!,
        success.emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: success.destinationPath),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          _revertedToOriginalMailbox(MoveToMailboxRequest(
              {success.destinationMailboxId: [success.emailId]},
              success.currentMailboxId,
              MoveAction.undo,
              mailboxDashBoardController.sessionCurrent!,
              success.emailActionType));
        },
        leadingIcon: SvgPicture.asset(
            imagePaths.icFolderMailbox,
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.fill),
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        textActionColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
        maxWidth: responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      _moveToMailbox(currentContext!, accountId, newMoveRequest);
    }
  }

  void moveToTrash(BuildContext context, PresentationEmail email) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final trashMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleTrash);
    final currentMailbox = getMailboxContain(email);

    if (accountId != null && currentMailbox != null && trashMailboxId != null) {
      _moveToTrashAction(context, accountId, MoveToMailboxRequest(
        {currentMailbox.id: [email.id]},
        trashMailboxId,
        MoveAction.moving,
        mailboxDashBoardController.sessionCurrent!,
        EmailActionType.moveToTrash)
      );
    }
  }

  void _moveToTrashAction(BuildContext context, AccountId accountId, MoveToMailboxRequest moveRequest) {
    closeEmailView(context);
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void moveToSpam(BuildContext context, PresentationEmail email) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final currentMailbox = getMailboxContain(email);

    if (accountId != null && currentMailbox != null && spamMailboxId != null) {
      _moveToSpamAction(context, accountId, MoveToMailboxRequest(
          {currentMailbox.id: [email.id]},
          spamMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpam(BuildContext context, PresentationEmail email) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (accountId != null && spamMailboxId != null && inboxMailboxId != null) {
      _moveToSpamAction(context, accountId, MoveToMailboxRequest(
          {spamMailboxId: [email.id]},
          inboxMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.unSpam)
      );
    }
  }

  void _moveToSpamAction(BuildContext context, AccountId accountId, MoveToMailboxRequest moveRequest) {
    closeEmailView(context);
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction markStarAction) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = getMailboxContain(presentationEmail);
    if (accountId != null && mailboxCurrent != null) {
      consumeState(_markAsStarEmailInteractor.execute(accountId, presentationEmail.toEmail(), markStarAction));
    }
  }

  void _markAsEmailStarSuccess(Success success) {
    if (success is MarkAsStarEmailSuccess) {
      final selectedEmail = mailboxDashBoardController.selectedEmail.value;
      mailboxDashBoardController.setSelectedEmail(selectedEmail?.updateKeywords(success.updatedEmail.keywords));
    }
    mailboxDashBoardController.dispatchState(Right(success));
  }

  void handleEmailAction(BuildContext context, PresentationEmail presentationEmail, EmailActionType actionType) {
    switch(actionType) {
      case EmailActionType.markAsUnread:
        popBack();
        markAsEmailRead(presentationEmail, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        markAsStarEmail(presentationEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        markAsStarEmail(presentationEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        moveToMailbox(context, presentationEmail);
        break;
      case EmailActionType.moveToTrash:
        moveToTrash(context, presentationEmail);
        break;
      case EmailActionType.deletePermanently:
        deleteEmailPermanently(context, presentationEmail);
        break;
      case EmailActionType.moveToSpam:
        popBack();
        moveToSpam(context, presentationEmail);
        break;
      case EmailActionType.unSpam:
        popBack();
        unSpam(context, presentationEmail);
        break;
      default:
        break;
    }
  }

  void expandEmailAddress() {
    emailAddressExpandMode.value = ExpandMode.EXPAND;
  }

  void collapseEmailAddress() {
    emailAddressExpandMode.value = ExpandMode.COLLAPSE;
  }

  void openEmailAddressDialog(BuildContext context, EmailAddress emailAddress) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (EmailAddressBottomSheetBuilder(context, imagePaths, emailAddress)
        ..addOnCloseContextMenuAction(() => popBack())
        ..addOnCopyEmailAddressAction((emailAddress) => copyEmailAddress(context, emailAddress))
        ..addOnComposeEmailAction((emailAddress) => composeEmailFromEmailAddress(emailAddress))
        ..addOnQuickCreatingRuleEmailBottomSheetAction((emailAddress) => quickCreatingRule(context, emailAddress))
      ).show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (BuildContext context) => PointerInterceptor(
          child: EmailAddressDialogBuilder(
            emailAddress,
            onCloseDialogAction: () => popBack(),
            onCopyEmailAddressAction: (emailAddress) => copyEmailAddress(context, emailAddress),
            onComposeEmailAction: (emailAddress) => composeEmailFromEmailAddress(emailAddress),
            onQuickCreatingRuleEmailDialogAction: (emailAddress) => quickCreatingRule(context, emailAddress)
          )
        )
      );
    }
  }

  void copyEmailAddress(BuildContext context, EmailAddress emailAddress) {
    popBack();

    Clipboard.setData(ClipboardData(text: emailAddress.emailAddress)).then((_){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).email_address_copied_to_clipboard))
      );
    });
  }

  void composeEmailFromEmailAddress(EmailAddress emailAddress) {
    popBack();

    final arguments = ComposerArguments(
        emailActionType: EmailActionType.composeFromEmailAddress,
        emailAddress: emailAddress,
        mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

    mailboxDashBoardController.goToComposer(arguments);
  }

  void openMailToLink(Uri? uri) {
    log('SingleEmailController::openMailToLink(): ${uri.toString()}');
    String address = uri?.path ?? '';
    log('SingleEmailController::openMailToLink(): address: $address');
    if (address.isNotEmpty) {
      final emailAddress = EmailAddress(null, address);
      final arguments = ComposerArguments(
          emailActionType: EmailActionType.composeFromEmailAddress,
          emailAddress: emailAddress,
          mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

      mailboxDashBoardController.goToComposer(arguments);
    }
  }

  void deleteEmailPermanently(BuildContext context, PresentationEmail email) {
    if (responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(DeleteActionType.single.getContentDialog(context))
          ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
              ..key(const Key('confirm_dialog_delete_email_permanently'))
              ..title(DeleteActionType.single.getTitleDialog(context))
              ..content(DeleteActionType.single.getContentDialog(context))
              ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
            .build()));
    }
  }

  void _deleteEmailPermanentlyAction(BuildContext context, PresentationEmail email) {
    popBack();
    closeEmailView(context);
    mailboxDashBoardController.deleteEmailPermanently(email);
  }

  void _handleSendReceiptToSenderAction(BuildContext context) {
    final accountId = mailboxDashBoardController.accountId.value;
    final userProfile = mailboxDashBoardController.userProfile.value;
    if (accountId == null || userProfile == null) {
      return;
    }

    if (_sendReceiptToSenderInteractor == null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(context).toastMessageNotSupportMdnWhenSendReceipt,
          leadingIcon: SvgPicture.asset(
              imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: responsiveUtils.getMaxWidthToast(currentContext!));
      return;
    }

    if (_identitySelected == null || _identitySelected?.id == null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(context).toastMessageCannotFoundIdentityWhenSendReceipt,
          leadingIcon: SvgPicture.asset(
              imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: responsiveUtils.getMaxWidthToast(currentContext!));
      return;
    }

    if (currentEmail == null || _currentEmailId == null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(context).toastMessageCannotFoundEmailIdWhenSendReceipt,
          leadingIcon: SvgPicture.asset(
              imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: responsiveUtils.getMaxWidthToast(currentContext!));
      return;
    }

    final mdnToSender = _generateMDN(context, currentEmail!, userProfile);
    final sendReceiptRequest = SendReceiptToSenderRequest(
        mdn: mdnToSender,
        identityId: _identitySelected!.id!,
        sendId: Id(_uuid.v1()));
    log('SingleEmailController::_handleSendReceiptToSenderAction(): sendReceiptRequest: $sendReceiptRequest');

    consumeState(_sendReceiptToSenderInteractor!.execute(accountId, sendReceiptRequest));
  }

  MDN _generateMDN(BuildContext context, PresentationEmail email, UserProfile userProfile) {
    final receiverEmailAddress = userProfile.email;
    final subjectEmail = email.subject ?? '';
    final timeCurrent = DateTime.now();
    final timeAsString = '${timeCurrent.formatDate(
        pattern: 'EEE, d MMM yyyy HH:mm:ss')} (${timeCurrent.timeZoneName})';

    final mdnToSender = MDN(
        forEmailId: email.id,
        subject: AppLocalizations.of(context).subjectSendReceiptToSender(subjectEmail),
        textBody: AppLocalizations.of(context).textBodySendReceiptToSender(
            receiverEmailAddress,
            subjectEmail,
            timeAsString),
        disposition: Disposition(
            ActionMode.manual,
            SendingMode.manually,
            DispositionType.displayed));

    return mdnToSender;
  }

  void _sendReceiptToSenderSuccess(SendReceiptToSenderSuccess success) {
    log('SingleEmailController::_sendReceiptToSenderSuccess(): ${success.mdn.toString()}');
    if (currentContext != null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageSendReceiptSuccess,
          leadingIcon: SvgPicture.asset(
              imagePaths.icReadReceiptMessage,
              width: 24,
              height: 24,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: responsiveUtils.getMaxWidthToast(currentContext!));
    }
  }

  void closeEmailView(BuildContext context) {
    log('SingleEmailController::closeEmailView(): ');
    if (emailSupervisorController.supportedPageView.isTrue) {
      emailSupervisorController.presentationEmailsLoaded.removeWhere((e) => e.emailCurrent?.id == currentEmail?.id);
      emailSupervisorController.currentIndexPageView = -1;
      _getEmailDeBouncer.value = null;
    }
    mailboxDashBoardController.clearSelectedEmail();
    _currentEmailId = null;
    _resetToOriginalValue();
    _updateRouteOnBrowser();
    if (mailboxDashBoardController.searchController.isSearchEmailRunning) {
      if (responsiveUtils.isWebDesktop(context)) {
        mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
      } else {
        mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
      }
    } else {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
      if (isOpenEmailNotMailboxFromRoute) {
        mailboxDashBoardController.dispatchAction(SelectMailboxDefaultAction());
      }
    }
  }

  bool get isOpenEmailNotMailboxFromRoute => emailSupervisorController.supportedPageView.isFalse
    && mailboxDashBoardController.selectedMailbox.value == null;

  void _updateRouteOnBrowser() {
    log('SingleEmailController::_updateRouteOnBrowser(): isSearchEmailRunning: ${mailboxDashBoardController.searchController.isSearchEmailRunning}');
    if (BuildUtils.isWeb) {
      final selectedMailboxId = mailboxDashBoardController.selectedMailbox.value?.id;
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          mailboxId: selectedMailboxId,
          dashboardType: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? DashboardType.search
            : DashboardType.normal
        )
      );
      RouteUtils.updateRouteOnBrowser('Mailbox-${selectedMailboxId?.id.value}', route);
    }
  }

  void pressEmailAction(EmailActionType emailActionType) {
    if (emailActionType == EmailActionType.compose) {
      mailboxDashBoardController.goToComposer(ComposerArguments());
    } else {
      final arguments = ComposerArguments(
          emailActionType: emailActionType,
          presentationEmail: mailboxDashBoardController.selectedEmail.value!,
          emailContents: initialEmailContents,
          attachments: emailActionType == EmailActionType.forward ? attachments : null,
          mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

      mailboxDashBoardController.goToComposer(arguments);
    }
  }

  void quickCreatingRule(BuildContext context, EmailAddress emailAddress) async {
    popBack();

    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = RulesFilterCreatorArguments(
        accountId,
        session,
        emailAddress: emailAddress);

      if (BuildUtils.isWeb) {
        showDialogRuleFilterCreator(
          context: context,
          arguments: arguments,
          onCreatedRuleFilter: (arguments) {
            if (arguments is CreateNewEmailRuleFilterRequest) {
              _createNewRuleFilterAction(accountId, arguments);
            }
          }
        );
      } else {
        final newRuleFilterRequest = await push(
          AppRoutes.rulesFilterCreator,
          arguments: arguments
        );

        if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
          _createNewRuleFilterAction(accountId, newRuleFilterRequest);
        }
      }
    }
  }

  void _createNewRuleFilterAction(
      AccountId accountId,
      CreateNewEmailRuleFilterRequest ruleFilterRequest
  ) async {
    try {
      _createNewEmailRuleFilterInteractor = Get.find<CreateNewEmailRuleFilterInteractor>();
    } catch (e) {
      logError('SingleEmailController::onInit(): ${e.toString()}');
    }
    if (_createNewEmailRuleFilterInteractor != null) {
      consumeState(_createNewEmailRuleFilterInteractor!.execute(accountId, ruleFilterRequest));
    }
  }

  void _createNewRuleFilterSuccess(CreateNewRuleFilterSuccess success) {
    if (success.newListRules.isNotEmpty == true) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).newFilterWasCreated,
          icon: imagePaths.icSelected);
      }
    }
  }

  void toggleScrollPhysicsPagerView(bool leftDirection) {
    log('SingleEmailController::toggleScrollPhysicsPagerView():leftDirection: $leftDirection');
    log('SingleEmailController::toggleScrollPhysicsPagerView():canGetOlderEmail: ${emailSupervisorController.canGetOlderEmail.isTrue}');
    log('SingleEmailController::toggleScrollPhysicsPagerView():canGetNewerEmail: ${emailSupervisorController.canGetNewerEmail.isTrue}');

    if (leftDirection) {
      if (emailSupervisorController.canGetNewerEmail.isTrue) {
        emailSupervisorController.getNewerEmail();
      }
    } else {
      if (emailSupervisorController.canGetOlderEmail.isTrue) {
        emailSupervisorController.getOlderEmail();
      }
    }
  }
}