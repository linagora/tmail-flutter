import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_action.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';

class MailboxDashBoardController extends ReloadableController {

  final GetUserProfileInteractor _getUserProfileInteractor = Get.find<GetUserProfileInteractor>();
  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final DeleteCredentialInteractor _deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final CachingManager _cachingManager = Get.find<CachingManager>();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final searchState = SearchState.initial().obs;
  final suggestionSearch = <String>[].obs;
  final dashBoardAction = DashBoardAction.none.obs;
  final routePath = AppRoutes.MAILBOX_DASHBOARD.obs;

  SearchQuery? searchQuery;
  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxId = Map();
  Map<MailboxId, PresentationMailbox> mapMailbox = Map();
  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  RouterArguments? routerArguments;

  MailboxDashBoardController();

  @override
  void onReady() {
    super.onReady();
    log('MailboxDashBoardController::onReady()');
    dispatchRoute(AppRoutes.THREAD);
    _setSessionCurrent();
    _getUserProfile();
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
        if (success is GetUserProfileSuccess) {
          userProfile.value = success.userProfile;
        } else if (success is SendEmailSuccess) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.toastSuccessBackgroundColor,
                message: AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
                icon: _imagePaths.icSendToast);
          }
          clearState();
        } else if (success is SaveEmailAsDraftsSuccess) {
          log('MailboxDashBoardController::onDone(): SaveEmailAsDraftsSuccess');
          _saveEmailAsDraftsSuccess(success);
          clearState();
        } else if (success is RemoveEmailDraftsSuccess
          || success is UpdateEmailDraftsSuccess) {
          clearState();
        }
      }
    );
  }

  @override
  void onError(error) {
  }

  void _getUserProfile() async {
    consumeState(_getUserProfileInteractor.execute());
  }

  void _setSessionCurrent() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final arguments = Get.arguments;
      log('MailboxDashBoardController::_setSessionCurrent(): arguments = $arguments');
      if (arguments is Session) {
        sessionCurrent = Get.arguments as Session;
        accountId.value = sessionCurrent?.accounts.keys.first;
      } else {
        if (kIsWeb) {
          reload();
        }
      }
    });
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

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  bool get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen == true;

  bool isSearchActive() {
    return searchState.value.searchStatus == SearchStatus.ACTIVE;
  }

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch() {
    searchState.value = searchState.value.disableSearchState();
    searchQuery = SearchQuery.initial();
    clearSuggestionSearch();
    searchInputController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clearSearchText() {
    searchQuery = SearchQuery.initial();
    clearSuggestionSearch();
    searchFocus.requestFocus();
  }

  void clearSuggestionSearch() {
    suggestionSearch.clear();
  }

  void addSuggestionSearch(String query) {
    if (query.trim().isNotEmpty) {
      suggestionSearch.value = [query];
    } else {
      clearSearchText();
    }
  }

  void searchEmail(BuildContext context, String value) {
    searchQuery = SearchQuery(value);
    dispatchState(Right(SearchEmailNewQuery(searchQuery ?? SearchQuery.initial())));
    clearSuggestionSearch();
    FocusScope.of(context).unfocus();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).drafts_saved,
          AppLocalizations.of(currentContext!).discard,
          () => _discardEmail(success.emailAsDrafts)
      );
    }
  }

  void _discardEmail(Email email) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_removeEmailDraftsInteractor.execute(currentAccountId, email.id));
    }
  }

  void dispatchDashBoardAction(DashBoardAction action, {RouterArguments? arguments}) {
    switch(action) {
      case DashBoardAction.none:
        routerArguments = null;
        Get.delete<ComposerController>();
        break;
      case DashBoardAction.compose:
        routerArguments = arguments;
        ComposerBindings().dependencies();
        break;
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

  void composeEmailAction() {
    if (kIsWeb) {
      if (dashBoardAction != DashBoardAction.compose) {
        dispatchDashBoardAction(DashBoardAction.compose, arguments: ComposerArguments());
      }
    } else {
      push(AppRoutes.COMPOSER, arguments: ComposerArguments());
    }
  }

  void _deleteCredential() async {
    await _deleteCredentialInteractor.execute();
  }

  void _clearAllCache() async {
    await _cachingManager.clearAll();
  }

  void logoutAction() {
    _deleteCredential();
    if (!kIsWeb) _clearAllCache();
    pushAndPopAll(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }
}