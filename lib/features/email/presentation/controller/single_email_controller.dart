import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:better_open_file/better_open_file.dart' as open_file;
import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_unescape_html_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/new_line_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/presentation/utils/html_transformer/dom/sanitize_hyper_link_tag_in_html_transformers.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mdn/disposition.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:model/email/eml_attachment.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/calendar_event_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/preview_email_eml_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_maybe_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reject_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_pdf_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/send_receipt_to_sender_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_event_attendance_status_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/maybe_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_reject_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/send_receipt_to_sender_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_event_attendance_status_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/calendar_event_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_organizer_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_list/attachment_list_dialog_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_dialog_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/html_attachment_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_viewer.dart';
import 'package:tmail_ui_user/features/email_previewer/email_previewer_dialog_view.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
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
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SingleEmailController extends BaseController with AppLoaderMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final emailSupervisorController = Get.find<EmailSupervisorController>();
  final _downloadManager = Get.find<DownloadManager>();
  final _printUtils = Get.find<PrintUtils>();
  final _attachmentListScrollController = ScrollController();

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
  final PrintEmailInteractor _printEmailInteractor;
  final StoreEventAttendanceStatusInteractor _storeEventAttendanceStatusInteractor;
  final ParseEmailByBlobIdInteractor _parseEmailByBlobIdInteractor;
  final PreviewEmailFromEmlFileInteractor _previewEmailFromEmlFileInteractor;
  final GetHtmlContentFromAttachmentInteractor _getHtmlContentFromAttachmentInteractor;
  final DownloadAllAttachmentsForWebInteractor _downloadAllAttachmentsForWebInteractor;
  final ExportAllAttachmentsInteractor _exportAllAttachmentsInteractor;

  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  SendReceiptToSenderInteractor? _sendReceiptToSenderInteractor;
  ParseCalendarEventInteractor? _parseCalendarEventInteractor;
  AcceptCalendarEventInteractor? _acceptCalendarEventInteractor;
  MaybeCalendarEventInteractor? _maybeCalendarEventInteractor;
  RejectCalendarEventInteractor? _rejectCalendarEventInteractor;

  final emailContents = RxnString();
  final attachments = <Attachment>[].obs;
  final blobCalendarEvent = Rxn<BlobCalendarEvent>();
  final emailLoadedViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final emailUnsubscribe = Rxn<EmailUnsubscribe>();
  final attachmentsViewState = RxMap<Id, Either<Failure, Success>>();
  final isEmailContentHidden = RxBool(false);
  final currentEmailLoaded = Rxn<EmailLoaded>();

  EmailId? _currentEmailId;
  Identity? _identitySelected;
  ButtonState? _printEmailButtonState;

  final StreamController<Either<Failure, Success>> _downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get downloadProgressState => _downloadProgressStateController.stream;

  PresentationEmail? get currentEmail => mailboxDashBoardController.selectedEmail.value;

  bool get calendarEventProcessing => viewState.value.fold(
    (failure) => false,
    (success) => success is CalendarEventReplying || success is StoreEventAttendanceStatusLoading);

  CalendarEvent? get calendarEvent => blobCalendarEvent.value?.calendarEventList.firstOrNull;
  Id? get _displayingEventBlobId => blobCalendarEvent.value?.blobId;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  UserName? get userName => session?.username;

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
    this._storeOpenedEmailInteractor,
    this._printEmailInteractor,
    this._storeEventAttendanceStatusInteractor,
    this._parseEmailByBlobIdInteractor,
    this._previewEmailFromEmlFileInteractor,
    this._getHtmlContentFromAttachmentInteractor,
    this._downloadAllAttachmentsForWebInteractor,
    this._exportAllAttachmentsInteractor,
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
    _attachmentListScrollController.dispose();
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
      _handleMarkAsEmailReadCompleted(success.readActions);
    } else if (success is ExportAttachmentSuccess) {
      _exportAttachmentSuccessAction(success);
    } else if (success is ExportAllAttachmentsSuccess) {
      _exportAllAttachmentsSuccessAction(success);
    } else if (success is MoveToMailboxSuccess) {
      _moveToMailboxSuccess(success);
    } else if (success is MarkAsStarEmailSuccess) {
      _markAsEmailStarSuccess(success);
    } else if (success is DownloadAttachmentForWebSuccess) {
      _downloadAttachmentForWebSuccessAction(success);
    } else if (success is StartDownloadAttachmentForWeb) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
    } else if (success is DownloadingAttachmentForWeb) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
    } else if (success is DownloadAllAttachmentsForWebSuccess) {
      mailboxDashBoardController.deleteDownloadTask(success.taskId);
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
    } else if (success is PrintEmailLoading) {
      _showMessageWhenStartingEmailPrinting();
    } else if (success is PrintEmailSuccess) {
      _handlePrintEmailSuccess(success);
    } else if (success is CalendarEventReplySuccess) {
      calendarEventSuccess(success);
    } else if (success is StoreEventAttendanceStatusSuccess) {
      _showToastMessageEventAttendanceSuccess(success);
    } else if (success is ParseEmailByBlobIdSuccess) {
      _handleParseEmailByBlobIdSuccess(success);
    } else if (success is PreviewEmailFromEmlFileSuccess) {
      _handlePreviewEmailFromEMLFileSuccess(success);
    } else if (success is GetHtmlContentFromAttachmentSuccess) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
      Get.dialog(HtmlAttachmentPreviewer(
        title: success.htmlAttachmentTitle,
        htmlContent: success.sanitizedHtmlContent,
        mailToClicked: openMailToLink,
        downloadAttachmentClicked: () {
          if (currentContext == null || attachments.isEmpty) return;
          handleDownloadAttachmentAction(currentContext!, success.attachment);
        },
        responsiveUtils: responsiveUtils,
      ));
    } else if (success is GettingHtmlContentFromAttachment) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is MarkAsEmailReadFailure) {
      _handleMarkAsEmailReadCompleted(failure.readActions);
    } else if (failure is DownloadAttachmentsFailure) {
      _downloadAttachmentsFailure(failure);
    } else if (failure is ExportAttachmentFailure) {
      _exportAttachmentFailureAction(failure);
    } else if (failure is ExportAllAttachmentsFailure) {
      _exportAllAttachmentsFailureAction(failure);
    } else if (failure is DownloadAttachmentForWebFailure) {
      _downloadAttachmentForWebFailureAction(failure);
    } else if (failure is DownloadAllAttachmentsForWebFailure) {
      _downloadAllAttachmentsForWebFailure(failure);
    } else if (failure is ParseCalendarEventFailure) {
      _handleParseCalendarEventFailure(failure);
    } else if (failure is GetEmailContentFailure) {
      emailLoadedViewState.value = Left<Failure, Success>(failure);
    } else if (failure is PrintEmailFailure) {
      _showMessageWhenEmailPrintingFailed(failure);
    } else if (failure is CalendarEventReplyFailure
        || failure is StoreEventAttendanceStatusFailure) {
      _calendarEventFailure(failure);
    } else if (failure is ParseEmailByBlobIdFailure) {
      _handleParseEmailByBlobIdFailure(failure);
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      _handlePreviewEmailFromEMLFileFailure(failure);
    } else if (failure is GetHtmlContentFromAttachmentFailure) {
      _handleGetHtmlContentFromAttachmentFailure(failure);
    } else if (failure is PreviewPDFFileFailure) {
      _handlePreviewPDFFileFailure(failure);
    }
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _injectAndGetInteractorBindings(
          session,
          accountId
        );
      }
    });

    ever<PresentationEmail?>(
      mailboxDashBoardController.selectedEmail,
      _handleOpenEmailDetailedView
    );

    ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is CloseEmailDetailedViewToRedirectToTheInboxAction) {
        if (emailSupervisorController.supportedPageView.isTrue) {
          emailSupervisorController.popEmailQueue(_currentEmailId);
          emailSupervisorController.setCurrentEmailIndex(-1);
          emailSupervisorController.disposePageViewController();
        }
        _updateCurrentEmailId(null);
        _resetToOriginalValue(isEmailClosing: true);
        mailboxDashBoardController.clearSelectedEmail();
        mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is CloseEmailDetailedViewAction) {
        closeEmailView(context: currentContext);
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is HideEmailContentViewAction) {
        isEmailContentHidden.value = true;
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is ShowEmailContentViewAction) {
        isEmailContentHidden.value = false;
        mailboxDashBoardController.clearEmailUIAction();
      }
    });

    ever(mailboxDashBoardController.viewState, (viewState) {
      viewState.map((success) {
        if (success is UnsubscribeEmailSuccess) {
          emailUnsubscribe.value = null;
        }
      });
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

    if (mailboxDashBoardController.listIdentities.isEmpty) {
      _getAllIdentities();
    } else {
      _initializeSelectedIdentity(mailboxDashBoardController.listIdentities);
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
                  attachment: success.attachment,
                  onCancel: () => success.cancelToken?.cancel(),
                ),
              );

              if (currentOverlayContext != null && currentContext != null) {
                appToast.showToastMessage(
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
            } else if (success is StartDownloadAllAttachmentsForWeb) {
              emailSupervisorController.mailboxDashBoardController.addDownloadTask(
                DownloadTaskState(
                  taskId: success.taskId,
                  attachment: success.attachment,
                  onCancel: () => success.cancelToken?.cancel(),
                ),
              );

              if (currentOverlayContext != null && currentContext != null) {
                appToast.showToastMessage(
                  currentOverlayContext!,
                  AppLocalizations.of(currentContext!).your_download_has_started,
                  leadingSVGIconColor: AppColor.primaryColor,
                  leadingSVGIcon: imagePaths.icDownload);
              }
            } else if (success is DownloadingAllAttachmentsForWeb) {
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
    _acceptCalendarEventInteractor = getBinding<AcceptCalendarEventInteractor>();
    _maybeCalendarEventInteractor = getBinding<MaybeCalendarEventInteractor>();
    _rejectCalendarEventInteractor = getBinding<RejectCalendarEventInteractor>();
  }

  void _injectCalendarEventBindings(Session? session, AccountId? accountId) {
    if (session != null && accountId != null) {
      if (CapabilityIdentifier.jamesCalendarEvent.isSupported(session, accountId)) {
        CalendarEventInteractorBindings().dependencies();
      }
    }
  }

  void _getAllIdentities() {
    if (accountId != null && session != null) {
      consumeState(_getAllIdentitiesInteractor.execute(session!, accountId!));
    }
  }

  void _getAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      _initializeSelectedIdentity(success.identities!);
    }
  }

  void _initializeSelectedIdentity(List<Identity> identities) {
    if (currentEmail != null) {
      final currentMailbox = getMailboxContain(currentEmail!);
      if (_isBelongToTeamMailboxes(currentMailbox)) {
        _setUpDefaultIdentityForTeamMailbox(identities, currentMailbox!);
      } else {
        _setUpDefaultIdentity(identities);
      }
    } else {
      _setUpDefaultIdentity(identities);
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

  void _getEmailContentAction(EmailId emailId) {
    final emailLoaded = emailSupervisorController.getEmailInQueueByEmailId(emailId);

    if (emailLoaded != null) {
      consumeState(Stream.value(Right<Failure, Success>(
        GetEmailContentSuccess(
          htmlEmailContent: emailLoaded.htmlContent,
          attachments: emailLoaded.attachments,
          inlineImages: emailLoaded.inlineImages,
          emailCurrent: emailLoaded.emailCurrent
        )
      )));
    } else {
      if (session != null && accountId != null) {
        try {
          final baseDownloadUrl = session!.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl);
          TransformConfiguration transformConfiguration = PlatformInfo.isWeb
            ? TransformConfiguration.forPreviewEmailOnWeb()
            : TransformConfiguration.forPreviewEmail();

          consumeState(_getEmailContentInteractor.execute(
            session!,
            accountId!,
            emailId,
            baseDownloadUrl,
            transformConfiguration
          ));
        } catch (e) {
          logError('SingleEmailController::_getEmailContentAction(): $e');
          consumeState(Stream.value(Left(GetEmailContentFailure(e))));
        }
      }
    }
  }

  void _getEmailContentOfflineSuccess(GetEmailContentFromCacheSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    if (emailSupervisorController.presentationEmailsLoaded.length > ThreadConstants.defaultLimit.value.toInt()) {
      emailSupervisorController.popFirstEmailQueue();
    }
    emailSupervisorController.popEmailQueue(success.emailCurrent?.id);

    currentEmailLoaded.value = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments ?? []),
      inlineImages: List.of(success.inlineImages ?? []),
      emailCurrent: success.emailCurrent,
    );
    emailSupervisorController.pushEmailQueue(currentEmailLoaded.value!);

    if (success.emailCurrent?.id == currentEmail?.id) {
      attachments.value = success.attachments ?? [];
      attachmentsViewState.value = {
        for (var attachment in attachments.where((item) => item.blobId != null))
          attachment.blobId!: Right(IdleDownloadAttachmentForWeb())
      };

      if (_canParseCalendarEvent(blobIds: success.attachments?.calendarEventBlobIds ?? {})) {
        _parseCalendarEventAction(
          accountId: mailboxDashBoardController.accountId.value!,
          blobIds: success.attachments?.calendarEventBlobIds ?? {},
        );
      } else {
        emailContents.value = success.htmlEmailContent;
      }

      final isShowMessageReadReceipt = success.emailCurrent?.hasReadReceipt(mailboxDashBoardController.mapMailboxById) == true;
      if (isShowMessageReadReceipt) {
        _handleReadReceipt();
      }

      if (currentEmail?.isSubscribed == false && success.emailCurrent?.hasListUnsubscribe == true) {
        _handleUnsubscribe(success.emailCurrent!.listUnsubscribe);
      } else {
        emailUnsubscribe.value = null;
      }
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    if (emailSupervisorController.presentationEmailsLoaded.length > ThreadConstants.defaultLimit.value.toInt()) {
      emailSupervisorController.popFirstEmailQueue();
    }
    emailSupervisorController.popEmailQueue(success.emailCurrent?.id);

    currentEmailLoaded.value = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments ?? []),
      inlineImages: List.of(success.inlineImages ?? []),
      emailCurrent: success.emailCurrent,
    );
    emailSupervisorController.pushEmailQueue(currentEmailLoaded.value!);

    if (success.emailCurrent?.id == currentEmail?.id) {
      attachments.value = success.attachments ?? [];
      attachmentsViewState.value = {
        for (var attachment in attachments.where((item) => item.blobId != null))
          attachment.blobId!: Right(IdleDownloadAttachmentForWeb())
      };

      if (_canParseCalendarEvent(blobIds: success.attachments?.calendarEventBlobIds ?? {})) {
        _parseCalendarEventAction(
          accountId: mailboxDashBoardController.accountId.value!,
          blobIds: success.attachments?.calendarEventBlobIds ?? {},
        );
      } else {
        emailContents.value = success.htmlEmailContent;
      }

      if (PlatformInfo.isMobile) {
        final detailedEmail = DetailedEmail(
          emailId: currentEmail!.id!,
          createdTime: currentEmail?.receivedAt?.value ?? DateTime.now(),
          attachments: success.attachments,
          inlineImages: success.inlineImages,
          headers: success.emailCurrent?.headers,
          keywords: success.emailCurrent?.keywords,
          htmlEmailContent: success.htmlEmailContent,
          messageId: success.emailCurrent?.messageId,
          references: success.emailCurrent?.references,
          sMimeStatusHeader: success.emailCurrent?.sMimeStatusHeader,
        );

        _storeOpenedEmailAction(
          session,
          accountId,
          detailedEmail
        );
      }

      final isShowMessageReadReceipt = success.emailCurrent
          ?.hasReadReceipt(mailboxDashBoardController.mapMailboxById) == true;
      if (isShowMessageReadReceipt) {
        _handleReadReceipt();
      }

      if (currentEmail?.isSubscribed == false && success.emailCurrent?.hasListUnsubscribe == true) {
        _handleUnsubscribe(success.emailCurrent!.listUnsubscribe);
      } else {
        emailUnsubscribe.value = null;
      }
    }
  }

  void _handleUnsubscribe(String listUnsubscribe) {
    emailUnsubscribe.value = EmailUtils.parsingUnsubscribe(listUnsubscribe);
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

  void _resetToOriginalValue({bool isEmailClosing = false}) {
    emailContents.value = null;
    currentEmailLoaded.value = null;
    attachments.clear();
    attachmentsViewState.value = {};
    blobCalendarEvent.value = null;
    emailUnsubscribe.value = null;
    _identitySelected = null;
    if (isEmailClosing) {
      emailLoadedViewState.value = Right(UIState.idle);
      viewState.value = Right(UIState.idle);
    }
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

  void markAsEmailRead(
    PresentationEmail presentationEmail,
    ReadActions readActions,
    MarkReadAction markReadAction,
  ) {
    if (accountId != null && session != null) {
      consumeState(_markAsEmailReadInteractor.execute(
        session!,
        accountId!,
        presentationEmail.id!,
        readActions,
        markReadAction,
        presentationEmail.mailboxContain?.mailboxId,
      ));
    }
  }

  void _handleMarkAsEmailReadCompleted(ReadActions readActions) {
    if (_currentEmailId != null) {
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        [_currentEmailId!],
        readAction: readActions,
      );
    }
    if (readActions == ReadActions.markAsUnread) {
      closeEmailView(context: currentContext);
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
            appToast.showToastMessage(
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
                appToast.showToastMessage(
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

  void _downloadAttachmentsAction(List<Attachment> attachments) {
    if (accountId != null && session != null) {
      try {
        final baseDownloadUrl = session!.getDownloadUrl(
          jmapUrl: dynamicUrlInterceptors.jmapUrl,
        );
        consumeState(_downloadAttachmentsInteractor.execute(
          attachments,
          accountId!,
          baseDownloadUrl,
        ));
      } catch (e) {
        logError('SingleEmailController::_downloadAttachmentsAction(): $e');
        consumeState(Stream.value(Left(DownloadAttachmentsFailure(e))));
      }
    }
  }

  void _downloadAttachmentsFailure(DownloadAttachmentsFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).attachment_download_failed);
    }
  }

  void exportAttachment(BuildContext context, Attachment attachment) {
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, attachment.name ?? '', cancelToken: cancelToken);
    _exportAttachmentAction(attachment, cancelToken);
  }

  void _showDownloadingFileDialog(BuildContext context, String attachmentName, {CancelToken? cancelToken}) {
    if (cancelToken != null) {
      showCupertinoDialog(
          context: context,
          builder: (_) =>
              PointerInterceptor(child: (DownloadingFileDialogBuilder()
                    ..key(const Key('downloading_file_dialog'))
                    ..title(AppLocalizations.of(context).preparing_to_export)
                    ..content(AppLocalizations.of(context).downloading_file(attachmentName))
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
                  ..content(AppLocalizations.of(context).downloading_file(attachmentName)))
                .build()));
    }
  }

  void _exportAttachmentAction(Attachment attachment, CancelToken cancelToken) {
    if (accountId != null && session != null) {
      try {
        final baseDownloadUrl = session!.getDownloadUrl(
          jmapUrl: dynamicUrlInterceptors.jmapUrl,
        );
        consumeState(_exportAttachmentInteractor.execute(
          attachment,
          accountId!,
          baseDownloadUrl,
          cancelToken,
        ));
      } catch (e) {
        logError('SingleEmailController::_exportAttachmentAction(): $e');
        consumeState(Stream.value(Left(ExportAttachmentFailure(e))));
      }
    }
  }

  void exportAllAttachments(BuildContext context, String outputFileName) {
    final cancelToken = CancelToken();
    _showDownloadingFileDialog(context, outputFileName, cancelToken: cancelToken);
    _exportAllAttachmentsAction(outputFileName, cancelToken);
  }

  void _exportAllAttachmentsAction(String outputFileName, CancelToken cancelToken) {
    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(ExportAllAttachmentsFailure(
        exception: NotFoundSessionException(),
      ))));
      return;
    }

    final downloadAllSupported = session!.isDownloadAllSupported(accountId);
    if (!downloadAllSupported || _currentEmailId == null) {
      consumeState(Stream.value(Left(ExportAllAttachmentsFailure())));
      return;
    }
    
    final baseDownloadAllUrl = session!.getDownloadAllCapability(accountId)!.endpoint!;
    consumeState(_exportAllAttachmentsInteractor.execute(
      accountId!,
      _currentEmailId!,
      baseDownloadAllUrl,
      outputFileName,
      cancelToken: cancelToken,
    ));
  }

  void _exportAttachmentFailureAction(ExportAttachmentFailure failure) {
    if (failure.exception is! CancelDownloadFileException) {
      popBack();

      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).attachment_download_failed);
      }
    }
  }

  void _exportAttachmentSuccessAction(ExportAttachmentSuccess success) async {
    popBack();
    _openDownloadedPreviewWorkGroupDocument(success.downloadedResponse);
  }

  void _exportAllAttachmentsFailureAction(ExportAllAttachmentsFailure failure) {
    if (failure.exception is! CancelDownloadFileException) {
      popBack();

      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).attachment_download_failed);
      }
    }
  }

  void _exportAllAttachmentsSuccessAction(ExportAllAttachmentsSuccess success) {
    popBack();
    _saveDownloadedZipAttachments(success.downloadedResponse.filePath);
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
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).noPreviewAvailable);
      }
    }
  }

  Future<void> _saveDownloadedZipAttachments(String filePath) async {
    final params = SaveFileDialogParams(sourceFilePath: filePath);
    await FlutterFileDialog.saveFile(params: params);
  }

  void downloadAttachmentForWeb(Attachment attachment) {
    if (accountId != null && session != null) {
      final generateTaskId = DownloadTaskId(uuid.v4());
      try {
        final baseDownloadUrl = session!.getDownloadUrl(
          jmapUrl: dynamicUrlInterceptors.jmapUrl,
        );
        final cancelToken = CancelToken();
        consumeState(_downloadAttachmentForWebInteractor.execute(
          generateTaskId,
          attachment,
          accountId!,
          baseDownloadUrl,
          _downloadProgressStateController,
          cancelToken: cancelToken,
        ));
      } catch (e) {
        logError('SingleEmailController::downloadAttachmentForWeb(): $e');
        consumeState(Stream.value(Left(DownloadAttachmentForWebFailure(attachment: attachment, taskId: generateTaskId, exception: e))));
      }
    } else {
      consumeState(Stream.value(
        Left(DownloadAttachmentForWebFailure(
          attachment: attachment,
          exception: NotFoundSessionException()))
      ));
    }
  }

  void downloadAllAttachmentsForWeb(String outputFileName) {
    final taskId = DownloadTaskId(uuid.v4());
    final session = this.session;
    final accountId = this.accountId;

    if (accountId == null || session == null) {
      consumeState(Stream.value(Left(DownloadAllAttachmentsForWebFailure(
        exception: NotFoundSessionException(),
        taskId: taskId,
      ))));
      return;
    }

    final downloadAllSupported = session.isDownloadAllSupported(accountId);
    final emailId = _currentEmailId;

    if (!downloadAllSupported || emailId == null) {
      consumeState(Stream.value(Left(DownloadAllAttachmentsForWebFailure(
        taskId: taskId,
      ))));
      return;
    }

    final baseDownloadAllUrl = session.getDownloadAllCapability(accountId)!.endpoint!;
    final downloadAttachment = Attachment(
      name: outputFileName,
      type: MediaType('application', 'zip'),
    );
    final cancelToken = CancelToken();
    consumeState(_downloadAllAttachmentsForWebInteractor.execute(
      accountId,
      emailId,
      baseDownloadAllUrl,
      downloadAttachment,
      taskId,
      _downloadProgressStateController,
      cancelToken: cancelToken,
    ));
  }

  bool isDownloadAllSupported() {
    return session?.isDownloadAllSupported(accountId) ?? false;
  }

  bool downloadAllButtonIsEnabled() {
    return isDownloadAllSupported() && attachments.length > 1;
  }

  void _downloadAllAttachmentsForWebFailure(
    DownloadAllAttachmentsForWebFailure failure,
  ) {
    mailboxDashBoardController.deleteDownloadTask(failure.taskId);
    if (currentOverlayContext == null || currentContext == null) return;
    String message = AppLocalizations.of(currentContext!).attachment_download_failed;
    if (failure.cancelToken?.isCancelled == true) {
      message = AppLocalizations.of(currentContext!).downloadAttachmentHasBeenCancelled;
    }
    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void _downloadAttachmentForWebSuccessAction(DownloadAttachmentForWebSuccess success) {
    log('SingleEmailController::_downloadAttachmentForWebSuccessAction():');

    _updateAttachmentsViewState(success.attachment.blobId, Right(success));

    mailboxDashBoardController.deleteDownloadTask(success.taskId);

    _downloadManager.createAnchorElementDownloadFileWeb(
        success.bytes,
        success.attachment.generateFileName());
  }

  void _downloadPDFFile(Uint8List bytes, String fileName) {
    _downloadManager.createAnchorElementDownloadFileWeb(bytes, fileName);
  }

  void _printPDFFile(Uint8List bytes, String fileName) async {
    await _printUtils.printPDFFile(bytes, fileName);
  }

  void _downloadAttachmentForWebFailureAction(DownloadAttachmentForWebFailure failure) {
    log('SingleEmailController::_downloadAttachmentForWebFailureAction(): $failure');
    if (failure.taskId != null) {
      mailboxDashBoardController.deleteDownloadTask(failure.taskId!);
    }

    if (failure.attachment != null) {
      _updateAttachmentsViewState(failure.attachment?.blobId, Left(failure));
    }
    
    if (currentOverlayContext == null || currentContext == null) return;

    String message = AppLocalizations.of(currentContext!).attachment_download_failed;
    if (failure.attachment is EMLAttachment) {
      message = AppLocalizations.of(currentContext!).downloadMessageAsEMLFailed;
    } else if (failure.cancelToken?.isCancelled == true) {
      message = AppLocalizations.of(currentContext!).downloadAttachmentHasBeenCancelled;
    }

    appToast.showToastErrorMessage(currentOverlayContext!, message);
  }

  void _updateAttachmentsViewState(
    Id? attachmentBlobId,
    Either<Failure, Success> viewState) {
      if (attachmentBlobId != null) {
        attachmentsViewState[attachmentBlobId] = viewState;
      }
  }

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    final currentMailbox = getMailboxContain(email);

    if (currentMailbox != null && accountId != null) {
      final arguments = DestinationPickerArguments(
        accountId!,
        MailboxActions.moveEmail,
        session,
        mailboxIdSelected: currentMailbox.mailboxId
      );

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox != null &&
          destinationMailbox is PresentationMailbox &&
          session != null &&
          context.mounted
      ) {
        _dispatchMoveToAction(
          context,
          accountId!,
          session!,
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
          EmailActionType.moveToTrash),
        {emailSelected.id!: emailSelected.hasRead});
    } else if (destinationMailbox.isSpam) {
      _moveToSpamAction(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToSpam),
        {emailSelected.id!: emailSelected.hasRead});
    } else {
      _moveToMailbox(
        context,
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath),
        {emailSelected.id!: emailSelected.hasRead});
    }
  }

  void _moveToMailbox(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    closeEmailView(context: context);
    consumeState(_moveToMailboxInteractor.execute(
      session,
      accountId,
      moveRequest,
      emailIdsWithReadStatus,
    ));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        success.emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: success.destinationPath),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          _revertedToOriginalMailbox(MoveToMailboxRequest(
            {success.destinationMailboxId: [success.emailId]},
            success.currentMailboxId,
            MoveAction.undo,
            success.emailActionType),
            success.emailIdsWithReadStatus,
          );
        },
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo)
      );
    }
  }

  void _revertedToOriginalMailbox(
    MoveToMailboxRequest newMoveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    if (accountId != null && session != null) {
      _moveToMailbox(
        currentContext!,
        session!,
        accountId!,
        newMoveRequest,
        emailIdsWithReadStatus,
      );
    }
  }

  void moveToTrash(BuildContext context, PresentationEmail email) {
    final trashMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleTrash);
    final currentMailbox = getMailboxContain(email);

    if (session != null && accountId != null && currentMailbox != null && trashMailboxId != null) {
      _moveToTrashAction(
        context,
        session!,
        accountId!,
        MoveToMailboxRequest(
          {currentMailbox.id: [email.id!]},
          trashMailboxId,
          MoveAction.moving,
          EmailActionType.moveToTrash),
        {email.id!: email.hasRead},
      );
    }
  }

  void _moveToTrashAction(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    closeEmailView(context: context);
    mailboxDashBoardController.moveToMailbox(
      session,
      accountId,
      moveRequest,
      emailIdsWithReadStatus,
    );
  }

  void moveToSpam(BuildContext context, PresentationEmail email) {
    final spamMailboxId = mailboxDashBoardController.spamMailboxId;
    final currentMailbox = getMailboxContain(email);

    if (session != null && accountId != null && currentMailbox != null && spamMailboxId != null) {
      _moveToSpamAction(
        context,
        session!,
        accountId!,
        MoveToMailboxRequest(
          {currentMailbox.id: [email.id!]},
          spamMailboxId,
          MoveAction.moving,
          EmailActionType.moveToSpam),
        {email.id!: email.hasRead},
      );
    }
  }

  void unSpam(BuildContext context, PresentationEmail email) {
    final spamMailboxId = mailboxDashBoardController.spamMailboxId;
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (session != null && accountId != null && spamMailboxId != null && inboxMailboxId != null) {
      _moveToSpamAction(
        context,
        session!,
        accountId!,
        MoveToMailboxRequest(
          {spamMailboxId: [email.id!]},
          inboxMailboxId,
          MoveAction.moving,
          EmailActionType.unSpam),
        {email.id!: email.hasRead},
      );
    }
  }

  void _moveToSpamAction(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) {
    closeEmailView(context: context);
    mailboxDashBoardController.moveToMailbox(
      session,
      accountId,
      moveRequest,
      emailIdsWithReadStatus,
    );
  }

  void markAsStarEmail(
    PresentationEmail presentationEmail,
    MarkStarAction markStarAction,
  ) {
    if (accountId != null && session != null) {
      consumeState(_markAsStarEmailInteractor.execute(
        session!,
        accountId!,
        presentationEmail.id!,
        markStarAction,
      ));
    }
  }

  void _markAsEmailStarSuccess(MarkAsStarEmailSuccess success) {
    final newEmail = currentEmail?.updateKeywords({
      KeyWordIdentifier.emailFlagged: success.markStarAction == MarkStarAction.markStar,
    });
    mailboxDashBoardController.setSelectedEmail(newEmail);

    final emailId = newEmail?.id;
    if (emailId == null) return;
    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      markStarAction: success.markStarAction,
    );
  }

  void handleEmailAction(BuildContext context, PresentationEmail presentationEmail, EmailActionType actionType) {
    switch(actionType) {
      case EmailActionType.markAsUnread:
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
        moveToSpam(context, presentationEmail);
        break;
      case EmailActionType.unSpam:
        unSpam(context, presentationEmail);
        break;
      case EmailActionType.createRule:
        quickCreatingRule(context, presentationEmail.from!.first);
        break;
      case EmailActionType.unsubscribe:
        _unsubscribeEmail(context, presentationEmail);
        break;
      case EmailActionType.archiveMessage:
        archiveMessage(context, presentationEmail);
        break;
      case EmailActionType.printAll:
        _printEmail(context, presentationEmail);
        break;
      case EmailActionType.downloadMessageAsEML:
        _downloadMessageAsEML(presentationEmail);
        break;
      case EmailActionType.editAsNewEmail:
        _editAsNewEmail(presentationEmail);
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
      Get.dialog(
        PointerInterceptor(
          child: EmailAddressDialogBuilder(
            emailAddress,
            onCloseDialogAction: () => popBack(),
            onCopyEmailAddressAction: (emailAddress) => copyEmailAddress(context, emailAddress),
            onComposeEmailAction: (emailAddress) => composeEmailFromEmailAddress(emailAddress),
            onQuickCreatingRuleEmailDialogAction: (emailAddress) => quickCreatingRule(context, emailAddress)
          )
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
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
    if (uri == null) return;
    
    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(uri.toString());
    log('SingleEmailController::openMailToLink(): ${uri.toString()}');
    if (!RouteUtils.canOpenComposerFromNavigationRouter(navigationRouter)) return;

    mailboxDashBoardController.goToComposer(
      ComposerArguments.fromMailtoUri(
        listEmailAddress: navigationRouter.listEmailAddress,
        cc: navigationRouter.cc,
        bcc: navigationRouter.bcc,
        subject: navigationRouter.subject,
        body: navigationRouter.body
      )
    );
  }

  void deleteEmailPermanently(BuildContext context, PresentationEmail email) {
    if (responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(DeleteActionType.single.getContentDialog(context))
          ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email)))
        .show();
    } else {
      Get.dialog(
        PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
            ..key(const Key('confirm_dialog_delete_email_permanently'))
            ..title(DeleteActionType.single.getTitleDialog(context))
            ..content(DeleteActionType.single.getContentDialog(context))
            ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
            ..colorConfirmButton(AppColor.colorConfirmActionDialog)
            ..styleTextConfirmButton(const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorActionDeleteConfirmDialog))
            ..onCloseButtonAction(() => popBack())
            ..onConfirmButtonAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email))
            ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
          .build()
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _deleteEmailPermanentlyAction(BuildContext context, PresentationEmail email) {
    popBack();
    closeEmailView(context: context);
    mailboxDashBoardController.deleteEmailPermanently(email);
  }

  void _handleSendReceiptToSenderAction(BuildContext context) {
    if (accountId == null || session == null) {
      return;
    }

    if (_sendReceiptToSenderInteractor == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageNotSupportMdnWhenSendReceipt);
      return;
    }

    if (_identitySelected == null || _identitySelected?.id == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageCannotFoundIdentityWhenSendReceipt);
      return;
    }

    if (currentEmail == null || _currentEmailId == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageCannotFoundEmailIdWhenSendReceipt);
      return;
    }

    final receiverEmailAddress = _getReceiverEmailAddress(currentEmail!) ?? session!.getOwnEmailAddress();
    log('SingleEmailController::_handleSendReceiptToSenderAction():receiverEmailAddress: $receiverEmailAddress');
    final mdnToSender = _generateMDN(context, currentEmail!, receiverEmailAddress);
    final sendReceiptRequest = SendReceiptToSenderRequest(
        mdn: mdnToSender,
        identityId: _identitySelected!.id!,
        sendId: Id(uuid.v1()));
    log('SingleEmailController::_handleSendReceiptToSenderAction(): sendReceiptRequest: $sendReceiptRequest');

    consumeState(_sendReceiptToSenderInteractor!.execute(accountId!, sendReceiptRequest));
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
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageSendReceiptSuccess,
        leadingSVGIcon: imagePaths.icReadReceiptMessage);
    }
  }

  void closeEmailView({BuildContext? context}) {
    if (emailSupervisorController.supportedPageView.isTrue) {
      emailSupervisorController.popEmailQueue(_currentEmailId);
      emailSupervisorController.setCurrentEmailIndex(-1);
      emailSupervisorController.disposePageViewController();
    }
    mailboxDashBoardController.clearSelectedEmail();
    _updateCurrentEmailId(null);
    _resetToOriginalValue(isEmailClosing: true);
    _replaceBrowserHistory();
    if (mailboxDashBoardController.searchController.isSearchEmailRunning) {
      if (context != null && responsiveUtils.isWebDesktop(context)) {
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

  void _replaceBrowserHistory() {
    if (PlatformInfo.isWeb) {
      final selectedMailboxId = mailboxDashBoardController.selectedMailbox.value?.id;
      final isSearchRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
      RouteUtils.replaceBrowserHistory(
        title: isSearchRunning
          ? 'SearchEmail'
          : 'Mailbox-${selectedMailboxId?.id.value}',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: isSearchRunning
              ? null
              : selectedMailboxId,
            dashboardType: isSearchRunning
              ? DashboardType.search
              : DashboardType.normal,
            searchQuery: isSearchRunning
              ? mailboxDashBoardController.searchController.searchQuery
              : null
          )
        )
      );
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
            content: currentEmailLoaded.value?.htmlContent ?? '',
            inlineImages: currentEmailLoaded.value?.inlineImages ?? [],
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: currentEmailLoaded.value?.emailCurrent?.messageId,
            references: currentEmailLoaded.value?.emailCurrent?.references,
            listPost: currentEmailLoaded.value?.emailCurrent?.listPost,
          )
        );
        break;
      case EmailActionType.replyToList:
        log('SingleEmailController::pressEmailAction:replyToList');
        mailboxDashBoardController.goToComposer(
          ComposerArguments.replyToListEmail(
            presentationEmail: presentationEmail,
            content: currentEmailLoaded.value?.htmlContent ?? '',
            inlineImages: currentEmailLoaded.value?.inlineImages ?? [],
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: currentEmailLoaded.value?.emailCurrent?.messageId,
            references: currentEmailLoaded.value?.emailCurrent?.references,
            listPost: currentEmailLoaded.value?.emailCurrent?.listPost,
          )
        );
        break;
      case EmailActionType.replyAll:
        mailboxDashBoardController.goToComposer(
          ComposerArguments.replyAllEmail(
            presentationEmail: presentationEmail,
            content: currentEmailLoaded.value?.htmlContent ?? '',
            inlineImages: currentEmailLoaded.value?.inlineImages ?? [],
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: currentEmailLoaded.value?.emailCurrent?.messageId,
            references: currentEmailLoaded.value?.emailCurrent?.references,
            listPost: currentEmailLoaded.value?.emailCurrent?.listPost,
          )
        );
        break;
      case EmailActionType.forward:
        mailboxDashBoardController.goToComposer(
          ComposerArguments.forwardEmail(
            presentationEmail: presentationEmail,
            content: currentEmailLoaded.value?.htmlContent ?? '',
            attachments: attachments,
            inlineImages: currentEmailLoaded.value?.inlineImages ?? [],
            messageId: currentEmailLoaded.value?.emailCurrent?.messageId,
            references: currentEmailLoaded.value?.emailCurrent?.references,
          )
        );
        break;
      default:
        break;
    }
  }

  void quickCreatingRule(BuildContext context, EmailAddress emailAddress) async {
    popBack();

    if (accountId != null && session != null) {
      final arguments = RulesFilterCreatorArguments(
        accountId!,
        session!,
        emailAddress: emailAddress);

      final newRuleFilterRequest = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.rulesFilterCreator, arguments: arguments)
        : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

      if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
        _createNewRuleFilterAction(accountId!, newRuleFilterRequest);
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
        appToast.showToastSuccessMessage(
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
    return session != null &&
      accountId != null &&
      CapabilityIdentifier.jamesCalendarEvent.isSupported(session!, accountId!);
  }

  @visibleForTesting
  parseCalendarEventAction({
    required AccountId accountId,
    required Set<Id> blobIds,
  }) => _parseCalendarEventAction(accountId: accountId, blobIds: blobIds);

  void _parseCalendarEventAction({
    required AccountId accountId,
    required Set<Id> blobIds,
  }) {
    log("SingleEmailController::_parseCalendarEventAction:blobIds: $blobIds");
    consumeState(_parseCalendarEventInteractor!.execute(
      accountId,
      blobIds,
      TransformConfiguration.fromTextTransformers(const [
        SanitizeAutolinkUnescapeHtmlTransformer(),
        StandardizeHtmlSanitizingTransformers(),
        NewLineTransformer(),
      ])
    ));
  }

  void _handleParseCalendarEventSuccess(ParseCalendarEventSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);
    blobCalendarEvent.value = success.blobCalendarEventList.first;
    if (PlatformInfo.isMobile) {
      _enableScrollPageView();
    }
  }

  void _handleParseCalendarEventFailure(ParseCalendarEventFailure failure) {
    emailLoadedViewState.value = Left<Failure, Success>(failure);
    emailContents.value = currentEmailLoaded.value?.htmlContent;
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
      (AttachmentListBottomSheetBuilder(context, attachments, imagePaths, _attachmentListScrollController)
        ..onCloseButtonAction(() => popBack())
        ..onDownloadAttachmentFileAction((attachment) => handleDownloadAttachmentAction(context, attachment))
        ..onViewAttachmentFileAction((attachment) => handleViewAttachmentAction(context, attachment))
        ..onDownloadAllButtonAction(isDownloadAllSupported()
          ? () => downloadAllAttachmentsForWeb('TwakeMail-${DateTime.now()}')
          : null
        )
      ).show();
    } else {
      Get.dialog(
        PointerInterceptor(
          child: AttachmentListDialogBuilder(
            imagePaths: imagePaths,
            attachments: attachments,
            responsiveUtils: responsiveUtils,
            scrollController: _attachmentListScrollController,
            backgroundColor: Colors.black.withAlpha(24),
            onCloseButtonAction: () => popBack(),
            onDownloadAttachmentFileAction: (attachment) => handleDownloadAttachmentAction(context, attachment),
            onViewAttachmentFileAction: (attachment) => handleViewAttachmentAction(context, attachment),
            onDownloadAllButtonAction: isDownloadAllSupported()
              ? () => downloadAllAttachmentsForWeb('TwakeMail-${DateTime.now()}')
              : null,
          )
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _unsubscribeEmail(BuildContext context, PresentationEmail presentationEmail) {
    showConfirmDialogAction(
      context,
      '',
      AppLocalizations.of(context).unsubscribe,
      onConfirmAction: () {
        if (emailUnsubscribe.value?.httpLinks.isNotEmpty == true) {
          _handleUnsubscribeMailByHttpsLink(
            context: context,
            emailId: presentationEmail.id!,
            httpLinks: emailUnsubscribe.value!.httpLinks
          );
        } else if (emailUnsubscribe.value?.mailtoLinks.isNotEmpty == true) {
          _handleUnsubscribeMailByMailtoLink(
            context: context,
            emailId: presentationEmail.id!,
            mailtoLinks: emailUnsubscribe.value!.mailtoLinks
          );
        }
      },
      showAsBottomSheet: true,
      title: AppLocalizations.of(context).unsubscribeMail,
      icon: SvgPicture.asset(imagePaths.icEmpty),
      messageStyle: const TextStyle(
        color: AppColor.messageDialogColor,
        fontSize: 14,
        fontWeight: FontWeight.w500
      ),
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(context).unsubscribeMailDialogMessage),
        TextSpan(
          text: ' ${presentationEmail.getSenderName()}',
          style: const TextStyle(
            color: AppColor.messageDialogHighlightColor,
            fontSize: 15,
            fontWeight: FontWeight.w500
          ),
        ),
        const TextSpan(text: ' ?'),
      ]
    );
  }

  void _handleUnsubscribeMailByHttpsLink({
    required BuildContext context,
    required EmailId emailId,
    required List<String> httpLinks
  }) {
    log('SingleEmailController::_handleUnsubscribeMailByHttpsLink:httpLinks: $httpLinks');
    mailboxDashBoardController.unsubscribeMail(emailId);
    AppUtils.launchLink(httpLinks.first);
  }

  void _handleUnsubscribeMailByMailtoLink({
    required BuildContext context,
    required EmailId emailId,
    required List<String> mailtoLinks
  }) {
    log('SingleEmailController::_handleUnsubscribeMailByMailtoLink:mailtoLinks: $mailtoLinks');
    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(mailtoLinks.first);
    mailboxDashBoardController.goToComposer(
      ComposerArguments.fromUnsubscribeMailtoLink(
        listEmailAddress: navigationRouter.listEmailAddress,
        subject: navigationRouter.subject,
        body: navigationRouter.body,
        previousEmailId: emailId,
      )
    );
  }

  void archiveMessage(BuildContext context, PresentationEmail email) {
    mailboxDashBoardController.archiveMessage(context, email);
  }

  void _printEmail(BuildContext context, PresentationEmail email) {
    if (_printEmailButtonState == ButtonState.disabled) {
      log('SingleEmailController::_printEmail: Print email started');
      return;
    }

    _printEmailButtonState = ButtonState.disabled;

    final locale = Localizations.localeOf(context);
    final appLocalizations = AppLocalizations.of(context);

    consumeState(
      _printEmailInteractor.execute(
        EmailPrint(
          appName: appLocalizations.app_name,
          userName: mailboxDashBoardController.userEmail,
          attachments: currentEmailLoaded.value!.attachments,
          emailContent: currentEmailLoaded.value!.htmlContent,
          fromPrefix: appLocalizations.from_email_address_prefix,
          toPrefix: appLocalizations.to_email_address_prefix,
          ccPrefix: appLocalizations.cc_email_address_prefix,
          bccPrefix: appLocalizations.bcc_email_address_prefix,
          replyToPrefix: appLocalizations.replyToEmailAddressPrefix,
          titleAttachment: appLocalizations.attachments.toLowerCase(),
          toAddress: email.to?.listEmailAddressToString(isFullEmailAddress: true),
          ccAddress: email.cc?.listEmailAddressToString(isFullEmailAddress: true),
          bccAddress: email.bcc?.listEmailAddressToString(isFullEmailAddress: true),
          replyToAddress: email.replyTo?.listEmailAddressToString(isFullEmailAddress: true),
          sender: email.from?.isNotEmpty == true
            ? email.from!.first
            : null,
          receiveTime: email.getReceivedAt(
            locale.toLanguageTag(),
            pattern: email.receivedAt
              ?.value
              .toLocal()
              .toPatternForPrinting(locale.toLanguageTag()),
          ),
          subject: email.subject,
        )
      )
    );
  }

  void _showMessageWhenStartingEmailPrinting() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).printingInProgress,
        leadingSVGIconColor: AppColor.primaryColor,
        leadingSVGIcon: imagePaths.icPrinter);
    }
  }

  void _handlePrintEmailSuccess(PrintEmailSuccess success) {
    _printEmailButtonState = ButtonState.enabled;
  }

  void _showMessageWhenEmailPrintingFailed(PrintEmailFailure failure) {
    _printEmailButtonState = ButtonState.enabled;

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).printingFailed);
    }
  }

  void onCalendarEventReplyAction(EventActionType eventActionType, EmailId emailId) {
    switch (eventActionType) {
      case EventActionType.yes:
        _acceptCalendarEventAction(emailId);
        break;
      case EventActionType.maybe:
        _maybeCalendarEventAction(emailId);
        break;
      case EventActionType.no:
        _rejectCalendarEventAction(emailId);
        break;
      default:
        break;
    }
  }

  void _acceptCalendarEventAction(EmailId emailId) {
    if (_acceptCalendarEventInteractor == null
      || _displayingEventBlobId == null
      || accountId == null
      || session == null
      || session!.validateCalendarEventCapability(accountId!).isAvailable == false
    ) {
      consumeState(Stream.value(Left(CalendarEventAcceptFailure())));
    } else {
      consumeState(_acceptCalendarEventInteractor!.execute(
        accountId!,
        {_displayingEventBlobId!},
        emailId,
        session!.getLanguageForCalendarEvent(
          LocalizationService.getLocaleFromLanguage(),
          accountId!,
        ),
      ));
    }
  }

  void _rejectCalendarEventAction(EmailId emailId) {
    if (_rejectCalendarEventInteractor == null
      || _displayingEventBlobId == null
      || accountId == null
      || session == null
      || session!.validateCalendarEventCapability(accountId!).isAvailable == false
    ) {
      consumeState(Stream.value(Left(CalendarEventRejectFailure())));
    } else {
      consumeState(_rejectCalendarEventInteractor!.execute(
        accountId!,
        {_displayingEventBlobId!},
        emailId,
        session!.getLanguageForCalendarEvent(
          LocalizationService.getLocaleFromLanguage(),
          accountId!,
        ),
      ));
    }
  }

  void _maybeCalendarEventAction(EmailId emailId) {
    if (_maybeCalendarEventInteractor == null
      || _displayingEventBlobId == null
      || accountId == null
      || session == null
      || session!.validateCalendarEventCapability(accountId!).isAvailable == false
    ) {
      consumeState(Stream.value(Left(CalendarEventMaybeFailure())));
    } else {
      consumeState(_maybeCalendarEventInteractor!.execute(
        accountId!,
        {_displayingEventBlobId!},
        emailId,
        session!.getLanguageForCalendarEvent(
          LocalizationService.getLocaleFromLanguage(),
          accountId!,
        ),
      ));
    }
  }

  void calendarEventSuccess(CalendarEventReplySuccess success) {
    if (session == null || accountId == null) {
      consumeState(Stream.value(Left(StoreEventAttendanceStatusFailure(exception: NotFoundSessionException()))));
      return;
    }

    consumeState(_storeEventAttendanceStatusInteractor.execute(
      session!,
      accountId!,
      success.emailId,
      success.getEventActionType()
    ));
  }

  void _showToastMessageEventAttendanceSuccess(StoreEventAttendanceStatusSuccess success) {
    final newEmail = currentEmail?.updateKeywords(
      success.eventActionType.getMapKeywords(),
    );
    mailboxDashBoardController.setSelectedEmail(newEmail);

    if (currentOverlayContext == null || currentContext == null) {
      return;
    }

    appToast.showToastSuccessMessage(
      currentOverlayContext!,
      success.eventActionType.getToastMessageSuccess(currentContext!));
  }

  void _calendarEventFailure(Failure failure) {
    if (currentOverlayContext == null || currentContext == null) {
      return;
    }

    if (failure is CalendarEventReplyFailure && failure.exception is CannotReplyCalendarEventException) {
      final replyEventException = failure.exception as CannotReplyCalendarEventException;

      if (replyEventException.mapErrors?.isNotEmpty == true) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          replyEventException.mapErrors!.values.first.description
            ?? AppLocalizations.of(currentContext!).eventReplyWasSentUnsuccessfully);
        return;
      }
    }

    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).eventReplyWasSentUnsuccessfully);
  }

  void _downloadMessageAsEML(PresentationEmail presentationEmail) {
    final emlAttachment = presentationEmail.createEMLAttachment();
    if (emlAttachment.blobId == null) {
      consumeState(Stream.value(Left(DownloadAttachmentForWebFailure(exception: NotFoundEmailBlobIdException()))));
      return;
    }

    downloadAttachmentForWeb(emlAttachment);
  }

  void _editAsNewEmail(PresentationEmail presentationEmail) {
    if (accountId == null || session == null) return;

    mailboxDashBoardController.goToComposer(
      ComposerArguments.editAsNewEmail(presentationEmail),
    );
  }

  void handleDownloadAttachmentAction(BuildContext context, Attachment attachment) {
    if (PlatformInfo.isWeb) {
      downloadAttachmentForWeb(attachment);
    } else if (PlatformInfo.isMobile) {
      exportAttachment(context, attachment);
    } else {
      log('EmailView::handleDownloadAttachmentAction: THE PLATFORM IS SUPPORTED');
    }
  }

  void handleDownloadAllAttachmentsAction(
    BuildContext context,
    String outputFileName,
  ) {
    if (PlatformInfo.isWeb) {
      downloadAllAttachmentsForWeb(outputFileName);
    } else if (PlatformInfo.isMobile) {
      exportAllAttachments(context, outputFileName);
    } else {
      log('EmailView::handleDownloadAllAttachmentsAction: THE PLATFORM IS SUPPORTED');
    }
  }

  void handleViewAttachmentAction(BuildContext context, Attachment attachment) {
    if (PlatformInfo.isWeb && PlatformInfo.isCanvasKit && attachment.isPDFFile) {
      previewPDFFileAction(context, attachment);
    } else if (attachment.isEMLFile) {
      previewEMLFileAction(attachment.blobId, AppLocalizations.of(context));
    } else if (attachment.isHTMLFile) {
      final attachmentEvaluation = evaluateAttachment(attachment);
      if (!attachmentEvaluation.canDownloadAttachment) {
        consumeState(Stream.value(Left(GetHtmlContentFromAttachmentFailure(
          exception: null,
          attachment: attachment,
        ))));
        return;
      }

      consumeState(_getHtmlContentFromAttachmentInteractor.execute(
        attachmentEvaluation.accountId!,
        attachment,
        DownloadTaskId(attachmentEvaluation.blobId!.value),
        attachmentEvaluation.downloadUrl!,
        TransformConfiguration.create(
          customDomTransformers: [SanitizeHyperLinkTagInHtmlTransformer()],
          customTextTransformers: [const StandardizeHtmlSanitizingTransformers()],
        ),
      ));
    }else {
      handleDownloadAttachmentAction(context, attachment);
    }
  }

  ({
    bool canDownloadAttachment,
    AccountId? accountId,
    String? downloadUrl,
    Id? blobId,
  }) evaluateAttachment(
    Attachment attachment,
  ) {
    final accountId = mailboxDashBoardController.accountId.value;
    dynamic downloadUrl;
    try {
      downloadUrl = mailboxDashBoardController.sessionCurrent
        ?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl);
    } catch (e) {
      logError('SingleEmailController::_getEmailContentAction(): $e');
      downloadUrl = null;
    }
    final blobId = attachment.blobId;

    if (accountId == null || downloadUrl == null || blobId == null) {
      return (
        canDownloadAttachment: false,
        accountId: accountId,
        downloadUrl: downloadUrl,
        blobId: blobId,
      );
    }

    return (
      canDownloadAttachment: true,
      accountId: accountId,
      downloadUrl: downloadUrl,
      blobId: blobId,
    );
  }

  Future<void> previewPDFFileAction(BuildContext context, Attachment attachment) async {
    if (accountId == null || session == null) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).noPreviewAvailable);
      return;
    }

    try {
      final downloadUrl = session!.getDownloadUrl(
        jmapUrl: dynamicUrlInterceptors.jmapUrl,
      );

      await Get.generalDialog(
        barrierColor: Colors.black.withOpacity(0.8),
        pageBuilder: (_, __, ___) {
          return PointerInterceptor(
            child: PDFViewer(
              attachment: attachment,
              accountId: accountId!,
              downloadUrl: downloadUrl,
              downloadAction: _downloadPDFFile,
              printAction: _printPDFFile,
            )
          );
        },
      );
    } catch (e) {
      logError('SingleEmailController::previewPDFFileAction(): $e');
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(e))));
    }
  }

  void previewEMLFileAction(Id? blobId, AppLocalizations appLocalizations) {
    SmartDialog.showLoading(
      msg: appLocalizations.loadingPleaseWait,
      maskColor: Colors.black38,
    );

    if (accountId == null) {
      consumeState(Stream.value(Left(ParseEmailByBlobIdFailure(NotFoundAccountIdException()))));
      return;
    }

    if (blobId == null) {
      consumeState(Stream.value(Left(ParseEmailByBlobIdFailure(NotFoundBlobIdException([])))));
      return;
    }

    consumeState(_parseEmailByBlobIdInteractor.execute(accountId!, blobId));
  }

  void _handleParseEmailByBlobIdSuccess(ParseEmailByBlobIdSuccess success) {
    if (session == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundSessionException()))));
      return;
    }

    if (accountId == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundAccountIdException()))));
      return;
    }

    if (currentContext == null) {
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(NotFoundContextException()))));
      return;
    }

    try {
      consumeState(_previewEmailFromEmlFileInteractor.execute(
        PreviewEmailEMLRequest(
          accountId: accountId!,
          userName: userName!,
          blobId: success.blobId,
          email: success.email,
          locale: Localizations.localeOf(currentContext!),
          appLocalizations: AppLocalizations.of(currentContext!),
          baseDownloadUrl: session!.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl),
        ),
      ));
    } catch (e) {
      logError('SingleEmailController::_handleParseEmailByBlobIdSuccess(): $e');
      consumeState(Stream.value(Left(PreviewEmailFromEmlFileFailure(e))));
    }
  }

  void _handleParseEmailByBlobIdFailure(ParseEmailByBlobIdFailure failure) {
    SmartDialog.dismiss();
    toastManager.showMessageFailure(failure);
  }

  void _handlePreviewPDFFileFailure(PreviewPDFFileFailure failure) {
    SmartDialog.dismiss();
    toastManager.showMessageFailure(failure);
  }

  void _handlePreviewEmailFromEMLFileFailure(PreviewEmailFromEmlFileFailure failure) {
    SmartDialog.dismiss();
    toastManager.showMessageFailure(failure);
  }

  void _handlePreviewEmailFromEMLFileSuccess(PreviewEmailFromEmlFileSuccess success) {
    SmartDialog.dismiss();

    if (PlatformInfo.isWeb) {
      bool isOpen = HtmlUtils.openNewWindowByUrl(
        RouteUtils.createUrlWebLocationBar(
          AppRoutes.emailEMLPreviewer,
          previewId: success.emlPreviewer.id
        ).toString(),
      );

      if (!isOpen) {
        toastManager.showMessageFailure(PreviewEmailFromEmlFileFailure(CannotOpenNewWindowException()));
      }
    } else if (PlatformInfo.isMobile) {
      if (currentContext == null) {
        toastManager.showMessageFailure(PreviewEmailFromEmlFileFailure(NotFoundContextException()));
        return;
      }

      showModalSheetToPreviewEMLAttachment(
        currentContext!,
        success.emlPreviewer);
    }
  }

  void showModalSheetToPreviewEMLAttachment(
    BuildContext context,
    EMLPreviewer emlPreviewer,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          builder: (context, ___) => EmailPreviewerDialogView(
            emlPreviewer: emlPreviewer,
            onMailtoDelegateAction: openMailToLink,
            onPreviewEMLDelegateAction: (uri) => _openEMLPreviewer(context, uri),
            onDownloadAttachmentDelegateAction: (uri) =>
                _downloadAttachmentInEMLPreview(context, uri),
          ),
        );
      },
    );
  }

  Future<void> _openEMLPreviewer(BuildContext context, Uri? uri) async {
    log('SingleEmailController::_openEMLPreviewer:uri = $uri');
    if (uri == null) return;

    final blobId = uri.path;
    log('SingleEmailController::_openEMLPreviewer:blobId = $blobId');
    if (blobId.isEmpty) return;

    previewEMLFileAction(Id(blobId), AppLocalizations.of(context));
  }

  Future<void> _downloadAttachmentInEMLPreview(BuildContext context, Uri? uri) async {
    log('SingleEmailController::_downloadAttachmentInEMLPreview:uri = $uri');
    if (uri == null) return;

    final attachment = EmailUtils.parsingAttachmentByUri(uri);
    if (attachment == null) return;

    handleDownloadAttachmentAction(context, attachment);
  }

  void handleMailToAttendees(CalendarOrganizer? organizer, List<CalendarAttendee>? attendees) {
    List<EmailAddress> listEmailAddressAttendees = [];

    if (organizer != null) {
      listEmailAddressAttendees.add(organizer.toEmailAddress());
    }

    final listEmailAddress = attendees
        ?.map((attendee) => attendee.toEmailAddress())
        .toList() ?? [];

    listEmailAddressAttendees.addAll(listEmailAddress);

    final currentUserEmail = mailboxDashBoardController.sessionCurrent?.getOwnEmailAddress() ?? '';
    final listEmailAddressMailTo = listEmailAddressAttendees.removeInvalidEmails(currentUserEmail);
    log('SingleEmailController::handleMailToAttendees: listEmailAddressMailTo = $listEmailAddressMailTo');
    mailboxDashBoardController.goToComposer(
      ComposerArguments.fromMailtoUri(listEmailAddress: listEmailAddressMailTo)
    );
  }

  void _handleGetHtmlContentFromAttachmentFailure(GetHtmlContentFromAttachmentFailure failure) {
    _updateAttachmentsViewState(failure.attachment.blobId, Left(failure));
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).thisHtmlAttachmentCannotBePreviewed);
    }
  }
}