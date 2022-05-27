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
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class MailboxDashBoardController extends ReloadableController {

  final GetUserProfileInteractor _getUserProfileInteractor = Get.find<GetUserProfileInteractor>();
  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final Connectivity _connectivity = Get.find<Connectivity>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();

  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;
  final QuickSearchEmailInteractor _quickSearchEmailInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final searchState = SearchState.initial().obs;
  final dashBoardAction = Rxn<UIAction>();
  final routePath = AppRoutes.MAILBOX_DASHBOARD.obs;
  final appInformation = Rxn<PackageInfo>();
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final listFilterQuickSearch = RxList<QuickSearchFilter>();
  final emailReceiveTimeType = Rxn<EmailReceiveTimeType>();

  SearchQuery? searchQuery;
  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxId = {};
  Map<MailboxId, PresentationMailbox> mapMailbox = {};
  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  RouterArguments? routerArguments;
  late StreamSubscription _connectivityStreamSubscription;
  late StreamSubscription _emailReceiveManagerStreamSubscription;

  MailboxDashBoardController(
    this._moveToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._saveRecentSearchInteractor,
    this._getAllRecentSearchLatestInteractor,
    this._quickSearchEmailInteractor,
  );

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

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch() {
    searchState.value = searchState.value.disableSearchState();
    searchQuery = SearchQuery.initial();
    searchInputController.clear();
    listFilterQuickSearch.clear();
    emailReceiveTimeType.value = null;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clearTextSearch() {
    searchQuery = SearchQuery.initial();
    searchInputController.clear();
    searchFocus.requestFocus();
  }

  void updateTextSearch(String value) {
    searchInputController.text = value;
  }

  void searchEmail(BuildContext context, String value) {
    searchQuery = SearchQuery(value);
    dispatchState(Right(SearchEmailNewQuery(searchQuery ?? SearchQuery.initial())));
    FocusScope.of(context).unfocus();
    if (searchInsideEmailDetailedViewIsActive(context)) {
      closeEmailDetailedView();
    }
  }

  bool searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return BuildUtils.isWeb
        && _responsiveUtils.isDesktop(context)
        && routePath.value == AppRoutes.EMAIL;
  }

  void closeEmailDetailedView() {
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
    if (action is ComposeEmailAction) {
      routerArguments = action.arguments;
      ComposerBindings().dependencies();
    } else if (action is CloseComposeEmailAction) {
      routerArguments = null;
      Get.delete<ComposerController>();
    }
    dashBoardAction.value = action;
  }

  void dispatchRoute(String route) {
    routePath.value = route;
    log('MailboxDashBoardController::dispatchRoute(): $route');
  }

  @override
  void handleReloaded(Session session) {
    sessionCurrent = session;
    accountId.value = sessionCurrent?.accounts.keys.first;
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

  void saveRecentSearch(RecentSearch recentSearch) {
    consumeState(_saveRecentSearchInteractor.execute(recentSearch));
  }

  Future<List<RecentSearch>> getAllRecentSearchAction(String pattern) async {
    return await _getAllRecentSearchLatestInteractor.execute(pattern: pattern)
        .then((result) => result.fold(
            (failure) => <RecentSearch>[],
            (success) => success is GetAllRecentSearchLatestSuccess
                ? success.listRecentSearch
                : <RecentSearch>[]));
  }

  Future<List<PresentationEmail>> quickSearchEmailsAction(String pattern) async {
    if (accountId.value != null && selectedMailbox.value != null) {
      return await _quickSearchEmailInteractor.execute(
        accountId.value!,
        limit: UnsignedInt(5),
        sort: <Comparator>{}
          ..add(EmailComparator(EmailComparatorProperty.receivedAt)
            ..setIsAscending(false)),
        filter: EmailFilterCondition(
            text: pattern,
            hasAttachment: listFilterQuickSearch.contains(QuickSearchFilter.hasAttachment) ? true : null,
            from: listFilterQuickSearch.contains(QuickSearchFilter.fromMe) ? userProfile.value!.email : null,
            after: listFilterQuickSearch.contains(QuickSearchFilter.last7Days)
                ? UTCDate(DateTime.now().subtract(const Duration(days: 7)))
                : null,
            inMailbox: selectedMailbox.value!.id),
        properties: ThreadConstants.propertiesQuickSearch
      ).then((result) => result.fold(
          (failure) => <PresentationEmail>[],
          (success) => success is QuickSearchEmailSuccess ? success.emailList : <PresentationEmail>[]));
    }
    return <PresentationEmail>[];
  }

  void selectQuickSearchFilter(QuickSearchFilter quickSearchFilter, {bool fromSuggestionBox = false}) {
    if (listFilterQuickSearch.contains(quickSearchFilter)) {
      listFilterQuickSearch.remove(quickSearchFilter);
      if (fromSuggestionBox && quickSearchFilter == QuickSearchFilter.last7Days) {
        setEmailReceiveTimeType(null);
      }
    } else {
      listFilterQuickSearch.add(quickSearchFilter);
      if (fromSuggestionBox && quickSearchFilter == QuickSearchFilter.last7Days) {
        setEmailReceiveTimeType(EmailReceiveTimeType.last7Days);
      }
    }
  }

  void setEmailReceiveTimeType(EmailReceiveTimeType? receiveTimeType) {
    emailReceiveTimeType.value = receiveTimeType;
  }

  bool quickSearchFilterForLast7DaysIsActive () {
    return listFilterQuickSearch.contains(QuickSearchFilter.last7Days)
        && emailReceiveTimeType.value != null;
  }

  bool quickSearchFilterForHasAttachmentIsActive () {
    return listFilterQuickSearch.contains(QuickSearchFilter.hasAttachment)
        || filterMessageOption.value == FilterMessageOption.attachments;
  }

  bool quickSearchFilterForFromMeIsActive () {
    return listFilterQuickSearch.contains(QuickSearchFilter.fromMe);
  }

  bool filterForHasAttachmentIsActive () {
    return quickSearchFilterForHasAttachmentIsActive() || filterMessageWithAttachmentIsActive();
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

  void composeEmailAction() {
    if (kIsWeb) {
      if (dashBoardAction.value is! ComposeEmailAction) {
        dispatchAction(ComposeEmailAction(arguments: ComposerArguments()));
      }
    } else {
      push(AppRoutes.COMPOSER, arguments: ComposerArguments());
    }
  }

  void goToComposer(ComposerArguments arguments) {
    if (kIsWeb) {
      if (dashBoardAction.value is! ComposeEmailAction) {
        dispatchAction(ComposeEmailAction(arguments: arguments));
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

  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailReceiveManagerStreamSubscription.cancel();
    _connectivityStreamSubscription.cancel();
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}