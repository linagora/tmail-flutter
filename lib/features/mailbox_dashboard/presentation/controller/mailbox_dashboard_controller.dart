import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_email_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_sending_email_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/spam_report_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/set_error_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/refresh_action_view_event.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/controller/work_manager_controller.dart';
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
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/get_all_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_all_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/store_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/features/session/domain/usecases/store_session_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart' as work_manager;

class MailboxDashBoardController extends ReloadableController {

  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final SearchController searchController = Get.find<SearchController>();
  final DownloadController downloadController = Get.find<DownloadController>();
  final AppGridDashboardController appGridDashboardController = Get.find<AppGridDashboardController>();
  final SpamReportController spamReportController = Get.find<SpamReportController>();
  final NetworkConnectionController networkConnectionController = Get.find<NetworkConnectionController>();
  final Uuid _uuid = Get.find<Uuid>();

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

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;
  GetEmailStateToRefreshInteractor? _getEmailStateToRefreshInteractor;
  DeleteEmailStateToRefreshInteractor? _deleteEmailStateToRefreshInteractor;
  GetMailboxStateToRefreshInteractor? _getMailboxStateToRefreshInteractor;
  DeleteMailboxStateToRefreshInteractor? _deleteMailboxStateToRefreshInteractor;

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

  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  final emailsInCurrentMailbox = <PresentationEmail>[].obs;
  final listResultSearch = RxList<PresentationEmail>();
  PresentationMailbox? outboxMailbox;
  ComposerArguments? composerArguments;
  NavigationRouter? navigationRouter;

  late StreamSubscription _emailReceiveManagerStreamSubscription;
  late StreamSubscription _fileReceiveManagerStreamSubscription;

  final StreamController<Either<Failure, Success>> _progressStateController =
    StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  final StreamController<RefreshActionViewEvent> _refreshActionEventController =
    StreamController<RefreshActionViewEvent>.broadcast();

  final _notificationManager = LocalNotificationManager.instance;
  final _fcmService = FcmService.instance;

  MailboxDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    UpdateAuthenticationAccountInteractor updateAuthenticationAccountInteractor,
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
  ) : super(
    getAuthenticatedAccountInteractor,
    updateAuthenticationAccountInteractor
  );

  @override
  void onInit() {
    _registerStreamListener();
    super.onInit();
  }

  @override
  void onReady() {
    _registerPendingEmailAddress();
    _registerPendingEmailContents();
    _registerPendingFileInfo();
    _getSessionCurrent();
    _getAppVersion();
    super.onReady();
  }

  void _handleComposerCache() async {
    if (kIsWeb && userProfile.value != null) {
      _getEmailCacheOnWebInteractor.execute().fold(
        (failure) {},
        (success) {
          if(success is GetComposerCacheSuccess){
            final ComposerArguments composerArguments = ComposerArguments(
              emailActionType: EmailActionType.edit,
              presentationEmail: PresentationEmail(
                id: success.composerCache.id,
                subject: success.composerCache.subject,
                from: success.composerCache.from,
                to: success.composerCache.to,
                cc: success.composerCache.cc,
                bcc: success.composerCache.bcc,
              ),
              emailContents: success.composerCache.emailContentList.asHtmlString,
            );
            openComposerOverlay(composerArguments);
          }
        },
      );    
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is SendEmailLoading) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).your_email_being_sent,
          leadingSVGIcon: _imagePaths.icSendToast);
      }
    } else if (success is GetEmailStateToRefreshSuccess) {
      dispatchEmailUIAction(RefreshChangeEmailAction(success.storedState));
      _deleteEmailStateToRefreshAction();
    } else if (success is GetMailboxStateToRefreshSuccess) {
      dispatchMailboxUIAction(RefreshChangeMailboxAction(success.storedState));
      _deleteMailboxStateToRefreshAction();
    } else if (success is SendEmailSuccess) {
      if (currentOverlayContext != null && currentContext != null) {
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
          leadingSVGIcon: _imagePaths.icSendSuccessToast);
      }
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
    } else if (failure is MarkAsMailboxReadAllFailure ||
        failure is MarkAsMailboxReadFailure) {
      _markAsReadMailboxFailure(failure);
    } else if (failure is GetEmailByIdFailure) {
      _handleGetEmailDetailedFailed(failure);
    }
  }

  void _registerPendingEmailAddress() {
    _emailReceiveManagerStreamSubscription =
        _emailReceiveManager.pendingEmailAddressInfo.stream.listen((emailAddress) {
          log('MailboxDashBoardController::_registerPendingEmailAddress(): ${emailAddress?.email}');
          if (emailAddress != null && emailAddress.email?.isNotEmpty == true) {
            _emailReceiveManager.clearPendingEmailAddress();
            final arguments = ComposerArguments(
                emailActionType: EmailActionType.composeFromEmailAddress,
                emailAddress: emailAddress,
                mailboxRole: selectedMailbox.value?.role);
            goToComposer(arguments);
          }
        });
  }

  void _registerPendingEmailContents() {
    _emailReceiveManagerStreamSubscription =
      _emailReceiveManager.pendingEmailContentInfo.stream.listen((emailContent) {
        log('MailboxDashBoardController::_registerPendingEmailContents(): ${emailContent?.content}');
        if (emailContent != null && emailContent.content.isNotEmpty == true) {
          _emailReceiveManager.clearPendingEmailContent();
          final arguments = ComposerArguments(
            emailActionType: EmailActionType.edit,
            emailContents: [emailContent].asHtmlString,
            mailboxRole: selectedMailbox.value?.role);
          goToComposer(arguments);
          }
        });
  }

  void _registerPendingFileInfo() {
    _fileReceiveManagerStreamSubscription =
        _emailReceiveManager.pendingFileInfo.stream.listen((listFile) {
          log('MailboxDashBoardController::_registerPendingFileInfo(): ${listFile.length}');
          if (listFile.isNotEmpty && sessionCurrent != null) {
            _emailReceiveManager.clearPendingFileInfo();
            final arguments = ComposerArguments(
              emailActionType: EmailActionType.edit,
              mailboxRole: selectedMailbox.value?.role,
              listSharedMediaFile: listFile,
            );
            goToComposer(arguments);
          }
        });
  }

  void _registerStreamListener() {
    progressState.listen((state) {
      viewStateMarkAsReadMailbox.value = state;
    });

    _refreshActionEventController.stream
      .debounceTime(const Duration(milliseconds: FcmService.durationMessageComing))
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

  void _getUserProfile() async {
    userProfile.value = sessionCurrent != null ? UserProfile(sessionCurrent!.username.value) : null;
  }

  void _getSessionCurrent() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_getSessionCurrent(): arguments = $arguments');
    if (arguments is Session) {
      sessionCurrent = arguments;
      final personalAccount = sessionCurrent!.personalAccount;
      accountId.value = personalAccount.accountId;
      _getUserProfile();
      updateAuthenticationAccount(sessionCurrent!, accountId.value!, sessionCurrent!.username);
      injectAutoCompleteBindings(sessionCurrent, accountId.value);
      injectRuleFilterBindings(sessionCurrent, accountId.value);
      injectVacationBindings(sessionCurrent, accountId.value);
      injectFCMBindings(sessionCurrent, accountId.value);
      _getVacationResponse();
      spamReportController.getSpamReportStateAction();
      if (PlatformInfo.isMobile) {
        getAllSendingEmails();
        _storeSessionAction(sessionCurrent!);
      }
      if (PlatformInfo.isMobile && !_notificationManager.isNotificationClickedOnTerminate) {
        _handleClickLocalNotificationOnTerminated();
      } else {
        dispatchRoute(DashboardRoutes.thread);
      }
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
  void injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      super.injectFCMBindings(session, accountId);
      await LocalNotificationManager.instance.recreateStreamController();
      _registerLocalNotificationStreamListener();
    } catch (e) {
      logError('MailboxDashBoardController::injectFCMBindings(): $e');
    }
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
      RouteUtils.updateRouteOnBrowser(
        'Email-${presentationEmail.id?.id.value ?? ''}',
        presentationEmail.routeWeb!
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
    if (isDrawerOpen && _responsiveUtils.isWebDesktop(context)) {
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
    dispatchAction(StartSearchEmailAction());
    KeyboardUtils.hideKeyboard(context);
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    _unSelectedMailbox();
  }

  bool _searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return PlatformInfo.isWeb
        && _responsiveUtils.isDesktop(context)
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
      _appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).drafts_saved,
        actionName: AppLocalizations.of(currentContext!).discard,
        onActionClick: () => _discardEmail(success.emailAsDrafts),
        leadingSVGIcon: _imagePaths.icMailboxDrafts,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(_imagePaths.icUndo));
    }
  }

  void moveToMailbox(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(session, accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
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
            sessionCurrent!,
            success.emailActionType
          ));
        },
        leadingSVGIcon: _imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(_imagePaths.icUndo));
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
      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toast_message_delete_a_email_permanently_success,
        leadingSVGIcon: _imagePaths.icDeleteToast
      );
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    if (accountId.value != null && sessionCurrent != null) {
      consumeState(_markAsEmailReadInteractor.execute(
        sessionCurrent!,
        accountId.value!,
        presentationEmail.toEmail(),
        readActions));
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

      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: readActions == ReadActions.markAsUnread
          ? _imagePaths.icUnreadToast
          : _imagePaths.icReadToast
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
        _appToast.showToastMessage(
          currentOverlayContext!,
          message,
          leadingSVGIcon: markStarAction == MarkStarAction.unMarkStar
            ? _imagePaths.icUnStar
            : _imagePaths.icStar);
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
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveSelectedEmailMultipleToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveSelectedEmailMultipleToMailboxAction(
        session,
        accountId,
        MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
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
            sessionCurrent!,
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
            sessionCurrent!,
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
            sessionCurrent!,
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
      _appToast.showToastMessage(
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
              sessionCurrent!,
              emailActionType!,
              destinationPath: destinationPath
            ));
          }
        },
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(_imagePaths.icUndo),
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
          sessionCurrent!,
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
          sessionCurrent!,
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
          sessionCurrent!,
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
    if (_responsiveUtils.isScreenWithShortestSide(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(actionType.getContentDialog(
            context,
            count: listEmails?.length,
            mailboxName: mailboxCurrent?.name?.name))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            actionType.getConfirmActionName(context),
            () => _deleteSelectionEmailsPermanentlyAction(
                actionType,
                listEmails: listEmails,
                onCancelSelectionEmail: onCancelSelectionEmail)))
      .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_emails_permanently'))
              ..title(actionType.getTitleDialog(context))
              ..content(actionType.getContentDialog(
                  context,
                  count: listEmails?.length,
                  mailboxName: mailboxCurrent?.name?.name))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog, fit: BoxFit.fill))
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
            .build()));
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
      _appToast.showToastSuccessMessage(
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
      _appToast.showToastSuccessMessage(
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
      handleSendEmailAction(
        result.session,
        result.accountId,
        result.emailRequest,
        result.mailboxRequest,
        result.sendingEmailActionType
      );
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
    sessionCurrent = session;
    accountId.value = sessionCurrent?.accounts.keys.first;
    _getUserProfile();
    _handleComposerCache();
    injectAutoCompleteBindings(sessionCurrent, accountId.value);
    injectRuleFilterBindings(sessionCurrent, accountId.value);
    injectFCMBindings(sessionCurrent, accountId.value);
    injectVacationBindings(sessionCurrent, accountId.value);
    _getVacationResponse();
    spamReportController.getSpamReportStateAction();
    if (PlatformInfo.isMobile) {
      getAllSendingEmails();
      _storeSessionAction(sessionCurrent!);
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
        final maxSizeAttachmentsPerEmail = mailCapability.maxSizeAttachmentsPerEmail;
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

  void markAsReadMailboxAction() {
    final session = sessionCurrent;
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final mailboxName = selectedMailbox.value?.name;
    final countEmailsUnread = selectedMailbox.value?.unreadEmails?.value.value ?? 0;
    if (session != null && currentAccountId != null && mailboxId != null && mailboxName != null) {
      markAsReadMailbox(session, currentAccountId, mailboxId, mailboxName, countEmailsUnread.toInt());
    }
  }

  void markAsReadMailbox(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    MailboxName mailboxName,
    int totalEmailsUnread
  ) {
    consumeState(_markAsMailboxReadInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxName,
      totalEmailsUnread,
      _progressStateController));
  }

  void _markAsReadMailboxSuccess(Success success) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);

    if (success is MarkAsMailboxReadAllSuccess) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadSuccess(success.mailboxName.name),
          leadingSVGIcon: _imagePaths.icReadToast);
      }
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxName.name, success.countEmailsRead),
          leadingSVGIcon: _imagePaths.icReadToast);
      }
    }
  }

  void _markAsReadMailboxFailure(Failure failure) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);
  }

  void goToComposer(ComposerArguments arguments) async {
    if (PlatformInfo.isWeb) {
      if (composerOverlayState.value == ComposerOverlayState.inActive) {
        openComposerOverlay(arguments);
      }
    } else {
      final result = await push(AppRoutes.composer, arguments: arguments);
      if (result is SendingEmailArguments) {
        handleSendEmailAction(
          result.session,
          result.accountId,
          result.emailRequest,
          result.mailboxRequest,
          result.sendingEmailActionType
        );
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
    final result = await push(
      AppRoutes.settings,
      arguments: ManageAccountArguments(sessionCurrent)
    );

    if (result is VacationResponse) {
      vacationResponse.value = result;
      dispatchMailboxUIAction(RefreshChangeMailboxAction(null));
    }
  }

  void selectQuickSearchFilter(QuickSearchFilter filter) {
    return searchController.selectQuickSearchFilter(filter, userProfile.value!);
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
    final result = await push(AppRoutes.settings,
        arguments: ManageAccountArguments(
            sessionCurrent,
            menuSettingCurrent: AccountMenuItem.vacation));

    if (result is VacationResponse) {
      vacationResponse.value = result;
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('MailboxDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  void selectQuickSearchFilterAction(QuickSearchFilter filter) {
    log('MailboxDashBoardController::selectQuickSearchFilterAction(): filter: $filter');
    selectQuickSearchFilter(filter);
    dispatchAction(StartSearchEmailAction());
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

  bool get isMailboxTrashValid {
    return selectedMailbox.value != null
      && selectedMailbox.value!.isTrash
      && selectedMailbox.value!.countEmails > 0;
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

  void _handleMessageFromNotification(String? payload, {bool onForeground = true}) {
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
      _openInboxMailbox();
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
    dispatchRoute( DashboardRoutes.waiting);
  }

  void _openInboxMailbox() {
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
      properties: ThreadConstants.propertiesDefault
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
    if (currentContext == null) {
      clearState();
      return;
    }
    final exception = failure.exception;
    logError('MailboxDashBoardController::_handleSendEmailFailure():exception: $exception');
    if (exception is SetEmailMethodException) {
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
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        message,
        leadingSVGIcon: _imagePaths.icSendSuccessToast);
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
    if (exception is SetEmailMethodException) {
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
    if (exception is SetEmailMethodException) {
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

  void handleSendEmailAction(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
    SendingEmailActionType sendingEmailActionType
  ) {
    if (PlatformInfo.isMobile) {
      if (networkConnectionController.isNetworkConnectionAvailable()) {
        consumeState(_sendEmailInteractor.execute(
          session,
          accountId,
          emailRequest,
          mailboxRequest: mailboxRequest
        ));
      } else {
        _handleSendingEmailWhenNoNetwork(
          session,
          accountId,
          emailRequest,
          mailboxRequest,
          sendingEmailActionType
        );
      }
    } else {
      consumeState(_sendEmailInteractor.execute(
        session,
        accountId,
        emailRequest,
        mailboxRequest: mailboxRequest
      ));
    }
  }

  void _handleSendingEmailWhenNoNetwork(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
    SendingEmailActionType sendingEmailActionType
  ) {
    switch(sendingEmailActionType) {
      case SendingEmailActionType.create:
        _showConfirmDialogStoreSendingEmail(session, accountId, emailRequest, mailboxRequest);
        break;
      case SendingEmailActionType.edit:
        _handleUpdateSendingEmail(session, accountId, emailRequest, mailboxRequest);
        break;
      case SendingEmailActionType.delete:
      case SendingEmailActionType.resend:
        break;
    }
  }

  void _handleStoreSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest,
  ) {
    final sendingEmail = emailRequest.toSendingEmail(_uuid.v1(), mailboxRequest: mailboxRequest);
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
    }
  }

  void _showConfirmDialogStoreSendingEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    CreateNewMailboxRequest? mailboxRequest
  ) {
    showConfirmDialogAction(
      currentContext!,
      '',
      AppLocalizations.of(currentContext!).proceed,
      onConfirmAction: () {
        _handleStoreSendingEmail(session, accountId, emailRequest, mailboxRequest);
      },
      title: AppLocalizations.of(currentContext!).youAreInOfflineMode,
      icon: SvgPicture.asset(_imagePaths.icDialogOfflineMode),
      alignCenter: true,
      messageStyle: const TextStyle(
        color: AppColor.colorTitleSendingItem,
        fontSize: 15,
        fontWeight: FontWeight.normal
      ),
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(currentContext!).messageDialogWhenStoreSendingEmailFirst),
        TextSpan(
          text: AppLocalizations.of(currentContext!).messageDialogWhenStoreSendingEmailSecond,
          style: const TextStyle(
            color: AppColor.colorTitleSendingItem,
            fontSize: 15,
            fontWeight: FontWeight.w600
          ),
        ),
        TextSpan(text: AppLocalizations.of(currentContext!).messageDialogWhenStoreSendingEmailThird),
        TextSpan(
          text: AppLocalizations.of(currentContext!).sendingQueue,
          style: const TextStyle(
            color: AppColor.colorTitleSendingItem,
            fontSize: 15,
            fontWeight: FontWeight.w600
          ),
        ),
        TextSpan(text: AppLocalizations.of(currentContext!).messageDialogWhenStoreSendingEmailTail)
      ]
    );
  }

  void _handleStoreSendingEmailSuccess(StoreSendingEmailSuccess success) {
    addSendingEmailToSendingQueue(success.sendingEmail);
    getAllSendingEmails();
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messageHasBeenSavedToTheSendingQueue,
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icEmail);
    }
  }

  void _handleUpdateSendingEmailSuccess(UpdateSendingEmailSuccess success) async {
    await WorkManagerController().cancelByUniqueId(success.newSendingEmail.sendingId);
    addSendingEmailToSendingQueue(success.newSendingEmail);
    getAllSendingEmails();
  }

  void addSendingEmailToSendingQueue(SendingEmail sendingEmail) async {
    log('MailboxDashBoardController::addSendingEmailToSendingQueue():sendingEmail: $sendingEmail');
    final work = OneTimeWorkRequest(
      uniqueId: PlatformInfo.isAndroid
        ? sendingEmail.sendingId
        : WorkerType.sendingEmail.iOSUniqueId,
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
      _openDefaultMailbox();
    }
  }

  void _openDefaultMailbox() {
    dispatchRoute(DashboardRoutes.thread);
    dispatchMailboxUIAction(SelectMailboxDefaultAction());
  }

  void _storeSessionAction(Session session) {
    consumeState(_storeSessionInteractor.execute(session));
  }
  
  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailReceiveManagerStreamSubscription.cancel();
    _fileReceiveManagerStreamSubscription.cancel();
    _progressStateController.close();
    _refreshActionEventController.close();
    _notificationManager.closeStream();
    _fcmService.closeStream();
    MailboxDashBoardBindings().deleteController();
    super.onClose();
  }
}