import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/presentation/email_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxDashBoardController extends BaseController {

  final GetUserProfileInteractor _getUserProfileInteractor;
  final AppToast _appToast;
  final ImagePaths _imagePaths;
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final searchState = SearchState.initial().obs;
  final suggestionSearch = <String>[].obs;

  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  SearchQuery? searchQuery;
  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxId = Map();
  Map<MailboxId, PresentationMailbox> mapMailbox = Map();

  MailboxDashBoardController(
      this._getUserProfileInteractor,
      this._appToast,
      this._imagePaths,
      this._removeEmailDraftsInteractor,
  );

  @override
  void onReady() {
    super.onReady();
    _setSessionCurrent();
    _getUserProfile();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.map((success) {
      if (success is SendingEmailState) {
        if (Get.overlayContext != null && Get.context != null) {
          _appToast.showToastWithIcon(
              Get.overlayContext!,
              message: AppLocalizations.of(Get.context!).your_email_being_sent,
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
          if (Get.overlayContext != null && Get.context != null) {
            _appToast.showToastWithIcon(
                Get.overlayContext!,
                textColor: AppColor.toastErrorBackgroundColor,
                message: AppLocalizations.of(Get.context!).message_has_been_sent_failure,
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
          if (Get.overlayContext != null && Get.context != null) {
            _appToast.showToastWithIcon(
                Get.overlayContext!,
                textColor: AppColor.toastSuccessBackgroundColor,
                message: AppLocalizations.of(Get.context!).message_has_been_sent_successfully,
                icon: _imagePaths.icSendToast);
          }
          clearState();
        } else if (success is SaveEmailAsDraftsSuccess) {
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
      if (arguments is Session) {
        sessionCurrent = Get.arguments as Session;
        accountId.value = sessionCurrent?.accounts.keys.first;
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

  bool isSearchActive() {
    return searchState.value.searchStatus == SearchStatus.ACTIVE;
  }

  void enableSearch() {
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch() {
    searchState.value = searchState.value.disableSearchState();
    searchQuery = SearchQuery('');
    clearSuggestionSearch();
    searchInputController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void clearSearchText() {
    searchQuery = SearchQuery('');
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

  void searchEmail(String value) {
    searchQuery = SearchQuery(value);
    dispatchState(Right(SearchEmailNewQuery(searchQuery ?? SearchQuery(''))));
    clearSuggestionSearch();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (Get.context != null && Get.overlayContext != null) {
      _appToast.showToastWithAction(
          Get.overlayContext!,
          AppLocalizations.of(Get.context!).drafts_saved,
          AppLocalizations.of(Get.context!).discard,
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

  @override
  void onClose() {
    searchInputController.dispose();
    Get.delete<EmailController>();
    super.onClose();
  }
}