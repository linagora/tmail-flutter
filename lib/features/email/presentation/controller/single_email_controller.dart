import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mdn/disposition.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:model/model.dart';
import 'package:better_open_file/better_open_file.dart' as open_file;
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/calendar_event_interactor_bindings.dart';
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
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_dialog_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_dialog_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
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
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:uuid/uuid.dart';

class SingleEmailController extends BaseController with AppLoaderMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final emailSupervisorController = Get.find<EmailSupervisorController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();
  final _uuid = Get.find<Uuid>();
  final _downloadManager = Get.find<DownloadManager>();
  final _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final DownloadAttachmentsInteractor _downloadAttachmentsInteractor;
  final DeviceManager _deviceManager;
  final ExportAttachmentInteractor _exportAttachmentInteractor;
  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final StoreOpenedEmailInteractor _storeOpenedEmailInteractor;

  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  SendReceiptToSenderInteractor? _sendReceiptToSenderInteractor;
  ParseCalendarEventInteractor? _parseCalendarEventInteractor;

  final emailContents = RxnString();
  final attachments = <Attachment>[].obs;
  final calendarEvent = Rxn<CalendarEvent>();
  final eventActions = <EventAction>[].obs;
  final emailLoadedViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  EmailId? _currentEmailId;
  Identity? _identitySelected;
  EmailLoaded? _currentEmailLoaded;

  final StreamController<Either<Failure, Success>> _downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get downloadProgressState => _downloadProgressStateController.stream;

  PresentationEmail? get currentEmail => mailboxDashBoardController.selectedEmail.value;

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
    this._storeOpenedEmailInteractor
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    _listenDownloadAttachmentProgressState();
    super.onInit();
  }

  @override
  void onClose() {
    _downloadProgressStateController.close();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetEmailContentSuccess) {
      _getEmailContentSuccess(success);
    } else if (success is GetEmailContentFromCacheSuccess) {
      _getEmailContentOfflineSuccess(success);
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
    } else if (success is ParseCalendarEventLoading) {
      emailLoadedViewState.value = Right<Failure, Success>(success);
    } else if (success is ParseCalendarEventSuccess) {
      _handleParseCalendarEventSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is MarkAsEmailReadFailure) {
      _markAsEmailReadFailure(failure);
    } else if (failure is DownloadAttachmentsFailure) {
      _downloadAttachmentsFailure(failure);
    } else if (failure is ExportAttachmentFailure) {
      _exportAttachmentFailureAction(failure);
    } else if (failure is DownloadAttachmentForWebFailure) {
      _downloadAttachmentForWebFailureAction(failure);
    } else if (failure is ParseCalendarEventFailure) {
      _handleParseCalendarEventFailure(failure);
    } else if (failure is GetEmailContentFailure) {
      emailLoadedViewState.value = Left<Failure, Success>(failure);
    }
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _injectAndGetInteractorBindings(
          mailboxDashBoardController.sessionCurrent,
          accountId
        );
      }
    });

    ever<PresentationEmail?>(
      mailboxDashBoardController.selectedEmail,
      _handleOpenEmailDetailedView
    );

    ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is CloseEmailDetailedViewAction) {
        if (emailSupervisorController.supportedPageView.isTrue) {
          emailSupervisorController.popEmailQueue(_currentEmailId);
          emailSupervisorController.setCurrentEmailIndex(-1);
          emailSupervisorController.disposePageViewController();
        }
        _updateCurrentEmailId(null);
        _resetToOriginalValue();
        mailboxDashBoardController.clearSelectedEmail();
        mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
        mailboxDashBoardController.clearEmailUIAction();
      }
    });
  }

  bool isListEmailContainSelectedEmail(PresentationEmail selectedEmail) {
    return emailSupervisorController.currentListEmail.isNotEmpty 
      && emailSupervisorController.currentListEmail.listEmailIds.contains(selectedEmail.id);
  }

  void _handleOpenEmailDetailedView(PresentationEmail? selectedEmail) {
    if (selectedEmail == null || _currentEmailId == selectedEmail.id) {
      log('SingleEmailController::_handleOpenEmailDetailedView(): email unselected');
      return;
    }
    emailLoadedViewState.value = Right<Failure, Success>(GetEmailContentLoading());

    emailSupervisorController.updateNewCurrentListEmail();
    _updateCurrentEmailId(selectedEmail.id);
    _resetToOriginalValue();

    if (isListEmailContainSelectedEmail(selectedEmail)) {
      _createMultipleEmailViewAsPageView(selectedEmail.id!);
    } else {
      _createSingleEmailView(selectedEmail.id!);
    }

    if (!selectedEmail.hasRead) {
      markAsEmailRead(selectedEmail, ReadActions.markAsRead, MarkReadAction.tap);
    }

    if (_identitySelected == null) {
      _getAllIdentities();
    }
  }

  void _updateCurrentEmailId(EmailId? emailId) {
    _currentEmailId = emailId;
  }

  void _createMultipleEmailViewAsPageView(EmailId emailId) {
    log('SingleEmailController::_createMultipleEmailViewAsPageView():');
    emailSupervisorController.supportedPageView.value = true;
    emailSupervisorController.createPageControllerAndJumpToEmailById(emailId);
    _getEmailContentAction(emailId);
  }

  void _createSingleEmailView(EmailId emailId) {
    log('SingleEmailController::_createSingleEmailView():');
    emailSupervisorController.supportedPageView.value = false;
    _getEmailContentAction(emailId);
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

              if (currentOverlayContext != null && currentContext != null) {
                _appToast.showToastMessage(
                  currentOverlayContext!,
                  AppLocalizations.of(currentContext!).your_download_has_started,
                  leadingSVGIconColor: AppColor.primaryColor,
                  leadingSVGIcon: imagePaths.icDownload);
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
    _injectCalendarEventBindings(session, accountId);

    _createNewEmailRuleFilterInteractor = getBinding<CreateNewEmailRuleFilterInteractor>();
    _sendReceiptToSenderInteractor = getBinding<SendReceiptToSenderInteractor>();
    _parseCalendarEventInteractor = getBinding<ParseCalendarEventInteractor>();
  }

  void _injectCalendarEventBindings(Session? session, AccountId? accountId) {
    if (session != null && accountId != null) {
      if (CapabilityIdentifier.jamesCalendarEvent.isSupported(session, accountId)) {
        CalendarEventInteractorBindings().dependencies();
      }
    }
  }

  void _getAllIdentities() {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_getAllIdentitiesInteractor.execute(session, accountId));
    }
  }

  void _getAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      if (currentEmail != null) {
        final currentMailbox = getMailboxContain(currentEmail!);
        log('SingleEmailController::_getAllIdentitiesSuccess():currentMailbox: $currentMailbox');
        if (_isBelongToTeamMailboxes(currentMailbox)) {
          _setUpDefaultIdentityForTeamMailbox(success.identities!, currentMailbox!);
        } else {
          _setUpDefaultIdentity(success.identities!);
        }
      } else {
        _setUpDefaultIdentity(success.identities!);
      }
    }
  }

  bool _isBelongToTeamMailboxes(PresentationMailbox? presentationMailbox) {
    return presentationMailbox != null && presentationMailbox.isPersonal == false;
  }

  void _setUpDefaultIdentityForTeamMailbox(List<Identity> identities, PresentationMailbox currentMailbox) {
    final matchedTeamMailboxIdentity = identities.firstWhereOrNull((identity) => identity.email == currentMailbox.emailTeamMailBoxes);
    if (matchedTeamMailboxIdentity != null) {
      _identitySelected = matchedTeamMailboxIdentity;
    } else {
      _identitySelected = identities.first;
    }
  }

  void _setUpDefaultIdentity(List<Identity> identities) {
    _identitySelected = identities.first;
  }

  void _getEmailContentAction(EmailId emailId) async {
    final emailLoaded = emailSupervisorController.getEmailInQueueByEmailId(emailId);

    if (emailLoaded != null) {
      consumeState(Stream.value(Right<Failure, Success>(
        GetEmailContentSuccess(
          htmlEmailContent: emailLoaded.htmlContent,
          attachments: emailLoaded.attachments,
          emailCurrent: emailLoaded.emailCurrent
        )
      )));
    } else {
      final session = mailboxDashBoardController.sessionCurrent;
      final accountId = mailboxDashBoardController.accountId.value;
      if (session != null && accountId != null) {
        final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors.jmapUrl) ?? '';
        TransformConfiguration transformConfiguration = PlatformInfo.isWeb
          ? TransformConfiguration.forPreviewEmailOnWeb()
          : TransformConfiguration.forPreviewEmail();

        consumeState(_getEmailContentInteractor.execute(
          session,
          accountId,
          emailId,
          baseDownloadUrl,
          transformConfiguration
        ));
      }
    }
  }

  void _getEmailContentOfflineSuccess(GetEmailContentFromCacheSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    if (emailSupervisorController.presentationEmailsLoaded.length > ThreadConstants.defaultLimit.value.toInt()) {
      emailSupervisorController.popFirstEmailQueue();
    }
    emailSupervisorController.popEmailQueue(success.emailCurrent?.id);

    _currentEmailLoaded = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments),
      emailCurrent: success.emailCurrent,
    );
    emailSupervisorController.pushEmailQueue(_currentEmailLoaded!);

    if (success.emailCurrent?.id == currentEmail?.id) {
      attachments.value = success.attachments;

      if (_canParseCalendarEvent(blobIds: success.attachments.calendarEventBlobIds)) {
        _parseCalendarEventAction(
          accountId: mailboxDashBoardController.accountId.value!,
          blobIds: success.attachments.calendarEventBlobIds,
          emailContents: success.htmlEmailContent
        );
      } else {
        emailContents.value = success.htmlEmailContent;
      }

      final isShowMessageReadReceipt = success.emailCurrent?.hasReadReceipt(mailboxDashBoardController.mapMailboxById) == true;
      if (isShowMessageReadReceipt) {
        _handleReadReceipt();
      }
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    if (emailSupervisorController.presentationEmailsLoaded.length > ThreadConstants.defaultLimit.value.toInt()) {
      emailSupervisorController.popFirstEmailQueue();
    }
    emailSupervisorController.popEmailQueue(success.emailCurrent?.id);

    _currentEmailLoaded = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments),
      emailCurrent: success.emailCurrent,
    );
    emailSupervisorController.pushEmailQueue(_currentEmailLoaded!);

    if (success.emailCurrent?.id == currentEmail?.id) {
      attachments.value = success.attachments;

      if (_canParseCalendarEvent(blobIds: success.attachments.calendarEventBlobIds)) {
        _parseCalendarEventAction(
          accountId: mailboxDashBoardController.accountId.value!,
          blobIds: success.attachments.calendarEventBlobIds,
          emailContents: success.htmlEmailContent
        );
      } else {
        emailContents.value = success.htmlEmailContent;
      }

      if (PlatformInfo.isMobile) {
        final detailedEmail = DetailedEmail(
          emailId: currentEmail!.id!,
          createdTime: currentEmail?.receivedAt?.value ?? DateTime.now(),
          attachments: success.attachments,
          headers: currentEmail?.emailHeader?.toSet(),
          keywords: currentEmail?.keywords,
          htmlEmailContent: success.htmlEmailContent,
          messageId: success.emailCurrent?.messageId,
          references: success.emailCurrent?.references,
        );

        _storeOpenedEmailAction(
          mailboxDashBoardController.sessionCurrent,
          mailboxDashBoardController.accountId.value,
          detailedEmail
        );
      }

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
    emailContents.value = null;
    _currentEmailLoaded = null;
    attachments.clear();
    calendarEvent.value = null;
    eventActions.clear();
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

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions, MarkReadAction markReadAction) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_markAsEmailReadInteractor.execute(session, accountId, presentationEmail.toEmail(), readActions, markReadAction));
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

  void downloadAttachments(BuildContext context, List<Attachment> attachments) async {
    final needRequestPermission = await _deviceManager.isNeedRequestStoragePermissionOnAndroid();

    if (needRequestPermission) {
      final status = await Permission.storage.status;
      switch (status) {
        case PermissionStatus.granted:
          _downloadAttachmentsAction(attachments);
          break;
        case PermissionStatus.permanentlyDenied:
          if (context.mounted && currentOverlayContext != null && currentContext != null) {
            _appToast.showToastMessage(
              currentOverlayContext!,
              AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments,
            );
          }
          break;
        default: {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              _downloadAttachmentsAction(attachments);
              break;
            default:
              if (context.mounted && currentOverlayContext != null && currentContext != null) {
                _appToast.showToastMessage(
                  currentOverlayContext!,
                  AppLocalizations.of(context).you_need_to_grant_files_permission_to_download_attachments,
                );
              }
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
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors.jmapUrl);
      consumeState(_downloadAttachmentsInteractor.execute(attachments, accountId, baseDownloadUrl));
    }
  }

  void _downloadAttachmentsFailure(DownloadAttachmentsFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed);
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
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors.jmapUrl);
      consumeState(_exportAttachmentInteractor.execute(attachment, accountId, baseDownloadUrl, cancelToken));
    }
  }

  void _exportAttachmentFailureAction(ExportAttachmentFailure failure) {
    if (failure.exception is! CancelDownloadFileException) {
      popBack();

      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).attachment_download_failed);
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
      await Share.shareXFiles([XFile(downloadedResponse.filePath)]);
    }

    final openResult = await open_file.OpenFile.open(
        downloadedResponse.filePath,
        type: Platform.isAndroid ? downloadedResponse.mediaType!.mimeType : null,
        uti: Platform.isIOS ? downloadedResponse.mediaType!.getDocumentUti().value : null);

    if (openResult.type != open_file.ResultType.done) {
      logError('SingleEmailController::_openDownloadedPreviewWorkGroupDocument(): no preview available');
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).noPreviewAvailable);
      }
    }
  }

  void downloadAttachmentForWeb(BuildContext context, Attachment attachment) {
    _downloadAttachmentForWebAction(context, attachment);
  }

  void _downloadAttachmentForWebAction(BuildContext context, Attachment attachment) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent!.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors.jmapUrl);
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

    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed);
    }
  }

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    final currentMailbox = getMailboxContain(email);
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (currentMailbox != null && accountId != null) {
      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.moveEmail,
        session,
        mailboxIdSelected: currentMailbox.mailboxId
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox != null &&
          destinationMailbox is PresentationMailbox &&
          mailboxDashBoardController.sessionCurrent != null &&
          context.mounted
      ) {
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

  void _dispatchMoveToAction(
      BuildContext context,
      AccountId accountId,
      Session session,
      PresentationEmail emailSelected,
      PresentationMailbox currentMailbox,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      _moveToTrashAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveToSpamAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveToMailbox(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveToMailbox(BuildContext context, Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    closeEmailView(context);
    consumeState(_moveToMailboxInteractor.execute(session, accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showToastMessage(
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
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo)
      );
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      _moveToMailbox(currentContext!, session, accountId, newMoveRequest);
    }
  }

  void moveToTrash(BuildContext context, PresentationEmail email) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final trashMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleTrash);
    final currentMailbox = getMailboxContain(email);

    if (session != null && accountId != null && currentMailbox != null && trashMailboxId != null) {
      _moveToTrashAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [email.id!]},
          trashMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToTrash)
      );
    }
  }

  void _moveToTrashAction(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) {
    closeEmailView(context);
    mailboxDashBoardController.moveToMailbox(session, accountId, moveRequest);
  }

  void moveToSpam(BuildContext context, PresentationEmail email) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final currentMailbox = getMailboxContain(email);

    if (session != null && accountId != null && currentMailbox != null && spamMailboxId != null) {
      _moveToSpamAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [email.id!]},
          spamMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpam(BuildContext context, PresentationEmail email) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (session != null && accountId != null && spamMailboxId != null && inboxMailboxId != null) {
      _moveToSpamAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {spamMailboxId: [email.id!]},
          inboxMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.unSpam)
      );
    }
  }

  void _moveToSpamAction(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) {
    closeEmailView(context);
    mailboxDashBoardController.moveToMailbox(session, accountId, moveRequest);
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction markStarAction) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_markAsStarEmailInteractor.execute(session, accountId, presentationEmail.toEmail(), markStarAction));
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
        markAsEmailRead(presentationEmail, ReadActions.markAsUnread, MarkReadAction.tap);
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
    AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress);
  }

  void composeEmailFromEmailAddress(EmailAddress emailAddress) {
    popBack();
    mailboxDashBoardController.goToComposer(ComposerArguments.fromEmailAddress(emailAddress));
  }

  Future<void> openMailToLink(Uri? uri) async {
    log('SingleEmailController::openMailToLink(): ${uri.toString()}');
    String address = uri?.path ?? '';
    log('SingleEmailController::openMailToLink(): address: $address');
    if (address.isNotEmpty) {
      final emailAddress = EmailAddress(null, address);
      mailboxDashBoardController.goToComposer(ComposerArguments.fromEmailAddress(emailAddress));
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
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageNotSupportMdnWhenSendReceipt);
      return;
    }

    if (_identitySelected == null || _identitySelected?.id == null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageCannotFoundIdentityWhenSendReceipt);
      return;
    }

    if (currentEmail == null || _currentEmailId == null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageCannotFoundEmailIdWhenSendReceipt);
      return;
    }

    final receiverEmailAddress = _getReceiverEmailAddress(currentEmail!) ?? userProfile.email;
    log('SingleEmailController::_handleSendReceiptToSenderAction():receiverEmailAddress: $receiverEmailAddress');
    final mdnToSender = _generateMDN(context, currentEmail!, receiverEmailAddress);
    final sendReceiptRequest = SendReceiptToSenderRequest(
        mdn: mdnToSender,
        identityId: _identitySelected!.id!,
        sendId: Id(_uuid.v1()));
    log('SingleEmailController::_handleSendReceiptToSenderAction(): sendReceiptRequest: $sendReceiptRequest');

    consumeState(_sendReceiptToSenderInteractor!.execute(accountId, sendReceiptRequest));
  }

  String? _getReceiverEmailAddress(PresentationEmail presentationEmail) {
    final currentMailbox = getMailboxContain(presentationEmail);
    if (_isBelongToTeamMailboxes(currentMailbox)) {
      return currentMailbox!.emailTeamMailBoxes;
    } else {
      return null;
    }
  }

  MDN _generateMDN(BuildContext context, PresentationEmail email, String emailAddress) {
    final receiverEmailAddress = emailAddress;
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
      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageSendReceiptSuccess,
        leadingSVGIcon: imagePaths.icReadReceiptMessage);
    }
  }

  void closeEmailView(BuildContext context) {
    if (emailSupervisorController.supportedPageView.isTrue) {
      emailSupervisorController.popEmailQueue(_currentEmailId);
      emailSupervisorController.setCurrentEmailIndex(-1);
      emailSupervisorController.disposePageViewController();
    }
    mailboxDashBoardController.clearSelectedEmail();
    _updateCurrentEmailId(null);
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
        mailboxDashBoardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
      }
    }
  }

  bool get isOpenEmailNotMailboxFromRoute => emailSupervisorController.supportedPageView.isFalse
    && mailboxDashBoardController.selectedMailbox.value == null;

  void _updateRouteOnBrowser() {
    log('SingleEmailController::_updateRouteOnBrowser(): isSearchEmailRunning: ${mailboxDashBoardController.searchController.isSearchEmailRunning}');
    if (PlatformInfo.isWeb) {
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

  void pressEmailAction(
    EmailActionType emailActionType,
    PresentationEmail presentationEmail
  ) {
    switch(emailActionType) {
      case EmailActionType.compose:
        mailboxDashBoardController.goToComposer(ComposerArguments());
        break;
      case EmailActionType.reply:
        mailboxDashBoardController.goToComposer(
          ComposerArguments.replyEmail(
            presentationEmail: presentationEmail,
            content: _currentEmailLoaded?.htmlContent ?? '',
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: _currentEmailLoaded?.emailCurrent?.messageId,
            references: _currentEmailLoaded?.emailCurrent?.references,
          )
        );
        break;
      case EmailActionType.replyAll:
        mailboxDashBoardController.goToComposer(
          ComposerArguments.replyAllEmail(
            presentationEmail: presentationEmail,
            content: _currentEmailLoaded?.htmlContent ?? '',
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: _currentEmailLoaded?.emailCurrent?.messageId,
            references: _currentEmailLoaded?.emailCurrent?.references,
          )
        );
        break;
      case EmailActionType.forward:
        mailboxDashBoardController.goToComposer(
          ComposerArguments.forwardEmail(
            presentationEmail: presentationEmail,
            content: _currentEmailLoaded?.htmlContent ?? '',
            attachments: attachments,
            messageId: _currentEmailLoaded?.emailCurrent?.messageId,
            references: _currentEmailLoaded?.emailCurrent?.references,
          )
        );
        break;
      default:
        break;
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

      final newRuleFilterRequest = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.rulesFilterCreator, arguments: arguments)
        : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

      if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
        _createNewRuleFilterAction(accountId, newRuleFilterRequest);
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
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).newFilterWasCreated);
      }
    }
  }

  void toggleScrollPhysicsPagerView(bool leftDirection) {
    log('SingleEmailController::toggleScrollPhysicsPagerView():leftDirection: $leftDirection');
    if (leftDirection) {
      emailSupervisorController.moveToNextEmail();
    } else {
      emailSupervisorController.backToPreviousEmail();
    }
  }

  Future<bool> backButtonPressedCallbackAction(BuildContext context) async {
    if (PlatformInfo.isMobile) {
      closeEmailView(context);
    }
    return false;
  }

  void _storeOpenedEmailAction(Session? session, AccountId? accountId, DetailedEmail detailedEmail) async {
    if (session != null && accountId != null) {
      consumeState(_storeOpenedEmailInteractor.execute(session, accountId, detailedEmail));
    }
  }

  bool _canParseCalendarEvent({required Set<Id> blobIds}) {
    return _isCalendarEventSupported &&
      currentEmail?.hasCalendarEvent == true &&
      blobIds.isNotEmpty &&
      _parseCalendarEventInteractor != null;
  }

  bool get _isCalendarEventSupported {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    return session != null &&
      accountId != null &&
      CapabilityIdentifier.jamesCalendarEvent.isSupported(session, accountId);
  }

  void _parseCalendarEventAction({
    required AccountId accountId,
    required Set<Id> blobIds,
    required String emailContents
  }) {
    log("SingleEmailController::_parseCalendarEventAction:blobIds: $blobIds");
    consumeState(_parseCalendarEventInteractor!.execute(accountId, blobIds, emailContents));
  }

  void _handleParseCalendarEventSuccess(ParseCalendarEventSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    calendarEvent.value = success.calendarEventList.first;
    eventActions.value = success.eventActionList;
    if (PlatformInfo.isMobile) {
      _enableScrollPageView();
    }
  }

  void _handleParseCalendarEventFailure(ParseCalendarEventFailure failure) {
    emailLoadedViewState.value = Left<Failure, Success>(failure);
    emailContents.value = _currentEmailLoaded?.htmlContent;
  }

  void _enableScrollPageView() {
    emailSupervisorController.scrollPhysicsPageView.value = null;
  }

  void openNewTabAction(String link) {
    AppUtils.launchLink(link);
  }

  void openNewComposerAction(String mailTo) {
    final emailAddress = EmailAddress(mailTo, mailTo);
    mailboxDashBoardController.goToComposer(ComposerArguments.fromEmailAddress(emailAddress));
  }

  void openAttachmentList(BuildContext context, List<Attachment> attachments) {
    if (responsiveUtils.isMobile(context)) {
      (AttachmentListBottomSheetBuilder(context, attachments, imagePaths)
        ..onCloseButtonAction(() => popBack())
        ..onDownloadAttachmentFileAction((attachment) {
          if (PlatformInfo.isWeb) {
            downloadAttachmentForWeb(context, attachment);
          } else {
            exportAttachment(context, attachment);
          }
        })
      ).show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (BuildContext context) => 
          PointerInterceptor(
            child: (AttachmentListDialogBuilder(context, imagePaths, attachments, responsiveUtils)
              ..backgroundColor(Colors.black.withAlpha(24))
              ..onCloseButtonAction(() => popBack())
              ..onDownloadAttachmentFileAction((attachment) {
                if (PlatformInfo.isWeb) {
                  downloadAttachmentForWeb(context, attachment);
                } else {
                  exportAttachment(context, attachment);
                }
              })
            ).build()
          )
      );
    }
  }
}