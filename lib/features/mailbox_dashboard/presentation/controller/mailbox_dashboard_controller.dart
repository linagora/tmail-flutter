import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class MailboxDashBoardController extends ReloadableController {

  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final Connectivity _connectivity = Get.find<Connectivity>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final SearchController searchController = Get.find<SearchController>();

  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final MarkAsMailboxReadInteractor _markAsMailboxReadInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final dashBoardAction = Rxn<UIAction>();
  final routePath = AppRoutes.MAILBOX_DASHBOARD.obs;
  final appInformation = Rxn<PackageInfo>();
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final composerOverlayState = ComposerOverlayState.inActive.obs;

  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxId = {};
  Map<MailboxId, PresentationMailbox> mapMailbox = {};
  RouterArguments? routerArguments;
  late StreamSubscription _connectivityStreamSubscription;
  late StreamSubscription _emailReceiveManagerStreamSubscription;

  MailboxDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    this._moveToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._markAsMailboxReadInteractor,
  ) : super(logoutOidcInteractor,
      deleteAuthorityOidcInteractor,
      getAuthenticatedAccountInteractor);

  @override
  void onInit() {
    _registerNetworkConnectivityState();
    _registerPendingEmailAddress();
    super.onInit();
  }

  @override
  void onReady() {
    log('MailboxDashBoardController::onReady()');
    dispatchRoute(AppRoutes.THREAD);
    _setSessionCurrent();
    _getUserProfile();
    _getAppVersion();
    super.onReady();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.map((success) {
      if (success is SendingEmailState) {
        if (currentOverlayContext != null && currentContext != null) {
          _appToast.showToastWithIcon(
              currentOverlayContext!,
              message: AppLocalizations.of(currentContext!).your_email_being_sent,
              icon: _imagePaths.icSendToast);
        }
      }
    });
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
            || failure is UpdateEmailDraftsFailure) {
          clearState();
        }
      },
      (success) {
        if (success is SendEmailSuccess) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.toastSuccessBackgroundColor,
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
        } else if (success is MarkAsMailboxReadAllSuccess) {
          _markAsReadMailboxSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _registerNetworkConnectivityState() async {
    setNetworkConnectivityState(await _connectivity.checkConnectivity());
    _connectivityStreamSubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      log('MailboxDashBoardController::_registerNetworkConnectivityState(): ConnectivityResult: ${result.name}');
      setNetworkConnectivityState(result);
      if (userProfile.value == null && result != ConnectivityResult.none) {
        _getUserProfile();
      }
    });
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

  void _getUserProfile() async {
    userProfile.value = sessionCurrent != null ? UserProfile(sessionCurrent!.username.value) : null;
  }

  void _setSessionCurrent() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_setSessionCurrent(): arguments = $arguments');
    if (arguments is Session) {
      sessionCurrent = arguments;
      accountId.value = sessionCurrent?.accounts.keys.first;
    } else {
      if (kIsWeb) {
        reload();
      }
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('MailboxDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  MailboxId? getMailboxIdByRole(Role role) {
    return mapDefaultMailboxId[role];
  }

  void setMapDefaultMailboxId(Map<Role, MailboxId> newMapMailboxId) {
    mapDefaultMailboxId = newMapMailboxId;
  }

  void setMapMailbox(Map<MailboxId, PresentationMailbox> newMapMailbox) {
    mapMailbox = newMapMailbox;
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.value = newPresentationMailbox;
  }

  void setNewFirstSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.firstRebuild = true;
    selectedMailbox.value = newPresentationMailbox;
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    selectedEmail.value = newPresentationEmail;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
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
    searchController.updateFilterEmail(text: SearchQuery(value));
    dispatchState(Right(SearchEmailNewQuery(searchController.searchEmailFilter.value.text ?? SearchQuery.initial())));
    FocusScope.of(context).unfocus();
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    if (value.isEmpty){
      searchController.disableSearch();
      searchController.setEmailReceiveTimeType(null);
    }
  }

  bool _searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return BuildUtils.isWeb
        && _responsiveUtils.isDesktop(context)
        && routePath.value == AppRoutes.EMAIL;
  }

  void _closeEmailDetailedView() {
    dispatchRoute(AppRoutes.THREAD);
    clearSelectedEmail();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).drafts_saved,
          AppLocalizations.of(currentContext!).discard,
          () => _discardEmail(success.emailAsDrafts),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void moveToMailbox(AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          success.emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: success.destinationPath),
          AppLocalizations.of(currentContext!).undo_action, () {
            _revertedToOriginalMailbox(MoveToMailboxRequest(
                [success.emailId],
                success.destinationMailboxId,
                success.currentMailboxId,
                MoveAction.undo,
                success.emailActionType));
          },
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
    Get.delete<ComposerController>();
    composerOverlayState.value = ComposerOverlayState.inActive;
  }

  void dispatchRoute(String route) {
    routePath.value = route;
    log('MailboxDashBoardController::dispatchRoute(): $route');
  }

  @override
  void handleReloaded(Session session) {
    sessionCurrent = session;
    accountId.value = sessionCurrent?.accounts.keys.first;
    _getUserProfile();
  }

  UnsignedInt? get maxSizeAttachmentsPerEmail {
    if (sessionCurrent != null && accountId.value != null) {
      final mailCapability = sessionCurrent
          ?.accounts[accountId.value]
          ?.accountCapabilities[CapabilityIdentifier.jmapMail];
      if (mailCapability is MailCapability) {
        final maxSizeAttachmentsPerEmail = mailCapability.maxSizeAttachmentsPerEmail;
        log('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): $maxSizeAttachmentsPerEmail');
        return maxSizeAttachmentsPerEmail;
      }
    }
    return null;
  }

  bool filterMessageWithAttachmentIsActive () {
    return filterMessageOption.value == FilterMessageOption.attachments;
  }

  bool filterMessageUnreadIsActive () {
    return filterMessageOption.value == FilterMessageOption.unread;
  }

  bool filterMessageStarredIsActive () {
    return filterMessageOption.value == FilterMessageOption.starred;
  }

  void markAsReadMailboxAction() {
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final mailboxName = selectedMailbox.value?.name;
    if (currentAccountId != null && mailboxId != null && mailboxName != null) {
      markAsReadMailbox(currentAccountId, mailboxId, mailboxName);
    }
  }

  void markAsReadMailbox(AccountId accountId, MailboxId mailboxId, MailboxName mailboxName) {
    consumeState(_markAsMailboxReadInteractor.execute(accountId, mailboxId, mailboxName));
  }

  void _markAsReadMailboxSuccess(MarkAsMailboxReadAllSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!)
              .toastMessageMarkAsMailboxReadSuccess(success.mailboxName.name),
          icon: _imagePaths.icReadToast);
    }
  }

  void goToComposer(ComposerArguments arguments) {
    if (BuildUtils.isWeb) {
      if (composerOverlayState.value == ComposerOverlayState.inActive) {
        openComposerOverlay(arguments);
      }
    } else {
      push(AppRoutes.COMPOSER, arguments: arguments);
    }
  }

  void clearDashBoardAction() {
    dashBoardAction.value = DashBoardAction.idle;
  }

  void goToSettings() {
    if (currentContext != null && (_responsiveUtils.isMobile(currentContext!)
        || _responsiveUtils.isTablet(currentContext!))) {
      closeMailboxMenuDrawer();
    }
    push(AppRoutes.MANAGE_ACCOUNT,
        arguments: ManageAccountArguments(sessionCurrent));
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

  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailReceiveManagerStreamSubscription.cancel();
    _connectivityStreamSubscription.cancel();
    super.onClose();
  }
}