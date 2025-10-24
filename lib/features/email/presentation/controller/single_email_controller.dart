import 'dart:async';

import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/text/new_line_transformer.dart';
import 'package:core/presentation/utils/html_transformer/text/sanitize_autolink_unescape_html_transformer.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/attendance/calendar_event_attendance.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/calendar_event.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/attendee/calendar_attendee.dart';
import 'package:jmap_dart_client/jmap/mail/calendar/properties/calendar_organizer.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mdn/disposition.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:model/error_type_handler/unknown_uri_exception.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/view_entire_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_counter_accept_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_maybe_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reject_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/calendar_event_reply_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_all_attachments_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/export_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_entire_message_as_document_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_and_get_html_content_from_attachment_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_calendar_event_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/parse_email_by_blob_id_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/preview_email_from_eml_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/send_receipt_to_sender_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_counter_accept_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/calendar_event_reject_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_all_attachments_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_all_attachments_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/export_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_entire_message_as_document_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_and_get_html_content_from_attachment_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/maybe_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_calendar_event_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/parse_email_by_blob_id_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/preview_email_from_eml_file_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/send_receipt_to_sender_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/store_opened_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/calendar_event_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_attendee_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/calendar_organizer_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/handle_open_attachment_list_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/update_attendance_status_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/download_attachment_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/mixin/preview_attachment_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/model/blob_calendar_event.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/focus_thread_detail_expanded_email.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/mark_collapsed_email_unread_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/on_thread_page_changed.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/update_cached_list_email_loaded.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class SingleEmailController extends BaseController
    with AppLoaderMixin,
        PreviewAttachmentMixin,
        DownloadAttachmentMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final DownloadAttachmentsInteractor _downloadAttachmentsInteractor;
  final DeviceManager _deviceManager;
  final ExportAttachmentInteractor _exportAttachmentInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final StoreOpenedEmailInteractor _storeOpenedEmailInteractor;
  final PrintEmailInteractor _printEmailInteractor;
  final ParseEmailByBlobIdInteractor _parseEmailByBlobIdInteractor;
  final PreviewEmailFromEmlFileInteractor _previewEmailFromEmlFileInteractor;
  final DownloadAndGetHtmlContentFromAttachmentInteractor _downloadAndGetHtmlContentFromAttachmentInteractor;
  final DownloadAllAttachmentsForWebInteractor _downloadAllAttachmentsForWebInteractor;
  final ExportAllAttachmentsInteractor _exportAllAttachmentsInteractor;
  final EmailId? _currentEmailId;

  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  SendReceiptToSenderInteractor? _sendReceiptToSenderInteractor;
  ParseCalendarEventInteractor? _parseCalendarEventInteractor;
  AcceptCalendarEventInteractor? _acceptCalendarEventInteractor;
  MaybeCalendarEventInteractor? _maybeCalendarEventInteractor;
  RejectCalendarEventInteractor? _rejectCalendarEventInteractor;
  AcceptCounterCalendarEventInteractor? _acceptCounterCalendarEventInteractor;
  ThreadDetailController? _threadDetailController;

  final emailContents = RxnString();
  final attachments = <Attachment>[].obs;
  final isDisplayAllAttachments = RxBool(false);
  final emlPreviewer = <Attachment>[].obs;
  final blobCalendarEvent = Rxn<BlobCalendarEvent>();
  final emailLoadedViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final emailUnsubscribe = Rxn<EmailUnsubscribe>();
  final attachmentsViewState = RxMap<Id, Either<Failure, Success>>();
  final isEmailContentHidden = RxBool(false);
  final currentEmailLoaded = Rxn<EmailLoaded>();
  final isEmailContentClipped = RxBool(false);
  final attendanceStatus = Rxn<AttendanceStatus>();
  final htmlContentViewKey = GlobalKey<HtmlContentViewState>();

  Identity? _identitySelected;
  ButtonState? _printEmailButtonState;
  GlobalKey? attachmentListKey;

  final obxListeners = <Worker>[];
  late final EmailActionReactor emailActionReactor;

  final StreamController<Either<Failure, Success>> _downloadProgressStateController =
      StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get downloadProgressState => _downloadProgressStateController.stream;

  ThreadDetailController? get threadDetailController => _threadDetailController;

  PresentationEmail? get currentEmail {
    if (PlatformInfo.isMobile &&
        _threadDetailController?.isThreadDetailEnabled != true) {
      return mailboxDashBoardController.selectedEmail.value;
    }
    return _currentEmailId == null
      ? null
      : _threadDetailController?.emailIdsPresentation[_currentEmailId];
  }

  bool get calendarEventProcessing => viewState.value.fold(
    (failure) => false,
    (success) => success is CalendarEventReplying);

  CalendarEvent? get calendarEvent => blobCalendarEvent.value?.calendarEventList.firstOrNull;
  Id? get _displayingEventBlobId => blobCalendarEvent.value?.blobId;
  bool get isCalendarEventFree => blobCalendarEvent.value?.isFree ?? true;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  String get ownEmailAddress => mailboxDashBoardController.ownEmailAddress.value;

  GlobalObjectKey? get htmlViewKey => _threadDetailController?.expandedEmailHtmlViewKey;

  bool get isThreadDetailEnabled =>
      _threadDetailController?.isThreadDetailEnabled == true;

  SingleEmailController(
    this._getEmailContentInteractor,
    this._markAsEmailReadInteractor,
    this._downloadAttachmentsInteractor,
    this._deviceManager,
    this._exportAttachmentInteractor,
    this._markAsStarEmailInteractor,
    this._downloadAttachmentForWebInteractor,
    this._getAllIdentitiesInteractor,
    this._storeOpenedEmailInteractor,
    this._printEmailInteractor,
    this._parseEmailByBlobIdInteractor,
    this._previewEmailFromEmlFileInteractor,
    this._downloadAndGetHtmlContentFromAttachmentInteractor,
    this._downloadAllAttachmentsForWebInteractor,
    this._exportAllAttachmentsInteractor, {
    EmailId? currentEmailId,
  }) : _currentEmailId = currentEmailId;

  @override
  void onInit() {
    if (PlatformInfo.isWeb) {
      attachmentListKey = GlobalKey();
    }
    _threadDetailController = getBinding<ThreadDetailController>();
    _injectCalendarEventBindings(session, accountId);
    _registerObxStreamListener();
    _listenDownloadAttachmentProgressState();
    emailActionReactor = EmailActionReactor(
      _markAsEmailReadInteractor,
      _markAsStarEmailInteractor,
      _createNewEmailRuleFilterInteractor,
      _printEmailInteractor,
      _getEmailContentInteractor,
      _downloadAttachmentForWebInteractor,
    );
    super.onInit();
  }

  @override
  void onClose() {
    _threadDetailController = null;
    _downloadProgressStateController.close();
    CalendarEventInteractorBindings().dispose();
    MdnInteractorBindings().dispose();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetEmailContentSuccess) {
      _getEmailContentSuccess(success);
    } else if (success is GetEmailContentFromCacheSuccess) {
      _getEmailContentOfflineSuccess(success);
    } else if (success is MarkAsEmailReadSuccess) {
      _handleMarkAsEmailReadCompleted(success);
    } else if (success is ExportAttachmentSuccess) {
      exportAttachmentSuccessAction(success.downloadedResponse);
    } else if (success is ExportAllAttachmentsSuccess) {
      exportAllAttachmentsSuccessAction(success.downloadedResponse.filePath);
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
    } else if (success is ParseEmailByBlobIdSuccess) {
      handleParseEmailByBlobIdSuccess(
        context: currentContext,
        accountId: accountId,
        session: session,
        ownEmailAddress: ownEmailAddress,
        blobId: success.blobId,
        email: success.email,
        controller: this,
        previewInteractor: _previewEmailFromEmlFileInteractor,
      );
    } else if (success is PreviewEmailFromEmlFileSuccess) {
      previewEMLFileAction(
        emlPreviewer: success.emlPreviewer,
        context: currentContext,
        imagePaths: imagePaths,
        onMailtoAction: openMailToLink,
        onDownloadAction: (uri) async => downloadAttachmentInEMLPreview(
          uri: uri,
          onDownloadAction: handleDownloadAttachmentAction,
        ),
        onPreviewAction: (uri) async {
          if (currentContext != null) {
            openEMLPreviewer(
              context: currentContext!,
              uri: uri,
              accountId: accountId,
              controller: this,
              parseEmailInteractor: _parseEmailByBlobIdInteractor,
            );
          }
        },
      );
    } else if (success is DownloadAndGetHtmlContentFromAttachmentSuccess) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
      previewHtmlFileAction(
        attachment: success.attachment,
        title: success.htmlAttachmentTitle,
        content: success.sanitizedHtmlContent,
        openMailToLink: openMailToLink,
        onDownloadAction: handleDownloadAttachmentAction,
        responsiveUtils: responsiveUtils,
      );
    } else if (success is DownloadAndGettingHtmlContentFromAttachment) {
      _updateAttachmentsViewState(success.attachment.blobId, Right(success));
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is MarkAsEmailReadFailure) {
      _handleMarkAsEmailReadFailure(failure);
    } else if (failure is DownloadAttachmentsFailure) {
      _downloadAttachmentsFailure(failure);
    } else if (failure is ExportAttachmentFailure) {
      exportAttachmentFailureAction(failure.exception);
    } else if (failure is ExportAllAttachmentsFailure) {
      exportAllAttachmentsFailureAction(failure.exception);
    } else if (failure is DownloadAttachmentForWebFailure) {
      downloadAttachmentForWebFailureAction(
        failureState: failure,
        onCallbackAction: () {
          if (failure.taskId != null) {
            mailboxDashBoardController.deleteDownloadTask(failure.taskId!);
          }

          if (failure.attachment != null) {
            _updateAttachmentsViewState(
              failure.attachment?.blobId,
              Left(failure),
            );
          }
        },
      );
    } else if (failure is DownloadAllAttachmentsForWebFailure) {
      downloadAllAttachmentsForWebFailure(
        failureState: failure,
        onCallbackAction: () {
          mailboxDashBoardController.deleteDownloadTask(failure.taskId);
        }
      );
    } else if (failure is ParseCalendarEventFailure) {
      _handleParseCalendarEventFailure(failure);
    } else if (failure is GetEmailContentFailure) {
      _handleGetEmailContentFailure(failure);
    } else if (failure is PrintEmailFailure) {
      _showMessageWhenEmailPrintingFailed(failure);
    } else if (failure is CalendarEventReplyFailure) {
      _calendarEventFailure(failure);
    } else if (failure is ParseEmailByBlobIdFailure) {
      handleParseEmailByBlobIdFailure(failure);
    } else if (failure is PreviewEmailFromEmlFileFailure) {
      handlePreviewEmailFromEMLFileFailure(failure);
    } else if (failure is DownloadAndGetHtmlContentFromAttachmentFailure) {
      _updateAttachmentsViewState(failure.attachment.blobId, Left(failure));
      handlePreviewHtmlFileFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  void _handleMarkAsEmailReadFailure(MarkAsEmailReadFailure failure) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).an_error_occurred,
      );
    }
  }

  void _handleGetEmailContentFailure(GetEmailContentFailure failure) {
    emailLoadedViewState.value = Left<Failure, Success>(failure);
    showRetryToast(failure);
  }

  void _registerObxStreamListener() {
    if (accountId != null) {
      _injectAndGetInteractorBindings(session, accountId!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleOpenEmailDetailedView();
    });

    obxListeners.add(ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is HideEmailContentViewAction) {
        isEmailContentHidden.value = true;
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is ShowEmailContentViewAction) {
        isEmailContentHidden.value = false;
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is PerformEmailActionInThreadDetailAction) {
        if (action.presentationEmail.id != _currentEmailId) return;
        pressEmailAction(
          action.emailActionType,
          action.presentationEmail,
        );
      } else if (action is DisposePreviousExpandedEmailAction) {
        if (_currentEmailId == null || _currentEmailId != action.emailId) return;
        for (var worker in obxListeners) {
          worker.dispose();
        }
        Get.delete<SingleEmailController>(tag: action.emailId.id.value);
      } else if (action is CloseEmailInThreadDetailAction) {
        if (_currentEmailId == null) return;
        closeEmailView(context: currentContext);
        for (var worker in obxListeners) {
          worker.dispose();
        }
        Get.delete<SingleEmailController>(tag: _currentEmailId!.id.value);
      } else if (action is UnsubscribeFromThreadAction) {
        if (_currentEmailId == null || action.emailId != _currentEmailId) return;
        _handleUnsubscribe(action.listUnsubscribe);
      } else if (action is CollapseEmailInThreadDetailAction) {
        if (_currentEmailId == null || action.emailId != _currentEmailId) return;
        for (var worker in obxListeners) {
          worker.dispose();
        }
        Get.delete<SingleEmailController>(tag: _currentEmailId!.id.value);
      } else if (action is OpenAttachmentListAction) {
        if (_currentEmailId == null || action.emailId != _currentEmailId) {
          return;
        }
        jumpToAttachmentList(
          emailId: _currentEmailId!,
          countAttachments: action.countAttachments,
          screenHeight: action.screenHeight,
          isDisplayAllAttachments: action.isDisplayAllAttachments,
        );
        mailboxDashBoardController.clearEmailUIAction();
      }
    }));

    obxListeners.add(ever(mailboxDashBoardController.viewState, (viewState) {
      viewState.map((success) {
        if (success is UnsubscribeEmailSuccess) {
          if (success.emailId != _currentEmailId) return;
          emailUnsubscribe.value = null;
        }
      });
    }));
  }

  void _handleOpenEmailDetailedView() {
    if (currentEmail == null) {
      log('SingleEmailController::_handleOpenEmailDetailedView(): email unselected');
      return;
    }
    emailLoadedViewState.value = Right<Failure, Success>(GetEmailContentLoading());

    _resetToOriginalValue();

    if (currentEmail?.id != null) {
      _createSingleEmailView(currentEmail!.id!);
    }

    if (!currentEmail!.hasRead) {
      markAsEmailRead(currentEmail!, ReadActions.markAsRead, MarkReadAction.tap);
    }

    if (mailboxDashBoardController.listIdentities.isEmpty) {
      _getAllIdentities();
    } else {
      _initializeSelectedIdentity(mailboxDashBoardController.listIdentities);
    }
  }

  void _createSingleEmailView(EmailId emailId) {
    log('SingleEmailController::_createSingleEmailView():');
    _getEmailContentAction(emailId);
  }

  void _listenDownloadAttachmentProgressState() {
    downloadProgressState.listen((state) {
        log('SingleEmailController::_listenDownloadAttachmentProgressState(): $state');
        state.fold(
          (failure) => null,
          (success) {
            if (success is StartDownloadAttachmentForWeb && !success.previewerSupported) {
              mailboxDashBoardController.addDownloadTask(
                DownloadTaskState(
                  taskId: success.taskId,
                  attachment: success.attachment,
                  onCancel: () => success.cancelToken?.cancel(),
                ),
              );

              if (currentOverlayContext != null && currentContext != null && !success.previewerSupported) {
                appToast.showToastMessage(
                  currentOverlayContext!,
                  AppLocalizations.of(currentContext!).your_download_has_started,
                  leadingSVGIconColor: AppColor.primaryColor,
                  leadingSVGIcon: imagePaths.icDownload);
              }
            } else if (success is DownloadingAttachmentForWeb) {
              final percent = success.progress.round();
              log('SingleEmailController::DownloadingAttachmentForWeb(): $percent%');

              mailboxDashBoardController.updateDownloadTask(
                success.taskId,
                (currentTask) {
                  final newTask = currentTask.copyWith(
                    progress: success.progress,
                    downloaded: success.downloaded,
                    total: success.total);

                  return newTask;
                });
            } else if (success is StartDownloadAllAttachmentsForWeb) {
              mailboxDashBoardController.addDownloadTask(
                DownloadTaskState(
                  taskId: success.taskId,
                  attachment: success.attachment,
                  onCancel: () => success.cancelToken?.cancel(),
                ),
              );

              if (currentOverlayContext != null && currentContext != null) {
                appToast.showToastSuccessMessage(
                  currentOverlayContext!,
                  AppLocalizations.of(currentContext!).creatingAnArchiveForDownloading,
                  leadingSVGIconColor: Colors.white,
                  leadingSVGIcon: imagePaths.icDownloadAll,
                );
              }
            } else if (success is DownloadingAllAttachmentsForWeb) {
              final percent = success.progress.round();
              log('SingleEmailController::DownloadingAttachmentForWeb(): $percent%');

              mailboxDashBoardController.updateDownloadTask(
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
    _acceptCounterCalendarEventInteractor = getBinding<AcceptCounterCalendarEventInteractor>();
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
    if (_currentEmailId != null && _threadDetailController?.cachedEmailLoaded[_currentEmailId!] != null) {
      final emailLoaded = _threadDetailController!.cachedEmailLoaded[_currentEmailId!]!;
      consumeState(Stream.value(Right(GetEmailContentFromThreadCacheSuccess(
        htmlEmailContent: emailLoaded.htmlContent,
        emailCurrent: emailLoaded.emailCurrent,
        attachments: emailLoaded.attachments,
        inlineImages: emailLoaded.inlineImages,
      ))));
      return;
    }

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
        consumeState(Stream.value(Left(GetEmailContentFailure(
          e,
          onRetry: e is UnknownUriException
            ? null
            : _getEmailContentInteractor.execute(
                session!,
                accountId!,
                emailId,
                session!.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl),
                PlatformInfo.isWeb
                  ? TransformConfiguration.forPreviewEmailOnWeb()
                  : TransformConfiguration.forPreviewEmail(),
              ),
        ))));
      }
    }
  }

  void _getEmailContentOfflineSuccess(GetEmailContentFromCacheSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);

    currentEmailLoaded.value = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments ?? []),
      inlineImages: List.of(success.inlineImages ?? []),
      emailCurrent: success.emailCurrent,
    );
    _threadDetailController?.currentEmailLoaded.value = currentEmailLoaded.value;

    if (success.emailCurrent.id == currentEmail?.id) {
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

      final isShowMessageReadReceipt = success.emailCurrent.hasReadReceipt(mailboxDashBoardController.mapMailboxById) == true;
      if (isShowMessageReadReceipt) {
        _handleReadReceipt();
      }

      if (currentEmail?.isSubscribed == false && success.emailCurrent.hasListUnsubscribe == true) {
        _handleUnsubscribe(success.emailCurrent.listUnsubscribe);
      } else {
        emailUnsubscribe.value = null;
      }
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailLoadedViewState.value = Right<Failure, Success>(success);

    currentEmailLoaded.value = EmailLoaded(
      htmlContent: success.htmlEmailContent,
      attachments: List.of(success.attachments ?? []),
      inlineImages: List.of(success.inlineImages ?? []),
      emailCurrent: success.emailCurrent,
    );
    _threadDetailController?.currentEmailLoaded.value = currentEmailLoaded.value;

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
      } else if (currentEmail?.id != null && currentEmailLoaded.value != null) {
        _threadDetailController?.cacheEmailLoaded(
          currentEmail!.id!,
          currentEmailLoaded.value!,
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
    if ((_threadDetailController?.emailIdsPresentation.keys.length ?? 0) > 1 == true) {
      _jumpScrollViewToTopOfEmail();
    }
  }

  void _jumpScrollViewToTopOfEmail() {
    if (_currentEmailId == null) return;
    _threadDetailController?.focusExpandedEmail(_currentEmailId!);
  }

  void _handleUnsubscribe(String listUnsubscribe) {
    emailUnsubscribe.value = EmailUtils.parsingUnsubscribe(listUnsubscribe);
  }

  void _handleReadReceipt() {
    if (currentContext != null) {
      MessageDialogActionManager().showConfirmDialogAction(currentContext!,
        AppLocalizations.of(currentContext!).subTitleReadReceiptRequestNotificationMessage,
        AppLocalizations.of(currentContext!).yes,
        onConfirmAction: () => _handleSendReceiptToSenderAction(currentContext!),
        showAsBottomSheet: true,
        dialogMargin: MediaQuery.paddingOf(currentContext!).add(const EdgeInsets.only(bottom: 12)),
        title: AppLocalizations.of(currentContext!).titleReadReceiptRequestNotificationMessage,
        cancelTitle: AppLocalizations.of(currentContext!).no,
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
    isEmailContentClipped.value = false;
    attendanceStatus.value = null;
    if (isEmailClosing) {
      emailLoadedViewState.value = Right(UIState.idle);
      viewState.value = Right(UIState.idle);
    }
  }

  PresentationMailbox? getMailboxContain(PresentationEmail email) {
    return email.findMailboxContain(mailboxDashBoardController.mapMailboxById);
  }

  void markAsEmailRead(
    PresentationEmail presentationEmail,
    ReadActions readActions,
    MarkReadAction markReadAction,
  ) {
    if (accountId != null && session != null && presentationEmail.id != null) {
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

  void _handleMarkAsEmailReadCompleted(MarkAsEmailReadSuccess success) {
    _threadDetailController?.markCollapsedEmailReadSuccess(success);
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

  void exportAllAttachments(String outputFileName) {
    final cancelToken = CancelToken();
    showDownloadingFileDialog(
      attachmentName: outputFileName,
      cancelToken: cancelToken,
    );
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
    if (!downloadAllSupported) {
      consumeState(Stream.value(Left(ExportAllAttachmentsFailure())));
      return;
    }
    
    final baseDownloadAllUrl = session!.getDownloadAllCapability(accountId)!.endpoint!;
    consumeState(_exportAllAttachmentsInteractor.execute(
      accountId!,
      currentEmail!.id!,
      baseDownloadAllUrl,
      outputFileName,
      cancelToken: cancelToken,
    ));
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
    final emailId = currentEmail?.id;

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

  void _downloadAttachmentForWebSuccessAction(DownloadAttachmentForWebSuccess success) {
    log('SingleEmailController::_downloadAttachmentForWebSuccessAction():');

    _updateAttachmentsViewState(success.attachment.blobId, Right(success));

    mailboxDashBoardController.deleteDownloadTask(success.taskId);

    if (!success.previewerSupported) {
      downloadFileWebAction(
        fileName: success.attachment.generateFileName(),
        fileBytes: success.bytes,
      );
      return;
    }

    if (success.attachment.isImage) {
      previewImageFileAction(
        attachment: success.attachment,
        imageBytes: success.bytes,
        context: currentContext,
        onDownloadAction: handleDownloadAttachmentAction,
      );
    } else if (success.attachment.isText || success.attachment.isJson) {
      previewPlainTextFileAction(
        attachment: success.attachment,
        fileBytes: success.bytes,
        context: currentContext,
        onDownloadAction: handleDownloadAttachmentAction,
      );
    }
  }

  void _updateAttachmentsViewState(
    Id? attachmentBlobId,
    Either<Failure, Success> viewState) {
      if (attachmentBlobId != null) {
        attachmentsViewState[attachmentBlobId] = viewState;
      }
  }

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    if (session != null && accountId != null) {
      final moveActionRequest = await emailActionReactor.moveToMailbox(
        session!,
        accountId!,
        email,
        mapMailbox: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: currentEmail?.findMailboxContain(
          mailboxDashBoardController.mapMailboxById,
        ),
        isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
      );
      if (!context.mounted || moveActionRequest == null) return;
      mailboxDashBoardController.moveToMailbox(
        session!,
        accountId!,
        moveActionRequest.moveRequest,
        moveActionRequest.emailIdsWithReadStatus,
      );
      if (_threadDetailController?.emailIdsPresentation.length == 1) {
        _threadDetailController?.closeThreadDetailAction(context);
      }
    }
  }

  void moveToTrash(BuildContext context, PresentationEmail email) {
    if (session != null && accountId != null) {
      final moveActionRequest = emailActionReactor.moveToTrash(
        email,
        mapMailbox: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
        isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
        mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
      );
      if (!context.mounted || moveActionRequest == null) return;
      mailboxDashBoardController.moveToMailbox(
        session!,
        accountId!,
        moveActionRequest.moveRequest,
        moveActionRequest.emailIdsWithReadStatus,
      );
      if (_threadDetailController?.emailIdsPresentation.length == 1) {
        _threadDetailController?.closeThreadDetailAction(context);
      }
    }
  }

  void moveToSpam(BuildContext context, PresentationEmail email) {
    if (session != null && accountId != null) {
      final moveActionRequest = emailActionReactor.moveToSpam(
        email,
        mapMailbox: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
        isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
        mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
      );
      if (!context.mounted || moveActionRequest == null) return;
      mailboxDashBoardController.moveToMailbox(
        session!,
        accountId!,
        moveActionRequest.moveRequest,
        moveActionRequest.emailIdsWithReadStatus,
      );
      if (_threadDetailController?.emailIdsPresentation.length == 1) {
        _threadDetailController?.closeThreadDetailAction(context);
      }
    }
  }

  void unSpam(BuildContext context, PresentationEmail email) {
    if (session != null && accountId != null) {
      final moveActionRequest = emailActionReactor.unSpam(
        email,
        mapMailbox: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
        isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
        mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
      );
      if (!context.mounted || moveActionRequest == null) return;
      mailboxDashBoardController.moveToMailbox(
        session!,
        accountId!,
        moveActionRequest.moveRequest,
        moveActionRequest.emailIdsWithReadStatus,
      );
      if (_threadDetailController?.emailIdsPresentation.length == 1) {
        _threadDetailController?.closeThreadDetailAction(context);
      }
    }
  }

  void _markAsEmailStarSuccess(MarkAsStarEmailSuccess success) {
    final newKeywords = {
      KeyWordIdentifier.emailFlagged:
        success.markStarAction == MarkStarAction.markStar,
    };

    final newEmail = currentEmail?.updateKeywords(newKeywords);
    final emailId = newEmail?.id;
    if (emailId == null) return;

    if (PlatformInfo.isMobile && !isThreadDetailEnabled) {
      mailboxDashBoardController.selectedEmail.value?.resyncKeywords(newKeywords);
    } else {
      _threadDetailController?.emailIdsPresentation[emailId] = newEmail;
    }

    mailboxDashBoardController.updateEmailFlagByEmailIds(
      [emailId],
      markStarAction: success.markStarAction,
    );

    toastManager.showMessageSuccess(success);
  }

  void handleEmailAction(BuildContext context, PresentationEmail presentationEmail, EmailActionType actionType) {
    switch(actionType) {
      case EmailActionType.markAsUnread:
        if (session != null && accountId != null) {
          consumeState(emailActionReactor.markAsEmailRead(
            session!,
            accountId!,
            presentationEmail,
            readAction: ReadActions.markAsUnread,
          ));
        }
        break;
      case EmailActionType.markAsStarred:
        if (session != null && accountId != null) {
          consumeState(emailActionReactor.markAsStarEmail(
            session!,
            accountId!,
            presentationEmail,
            markStarAction: MarkStarAction.markStar,
          ));
        }
        break;
      case EmailActionType.unMarkAsStarred:
        if (session != null && accountId != null) {
          consumeState(emailActionReactor.markAsStarEmail(
            session!,
            accountId!,
            presentationEmail,
            markStarAction: MarkStarAction.unMarkStar,
          ));
        }
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
      case EmailActionType.reply:
        _replyEmail(presentationEmail);
        break;
      case EmailActionType.replyAll:
      case EmailActionType.replyToList:
      case EmailActionType.forward:
        pressEmailAction(actionType, presentationEmail);
        break;
      default:
        break;
    }
  }

  void openEmailAddressDialog(EmailAddress emailAddress) {
    if (session == null || accountId == null) return;

    emailActionReactor.openEmailAddressDialog(
      session!,
      accountId!,
      emailAddress: emailAddress,
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
      appToast: appToast,
      onComposeEmailFromEmailAddressRequest: (emailAddress) {
        popBack();
        mailboxDashBoardController.openComposer(
          ComposerArguments.fromEmailAddress(emailAddress),
        );
      },
      onQuickCreateRuleRequest: (quickCreateRuleStream) {
        consumeState(quickCreateRuleStream);
      },
    );
  }

  Future<void> openMailToLink(Uri? uri) async {
    if (uri == null) return;
    
    final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(uri.toString());
    log('SingleEmailController::openMailToLink(): ${uri.toString()}');
    if (!RouteUtils.canOpenComposerFromNavigationRouter(navigationRouter)) return;

    mailboxDashBoardController.openComposer(
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
    emailActionReactor.deleteEmailPermanently(
      email,
      onDeleteEmailRequest: (email) {
        popBack();
        mailboxDashBoardController.deleteEmailPermanently(email);
        if (_threadDetailController?.emailIdsPresentation.length == 1) {
          _threadDetailController?.closeThreadDetailAction(context);
        }
      },
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
    );
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

    if (currentEmail == null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(context).toastMessageCannotFoundEmailIdWhenSendReceipt);
      return;
    }

    String receiverEmailAddress = _getReceiverEmailAddress(currentEmail!)
        ?? ownEmailAddress;
    if (receiverEmailAddress.trim().isEmpty) {
      receiverEmailAddress = session!.getOwnEmailAddressOrUsername();
    }
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
    mailboxDashBoardController.clearSelectedEmail();
    _resetToOriginalValue(isEmailClosing: true);
    _replaceBrowserHistory();
    if (mailboxDashBoardController.searchController.isSearchEmailRunning
      || getBinding<SearchEmailController>()?.searchIsRunning.value == true
    ) {
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

  bool get isOpenEmailNotMailboxFromRoute => mailboxDashBoardController.selectedMailbox.value == null;

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
        mailboxDashBoardController.openComposer(ComposerArguments());
        break;
      case EmailActionType.reply:
        _replyEmail(presentationEmail);
        break;
      case EmailActionType.replyToList:
        log('SingleEmailController::pressEmailAction:replyToList');
        mailboxDashBoardController.openComposer(
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
        mailboxDashBoardController.openComposer(
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
        mailboxDashBoardController.openComposer(
          ComposerArguments.forwardEmail(
            presentationEmail: presentationEmail,
            content: currentEmailLoaded.value?.htmlContent ?? '',
            attachments: List.from(attachments),
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
      consumeState(emailActionReactor.quickCreateRule(
        session!,
        accountId!,
        emailAddress: emailAddress,
      ));
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
    blobCalendarEvent.value = success.blobCalendarEventList.firstOrNull;
    updateAttendanceStatus(success);
  }

  void _handleParseCalendarEventFailure(ParseCalendarEventFailure failure) {
    emailLoadedViewState.value = Left<Failure, Success>(failure);
    emailContents.value = currentEmailLoaded.value?.htmlContent;
  }

  void openNewTabAction(String link) {
    AppUtils.launchLink(link);
  }

  void openNewComposerAction(String mailTo) {
    final emailAddress = EmailAddress(mailTo, mailTo);
    mailboxDashBoardController.openComposer(ComposerArguments.fromEmailAddress(emailAddress));
  }

  void showAllAttachmentsAction() {
    isDisplayAllAttachments.value = true;
    threadDetailController?.isDisplayAllAttachments = true;
  }

  void hideAllAttachmentsAction() {
    isDisplayAllAttachments.value = false;
    threadDetailController?.isDisplayAllAttachments = false;
  }

  void _unsubscribeEmail(BuildContext context, PresentationEmail presentationEmail) {
    emailActionReactor.unsubscribeEmail(
      presentationEmail,
      emailUnsubscribe: emailUnsubscribe.value,
      onUnsubscribeByHttpsLink: mailboxDashBoardController.unsubscribeMail,
      onUnsubscribeByMailtoLink: (emailId, navigationRouter) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.fromUnsubscribeMailtoLink(
            listEmailAddress: navigationRouter.listEmailAddress,
            subject: navigationRouter.subject,
            body: navigationRouter.body,
            previousEmailId: emailId,
          )
        );
      },
    );
  }

  void archiveMessage(BuildContext context, PresentationEmail email) {
    emailActionReactor.archiveMessage(
      email,
      onArchiveEmailRequest: (presentationEmail) {
        mailboxDashBoardController.archiveMessage(context, presentationEmail);
      },
    );
  }

  void _printEmail(BuildContext context, PresentationEmail email) {
    if (_printEmailButtonState == ButtonState.disabled) {
      log('SingleEmailController::_printEmail: Print email started');
      return;
    }

    _printEmailButtonState = ButtonState.disabled;
    String accountDisplayName = ownEmailAddress;
    if (accountDisplayName.trim().isEmpty) {
      accountDisplayName = session?.getOwnEmailAddressOrUsername() ?? '';
    }
    consumeState(emailActionReactor.printEmail(
      email,
      ownEmailAddress: accountDisplayName,
      emailLoaded: currentEmailLoaded.value!,
    ));
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
      case EventActionType.acceptCounter:
        _acceptCounterCalendarEventAction(emailId);
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

  void _acceptCounterCalendarEventAction(EmailId emailId) {
    if (canNotAcceptCounterCalendarEvent) {
      consumeState(Stream.value(Left(CalendarEventCounterAcceptFailure())));
    } else {
      consumeState(_acceptCounterCalendarEventInteractor!.execute(
        accountId!,
        {_displayingEventBlobId!},
        emailId,
      ));
    }
  }

  bool get canNotAcceptCounterCalendarEvent => _acceptCounterCalendarEventInteractor == null
    || _displayingEventBlobId == null
    || accountId == null
    || session == null
    || session!.validateCalendarEventCapability(accountId!).isAvailable == false
    || !session!.validateAcceptCounterCalendarEventCapability(accountId!);

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
          LocalizationService.getInitialLocale(),
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
          LocalizationService.getInitialLocale(),
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
          LocalizationService.getInitialLocale(),
          accountId!,
        ),
      ));
    }
  }

  void calendarEventSuccess(CalendarEventReplySuccess success) {
    updateAttendanceStatus(success);

    if (currentOverlayContext == null || currentContext == null) {
      return;
    }

    appToast.showToastSuccessMessage(
      currentOverlayContext!,
      success.getEventActionType().getToastMessageSuccess(currentContext!),
    );
  }

  void _calendarEventFailure(CalendarEventReplyFailure failure) {
    toastManager.showMessageFailure(failure);
  }

  void _downloadMessageAsEML(PresentationEmail presentationEmail) {
    if (accountId == null || session == null) return;

    consumeState(emailActionReactor.downloadMessageAsEML(
      session!,
      accountId!,
      presentationEmail,
      downloadProgressStateController: _downloadProgressStateController,
    ));
  }

  void _editAsNewEmail(PresentationEmail presentationEmail) {
    if (accountId == null || session == null) return;

    emailActionReactor.editAsNewEmail(
      presentationEmail,
      onEditAsEmailRequest: (presentationEmail) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.editAsNewEmail(presentationEmail),
        );
      },
    );
  }

  void _replyEmail(PresentationEmail presentationEmail) {
    emailActionReactor.replyEmail(
      presentationEmail,
      emailLoaded: currentEmailLoaded.value,
      onReplyEmailRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.replyEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            inlineImages: emailLoaded?.inlineImages,
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: emailLoaded?.emailCurrent?.messageId,
            references: emailLoaded?.emailCurrent?.references,
            listPost: emailLoaded?.emailCurrent?.listPost,
          )
        );
      },
    );
  }

  void handleDownloadAttachmentAction(
    Attachment attachment,
    {bool previewerSupported = false}
  ) {
    if (PlatformInfo.isWeb) {
      downloadAttachmentForWeb(
        attachment: attachment,
        accountId: accountId,
        session: session,
        controller: this,
        previewerSupported: previewerSupported,
        onReceiveController: _downloadProgressStateController,
        downloadInteractor: _downloadAttachmentForWebInteractor,
      );
    } else if (PlatformInfo.isMobile) {
      exportAttachment(
        attachment: attachment,
        accountId: accountId,
        session: session,
        controller: this,
        exportAttachmentInteractor: _exportAttachmentInteractor,
      );
    } else {
      log('EmailView::handleDownloadAttachmentAction: THE PLATFORM IS SUPPORTED');
    }
  }

  void handleDownloadAllAttachmentsAction(String outputFileName) {
    if (PlatformInfo.isWeb) {
      downloadAllAttachmentsForWeb(outputFileName);
    } else if (PlatformInfo.isMobile) {
      exportAllAttachments(outputFileName);
    } else {
      log('EmailView::handleDownloadAllAttachmentsAction: THE PLATFORM IS SUPPORTED');
    }
  }

  void handleViewAttachmentAction(BuildContext context, Attachment attachment) {
    previewAttachmentAction(
      context: context,
      attachment: attachment,
      accountId: accountId,
      session: session,
      controller: this,
      parseEmailInteractor: _parseEmailByBlobIdInteractor,
      downloadAndGetHtmlInteractor: _downloadAndGetHtmlContentFromAttachmentInteractor,
      onPreviewOrDownloadAction: (attachment, isPreview) {
        handleDownloadAttachmentAction(
          attachment,
          previewerSupported: isPreview,
        );
      },
    );
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

    final listEmailAddressMailTo =
        listEmailAddressAttendees.removeInvalidEmails(ownEmailAddress);
    log('SingleEmailController::handleMailToAttendees: listEmailAddressMailTo = $listEmailAddressMailTo');
    mailboxDashBoardController.openComposer(
      ComposerArguments.fromMailtoUri(listEmailAddress: listEmailAddressMailTo)
    );
  }

  void onHtmlContentClippedAction(bool isClipped) {
    log('SingleEmailController::onHtmlContentClippedAction:isClipped = $isClipped');
    isEmailContentClipped.value = isClipped;
  }

  Future<void> onViewEntireMessage({
    required BuildContext context,
    required PresentationEmail presentationEmail,
    required String emailContent,
  }) async {
    final getEntireMessageAsDocumentInteractor = getBinding<GetEntireMessageAsDocumentInteractor>();
    if (getEntireMessageAsDocumentInteractor == null) return;

    final appLocalizations = AppLocalizations.of(context);
    SmartDialog.showLoading(
      msg: appLocalizations.loadingPleaseWait,
      maskColor: Colors.black38,
    );

    final viewEntireMessageRequest = ViewEntireMessageRequest(
      ownEmailAddress: ownEmailAddress,
      presentationEmail: presentationEmail,
      attachments: List.from(attachments),
      emailContent: emailContent,
      locale: Localizations.localeOf(context),
      appLocalizations: appLocalizations,
    );

    final resultState = await getEntireMessageAsDocumentInteractor
      .execute(viewEntireMessageRequest)
      .last;

    resultState.foldSuccess<GetEntireMessageAsDocumentSuccess>(
      onSuccess: (success) {
        SmartDialog.dismiss();

        showDialogToPreviewEMLAttachment(
          context: context,
          emlPreviewer: EMLPreviewer(
            id: presentationEmail.id?.asString ?? '',
            title: presentationEmail.subject ?? '',
            content: success.messageDocument,
          ),
          imagePaths: imagePaths,
          onMailtoAction: openMailToLink,
          onPreviewAction: (uri) => openEMLPreviewer(
            context: context,
            uri: uri,
            accountId: accountId,
            controller: this,
            parseEmailInteractor: _parseEmailByBlobIdInteractor,
          ),
          onDownloadAction: (uri) async => downloadAttachmentInEMLPreview(
            uri: uri,
            onDownloadAction: handleDownloadAttachmentAction,
          ),
        );
      },
      onFailure: (_) {
        SmartDialog.dismiss();
      }
    );
  }

  void onScrollHorizontalEnd(bool isLeftDirection) {
    if (isLeftDirection) {
      _threadDetailController?.onPreviousMobile();
    } else {
      _threadDetailController?.onNextMobile();
    }
  }
}