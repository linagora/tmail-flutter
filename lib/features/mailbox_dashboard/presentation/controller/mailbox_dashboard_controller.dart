import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/compose_action_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/save_to_draft_arguments.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_sending_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_sending_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_restored_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/restore_deleted_message_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/unsubscribe_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_arguments.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/set_error_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/preview_email_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/refresh_action_view_event.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/restore_active_account_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/select_active_account_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/switch_active_account_arguments.dart';
import 'package:tmail_ui_user/features/mailto/presentation/model/mailto_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/controller/work_manager_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/one_time_work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/worker_type.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_state_to_refresh_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailbox_state_to_refresh_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/utils/fcm_utils.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/get_all_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_spam_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart' as work_manager;

class MailboxDashBoardController extends ReloadableController {

  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final search.SearchController searchController = Get.find<search.SearchController>();
  final DownloadController downloadController = Get.find<DownloadController>();
  final AppGridDashboardController appGridDashboardController = Get.find<AppGridDashboardController>();
  final SpamReportController spamReportController = Get.find<SpamReportController>();
  final NetworkConnectionController networkConnectionController = Get.find<NetworkConnectionController>();

  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final MarkAsMailboxReadInteractor _markAsMailboxReadInteractor;
  final GetComposerCacheOnWebInteractor _getEmailCacheOnWebInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final EmptyTrashFolderInteractor _emptyTrashFolderInteractor;
  final DeleteMultipleEmailsPermanentlyInteractor _deleteMultipleEmailsPermanentlyInteractor;
  final GetEmailByIdInteractor _getEmailByIdInteractor;
  final SendEmailInteractor _sendEmailInteractor;
  final StoreSendingEmailInteractor _storeSendingEmailInteractor;
  final UpdateSendingEmailInteractor _updateSendingEmailInteractor;
  final GetAllSendingEmailInteractor _getAllSendingEmailInteractor;
  final StoreSessionInteractor _storeSessionInteractor;
  final EmptySpamFolderInteractor _emptySpamFolderInteractor;
  final SaveEmailAsDraftsInteractor _saveEmailAsDraftsInteractor;
  final UpdateEmailDraftsInteractor _updateEmailDraftsInteractor;
  final DeleteSendingEmailInteractor _deleteSendingEmailInteractor;
  final UnsubscribeEmailInteractor _unsubscribeEmailInteractor;
  final RestoredDeletedMessageInteractor _restoreDeletedMessageInteractor;
  final GetRestoredDeletedMessageInterator _getRestoredDeletedMessageInteractor;

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;
  GetEmailStateToRefreshInteractor? _getEmailStateToRefreshInteractor;
  DeleteEmailStateToRefreshInteractor? _deleteEmailStateToRefreshInteractor;
  GetMailboxStateToRefreshInteractor? _getMailboxStateToRefreshInteractor;
  DeleteMailboxStateToRefreshInteractor? _deleteMailboxStateToRefreshInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final dashBoardAction = Rxn<UIAction>();
  final mailboxUIAction = Rxn<MailboxUIAction>();
  final emailUIAction = Rxn<EmailUIAction>();
  final dashboardRoute = DashboardRoutes.waiting.obs;
  final appInformation = Rxn<PackageInfo>();
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final composerOverlayState = ComposerOverlayState.inActive.obs;
  final viewStateMarkAsReadMailbox = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final vacationResponse = Rxn<VacationResponse>();
  final routerParameters = Rxn<Map<String, String?>>();
  final _isDraggingMailbox = RxBool(false);
  final searchMailboxActivated = RxBool(false);
  final listSendingEmails = RxList<SendingEmail>();
  final refreshingMailboxState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final draggableAppState = Rxn<DraggableAppState>();
  final isRecoveringDeletedMessage = RxBool(false);

  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  final emailsInCurrentMailbox = <PresentationEmail>[].obs;
  final listResultSearch = RxList<PresentationEmail>();
  PresentationMailbox? outboxMailbox;
  ComposerArguments? composerArguments;

  late StreamSubscription _emailAddressStreamSubscription;
  late StreamSubscription _emailContentStreamSubscription;
  late StreamSubscription _fileReceiveManagerStreamSubscription;

  final StreamController<Either<Failure, Success>> _progressStateController =
    StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  final StreamController<RefreshActionViewEvent> _refreshActionEventController =
    StreamController<RefreshActionViewEvent>.broadcast();

  final _notificationManager = LocalNotificationManager.instance;
  final _fcmService = FcmService.instance;

  MailboxDashBoardController(
    this._moveToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._markAsMailboxReadInteractor,
    this._getEmailCacheOnWebInteractor,
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._markAsMultipleEmailReadInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._emptyTrashFolderInteractor,
    this._deleteMultipleEmailsPermanentlyInteractor,
    this._getEmailByIdInteractor,
    this._sendEmailInteractor,
    this._storeSendingEmailInteractor,
    this._updateSendingEmailInteractor,
    this._getAllSendingEmailInteractor,
    this._storeSessionInteractor,
    this._emptySpamFolderInteractor,
    this._saveEmailAsDraftsInteractor,
    this._updateEmailDraftsInteractor,
    this._deleteSendingEmailInteractor,
    this._unsubscribeEmailInteractor,
    this._restoreDeletedMessageInteractor,
    this._getRestoredDeletedMessageInteractor,
  );

  @override
  void onInit() {
    _registerStreamListener();
    BackButtonInterceptor.add(_onBackButtonInterceptor, name: AppRoutes.dashboard);
    super.onInit();
  }

  @override
  void onReady() {
    _registerPendingEmailAddress();
    _registerPendingEmailContents();
    _registerPendingFileInfo();
    _handleArguments();
    _getAppVersion();
    super.onReady();
  }

