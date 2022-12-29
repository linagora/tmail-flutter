import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
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
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
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
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/app_grid_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_email_state_to_refresh_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_mailbox_state_to_refresh_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/delete_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_email_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_mailbox_state_to_refresh_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
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
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class MailboxDashBoardController extends ReloadableController {

  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final SearchController searchController = Get.find<SearchController>();
  final DownloadController downloadController = Get.find<DownloadController>();
  final NetworkConnectionController networkConnectionController = Get.find<NetworkConnectionController>();
  final AppGridDashboardController appGridDashboardController = Get.find<AppGridDashboardController>();

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
  final dashboardRoute = DashboardRoutes.waiting.obs;
  final appInformation = Rxn<PackageInfo>();
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final composerOverlayState = ComposerOverlayState.inActive.obs;
  final viewStateMarkAsReadMailbox = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final vacationResponse = Rxn<VacationResponse>();
  final routerParameters = Rxn<Map<String, String?>>();
  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  final emailsInCurrentMailbox = <PresentationEmail>[].obs;
  final listResultSearch = RxList<PresentationEmail>();
  PresentationMailbox? outboxMailbox;
  RouterArguments? routerArguments;
  NavigationRouter? navigationRouter;

  late StreamSubscription _emailReceiveManagerStreamSubscription;
  late StreamSubscription _fileReceiveManagerStreamSubscription;

  final StreamController<Either<Failure, Success>> _progressStateController =
    StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  final StreamController<RefreshActionViewEvent> _refreshActionEventController =
    StreamController<RefreshActionViewEvent>.broadcast();

  MailboxDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
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
  ) : super(logoutOidcInteractor,
      deleteAuthorityOidcInteractor,
      getAuthenticatedAccountInteractor);

  @override
  void onInit() {
    _registerStreamListener();
    super.onInit();
  }

  @override
  void onReady() {
    _registerPendingEmailAddress();
    _registerPendingFileInfo();
    _getSessionCurrent();
    _getAppVersion();
    _handleOpenAppByNotification();
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
                success.composerCache.id,
                subject: success.composerCache.subject,
                from: success.composerCache.from,
                to: success.composerCache.to,
                cc: success.composerCache.cc,
                bcc: success.composerCache.bcc,
              ),
              emailContents: success.composerCache.emailContentList,
            );
            openComposerOverlay(composerArguments);
          }
        },
      );    
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.fold(
      (failure) {
        log('MailboxDashBoardController::onData():failure $failure');
      },
      (success) {
        log('MailboxDashBoardController::onData():success $success');
        if (success is SendingEmailState) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                message: AppLocalizations.of(currentContext!).your_email_being_sent,
                icon: _imagePaths.icSendToast);
          }
        } else if (success is GetEmailStateToRefreshSuccess) {
          dispatchAction(RefreshChangeEmailAction(success.storedState));
          _deleteEmailStateToRefreshAction();
        } else if (success is GetMailboxStateToRefreshSuccess) {
          dispatchAction(RefreshChangeMailboxAction(success.storedState));
          _deleteMailboxStateToRefreshAction();
        }
      }
    );
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is SendEmailFailure) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.toastErrorBackgroundColor,
                message: AppLocalizations.of(currentContext!).message_has_been_sent_failure,
                icon: _imagePaths.icSendToast);
          }
          clearState();
        } else if (failure is SaveEmailAsDraftsFailure
            || failure is RemoveEmailDraftsFailure
            || failure is UpdateEmailDraftsFailure
            || failure is GetEmailByIdFailure) {
          clearState();
        } else if (failure is MarkAsMailboxReadAllFailure ||
            failure is MarkAsMailboxReadFailure) {
          _markAsReadMailboxFailure(failure);
        }
      },
      (success) {
        if (success is SendEmailSuccess) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.primaryColor,
                message: AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
                icon: _imagePaths.icSendToast);
          }
        } else if (success is SaveEmailAsDraftsSuccess) {
          log('MailboxDashBoardController::onDone(): SaveEmailAsDraftsSuccess');
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
        } else if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsReadSelectedMultipleEmailSuccess(success);
        } else if (success is MarkAsStarMultipleEmailAllSuccess
            || success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
          _markAsStarMultipleEmailSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is EmptyTrashFolderSuccess) {
          _emptyTrashFolderSuccess(success);
        } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess
            || success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
          _deleteMultipleEmailsPermanentlySuccess(success);
        } else if (success is GetAppDashboardConfigurationSuccess) {
          appGridDashboardController.handleShowAppDashboard(success.linagoraApplications);
        } else if(success is GetEmailByIdSuccess) {
          _moveToEmailDetailedView(success);
        }
      }
    );
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
    
    LocalNotificationManager.instance.localNotificationStream.listen(_handleLocalNotificationResponse);
  }

  void _handleOpenAppByNotification() async {
    log("_handleOpenAppByNotification(): isOpenAppByNotification: ${LocalNotificationManager.instance.isOpenAppByNotification}");
    await LocalNotificationManager.instance.setUp();
    if(LocalNotificationManager.instance.isOpenAppByNotification) {
      final emailId = EmailId(Id(LocalNotificationManager.instance.getEmailIdFromNotification()!));
      _getPresentationEmailFromEmailId(emailId);
    } else {
      dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _getUserProfile() async {
    userProfile.value = sessionCurrent != null ? UserProfile(sessionCurrent!.username.value) : null;
  }

  void _getSessionCurrent() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_getSessionCurrent(): arguments = $arguments');
    if (arguments is Session) {
      sessionCurrent = arguments;
      accountId.value = sessionCurrent?.accounts.keys.first;
      _getUserProfile();
      injectAutoCompleteBindings(sessionCurrent, accountId.value);
      injectRuleFilterBindings(sessionCurrent, accountId.value);
      injectVacationBindings(sessionCurrent, accountId.value);
      injectFCMBindings(sessionCurrent, accountId.value);
      _getVacationResponse();
    } else {
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
    if (BuildUtils.isWeb && presentationEmail.routeWeb != null) {
      RouteUtils.updateRouteOnBrowser(
        'Email-${presentationEmail.id.id.value}',
        presentationEmail.routeWeb!
      );
    }
  }

  void openMailboxMenuDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeMailboxMenuDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  bool get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen == true;

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void searchEmail(BuildContext context, String value) {
    clearFilterMessageOption();
    searchController.updateFilterEmail(text: SearchQuery(value));
    dispatchAction(StartSearchEmailAction());
    FocusScope.of(context).unfocus();
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    if (value.isEmpty){
      searchController.setEmailReceiveTimeType(null);
    }
    _unSelectedMailbox();
  }

  bool _searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return BuildUtils.isWeb
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
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).drafts_saved,
          actionName: AppLocalizations.of(currentContext!).discard,
          onActionClick: () => _discardEmail(success.emailAsDrafts),
          leadingIcon: SvgPicture.asset(
              _imagePaths.icMailboxDrafts,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void moveToMailbox(AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
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
                sessionCurrent!,
                success.emailActionType));
          },
          leadingIcon: SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_moveToMailboxInteractor.execute(currentAccountId, newMoveRequest));
    }
  }

  void _discardEmail(Email email) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_removeEmailDraftsInteractor.execute(currentAccountId, email.id));
    }
  }

  void deleteEmailPermanently(PresentationEmail email) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_deleteEmailPermanentlyInteractor.execute(currentAccountId, email.id));
    }
  }

  void _deleteEmailPermanentlySuccess(DeleteEmailPermanentlySuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_a_email_permanently_success,
          icon: _imagePaths.icDeleteToast);
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    if (accountId.value != null) {
      consumeState(_markAsEmailReadInteractor.execute(
          accountId.value!,
          presentationEmail.toEmail(),
          readActions));
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    if (accountId.value != null) {
      consumeState(_markAsStarEmailInteractor.execute(
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
    if (accountId.value != null) {
      consumeState(_markAsMultipleEmailReadInteractor.execute(
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

    if (currentContext != null && readActions != null && currentOverlayContext != null) {
      final message = readActions == ReadActions.markAsUnread
          ? AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).unread)
          : AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).read);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: readActions == ReadActions.markAsUnread
              ? _imagePaths.icUnreadToast
              : _imagePaths.icReadToast);
    }
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    final listEmail = listPresentationEmail
        .map((presentationEmail) => presentationEmail.toEmail())
        .toList();
    if (accountId.value != null) {
      consumeState(_markAsStarMultipleEmailInteractor.execute(
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

    if (currentContext != null && markStarAction != null && currentOverlayContext != null) {
      final message = markStarAction == MarkStarAction.unMarkStar
          ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
          : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: markStarAction == MarkStarAction.unMarkStar
              ? _imagePaths.icUnStar
              : _imagePaths.icStar);
    }
  }

  void moveSelectedMultipleEmailToMailbox(
      BuildContext context,
      List<PresentationEmail> listEmails,
      PresentationMailbox currentMailbox
  ) async {
    if (accountId.value != null) {
      final arguments = DestinationPickerArguments(accountId.value!, MailboxActions.moveEmail);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              if (sessionCurrent != null) {
                _dispatchMoveToMultipleAction(
                    accountId.value!,
                    sessionCurrent!,
                    listEmails.listEmailIds,
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
            sessionCurrent != null) {
          _dispatchMoveToMultipleAction(
              accountId.value!,
              sessionCurrent!,
              listEmails.listEmailIds,
              currentMailbox,
              destinationMailbox);
        }
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
      _moveSelectedEmailMultipleToMailboxAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveSelectedEmailMultipleToMailboxAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveSelectedEmailMultipleToMailboxAction(accountId, MoveToMailboxRequest(
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
    if(searchController.isSearchEmailRunning){
      final Map<MailboxId,List<EmailId>> mapListEmailSelectedByMailBoxId = {};
      for (var element in listEmails) {
        final mailbox = element.findMailboxContain(mapMailboxById);
        if(mailbox != null) {
          if(mapListEmailSelectedByMailBoxId.containsKey(mailbox.id)) {
            mapListEmailSelectedByMailBoxId[mailbox.id]?.add(element.id);
          } else {
            mapListEmailSelectedByMailBoxId.addAll({mailbox.id: [element.id]});
          }
        }
      }
      _handleDragSelectedMultipleEmailToMailboxAction(mapListEmailSelectedByMailBoxId, destinationMailbox);

    } else {
      if(selectedMailbox.value != null) {
        _handleDragSelectedMultipleEmailToMailboxAction({selectedMailbox.value!.id: listEmails.listEmailIds}, destinationMailbox);
      }
    }

  }

  void _handleDragSelectedMultipleEmailToMailboxAction(
    Map<MailboxId, List<EmailId>> mapListEmails,
    PresentationMailbox destinationMailbox,
  ) async {
    if (accountId.value != null ) {
      if (destinationMailbox.isTrash) {
        moveToMailbox(accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            sessionCurrent!,
            EmailActionType.moveToTrash,
          ),
        );
      } else if (destinationMailbox.isSpam) {
        moveToMailbox(accountId.value!,
          MoveToMailboxRequest(
            mapListEmails,
            destinationMailbox.id,
            MoveAction.moving,
            sessionCurrent!,
            EmailActionType.moveToSpam,
          ),
        );
      } else {
        moveToMailbox(accountId.value!,
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
      AccountId accountId,
      MoveToMailboxRequest moveRequest
  ) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
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
      _appToast.showBottomToast(
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
                  destinationPath: destinationPath));
            }
          },
          leadingIcon: SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    if (accountId.value != null) {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
          accountId.value!,
          newMoveRequest));
    }
  }

  void moveSelectedMultipleEmailToTrash(List<PresentationEmail> listEmails, PresentationMailbox mailboxCurrent) {
    final trashMailboxId = getMailboxIdByRole(PresentationMailbox.roleTrash);
    if (accountId.value != null && trashMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
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
    if (accountId.value != null && spamMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
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
    if (inboxMailboxId != null && accountId.value != null && spamMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
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
        _emptyTrashFolderAction(onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.multiple:
        _deleteMultipleEmailsPermanently(listEmails ?? [], onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.single:
        break;
    }
  }

  void _emptyTrashFolderAction({Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    final trashMailboxId = mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];
    if (accountId.value != null && trashMailboxId != null) {
      consumeState(_emptyTrashFolderInteractor.execute(accountId.value!, trashMailboxId));
    }
  }

  void _emptyTrashFolderSuccess(EmptyTrashFolderSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success,
          icon: _imagePaths.icDeleteToast);
    }
  }

  void _deleteMultipleEmailsPermanently(List<PresentationEmail> listEmails, {Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    if (accountId.value != null) {
      consumeState(_deleteMultipleEmailsPermanentlyInteractor.execute(
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

    if (currentContext != null && currentOverlayContext != null && listEmailIdResult.isNotEmpty) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length),
          icon: _imagePaths.icDeleteToast);
    }
  }

  void dispatchAction(UIAction action) {
    log('MailboxDashBoardController::dispatchAction(): ${action.runtimeType}');
    dashBoardAction.value = action;
  }

  void openComposerOverlay(RouterArguments? arguments) {
    routerArguments = arguments;
    ComposerBindings().dependencies();
    composerOverlayState.value = ComposerOverlayState.active;
  }

  void closeComposerOverlay() {
    routerArguments = null;
    ComposerBindings().dispose();
    composerOverlayState.value = ComposerOverlayState.inActive;
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
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final mailboxName = selectedMailbox.value?.name;
    final countEmailsUnread = selectedMailbox.value?.unreadEmails?.value.value ?? 0;
    if (currentAccountId != null && mailboxId != null && mailboxName != null) {
      markAsReadMailbox(currentAccountId, mailboxId, mailboxName, countEmailsUnread.toInt());
    }
  }

  void markAsReadMailbox(
      AccountId accountId,
      MailboxId mailboxId,
      MailboxName mailboxName,
      int totalEmailsUnread
  ) {
    consumeState(_markAsMailboxReadInteractor.execute(
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
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
            message: AppLocalizations.of(currentContext!)
                .toastMessageMarkAsMailboxReadSuccess(success.mailboxName.name),
            icon: _imagePaths.icReadToast);
      }
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
            message: AppLocalizations.of(currentContext!)
                .toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxName.name, success.countEmailsRead),
            icon: _imagePaths.icReadToast);
      }
    }
  }

  void _markAsReadMailboxFailure(Failure failure) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);
  }

  void goToComposer(ComposerArguments arguments) {
    if (BuildUtils.isWeb) {
      if (composerOverlayState.value == ComposerOverlayState.inActive) {
        openComposerOverlay(arguments);
      }
    } else {
      push(AppRoutes.composer, arguments: arguments);
    }
  }

  void clearDashBoardAction() {
    dashBoardAction.value = DashBoardAction.idle;
  }

  void goToSettings() async {
    if (isDrawerOpen) {
      closeMailboxMenuDrawer();
    }
    final result = await push(AppRoutes.settings,
        arguments: ManageAccountArguments(sessionCurrent));

    if (result is VacationResponse) {
      vacationResponse.value = result;
    }
  }

  void selectQuickSearchFilter({
    required QuickSearchFilter quickSearchFilter,
    bool fromSuggestionBox = false,
  }) => searchController.selectQuickSearchFilter(
    quickSearchFilter: quickSearchFilter,
    userProfile: userProfile.value!,
    fromSuggestionBox: fromSuggestionBox,
  );

  bool checkQuickSearchFilterSelected({
    required QuickSearchFilter quickSearchFilter,
    bool fromSuggestionBox = false,
  }) => searchController.checkQuickSearchFilterSelected(
      quickSearchFilter: quickSearchFilter,
      userProfile: userProfile.value!,
      fromSuggestionBox: fromSuggestionBox,
  );

  Future<List<PresentationEmail>> quickSearchEmails() => searchController.quickSearchEmails(accountId: accountId.value!);

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
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully,
            icon: _imagePaths.icChecked);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('MailboxDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  void selectQuickSearchFilterAction(QuickSearchFilter filter) {
    log('MailboxDashBoardController::selectQuickSearchFilterAction(): filter: $filter');
    selectQuickSearchFilter(quickSearchFilter: filter);
    dispatchAction(StartSearchEmailAction());
  }

  void selectReceiveTimeQuickSearchFilter(EmailReceiveTimeType? emailReceiveTimeType) {
    popBack();

    if (emailReceiveTimeType != null) {
      searchController.updateFilterEmail(emailReceiveTimeType: emailReceiveTimeType);
    } else {
      searchController.updateFilterEmail(emailReceiveTimeType: EmailReceiveTimeType.allTime);
    }
    searchController.setEmailReceiveTimeType(emailReceiveTimeType);
    searchController.updateFilterEmail();
    if (searchController.searchQuery == null){
      searchController.updateFilterEmail(text: SearchQuery.initial());
    }
    dispatchAction(StartSearchEmailAction());
  }

  bool get isMailboxTrash => selectedMailbox.value?.isTrash == true;

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
    if (_getEmailStateToRefreshInteractor != null) {
      consumeState(_getEmailStateToRefreshInteractor!.execute());
    }
    if (_getMailboxStateToRefreshInteractor != null) {
      consumeState(_getMailboxStateToRefreshInteractor!.execute());
    }
  }

  void _deleteEmailStateToRefreshAction() {
    log('MailboxDashBoardController::_deleteEmailStateToRefreshAction():');
    try {
      _deleteEmailStateToRefreshInteractor = getBinding<DeleteEmailStateToRefreshInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::_deleteEmailStateToRefreshAction(): $e');
    }
    if (_deleteEmailStateToRefreshInteractor != null) {
      consumeState(_deleteEmailStateToRefreshInteractor!.execute());
    }
  }

  void _deleteMailboxStateToRefreshAction() {
    log('MailboxDashBoardController::_deleteMailboxStateToRefreshAction():');
    try {
      _deleteMailboxStateToRefreshInteractor = getBinding<DeleteMailboxStateToRefreshInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::_deleteMailboxStateToRefreshAction(): $e');
    }
    if (_deleteMailboxStateToRefreshInteractor != null) {
      consumeState(_deleteMailboxStateToRefreshInteractor!.execute());
    }
  }

  Future<bool> haveLocalNotificationPress() async {
    return !(await LocalNotificationManager.instance.localNotificationStream.isEmpty);
  }

  void _handleLocalNotificationResponse(NotificationResponse response) {
    if(response.payload != null) {
      final emailId = EmailId(Id(response.payload!));
      _getPresentationEmailFromEmailId(emailId);
    }
  }

  void _getPresentationEmailFromEmailId(EmailId emailId) {
    if(accountId.value != null) {
      log('MailboxDashBoardController: _getPresentationEmailFromEmailId: $emailId');
      consumeState(_getEmailByIdInteractor.execute(accountId.value!, emailId, properties: ThreadConstants.propertiesDefault));
    }
  }

  void _moveToEmailDetailedView(GetEmailByIdSuccess success) {
    log('MailboxDashBoardController::_moveToEmailDetailedView(): ${success.email}');
    setSelectedEmail(success.email);
    dispatchRoute(DashboardRoutes.emailDetailed);
    // move to inbox so that user can back to inbox view
    dispatchAction(ClearSearchEmailAction());
  }

  void popAllRouteIfHave() {
    Get.until((route) => Get.currentRoute == AppRoutes.dashboard);
  }
  
  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailReceiveManagerStreamSubscription.cancel();
    _fileReceiveManagerStreamSubscription.cancel();
    _progressStateController.close();
    _refreshActionEventController.close();
    Get.delete<DownloadController>();
    FcmController.instance.dispose();
    LocalNotificationManager.instance.dispose();
    super.onClose();
  }
}