  void _handleComposerCache() async {
    _getEmailCacheOnWebInteractor.execute().fold(
      (failure) {},
      (success) {
        if(success is GetComposerCacheSuccess){
          openComposerOverlay(ComposerArguments.fromSessionStorageBrowser(success.composerCache));
        }
      },
    );
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is SendEmailLoading) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).your_email_being_sent,
          leadingSVGIcon: imagePaths.icSendToast);
      }
    } else if (success is GetEmailStateToRefreshSuccess) {
      dispatchEmailUIAction(RefreshChangeEmailAction(success.storedState));
      _deleteEmailStateToRefreshAction();
    } else if (success is GetMailboxStateToRefreshSuccess) {
      dispatchMailboxUIAction(RefreshChangeMailboxAction(success.storedState));
      _deleteMailboxStateToRefreshAction();
    } else if (success is SendEmailSuccess) {
      _handleSendEmailSuccess(success);
    } else if (success is SaveEmailAsDraftsSuccess) {
      _saveEmailAsDraftsSuccess(success);
    } else if (success is MoveToMailboxSuccess) {
      _moveToMailboxSuccess(success);
    } else if (success is DeleteEmailPermanentlySuccess) {
      _deleteEmailPermanentlySuccess(success);
    } else if (success is MarkAsMailboxReadAllSuccess ||
        success is MarkAsMailboxReadHasSomeEmailFailure) {
      _markAsReadMailboxSuccess(success);
    } else if (success is GetAllVacationSuccess) {
      if (success.listVacationResponse.isNotEmpty) {
        vacationResponse.value = success.listVacationResponse.first;
      }
    } else if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    } else if (success is MarkAsMultipleEmailReadAllSuccess ||
        success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      _markAsReadSelectedMultipleEmailSuccess(success);
    } else if (success is MarkAsStarMultipleEmailAllSuccess ||
        success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      _markAsStarMultipleEmailSuccess(success);
    } else if (success is MoveMultipleEmailToMailboxAllSuccess ||
        success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      _moveSelectedMultipleEmailToMailboxSuccess(success);
    } else if (success is EmptyTrashFolderSuccess) {
      _emptyTrashFolderSuccess(success);
    } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess ||
        success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      _deleteMultipleEmailsPermanentlySuccess(success);
    } else if (success is GetAppDashboardConfigurationSuccess) {
      appGridDashboardController.handleShowAppDashboard(success.linagoraApplications);
    } else if(success is GetEmailByIdSuccess) {
      _moveToEmailDetailedView(success);
    } else if (success is StoreSendingEmailSuccess) {
      _handleStoreSendingEmailSuccess(success);
    } else if (success is GetAllSendingEmailSuccess) {
      _handleGetAllSendingEmailsSuccess(success);
    } else if (success is UpdateSendingEmailSuccess) {
      _handleUpdateSendingEmailSuccess(success);
    } else if (success is EmptySpamFolderSuccess) {
      _emptySpamFolderSuccess(success);
    } else if (success is MarkAsEmailReadSuccess) {
      _markAsReadEmailSuccess(success);
    } else if (success is DeleteSendingEmailSuccess) {
      getAllSendingEmails();
    } else if (success is UnsubscribeEmailSuccess) {
      _handleUnsubscribeMailSuccess(success.newEmail);
    } else if (success is RestoreDeletedMessageSuccess) {
      dispatchMailboxUIAction(RefreshChangeMailboxAction(success.currentMailboxState));
      _handleRestoreDeletedMessageSuccess(success.emailRecoveryAction.id!);
    } else if (success is GetRestoredDeletedMessageSuccess) {
      _handleGetRestoredDeletedMessageSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is SendEmailFailure) {
      _handleSendEmailFailure(failure);
    } else if (failure is SaveEmailAsDraftsFailure) {
      _handleSaveEmailAsDraftsFailure(failure);
    } else if (failure is UpdateEmailDraftsFailure) {
      _handleUpdateEmailAsDraftsFailure(failure);
    } else if (failure is RemoveEmailDraftsFailure) {
      clearState();
    } else if (failure is MarkAsMailboxReadAllFailure) {
      _markAsReadMailboxAllFailure(failure);
    }  else if (failure is MarkAsMailboxReadFailure) {
      _markAsReadMailboxFailure(failure);
    } else if (failure is GetEmailByIdFailure) {
      _handleGetEmailDetailedFailed(failure);
    } else if (failure is RestoreDeletedMessageFailure) {
      _handleRestoreDeletedMessageFailed();
    } else if (failure is GetRestoredDeletedMessageFailure) {
      _handleRestoreDeletedMessageFailed();
    }
  }

  @override
  void handleExceptionAction({Failure? failure, Exception? exception}) {
    super.handleExceptionAction(failure: failure, exception: exception);
    if (failure is SendEmailFailure && exception is NoNetworkError) {
      if (PlatformInfo.isIOS) {
        if (currentContext != null) {
          _showToastSendMessageFailure(AppLocalizations.of(currentContext!).sendMessageFailure);
        }
        _updateSendingStateWhenSendEmailFailureOnIOS(failure);
      } else if (PlatformInfo.isAndroid) {
        if (failure.emailRequest.storedSendingId != null) {
          _handleStoreSendingEmail(
            failure.session,
            failure.accountId,
            failure.emailRequest,
            failure.mailboxRequest
          );
        } else {
          _handleUpdateSendingEmail(
            failure.session,
            failure.accountId,
            failure.emailRequest,
            failure.mailboxRequest
          );
        }
      }
    }
  }

  void _registerPendingEmailAddress() {
    _emailAddressStreamSubscription =
      _emailReceiveManager.pendingEmailAddressInfo.stream.listen((emailAddress) {
        if (emailAddress?.email?.isNotEmpty == true) {
          _emailReceiveManager.clearPendingEmailAddress();
          goToComposer(ComposerArguments.fromEmailAddress(emailAddress!));
        }
      });
  }

  void _registerPendingEmailContents() {
    _emailContentStreamSubscription =
      _emailReceiveManager.pendingEmailContentInfo.stream.listen((emailContent) {
        if (emailContent?.content.isNotEmpty == true) {
          _emailReceiveManager.clearPendingEmailContent();
          goToComposer(ComposerArguments.fromContentShared([emailContent!].asHtmlString));
        }
      });
  }

  void _registerPendingFileInfo() {
    _fileReceiveManagerStreamSubscription =
      _emailReceiveManager.pendingFileInfo.stream.listen((listFile) {
        if (listFile.isNotEmpty) {
          _emailReceiveManager.clearPendingFileInfo();
          goToComposer(ComposerArguments.fromFileShared(listFile));
        }
      });
  }

  void _registerStreamListener() {
    progressState.listen((state) {
      viewStateMarkAsReadMailbox.value = state;
    });

    _refreshActionEventController.stream
      .debounceTime(const Duration(milliseconds: FcmUtils.durationMessageComing))
      .listen(_handleRefreshActionWhenBackToApp);

    _registerLocalNotificationStreamListener();
  }

  void _registerLocalNotificationStreamListener() {
    _notificationManager.localNotificationStream.listen(_handleClickLocalNotificationOnForeground);
  }

  void _handleClickLocalNotificationOnTerminated() async {
    _notificationManager.activatedNotificationClickedOnTerminate = true;
    final notificationResponse = await _notificationManager.getCurrentNotificationResponse();
    log('MailboxDashBoardController::_handleClickLocalNotificationOnTerminated():payload: ${notificationResponse?.payload}');
    _handleMessageFromNotification(notificationResponse?.payload, onForeground: false);
  }

  void _handleArguments() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_handleArguments(): arguments = $arguments');
    if (arguments is Session) {
      _handleSession(arguments);
    } else if (arguments is MailtoArguments) {
      _handleMailtoURL(arguments);
    } else if (arguments is PreviewEmailArguments) {
      _handleOpenEmailAction(arguments);
    } else if (arguments is SwitchActiveAccountArguments) {
      _handleSwitchActiveAccountAction(arguments);
    }  else if (arguments is SelectActiveAccountArguments) {
      _handleSelectActiveAccountAction(arguments);
    } else if (arguments is RestoreActiveAccountArguments) {
      _handleRestorePreviousActiveAccountAction(arguments);
    } else {
      dispatchRoute(DashboardRoutes.thread);
      reload();
    }
  }

  @override
  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      super.injectVacationBindings(session, accountId);
      _getAllVacationInteractor = Get.find<GetAllVacationInteractor>();
      _updateVacationInteractor = Get.find<UpdateVacationInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::injectVacationBindings(): $e');
    }
  }

  @override
  Future<void> injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      await super.injectFCMBindings(session, accountId);
      await LocalNotificationManager.instance.recreateStreamController();
      _registerLocalNotificationStreamListener();
    } catch (e) {
      logError('MailboxDashBoardController::injectFCMBindings(): $e');
    }
  }

  void _handleSession(Session session) {
    log('MailboxDashBoardController::_handleSession:');
    _setUpComponentsFromSession(session, saveSession: true);

    if (PlatformInfo.isMobile && !_notificationManager.isNotificationClickedOnTerminate) {
      _handleClickLocalNotificationOnTerminated();
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _setUpComponentsFromSession(Session session, {bool saveSession = false}) {
    sessionCurrent = session;
    accountId.value = sessionCurrent!.personalAccount.accountId;
    userProfile.value = UserProfile(sessionCurrent!.username.value);

    injectAutoCompleteBindings(sessionCurrent, accountId.value);
    injectRuleFilterBindings(sessionCurrent, accountId.value);
    injectVacationBindings(sessionCurrent, accountId.value);
    injectFCMBindings(sessionCurrent, accountId.value);

    _getVacationResponse();
    spamReportController.getSpamReportStateAction();

    if (PlatformInfo.isMobile) {
      getAllSendingEmails();

      if (saveSession) {
        _storeSessionAction(
          sessionCurrent!,
          accountId.value!,
          sessionCurrent!.username
        );
      }
    }
  }

  void _handleMailtoURL(MailtoArguments arguments) {
    log('MailboxDashBoardController::_handleMailtoURL:');
    routerParameters.value = arguments.toMapRouter();
    _handleSession(arguments.session);
  }

  void _handleOpenEmailAction(PreviewEmailArguments arguments) {
    log('MailboxDashBoardController::_handleOpenEmailAction:arguments: $arguments');
    dispatchRoute(DashboardRoutes.waiting);
    _handleSession(arguments.session);
    _handleNotificationMessageFromEmailId(arguments.emailId);
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('MailboxDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
    }
  }

  MailboxId? getMailboxIdByRole(Role role) {
    return mapDefaultMailboxIdByRole[role];
  }

  void setMapDefaultMailboxIdByRole(Map<Role, MailboxId> newMapMailboxId) {
    mapDefaultMailboxIdByRole = newMapMailboxId;
  }

  void setMapMailboxById(Map<MailboxId, PresentationMailbox> newMapMailboxById) {
    mapMailboxById = newMapMailboxById;
  }

  void setOutboxMailbox(PresentationMailbox? newOutbox) {
    outboxMailbox = newOutbox;
    log('MailboxDashBoardController::setOutboxMailbox(): $newOutbox');
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    final previousMailbox = selectedMailbox.value;
    if (previousMailbox == newPresentationMailbox) {
      selectedMailbox.value = newPresentationMailbox;
      selectedMailbox.refresh();
    } else {
      selectedMailbox.value = newPresentationMailbox;
    }
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    log('MailboxDashBoardController::setSelectedEmail(): $newPresentationEmail');
    selectedEmail.value = newPresentationEmail;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  void openEmailDetailedView(PresentationEmail presentationEmail) {
    setSelectedEmail(presentationEmail);
    dispatchRoute(DashboardRoutes.emailDetailed);
    if (PlatformInfo.isWeb && presentationEmail.routeWeb != null) {
      RouteUtils.replaceBrowserHistory(
        title: 'Email-${presentationEmail.id?.id.value ?? ''}',
        url: presentationEmail.routeWeb!
      );
    }
  }

  void openMailboxMenuDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeMailboxMenuDrawer() {
    if (isDrawerOpen) {
      scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void hideMailboxMenuWhenScreenSizeChange(BuildContext context) {
    if (isDrawerOpen && responsiveUtils.isWebDesktop(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        closeMailboxMenuDrawer();
      });
    }
  }

  bool get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen == true;

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void searchEmail(BuildContext context, {String? queryString}) {
    log('MailboxDashBoardController::searchEmail():');
    clearFilterMessageOption();
    searchController.clearFilterSuggestion();
    if (queryString?.isNotEmpty == true) {
      searchController.updateFilterEmail(text: SearchQuery(queryString!));
    }
    searchController.updateFilterEmail(sortOrderOption: searchController.sortOrderFiltered.value.getSortOrder());
    dispatchAction(StartSearchEmailAction());
    KeyboardUtils.hideKeyboard(context);
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
  }

  bool _searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return PlatformInfo.isWeb
        && responsiveUtils.isDesktop(context)
        && dashboardRoute.value == DashboardRoutes.emailDetailed;
  }

  void clearSearchEmail() {
    dispatchAction(ClearSearchEmailAction());
    searchController.disableSimpleSearch();
  }

  void _unSelectedMailbox() {
    selectedMailbox.value = null;
  }

  void _closeEmailDetailedView() {
    log('MailboxDashBoardController::_closeEmailDetailedView(): ');
    dispatchRoute(DashboardRoutes.thread);
    clearSelectedEmail();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).drafts_saved,
        actionName: AppLocalizations.of(currentContext!).discard,
        onActionClick: () => _discardEmail(success.emailAsDrafts),
        leadingSVGIcon: imagePaths.icMailboxDrafts,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(session, accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
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
            success.emailActionType
          ));
        },
        leadingSVGIcon: imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null) {
      consumeState(_moveToMailboxInteractor.execute(session, currentAccountId, newMoveRequest));
    }
  }

  void _discardEmail(Email email) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null && email.id != null) {
      consumeState(_removeEmailDraftsInteractor.execute(session, currentAccountId, email.id!));
    }
  }

  void deleteEmailPermanently(PresentationEmail email) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null && email.id != null) {
      consumeState(_deleteEmailPermanentlyInteractor.execute(session, currentAccountId, email.id!));
    }
  }

  void _deleteEmailPermanentlySuccess(DeleteEmailPermanentlySuccess success) {
    if (currentOverlayContext != null &&  currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_delete_a_email_permanently_success,
        leadingSVGIcon: imagePaths.icDeleteToast
      );
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions, MarkReadAction markReadAction) async {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        presentationEmail.toEmail(),
        readActions,
        markReadAction));
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsStarEmailInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        presentationEmail.toEmail(),
        action));
    }
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, ReadActions readActions) {
    final listEmail = listPresentationEmail
        .map((presentationEmail) => presentationEmail.toEmail())
        .toList();
    log('MailboxDashBoardController::markAsReadSelectedMultipleEmail(): listEmail: ${listEmail.length}');
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsMultipleEmailReadInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmail,
        readActions));
    }
  }

  void _markAsReadSelectedMultipleEmailSuccess(Success success) {
    ReadActions? readActions;

    if (success is MarkAsMultipleEmailReadAllSuccess) {
      readActions = success.readActions;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      readActions = success.readActions;
    }

    if (readActions != null && currentContext != null && currentOverlayContext != null) {
      final message = readActions == ReadActions.markAsUnread
        ? AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).unread)
        : AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).read);

      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: readActions == ReadActions.markAsUnread
          ? imagePaths.icUnreadToast
          : imagePaths.icReadToast
      );
    }
  }

  void _markAsReadEmailSuccess(Success success) {
    ReadActions? readActions;
    MarkReadAction? markReadAction;
    PresentationEmail? presentationEmail;

    if (success is MarkAsEmailReadSuccess) {
      readActions = success.readActions;
      markReadAction = success.markReadAction;
      presentationEmail = success.updatedEmail.toPresentationEmail();
    }

    if (readActions != null && currentContext != null && currentOverlayContext != null && markReadAction == MarkReadAction.swipeOnThread) {
      final message = readActions == ReadActions.markAsUnread
        ? AppLocalizations.of(currentContext!).markedSingleMessageToast(AppLocalizations.of(currentContext!).unread.toLowerCase())
        : AppLocalizations.of(currentContext!).markedSingleMessageToast(AppLocalizations.of(currentContext!).read.toLowerCase());

      final undoAction = readActions == ReadActions.markAsUnread ? ReadActions.markAsRead : ReadActions.markAsUnread;

      appToast.showToastMessage(
        currentOverlayContext!,
        message,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          markAsEmailRead(presentationEmail!, undoAction, MarkReadAction.undo);
        },
        leadingSVGIcon: imagePaths.icToastSuccessMessage,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    final listEmail = listPresentationEmail
        .map((presentationEmail) => presentationEmail.toEmail())
        .toList();
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsStarMultipleEmailInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmail,
        markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(Success success) {
    MarkStarAction? markStarAction;
    int countMarkStarSuccess = 0;

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    }

    if (markStarAction != null) {
      final message = markStarAction == MarkStarAction.unMarkStar
        ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
        : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess);

      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          message,
          leadingSVGIcon: markStarAction == MarkStarAction.unMarkStar
            ? imagePaths.icUnStar
            : imagePaths.icStar);
      }
    }
  }

  void moveSelectedMultipleEmailToMailbox(
      BuildContext context,
      List<PresentationEmail> listEmails,
      PresentationMailbox currentMailbox
  ) async {
    if (accountId.value != null) {
      final arguments = DestinationPickerArguments(
        accountId.value!,
        MailboxActions.moveEmail,
        sessionCurrent,
        mailboxIdSelected: currentMailbox.mailboxId);

      final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
        : await push(AppRoutes.destinationPicker, arguments: arguments);

      if (destinationMailbox != null &&
          destinationMailbox is PresentationMailbox &&
          sessionCurrent != null &&
          accountId.value != null
      ) {
        _dispatchMoveToMultipleAction(
          accountId.value!,
          sessionCurrent!,
          listEmails.listEmailIds,
          currentMailbox,
          destinationMailbox
        );
      }
    }
  }

  void _dispatchMoveToMultipleAction(
      AccountId accountId,
      Session session,
      List<EmailId> listEmailIds,
      PresentationMailbox currentMailbox,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      _moveSelectedEmailMultipleToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveSelectedEmailMultipleToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToSpam));
    } else {
      _moveSelectedEmailMultipleToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void dragSelectedMultipleEmailToMailboxAction(
    List<PresentationEmail> listEmails,
    PresentationMailbox destinationMailbox,
  ) {
    if (searchController.isSearchEmailRunning){
      final Map<MailboxId,List<EmailId>> mapListEmailSelectedByMailBoxId = {};
      for (var element in listEmails) {
        final mailbox = element.findMailboxContain(mapMailboxById);
        if (mailbox != null && element.id != null) {
          if (mapListEmailSelectedByMailBoxId.containsKey(mailbox.id)) {
            mapListEmailSelectedByMailBoxId[mailbox.id]?.add(element.id!);
          } else {
            mapListEmailSelectedByMailBoxId.addAll({mailbox.id: [element.id!]});
          }
        }
      }
      _handleDragSelectedMultipleEmailToMailboxAction(mapListEmailSelectedByMailBoxId, destinationMailbox);
    } else {
      if (selectedMailbox.value != null) {
        _handleDragSelectedMultipleEmailToMailboxAction({selectedMailbox.value!.id: listEmails.listEmailIds}, destinationMailbox);
      }
    }

  }

  void _handleDragSelectedMultipleEmailToMailboxAction(
    Map<MailboxId, List<EmailId>> mapListEmails,
    PresentationMailbox destinationMailbox,
  ) async {
    if (accountId.value != null && sessionCurrent != null) {
      if (destinationMailbox.isTrash) {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToTrash,
          ),
        );
      } else if (destinationMailbox.isSpam) {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToSpam,
          ),
        );
      } else {
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            EmailActionType.moveToMailbox,
            destinationPath: destinationMailbox.mailboxPath,
          ),
        );
      }
    }
    dispatchAction(CancelSelectionAllEmailAction());
  }

  void _moveSelectedEmailMultipleToMailboxAction(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(session, accountId, moveRequest));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;
    EmailActionType? emailActionType;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
    }

    if (currentContext != null &&
        currentOverlayContext != null &&
        emailActionType != null &&
        moveAction == MoveAction.moving) {
      appToast.showToastMessage(
        currentOverlayContext!,
        emailActionType.getToastMessageMoveToMailboxSuccess(
          currentContext!,
          destinationPath: destinationPath),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          final newCurrentMailboxId = destinationMailboxId;
          final newDestinationMailboxId = currentMailboxId;
          if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
            _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest(
              {newCurrentMailboxId: movedEmailIds},
              newDestinationMailboxId,
              MoveAction.undo,
              emailActionType!,
              destinationPath: destinationPath
            ));
          }
        },
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  void _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        newMoveRequest));
    }
  }

  void moveSelectedMultipleEmailToTrash(List<PresentationEmail> listEmails, PresentationMailbox mailboxCurrent) {
    final trashMailboxId = getMailboxIdByRole(PresentationMailbox.roleTrash);
    if (accountId.value != null && trashMailboxId != null && sessionCurrent != null) {
      _moveSelectedEmailMultipleToMailboxAction(
        sessionCurrent!,
        accountId.value!,
        MoveToMailboxRequest(
          {mailboxCurrent.id: listEmails.listEmailIds},
          trashMailboxId,
          MoveAction.moving,
          EmailActionType.moveToTrash)
      );
    }
  }

  void moveSelectedMultipleEmailToSpam(List<PresentationEmail> listEmail, PresentationMailbox mailboxCurrent) {
    final spamMailboxId = getMailboxIdByRole(PresentationMailbox.roleSpam);
    if (accountId.value != null && spamMailboxId != null && sessionCurrent != null) {
      _moveSelectedEmailMultipleToMailboxAction(
        sessionCurrent!,
        accountId.value!,
        MoveToMailboxRequest(
          {mailboxCurrent.id: listEmail.listEmailIds},
          spamMailboxId,
          MoveAction.moving,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpamSelectedMultipleEmail(List<PresentationEmail> listEmail) {
    final spamMailboxId = getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    if (inboxMailboxId != null && accountId.value != null && spamMailboxId != null && sessionCurrent != null) {
      _moveSelectedEmailMultipleToMailboxAction(
        sessionCurrent!,
        accountId.value!,
        MoveToMailboxRequest(
          {spamMailboxId: listEmail.listEmailIds},
          inboxMailboxId,
          MoveAction.moving,
          EmailActionType.unSpam)
      );
    }
  }

  void deleteSelectionEmailsPermanently(
      BuildContext context,
      DeleteActionType actionType,
      {
        List<PresentationEmail>? listEmails,
        PresentationMailbox? mailboxCurrent,
        Function? onCancelSelectionEmail,
      }
  ) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(actionType.getContentDialog(
            context,
            count: listEmails?.length,
            mailboxName: mailboxCurrent?.getDisplayName(context)))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            actionType.getConfirmActionName(context),
            () => _deleteSelectionEmailsPermanentlyAction(
                actionType,
                listEmails: listEmails,
                onCancelSelectionEmail: onCancelSelectionEmail)))
      .show();
    } else {
      Get.dialog(
        PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_delete_emails_permanently'))
          ..title(actionType.getTitleDialog(context))
          ..content(actionType.getContentDialog(
              context,
              count: listEmails?.length,
              mailboxName: mailboxCurrent?.getDisplayName(context)))
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog))
          ..onCloseButtonAction(() => popBack())
          ..onConfirmButtonAction(
              actionType.getConfirmActionName(context),
              () => _deleteSelectionEmailsPermanentlyAction(
                  actionType,
                  listEmails: listEmails,
                  onCancelSelectionEmail: onCancelSelectionEmail))
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
        .build()
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _deleteSelectionEmailsPermanentlyAction(
    DeleteActionType actionType, {
    List<PresentationEmail>? listEmails,
    Function? onCancelSelectionEmail,
  }) {
    popBack();

    switch(actionType) {
      case DeleteActionType.all:
        emptyTrashFolderAction(onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.multiple:
        _deleteMultipleEmailsPermanently(listEmails ?? [], onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.single:
        break;
    }
  }

  void emptyTrashFolderAction({Function? onCancelSelectionEmail, MailboxId? trashFolderId}) {
    onCancelSelectionEmail?.call();

    final trashMailboxId = trashFolderId ?? mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];
    if (sessionCurrent != null && accountId.value != null && trashMailboxId != null) {
      consumeState(_emptyTrashFolderInteractor.execute(sessionCurrent!, accountId.value!, trashMailboxId));
    }
  }

  void _emptyTrashFolderSuccess(EmptyTrashFolderSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success);
    }
  }

  void _deleteMultipleEmailsPermanently(List<PresentationEmail> listEmails, {Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_deleteMultipleEmailsPermanentlyInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        listEmails.listEmailIds));
    }
  }

  void _deleteMultipleEmailsPermanentlySuccess(Success success) {
    List<EmailId> listEmailIdResult = <EmailId>[];
    if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
      listEmailIdResult = success.emailIds;
    } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      listEmailIdResult = success.emailIds;
    }

    if (currentOverlayContext != null && currentContext != null && listEmailIdResult.isNotEmpty) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length));
    }
  }

  void dispatchAction(UIAction action) {
    log('MailboxDashBoardController::dispatchAction(): ${action.runtimeType}');
    dashBoardAction.value = action;
  }

  void dispatchMailboxUIAction(MailboxUIAction newAction) {
    log('MailboxDashBoardController::dispatchMailboxUIAction():newAction: ${newAction.runtimeType}');
    mailboxUIAction.value = newAction;
  }

  void dispatchEmailUIAction(EmailUIAction newAction) {
    log('MailboxDashBoardController::dispatchEmailUIAction():newAction: ${newAction.runtimeType}');
    emailUIAction.value = newAction;
  }

  void openComposerOverlay(ComposerArguments? arguments) {
    composerArguments = arguments;
    ComposerBindings().dependencies();
    composerOverlayState.value = ComposerOverlayState.active;
  }

  void closeComposerOverlay({dynamic result}) {
    composerArguments = null;
    ComposerBindings().dispose();
    composerOverlayState.value = ComposerOverlayState.inActive;

    if (result is SendingEmailArguments) {
      handleSendEmailAction(result);
    } else if (result is SaveToDraftArguments) {
      saveEmailToDraft(arguments: result);
    }
  }

  void dispatchRoute(DashboardRoutes route) {
    log('MailboxDashBoardController::dispatchRoute(): $route');
    dashboardRoute.value = route;

    if (dashboardRoute.value == DashboardRoutes.searchEmail) {
      searchController.activateSimpleSearch();
    }
  }

  @override
  void handleReloaded(Session session) {
    log('MailboxDashBoardController::handleReloaded():');
    _getRouteParameters();
    _setUpComponentsFromSession(session, saveSession: true);
    if (PlatformInfo.isWeb) {
      _handleComposerCache();
    }
  }

  void _getRouteParameters() {
    final parameters = Get.parameters;
    log('MailboxDashBoardController::_getRouteParameters(): parameters: $parameters');
    routerParameters.value = parameters;
  }

  UnsignedInt? get maxSizeAttachmentsPerEmail {
    try {
      if (sessionCurrent != null && accountId.value != null) {
        final mailCapability = sessionCurrent!.getCapabilityProperties<MailCapability>(accountId.value!, CapabilityIdentifier.jmapMail);
        final maxSizeAttachmentsPerEmail = mailCapability?.maxSizeAttachmentsPerEmail;
        log('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): $maxSizeAttachmentsPerEmail');
        return maxSizeAttachmentsPerEmail;
      }
      return null;
    } catch (e) {
      logError('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): [Exception] $e');
      return null;
    }
  }

  void clearFilterMessageOption() {
    filterMessageOption.value = FilterMessageOption.all;
  }

  void markAsReadMailboxAction(BuildContext context) {
    final session = sessionCurrent;
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final countEmailsUnread = selectedMailbox.value?.unreadEmails?.value.value ?? 0;
    if (session != null && currentAccountId != null && mailboxId != null) {
      markAsReadMailbox(
        session,
        currentAccountId,
        mailboxId,
        selectedMailbox.value?.getDisplayName(context) ?? '',
        countEmailsUnread.toInt()
      );
    }
  }

  void markAsReadMailbox(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmailsUnread
  ) {
    consumeState(_markAsMailboxReadInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxDisplayName,
      totalEmailsUnread,
      _progressStateController));
  }

  void _markAsReadMailboxSuccess(Success success) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);

    if (success is MarkAsMailboxReadAllSuccess) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadSuccess(success.mailboxDisplayName),
          leadingSVGIcon: imagePaths.icReadToast);
      }
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxDisplayName, success.countEmailsRead),
          leadingSVGIcon: imagePaths.icReadToast);
      }
    }
  }

  void _markAsReadMailboxFailure(MarkAsMailboxReadFailure failure) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageMarkAsReadFolderFailureWithReason(
          failure.mailboxDisplayName,
          failure.exception.toString()
        )
      );
    }
  }

  void _markAsReadMailboxAllFailure(MarkAsMailboxReadAllFailure failure) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageMarkAsReadFolderAllFailure(failure.mailboxDisplayName)
      );
    }
  }

  void goToComposer(ComposerArguments arguments) async {
    if (PlatformInfo.isWeb) {
      if (composerOverlayState.value == ComposerOverlayState.inActive) {
        openComposerOverlay(arguments);
      }
    } else {
      final result = await push(AppRoutes.composer, arguments: arguments);
      if (result is SendingEmailArguments) {
        handleSendEmailAction(result);
      } else if (result is SaveToDraftArguments) {
        saveEmailToDraft(arguments: result);
      }
    }
  }

  void clearDashBoardAction() {
    dashBoardAction.value = DashBoardAction.idle;
  }

  void clearMailboxUIAction() {
    mailboxUIAction.value = MailboxUIAction.idle;
  }

  void clearEmailUIAction() {
    emailUIAction.value = EmailUIAction.idle;
  }

  void goToSettings() async {
    closeMailboxMenuDrawer();
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    final result = await push(
      AppRoutes.settings,
      arguments: ManageAccountArguments(
        sessionCurrent,
        previousUri: RouteUtils.baseUri,
      ),
    );

    BackButtonInterceptor.add(_onBackButtonInterceptor, name: AppRoutes.dashboard);

    if (result is Tuple2) {
      if (result.value1 is VacationResponse) {
        vacationResponse.value = result.value1;
        dispatchMailboxUIAction(RefreshChangeMailboxAction(null));
      }
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => _replaceBrowserHistory(uri: result.value2)
      );
    }
  }

  void selectQuickSearchFilter(QuickSearchFilter filter) {
    return searchController.selectQuickSearchFilter(filter, userProfile.value!);
  }

  void selectQuickSearchFilterFrom(EmailAddress fromEmailFilter) {
    return searchController.selectQuickSearchFilter(
      QuickSearchFilter.fromMe,
      userProfile.value!,
      fromEmailFilter: fromEmailFilter
    );
  }

  void addFilterToSuggestionForm(QuickSearchFilter filter) {
    searchController.addFilterToSuggestionForm(filter);
  }

  Future<List<PresentationEmail>> quickSearchEmails(String query) async {
    if (sessionCurrent != null && accountId.value != null && userProfile.value != null) {
      return searchController.quickSearchEmails(
        session: sessionCurrent!,
        accountId: accountId.value!,
        userProfile: userProfile.value!,
        query: query
      );
    } else {
      return [];
    }
  }

  void addDownloadTask(DownloadTaskState task) {
    downloadController.addDownloadTask(task);
  }

  void updateDownloadTask(
      DownloadTaskId taskId,
      UpdateDownloadTaskStateCallback updateDownloadTaskCallback
  ) {
    downloadController.updateDownloadTaskByTaskId(
        taskId,
        updateDownloadTaskCallback);
  }

  void deleteDownloadTask(DownloadTaskId taskId) {
    downloadController.deleteDownloadTask(taskId);
  }

  void disableVacationResponder() {
    if (accountId.value != null && _updateVacationInteractor != null) {
      final vacationDisabled = vacationResponse.value != null
          ? vacationResponse.value!.copyWith(isEnabled: false)
          : VacationResponse(isEnabled: false);
      consumeState(_updateVacationInteractor!.execute(accountId.value!, vacationDisabled));
    }
  }

  void goToVacationSetting() async {
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    final result = await push(
      AppRoutes.settings,
      arguments: ManageAccountArguments(
        sessionCurrent,
        menuSettingCurrent: AccountMenuItem.vacation,
        previousUri: RouteUtils.baseUri
      )
    );

    BackButtonInterceptor.add(_onBackButtonInterceptor, name: AppRoutes.dashboard);

    if (result is Tuple2) {
      if (result.value1 is VacationResponse) {
        vacationResponse.value = result.value1;
        dispatchMailboxUIAction(RefreshChangeMailboxAction(null));
      }
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => _replaceBrowserHistory(uri: result.value2)
      );
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (currentContext != null && currentOverlayContext != null) {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('MailboxDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  void selectQuickSearchFilterAction(QuickSearchFilter filter) async {
    log('MailboxDashBoardController::selectQuickSearchFilterAction(): filter: $filter');
    if (filter == QuickSearchFilter.fromMe) {
      if (accountId.value == null || sessionCurrent == null) {
        logError('MailboxDashBoardController::selectQuickSearchFilterAction(): accountId or sessionCurrent is null');
      }
      final listContactSelected = searchController.searchEmailFilter.value.from;
      final arguments = ContactArguments(accountId.value!, sessionCurrent!, listContactSelected);

      final newContact = await DialogRouter.pushGeneralDialog(routeName: AppRoutes.contact, arguments: arguments);

      if (newContact is EmailAddress) {
        selectQuickSearchFilterFrom(newContact);
        dispatchAction(StartSearchEmailAction(filter: filter));
      }
    } else {
      selectQuickSearchFilter(filter);
      dispatchAction(StartSearchEmailAction(filter: filter));
    }
  }

  void selectReceiveTimeQuickSearchFilter(BuildContext context, EmailReceiveTimeType receiveTime) {
    log('MailboxDashBoardController::selectReceiveTimeQuickSearchFilter():receiveTime: $receiveTime');
    popBack();

    if (receiveTime == EmailReceiveTimeType.customRange) {
      searchController.showMultipleViewDateRangePicker(
        context,
        searchController.startDateFiltered,
        searchController.endDateFiltered,
        onCallbackAction: (startDate, endDate) {
          dispatchAction(SelectDateRangeToAdvancedSearch(startDate, endDate));
          searchController.updateFilterEmail(
            emailReceiveTimeType: receiveTime,
            startDateOption: optionOf(startDate?.toUTCDate()),
            endDateOption: optionOf(startDate?.toUTCDate()),
            beforeOption: const None()
          );
          dispatchAction(StartSearchEmailAction());
        }
      );
    } else {
      dispatchAction(ClearDateRangeToAdvancedSearch(receiveTime));
      searchController.updateFilterEmail(
        emailReceiveTimeType: receiveTime,
        startDateOption: const None(),
        endDateOption: const None(),
        beforeOption: const None()
      );
      dispatchAction(StartSearchEmailAction());
    }
  }

  void selectSortOrderQuickSearchFilter(BuildContext context, EmailSortOrderType sortOrder) {
    log('MailboxDashBoardController::selectSortOrderQuickSearchFilter():sortOrder: $sortOrder');
    popBack();
    searchController.sortOrderFiltered.value = sortOrder;
    searchController.updateFilterEmail(sortOrderOption: sortOrder.getSortOrder());
    dispatchAction(StartSearchEmailAction());
  }

  bool isEmptyTrashBannerEnabledOnWeb(BuildContext context) {
    return selectedMailbox.value != null &&
      selectedMailbox.value!.isTrash &&
      selectedMailbox.value!.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      responsiveUtils.isWebDesktop(context);
  }

  bool isEmptyTrashBannerEnabledOnMobile(BuildContext context) {
    return selectedMailbox.value != null &&
      selectedMailbox.value!.isTrash &&
      selectedMailbox.value!.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      !responsiveUtils.isWebDesktop(context);
  }

  void emptyTrashAction(BuildContext context) {
    dispatchAction(EmptyTrashAction(context));
  }

  void showAppDashboardAction() async {
    log('MailboxDashBoardController::showAppDashboardAction(): begin');
    final apps = appGridDashboardController.linagoraApplications.value;
    if (apps != null) {
      consumeState(Stream.value(Right(GetAppDashboardConfigurationSuccess(apps))));
      return;
    }
    consumeState(appGridDashboardController.showDashboardAction());
  }

  bool isAbleMarkAllAsRead(){
    return !searchController.isSearchEmailRunning && selectedMailbox.value != null && selectedMailbox.value!.isDrafts;
  }

  void refreshActionWhenBackToApp() {
    log('MailboxDashBoardController::refreshActionWhenBackToApp():');
    _refreshActionEventController.add(RefreshActionViewEvent());
  }

  void _handleRefreshActionWhenBackToApp(RefreshActionViewEvent viewEvent) {
    log('MailboxDashBoardController::_handleRefreshActionWhenBackToApp():');
    try {
      _getEmailStateToRefreshInteractor = getBinding<GetEmailStateToRefreshInteractor>();
      _getMailboxStateToRefreshInteractor = getBinding<GetMailboxStateToRefreshInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::_handleRefreshActionWhenBackToApp(): $e');
    }
    if (_getEmailStateToRefreshInteractor != null && accountId.value != null && sessionCurrent != null) {
      consumeState(_getEmailStateToRefreshInteractor!.execute(accountId.value!, sessionCurrent!.username));
    }
    if (_getMailboxStateToRefreshInteractor != null && accountId.value != null && sessionCurrent != null) {
      consumeState(_getMailboxStateToRefreshInteractor!.execute(accountId.value!, sessionCurrent!.username));
    }
  }

  void _deleteEmailStateToRefreshAction() {
    log('MailboxDashBoardController::_deleteEmailStateToRefreshAction():');
    try {
      _deleteEmailStateToRefreshInteractor = getBinding<DeleteEmailStateToRefreshInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::_deleteEmailStateToRefreshAction(): $e');
    }
    if (_deleteEmailStateToRefreshInteractor != null && accountId.value != null && sessionCurrent != null) {
      consumeState(_deleteEmailStateToRefreshInteractor!.execute(accountId.value!, sessionCurrent!.username));
    }
  }

  void _deleteMailboxStateToRefreshAction() {
    log('MailboxDashBoardController::_deleteMailboxStateToRefreshAction():');
    try {
      _deleteMailboxStateToRefreshInteractor = getBinding<DeleteMailboxStateToRefreshInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::_deleteMailboxStateToRefreshAction(): $e');
    }
    if (_deleteMailboxStateToRefreshInteractor != null && accountId.value != null && sessionCurrent != null) {
      consumeState(_deleteMailboxStateToRefreshInteractor!.execute(accountId.value!, sessionCurrent!.username));
    }
  }

  void _handleClickLocalNotificationOnForeground(NotificationResponse? response) {
    _notificationManager.activatedNotificationClickedOnTerminate = true;
    log('MailboxDashBoardController::_handleClickLocalNotificationOnForeground():payload: ${response?.payload}');
    _handleMessageFromNotification(response?.payload);
  }

  void _handleMessageFromNotification(String? payload, {bool onForeground = true}) async {
    log('MailboxDashBoardController::_handleMessageFromNotification():payload: $payload');
    if (payload == null || payload.isEmpty) {
      dispatchRoute(DashboardRoutes.thread);
      return;
    }

    final payloadDecoded = jsonDecode(payload);
    if (payloadDecoded is Map<String, dynamic>) {
      final notificationPayload = NotificationPayload.fromJson(payloadDecoded);
      log('MailboxDashBoardController::_handleMessageFromNotification():notificationPayload: $notificationPayload');

      if (notificationPayload.emailId != null) {
        _handleNotificationMessageFromEmailId(notificationPayload.emailId!, onForeground: onForeground);
      } else if (notificationPayload.newState != null) {
        _handleNotificationMessageFromNewState(notificationPayload.newState!, onForeground: onForeground);
      } else {
        dispatchRoute(DashboardRoutes.thread);
      }
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _handleNotificationMessageFromNewState(jmap.State newState, {bool onForeground = true}) {
    if (onForeground) {
      _openInboxMailboxFromNotification();
    }
  }

  void _handleNotificationMessageFromEmailId(EmailId emailId, {bool onForeground = true}) {
    final currentAccountId = accountId.value;
    final session = sessionCurrent;
    if (currentAccountId != null && session != null) {
      if (onForeground) {
        _showWaitingView();
      }
      _getPresentationEmailFromEmailIdAction(emailId, currentAccountId, session);
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _showWaitingView() {
    popAllRouteIfHave();
    dispatchRoute(DashboardRoutes.waiting);
  }

  void _openInboxMailboxFromNotification() {
    popAllRouteIfHave();
    dispatchMailboxUIAction(SelectMailboxDefaultAction());
    dispatchRoute(DashboardRoutes.thread);
  }

  void _getPresentationEmailFromEmailIdAction(EmailId emailId, AccountId accountId, Session session) {
    log('MailboxDashBoardController:_getPresentationEmailFromEmailIdAction:emailId: $emailId');
    consumeState(_getEmailByIdInteractor.execute(
      session,
      accountId,
      emailId,
      properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId)
    ));
  }

  void _moveToEmailDetailedView(GetEmailByIdSuccess success) {
    log('MailboxDashBoardController::_moveToEmailDetailedView(): ${success.email}');
    setSelectedEmail(success.email);
    dispatchRoute(DashboardRoutes.emailDetailed);
  }

  void _handleGetEmailDetailedFailed(GetEmailByIdFailure failure) {
    logError('MailboxDashBoardController::_handleGetEmailDetailedFailed(): $failure');
    dispatchRoute(DashboardRoutes.thread);
  }

  void popAllRouteIfHave() {
    Get.until((route) => Get.currentRoute == AppRoutes.dashboard);
  }

  void handleOnForegroundGained() {
    log('MailboxDashBoardController::handleOnForegroundGained():');
    if (PlatformInfo.isMobile) {
      _updateTheme();
    }
    refreshActionWhenBackToApp();
  }

  void _updateTheme() {
    ThemeUtils.setSystemDarkUIStyle();
    if (isDrawerOpen) {
      ThemeUtils.setStatusBarTransparentColor();
    }
  }

  void updateEmailList(List<PresentationEmail> newEmailList) {
    emailsInCurrentMailbox.value = newEmailList;
  }
  
  void openMailboxAction(PresentationMailbox presentationMailbox) {
    dispatchMailboxUIAction(OpenMailboxAction(presentationMailbox));
  }

  bool get enableSpamReport => spamReportController.enableSpamReport;

  void getSpamReportBanner() {
    if (spamReportController.enableSpamReport &&
        sessionCurrent != null &&
        accountId.value != null) {
      spamReportController.getSpamMailboxAction(sessionCurrent!, accountId.value!);
    }
  }

  void refreshSpamReportBanner() {
    if (spamReportController.enableSpamReport && sessionCurrent != null && accountId.value != null) {
      spamReportController.getSpamMailboxCached(accountId.value!, sessionCurrent!.username);
    }
  }

  void storeSpamReportStateAction() {
    final storeSpamReportState = enableSpamReport ? SpamReportState.disabled : SpamReportState.enabled;
    spamReportController.storeSpamReportStateAction(storeSpamReportState);
  }

  void onDragMailbox(bool isDragging) {
    _isDraggingMailbox.value = isDragging;
  }

  bool get isDraggingMailbox => _isDraggingMailbox.value;

  void _handleSendEmailFailure(SendEmailFailure failure) {
    logError('MailboxDashBoardController::_handleSendEmailFailure():failure: $failure');
    _updateSendingStateWhenSendEmailFailureOnIOS(failure);
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleSendEmailFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).sendMessageFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).sendMessageFailure);
    }

    clearState();
  }

  bool _handleSetErrors(List<SetError> listErrors, {bool isDrafts = false}) {
    for (var error in listErrors) {
      if (error.type == SetError.tooLarge || error.type == SetError.overQuota) {
        if (isDrafts) {
          _showToastSendMessageFailure(error.toastMessageForSaveEmailAsDraftFailure(currentContext!));
        } else {
          _showToastSendMessageFailure(error.toastMessageForSendEmailFailure(currentContext!));
        }
        return true;
      }
    }
    return false;
  }

  void _showToastSendMessageFailure(String message) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: imagePaths.icSendSuccessToast);
    }
  }

  void _handleSaveEmailAsDraftsFailure(SaveEmailAsDraftsFailure failure) {
    logError('MailboxDashBoardController::_handleSaveEmailAsDraftsFailure():failure: $failure');
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleSaveEmailAsDraftsFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
    }

    clearState();
  }

  void _handleUpdateEmailAsDraftsFailure(UpdateEmailDraftsFailure failure) {
    logError('MailboxDashBoardController::_handleUpdateEmailAsDraftsFailure():failure: $failure');
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleUpdateEmailAsDraftsFailure():exception: $exception');
    if (exception is SetMethodException) {
      final listErrors = exception.mapErrors.values.toList();
      final toastSuccess = _handleSetErrors(listErrors);
      if (!toastSuccess) {
        _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
      }
    } else {
      _showToastSendMessageFailure(AppLocalizations.of(currentContext!).saveEmailAsDraftFailure);
    }

    clearState();
  }

  void handleSendEmailAction(SendingEmailArguments arguments) {
    switch(arguments.actionMode) {
      case ComposeActionMode.pushQueue:
        _handleStoreSendingEmail(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          arguments.mailboxRequest
        );
        break;
      case ComposeActionMode.editQueue:
        _handleUpdateSendingEmail(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          arguments.mailboxRequest
        );
        break;
      case ComposeActionMode.sent:
        consumeState(_sendEmailInteractor.execute(
          arguments.session,
          arguments.accountId,
          arguments.emailRequest,
          mailboxRequest: arguments.mailboxRequest
        ));
        break;
    }
  }

  void _handleStoreSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
  ) {
    log('MailboxDashBoardController::_handleStoreSendingEmail:');
    final sendingEmail = emailRequest.toSendingEmail(uuid.v1(), mailboxRequest: mailboxRequest);
    consumeState(_storeSendingEmailInteractor.execute(
      accountId,
      session.username,
      sendingEmail
    ));
  }

  void _handleUpdateSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
  ) {
    log('MailboxDashBoardController::_handleUpdateSendingEmail:');
    final storedSendingId = emailRequest.storedSendingId;
    if (storedSendingId != null) {
      final sendingEmail = emailRequest.toSendingEmail(storedSendingId, mailboxRequest: mailboxRequest);
      consumeState(_updateSendingEmailInteractor.execute(
        accountId,
        session.username,
        sendingEmail
      ));
    } else {
      logError('MailboxDashBoardController::_handleUpdateSendingEmail(): StoredSendingId is null');
      _handleStoreSendingEmail(
        session,
        accountId,
        emailRequest,
        mailboxRequest
      );
    }
  }

  void _handleStoreSendingEmailSuccess(StoreSendingEmailSuccess success) {
    if (PlatformInfo.isAndroid) {
      addSendingEmailToSendingQueue(success.sendingEmail);
    }
    getAllSendingEmails();
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messageHasBeenSavedToTheSendingQueue,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icEmail);
    }
  }

  void _handleUpdateSendingEmailSuccess(UpdateSendingEmailSuccess success) async {
    if (PlatformInfo.isAndroid) {
      await WorkManagerController().cancelByUniqueId(success.newSendingEmail.sendingId);
      addSendingEmailToSendingQueue(success.newSendingEmail);
    }
    getAllSendingEmails();
  }

  void addSendingEmailToSendingQueue(SendingEmail sendingEmail) async {
    log('MailboxDashBoardController::addSendingEmailToSendingQueue():sendingEmail: $sendingEmail');
    final work = OneTimeWorkRequest(
      uniqueId: sendingEmail.sendingId,
      taskId: sendingEmail.sendingId,
      tag: WorkerType.sendingEmail.name,
      inputData: sendingEmail.toJson()
        ..addAll({
          WorkManagerConstants.workerTypeKey: WorkerType.sendingEmail.name
        }),
      initialDelay: const Duration(milliseconds: WorkManagerConstants.delayTime),
      backoffPolicy: work_manager.BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(milliseconds: WorkManagerConstants.delayTime),
      constraints: work_manager.Constraints(networkType: work_manager.NetworkType.connected)
    );

    await WorkManagerController().enqueue(work);
  }

  void getAllSendingEmails() {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_getAllSendingEmailInteractor.execute(
        accountId.value!,
        sessionCurrent!.username
      ));
    }
  }

  void _handleGetAllSendingEmailsSuccess(GetAllSendingEmailSuccess success) async {
    listSendingEmails.value = success.sendingEmails;

    if (listSendingEmails.isEmpty && dashboardRoute.value == DashboardRoutes.sendingQueue) {
      openDefaultMailbox();
    }
  }

  void openDefaultMailbox() {
    dispatchRoute(DashboardRoutes.thread);
    dispatchMailboxUIAction(SelectMailboxDefaultAction());
  }

  void _storeSessionAction(Session session, AccountId accountId, UserName userName) {
    consumeState(_storeSessionInteractor.execute(session, accountId, userName));
  }

  void emptySpamFolderAction({Function? onCancelSelectionEmail, MailboxId? spamFolderId}) {
    onCancelSelectionEmail?.call();

    final spamMailboxId = spamFolderId ?? mapDefaultMailboxIdByRole[PresentationMailbox.roleSpam];
    if (sessionCurrent != null && accountId.value != null && spamMailboxId != null) {
      consumeState(
        _emptySpamFolderInteractor.execute(
          sessionCurrent!,
          accountId.value!,
          spamMailboxId
        )
      );
    }
  }

  void _emptySpamFolderSuccess(EmptySpamFolderSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success);
    }
  }

  bool isEmptySpamBannerEnabledOnWeb(BuildContext context) {
    return selectedMailbox.value != null &&
      selectedMailbox.value!.isSpam &&
      selectedMailbox.value!.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      responsiveUtils.isWebDesktop(context);
  }

  bool isEmptySpamBannerEnabledOnMobile(BuildContext context) {
    return selectedMailbox.value != null &&
      selectedMailbox.value!.isSpam &&
      selectedMailbox.value!.countTotalEmails > 0 &&
      !searchController.isSearchActive() &&
      !responsiveUtils.isWebDesktop(context);
  }

  void openDialogEmptySpamFolder(BuildContext context) {
    final spamMailbox = selectedMailbox.value;
    if (spamMailbox == null || !spamMailbox.isSpam) {
      logError('MailboxDashBoardController::openDialogEmptySpamFolder: Selected mailbox is not spam');
      return;

    }
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).emptySpamMessageDialog)
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(AppLocalizations.of(context).delete_all, () {
          popBack();
          if (spamMailbox.countTotalEmails > 0) {
            emptySpamFolderAction(spamFolderId: spamMailbox.id);
          } else {
            appToast.showToastWarningMessage(
              context,
              AppLocalizations.of(context).noEmailInYourCurrentFolder
            );
          }
        }))
          .show();
    } else {
      Get.dialog(
        PointerInterceptor(child: (ConfirmDialogBuilder(imagePaths)
          ..key(const Key('confirm_dialog_empty_spam'))
          ..title(AppLocalizations.of(context).emptySpamFolder)
          ..content(AppLocalizations.of(context).emptySpamMessageDialog)
          ..addIcon(SvgPicture.asset(imagePaths.icRemoveDialog, fit: BoxFit.fill))
          ..colorConfirmButton(AppColor.colorConfirmActionDialog)
          ..styleTextConfirmButton(const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColor.colorActionDeleteConfirmDialog))
          ..onCloseButtonAction(popBack)
          ..onConfirmButtonAction(AppLocalizations.of(context).delete_all, () {
            popBack();
            if (spamMailbox.countTotalEmails > 0) {
              emptySpamFolderAction(spamFolderId: spamMailbox.id);
            } else {
              appToast.showToastWarningMessage(
                context,
                AppLocalizations.of(context).noEmailInYourCurrentFolder
              );
            }
          })
          ..onCancelButtonAction(AppLocalizations.of(context).cancel, popBack)
        ).build()),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void refreshMailboxAction() async {
    refreshingMailboxState.value = Right(RefreshAllEmailLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    dispatchAction(RefreshAllEmailAction());
  }

  void selectAllEmailAction() {
    dispatchAction(SelectionAllEmailAction());
  }

  String get baseDownloadUrl => sessionCurrent?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl) ?? '';

  void redirectToInboxAction() {
    log('MailboxDashBoardController::redirectToInboxAction:');
    if (dashboardRoute.value == DashboardRoutes.emailDetailed) {
      dispatchEmailUIAction(CloseEmailDetailedViewToRedirectToTheInboxAction());
    }

    final inboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    if (inboxId == null) return;

    final inboxPresentation = mapMailboxById[inboxId];
    if (inboxPresentation == null) return;

    openMailboxAction(inboxPresentation);
  }

  bool get isDraggableAppActive => draggableAppState.value == DraggableAppState.active;

  void enableDraggableApp() {
    draggableAppState.value = DraggableAppState.active;
  }

  void disableDraggableApp() {
    draggableAppState.value = DraggableAppState.inActive;
  }

  void saveEmailToDraft({required SaveToDraftArguments arguments}) {
    if (arguments.oldEmailId != null) {
      consumeState(
        _updateEmailDraftsInteractor.execute(
          arguments.session,
          arguments.accountId,
          arguments.newEmail,
          arguments.oldEmailId!
        )
      );
    } else {
      consumeState(
        _saveEmailAsDraftsInteractor.execute(
          arguments.session,
          arguments.accountId,
          arguments.newEmail,
        )
      );
    }
  }

  void _handleSendEmailSuccess(SendEmailSuccess success) {
    if (PlatformInfo.isIOS &&
        success.emailRequest.storedSendingId != null &&
        accountId.value != null &&
        sessionCurrent != null
    ) {
      consumeState(_deleteSendingEmailInteractor.execute(
        accountId.value!,
        sessionCurrent!.username,
        success.emailRequest.storedSendingId!
      ));
    }
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
        leadingSVGIcon: imagePaths.icSendSuccessToast
      );
    }

    if (success.emailRequest.emailActionType == EmailActionType.composeFromUnsubscribeMailtoLink &&
        success.emailRequest.previousEmailId != null) {
      unsubscribeMail(success.emailRequest.previousEmailId!);
    }
  }

  void _updateSendingStateWhenSendEmailFailureOnIOS(SendEmailFailure failure) {
    log('MailboxDashBoardController::_updateSendingStateWhenSendEmailFailureOnIOS:');
    if (PlatformInfo.isIOS &&
        failure.emailRequest.storedSendingId != null &&
        accountId.value != null &&
        sessionCurrent != null
    ) {
      final sendingEmailError = failure.emailRequest.toSendingEmail(
        failure.emailRequest.storedSendingId!,
        mailboxRequest: failure.mailboxRequest,
        newState: SendingState.error
      );
      consumeState(
        _updateSendingEmailInteractor.execute(
          accountId.value!,
          sessionCurrent!.username,
          sendingEmailError
        )
      );
    }
  }

  Future<List<EmailAddress>> getContactSuggestion(String query) async {
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();

    if (_getAutoCompleteInteractor == null || accountId.value == null) {
      return <EmailAddress>[];
    }

    final listEmailAddress = await _getAutoCompleteInteractor!
      .execute(AutoCompletePattern(word: query, accountId: accountId.value!, limit: 2))
      .then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]
      ));
    log('MailboxDashBoardController::getAutoCompleteSuggestion:listEmailAddress: $listEmailAddress');
    return listEmailAddress;
  }

  void searchEmailByFromFields(BuildContext context, EmailAddress emailAddress) {
    KeyboardUtils.hideKeyboard(context);
    clearFilterMessageOption();
    searchController.clearFilterSuggestion();
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
    dispatchAction(SearchEmailByFromFieldsAction(emailAddress));
  }

  void unsubscribeMail(EmailId emailId) {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(
        _unsubscribeEmailInteractor.execute(
          sessionCurrent!,
          accountId.value!,
          emailId
        )
      );
    }
  }

  void _handleUnsubscribeMailSuccess(Email email) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).unsubscribedFromThisMailingList);
    }
    setSelectedEmail(email.toPresentationEmail());
  }

  void _replaceBrowserHistory({Uri? uri}) {
    log('MailboxDashBoardController::_replaceBrowserHistory:uri: $uri');
    if (PlatformInfo.isWeb) {
      final selectedMailboxId = selectedMailbox.value?.id;
      final selectedEmailId = selectedEmail.value?.id;
      final isSearchRunning = searchController.isSearchEmailRunning;
      String title = '';
      if (selectedEmail.value != null) {
        title = 'Email-${selectedEmailId?.asString ?? ''}';
      } else if (isSearchRunning) {
        title = 'SearchEmail';
      } else {
        title = 'Mailbox-${selectedMailboxId?.asString}';
      }
      RouteUtils.replaceBrowserHistory(
        title: title,
        url: uri ?? RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            emailId: selectedEmail.value?.id,
            mailboxId: isSearchRunning
              ? null
              : selectedMailboxId,
            dashboardType: isSearchRunning
              ? DashboardType.search
              : DashboardType.normal,
            searchQuery: isSearchRunning
              ? searchController.searchQuery
              : null
          )
        )
      );
    }
  }

  bool _navigateToScreen() {
    log('MailboxDashBoardController::_navigateToScreen: dashboardRoute: $dashboardRoute');
    switch(dashboardRoute.value) {
      case DashboardRoutes.emailDetailed:
        if (PlatformInfo.isMobile) {
          if (currentContext != null && canBack(currentContext!)) {
            return false;
          } else {
            dispatchEmailUIAction(CloseEmailDetailedViewAction());
            return true;
          }
        } else {
          dispatchEmailUIAction(CloseEmailDetailedViewAction());
          return true;
        }
      case DashboardRoutes.thread:
        if (PlatformInfo.isMobile) {
          if (currentContext != null && canBack(currentContext!)) {
            return false;
          } else if (isSelectionEnabled()) {
            dispatchAction(CancelSelectionAllEmailAction());
            return true;
          } else if (selectedMailbox.value?.isInbox == true) {
            return false;
          } else {
            openDefaultMailbox();
            return true;
          }
        }
        if (searchController.isSearchEmailRunning) {
          dispatchMailboxUIAction(SystemBackToInboxAction());
          return true;
        } else {
          if (selectedMailbox.value?.isInbox == true) {
            pushAndPopAll(AppRoutes.home);
            return true;
          } else {
            openDefaultMailbox();
            return true;
          }
        }
      case DashboardRoutes.sendingQueue:
        if (PlatformInfo.isMobile) {
          openDefaultMailbox();
          return true;
        }
        return false;
      case DashboardRoutes.searchEmail:
        if (PlatformInfo.isMobile) {
          if (currentContext != null && canBack(currentContext!)) {
            return false;
          } else if (listResultSearch.any((email) => email.selectMode == SelectMode.ACTIVE)) {
            dispatchAction(CancelSelectionSearchEmailAction());
            return true;
          } else {
            dispatchAction(CloseSearchEmailViewAction());
            return true;
          }
        } else {
          dispatchAction(CloseSearchEmailViewAction());
          return true;
        }
      default:
        return false;
    }
  }

  bool get _isDialogViewOpen => Get.isOverlaysOpen == true;

  bool _onBackButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    log('MailboxDashBoardController::_onBackButtonInterceptor:currentRoute: ${Get.currentRoute} | _isDialogViewOpen: $_isDialogViewOpen');
    if (_isDialogViewOpen) {
      popBack();
      _replaceBrowserHistory();
      return true;
    }

    if (Get.currentRoute.startsWith(AppRoutes.dashboard)) {
      return _navigateToScreen();
    }

    return false;
  }

  void archiveMessage(BuildContext context, PresentationEmail email) {
    final mailboxContain = email.findMailboxContain(mapMailboxById);
    if (mailboxContain != null) {
      final archiveMailboxId = getMailboxIdByRole(PresentationMailbox.roleArchive);
      final archiveMailboxPath = mapMailboxById[archiveMailboxId]?.getDisplayName(context);
      if (archiveMailboxId != null) {
        final moveToArchiveMailboxRequest = MoveToMailboxRequest(
          {mailboxContain.id: [email.id!]},
          archiveMailboxId,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: archiveMailboxPath
        );
        moveToMailbox(
          sessionCurrent!,
          accountId.value!,
          moveToArchiveMailboxRequest
        );
      }
    }
  }

  void _handleRestoreDeletedMessageSuccess(EmailRecoveryActionId emailRecoveryActionId) async {
    log('MailboxDashBoardController::_handleRestoreDeletedMessageSuccess():emailRecoveryActionId: $emailRecoveryActionId');
    _getRestoredDeletedMessage(emailRecoveryActionId);
  }

  void _getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) {
    consumeState(_getRestoredDeletedMessageInteractor.execute(sessionCurrent!, accountId.value!, emailRecoveryActionId));
  }

  void _handleRestoreDeletedMessageFailed() {
    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentOverlayContext!).restoreDeletedMessageFailed
    );
  }

  void _handleGetRestoredDeletedMessageSuccess(GetRestoredDeletedMessageSuccess success) async {
    if (selectedMailbox.value != null && selectedMailbox.value!.isRecovered) {
      dispatchEmailUIAction(RefreshChangeEmailAction(null));
    }

    if (success is GetRestoredDeletedMessageCompleted) {
      isRecoveringDeletedMessage.value = false;
      if (success.recoveredMailbox != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).restoreDeletedMessageSuccess,
          actionName: AppLocalizations.of(currentContext!).open,
          onActionClick: () => openMailboxAction(success.recoveredMailbox!.toPresentationMailbox()),
          leadingSVGIcon: imagePaths.icRecoverDeletedMessages,
          leadingSVGIconColor: Colors.white,
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          actionIcon: SvgPicture.asset(
            imagePaths.icFolderMailbox,
            colorFilter: Colors.white.asFilter(),
          )
        );
      } else {
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).restoreDeletedMessageSuccess
        );
      }
    } else if (success is GetRestoredDeletedMessageInProgress || success is GetRestoredDeletedMessageWaiting) {
      await Future.delayed(const Duration(seconds: 2));
      _getRestoredDeletedMessage(success.emailRecoveryAction.id!);
    } else if (success is GetRestoredDeletedMessageCanceled) {
      isRecoveringDeletedMessage.value = false;
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).restoreDeletedMessageCanceled,
        leadingSVGIcon: imagePaths.icRecoverDeletedMessages,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.primaryColor,
        textColor: Colors.white,
      );
    }
  }

  void gotoEmailRecovery() async {
    closeMailboxMenuDrawer();
    final currentAccountId = accountId.value;
    final currentSession = sessionCurrent;
    if (currentAccountId != null && currentSession != null) {
      final arguments = EmailRecoveryArguments(currentAccountId, currentSession);

      final result = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(
          routeName: AppRoutes.emailRecovery,
          arguments: arguments,
        )
      : await push(AppRoutes.emailRecovery, arguments: arguments);

      if (result is EmailRecoveryAction) {
        log('MailboxDashBoardController::gotoEmailRecovery():result: $result');
        handleRestoreEmailAction(result);
      }
    }
  }

  void handleRestoreEmailAction(EmailRecoveryAction emailRecoveryAction) {
    log('MailboxController::_handleRestoreEmailAction');
    final generateId = Id(const Uuid().v4());
    final restoreDeletedMessageRequest = RestoredDeletedMessageRequest(generateId, emailRecoveryAction);

    consumeState(_restoreDeletedMessageInteractor.execute(sessionCurrent!, accountId.value!, restoreDeletedMessageRequest));
    isRecoveringDeletedMessage.value = true;
  }

  void _loadActiveAccount({
    required PersonalAccount activeAccount,
    required Session sessionActiveAccount
  }) {
    dispatchRoute(DashboardRoutes.waiting);

    setCurrentActiveAccount(activeAccount);

    dynamicUrlInterceptors.changeBaseUrl(activeAccount.apiUrl);

    _setUpComponentsFromSession(sessionActiveAccount);

    dispatchRoute(DashboardRoutes.thread);
  }

  void _handleSwitchActiveAccountAction(SwitchActiveAccountArguments arguments) {
    log('MailboxDashBoardController::_handleSwitchActiveAccountAction:arguments: $arguments');
    _loadActiveAccount(
      activeAccount: arguments.nextAccount,
      sessionActiveAccount: arguments.sessionNextAccount
    );

    _showToastMessageSwitchActiveAccountSuccess(
      previousAccount: arguments.currentAccount,
      currentAccount: arguments.nextAccount,
      sessionPreviousAccount: arguments.sessionCurrentAccount,
    );
  }

  void _handleSelectActiveAccountAction(SelectActiveAccountArguments arguments) {
    log('MailboxDashBoardController::_handleSelectActiveAccountAction:arguments: $arguments');
    _loadActiveAccount(
      activeAccount: arguments.activeAccount,
      sessionActiveAccount: arguments.session
    );
  }

  void _showToastMessageSwitchActiveAccountSuccess({
    required PersonalAccount previousAccount,
    required PersonalAccount currentAccount,
    required Session sessionPreviousAccount,
  }) {
    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageSuccessWhenSwitchActiveAccount(currentAccount.userName?.value ?? ''),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _undoSwitchActiveAccountAction(previousAccount, sessionPreviousAccount),
        leadingSVGIcon: imagePaths.icToastSuccessMessage,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo));
    }
  }

  void _handleRestorePreviousActiveAccountAction(RestoreActiveAccountArguments arguments) {
    log('MailboxDashBoardController::_handleRestorePreviousActiveAccountAction:arguments: $arguments');
    if (arguments.exception != null &&
        currentContext != null &&
        currentOverlayContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageFailureWhenSwitchActiveAccount);
    }

    _loadActiveAccount(
      activeAccount: arguments.currentAccount,
      sessionActiveAccount: arguments.session
    );
  }

  void _undoSwitchActiveAccountAction(
    PersonalAccount previousAccount,
    Session sessionPreviousAccount
  ) {
    setUpInterceptors(previousAccount);

    dispatchRoute(DashboardRoutes.waiting);

    setCurrentActiveAccount(previousAccount);

    dynamicUrlInterceptors.changeBaseUrl(previousAccount.apiUrl);

    _setUpComponentsFromSession(sessionPreviousAccount);

    dispatchRoute(DashboardRoutes.thread);
  }

  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailAddressStreamSubscription.cancel();
    _emailContentStreamSubscription.cancel();
    _fileReceiveManagerStreamSubscription.cancel();
    _progressStateController.close();
    _refreshActionEventController.close();
    _notificationManager.closeStream();
    _fcmService.closeStream();
    BackButtonInterceptor.removeByName(AppRoutes.dashboard);
    super.onClose();
  }
}