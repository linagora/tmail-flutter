
import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/handle_urgent_exception.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/delegates/add_list_label_to_list_emails_delegate.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/handle_logic_label_extension.dart';
import 'package:tmail_ui_user/features/labels/presentation/mixin/label_sub_menu_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_emails_with_new_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_message.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/websocket/web_socket_queue_handler.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/model/search_email_result.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_email_notifier.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/handle_keyboard_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/mixin/search_label_filter_modal_mixin.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/search/email/presentation/state/search_email_presentation_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_more_action_context_menu_mixin.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/mail_list_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

typedef _SearchFilterMutationAction = void Function(
  SearchFilterNotifier notifier,
);

class SearchEmailController extends BaseController
    with EmailActionController,
        DateRangePickerMixin,
        SearchLabelFilterModalMixin,
        LabelSubMenuMixin,
        EmailMoreActionContextMenu {

  final networkConnectionController = Get.find<NetworkConnectionController>();

  final QuickSearchEmailInteractor _quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;

  final textInputSearchController = TextEditingController();
  final resultSearchScrollController = ScrollController();
  final textInputSearchFocus = FocusNode();
  final listSearchFilterScrollController = ScrollController();

  late Debouncer<String> _deBouncerTime;
  late Worker emailUIActionWorker;
  late Worker dashBoardActionWorker;
  late Worker viewStateWorker;
  WebSocketQueueHandler? _webSocketQueueHandler;
  FocusNode? keyboardFocusNode;
  StreamController<MailListShortcutActionViewEvent>? shortcutActionEventController;
  StreamSubscription<MailListShortcutActionViewEvent>? shortcutActionEventSubscription;
  ProviderSubscription<AsyncValue<SearchEmailResult>>? _searchEmailResultSubscription;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  String get ownEmailAddress => mailboxDashBoardController.ownEmailAddress.value;

  /// Committed search filter from the provider.
  SearchEmailFilter get searchEmailFilter =>
      appProviderContainer.read(searchFilterProvider);

  SearchFilterNotifier get _searchFilterNotifier =>
      appProviderContainer.read(searchFilterProvider.notifier);

  SearchEmailPresentationState get searchEmailPresentationState =>
      appProviderContainer.read(searchEmailPresentationProvider);

  SearchEmailPresentationNotifier get _searchEmailPresentationNotifier =>
      appProviderContainer.read(searchEmailPresentationProvider.notifier);

  String get currentSearchText =>
      searchEmailPresentationState.currentSearchText;

  List<PresentationEmail> get listSuggestionSearch =>
      searchEmailPresentationState.listSuggestionSearch;

  bool get searchIsRunning =>
      searchEmailPresentationState.searchIsRunning;

  SelectMode get selectionMode =>
      searchEmailPresentationState.selectionMode;

  Either<Failure, Success> get resultSearchViewState =>
      searchEmailPresentationState.resultSearchViewState;

  List<PresentationEmail> get listResultSearch =>
      searchEmailPresentationState.listResultSearch;

  SearchMoreState get searchMoreState =>
      searchEmailPresentationState.searchMoreState;

  bool get canSearchMore =>
      searchEmailPresentationState.canSearchMore;

  bool get _isCollapseThreadsEnabled =>
      appProviderContainer.read(localSettingsProvider).threadConfig.isEnabled;

  bool get _hasSearchSession {
    if (accountId == null) return false;

    return session != null;
  }

  SearchEmailController(
      this._quickSearchEmailInteractor,
      this._saveRecentSearchInteractor,
      this._getAllRecentSearchLatestInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    _registerSearchEmailResultBridge();
    _initializeDebounceTimeTextSearchChange();
    _initWorkerListener();
    _initWebSocketQueueHandler();
    onKeyboardShortcutInit();
  }

  @override
  void onReady() async {
    _searchEmailPresentationNotifier.setRecentSearches(
      await getAllRecentSearchAction(),
    );
    textInputSearchFocus.requestFocus();
    _searchEmailPresentationNotifier.resetSearchMore();
    // No WidgetRef in lifecycle; use the container bridge.
    _searchFilterNotifier.setSortOrder(
      mailboxDashBoardController.currentSortOrder,
    );
    super.onReady();
  }

  void _registerSearchEmailResultBridge() {
    if (_searchEmailResultSubscription != null) return;
    _searchEmailResultSubscription =
        appProviderContainer.listen<AsyncValue<SearchEmailResult>>(
      searchEmailProvider,
      (previous, next) => _handleSearchEmailResult(previous, next),
    );
  }

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '');
    _deBouncerTime.values.listen((value) async {
      log('SearchEmailController::_initializeDebounceTimeTextSearchChange(): $value');
      _searchEmailPresentationNotifier.setSuggestionSearchViewState(
        Right(LoadingState()),
      );
      _searchEmailPresentationNotifier.setCurrentSearchText(value);
      // No WidgetRef in debounce stream; use the container bridge.
      _searchFilterNotifier.setText(SearchFilterTextInput(value));
      if (_canLoadSearchSuggestions(value)) {
        final tupleListSuggestion = await Future.wait([
          quickSearchEmails(session: session!, accountId: accountId!),
          mailboxDashBoardController.getContactSuggestion(value)
        ]);
        if (currentSearchText != value) return;

        _searchEmailPresentationNotifier.setSuggestionSearches(
          tupleListSuggestion[0] as List<PresentationEmail>,
        );
        _searchEmailPresentationNotifier.setContactSuggestionSearches(
          tupleListSuggestion[1] as List<EmailAddress>,
        );
      } else {
        _searchEmailPresentationNotifier.clearSuggestionState();
      }
      if (listSuggestionSearch.isEmpty && currentSearchText.isEmpty) {
        final recentSearches = await getAllRecentSearchAction(pattern: value);
        if (currentSearchText != value) return;
        _searchEmailPresentationNotifier.setRecentSearches(
          recentSearches,
        );
      }
      _searchEmailPresentationNotifier.setSuggestionSearchViewState(
        Right(UIState.idle),
      );
    });
  }

  bool _canLoadSearchSuggestions(String value) {
    if (value.isEmpty) return false;

    return _hasSearchSession;
  }

  void onSearchFieldTap() {
    _searchEmailPresentationNotifier.setSearchIsRunning(false);
  }

  void _initWorkerListener() {
    dashBoardActionWorker = ever(
      mailboxDashBoardController.dashBoardAction,
      (action) {
        log('SearchEmailController::_initWorkerListener(): ${action.runtimeType}');
        if (action is CloseSearchEmailViewAction) {
          closeSearchView(context: currentContext);
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is CancelSelectionSearchEmailAction) {
          cancelSelectionMode();
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is SynchronizeEmailSortOrderAction) {
          _searchFilterNotifier.setSortOrder(action.emailSortOrderType);
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is SelectDateRangeToAdvancedSearch) {
          _searchFilterNotifier.update(
            SearchFilterPatch()
              ..emailReceiveTimeTypeOption = Some(action.receiveTime)
              ..startDateOption = optionOf(action.startDate?.toUTCDate())
              ..endDateOption = optionOf(action.endDate?.toUTCDate()),
          );
          mailboxDashBoardController.clearDashBoardAction();
        }
      }
    );

    emailUIActionWorker = ever(
      mailboxDashBoardController.emailUIAction,
      (action) {
        if (action is RefreshChangeEmailAction) {
          _refreshEmailChanges(newState: action.newState);
        }
      },
    );

    viewStateWorker = ever(mailboxDashBoardController.viewState, (viewState) {
      if (!mailboxDashBoardController.searchController.isSearchEmailRunning) return;
      final reactionState = viewState.getOrElse(() => UIState.idle);
      if (reactionState is MoveToMailboxSuccess) {
        mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
        );
      } else if (reactionState is MoveMultipleEmailToMailboxAllSuccess) {
        mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
        );
      } else if (reactionState is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
        mailboxDashBoardController.handleUpdateEmailsWithNewMailboxId(
          originalMailboxIdsWithEmailIds: reactionState.originalMailboxIdsWithMoveSucceededEmailIds,
          destinationMailboxId: reactionState.destinationMailboxId,
        );
      }
    });
  }

  void _refreshEmailChanges({required jmap.State newState}) {
    log('SearchEmailController::_refreshEmailChanges(): newState: $newState');
    if (!_canRefreshEmailChanges(newState)) {
      return;
    }
    log('SearchEmailController::_refreshEmailChanges: websocket enqueue message');
    _webSocketQueueHandler?.enqueue(WebSocketMessage(newState: newState));
  }

  bool _canRefreshEmailChanges(jmap.State newState) {
    final currentEmailState = mailboxDashBoardController.currentEmailState;

    if (!_hasSearchSession) return false;
    if (!searchIsRunning) return false;
    if (currentEmailState == null) return false;

    return currentEmailState != newState;
  }

  void _initWebSocketQueueHandler() {
    _webSocketQueueHandler = WebSocketQueueHandler(
      processMessageCallback: handleWebSocketMessage,
      onErrorCallback: onError,
    );
  }

  @visibleForTesting
  Future<void> handleWebSocketMessage(WebSocketMessage message) async {
    try {
      if (_shouldSkipWebSocketMessage(message)) {
        log('SearchEmailController::handleWebSocketMessage:Skipping redundant state: ${message.newState}');
        return Future.value();
      }

      await appProviderContainer.read(searchEmailProvider.notifier).execute(
        RefreshChangesIntent(currentCount: listResultSearch.length),
        session: session!,
        accountId: accountId!,
        properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
        collapseThreads: _isCollapseThreadsEnabled,
        trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
      );
    } catch (e, stackTrace) {
      logWarning('SearchEmailController::handleWebSocketMessage:Error processing state: $e');
      onError(e, stackTrace);
    } finally {
      if (mailboxDashBoardController.currentEmailState != null) {
        _webSocketQueueHandler?.removeMessagesUpToCurrent(
            mailboxDashBoardController.currentEmailState!.value);
      }
    }
  }

  bool _shouldSkipWebSocketMessage(WebSocketMessage message) {
    final currentEmailState = mailboxDashBoardController.currentEmailState;

    if (currentEmailState == null) return true;

    return currentEmailState == message.newState;
  }

  Future<List<RecentSearch>> getAllRecentSearchAction({String pattern = ''}) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;

    if (accountId == null || userName == null) {
      logWarning('SearchEmailController::getAllRecentSearchAction: accountId or userName is null');
      return <RecentSearch>[];
    }

    return _getAllRecentSearchLatestInteractor
        .execute(accountId, userName, pattern: pattern)
        .then((result) => result.fold(
          (failure) => <RecentSearch>[],
          (success) => success is GetAllRecentSearchLatestSuccess
            ? success.listRecentSearch
            : <RecentSearch>[]));
  }

  Future<List<PresentationEmail>> quickSearchEmails({
    required AccountId accountId,
    required Session session,
  }) async {
    return _quickSearchEmailInteractor
        .execute(
          session,
          accountId,
          limit: UnsignedInt(5),
          sort: searchEmailFilter.sortOrderType.getSortOrder().toNullable(),
          filter: searchEmailFilter.mappingToEmailFilterCondition(
            trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
          ),
          properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId),
          collapseThreads: _isCollapseThreadsEnabled,
        )
        .then((result) => result.fold(
            (failure) => <PresentationEmail>[],
            (success) => success is QuickSearchEmailSuccess
                ? success.emailList
                : <PresentationEmail>[]));
  }

  void saveRecentSearch(String queryString) {
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;

    if (accountId == null || userName == null) {
      logWarning('SearchEmailController::_saveRecentSearch: accountId or userName is null');
      return;
    }

    consumeState(_saveRecentSearchInteractor.execute(
      accountId,
      userName,
      RecentSearch.now(queryString),
    ));
  }

  void searchEmailAction() => _searchEmailAction();

  /// Bridges executor results into mobile presentation state.
  void _handleSearchEmailResult(
    AsyncValue<SearchEmailResult>? previous,
    AsyncValue<SearchEmailResult> value,
  ) {
    if (value.isLoading) {
      _searchEmailPresentationNotifier.setResultSearchViewState(
        Right(SearchingState()),
      );
      return;
    }
    if (value.hasError) {
      // Handle urgent failures before retry UI.
      if (!_handleUrgentSearchException(value.error)) {
        _searchEmailsFailure(_asSearchEmailFailure(value.error));
      }
      return;
    }
    final result = value.value;
    if (result == null) return;
    _applySearchResult(result, shouldScrollToTop: previous?.isLoading == true);
  }

  /// Routes urgent exceptions; true means handled.
  bool _handleUrgentSearchException(Object? error) {
    if (error == null) return false;
    return error is Failure
        ? handleUrgentExceptionIfNeeded(failure: error)
        : handleUrgentExceptionIfNeeded(exception: error);
  }

  SearchEmailFailure _asSearchEmailFailure(Object? error) {
    if (error is SearchEmailFailure) return error;
    if (error is FeatureFailure) return SearchEmailFailure(error.exception);
    return SearchEmailFailure(error);
  }

  void _searchEmailAction() {
    textInputSearchFocus.unfocus();

    if (session == null || accountId == null) {
      _searchEmailsFailure(SearchEmailFailure(NotFoundSessionException()));
      return;
    }

    _searchEmailPresentationNotifier.setResultSearchViewState(
      Right(SearchingState()),
    );
    _searchEmailPresentationNotifier.resetSearchMore();
    _searchEmailPresentationNotifier.setSearchIsRunning(true);
    cancelSelectionMode();
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: 'SearchEmail',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            searchQuery: searchEmailFilter.text,
            dashboardType: DashboardType.search
          )
        )
      );
    }

    appProviderContainer.read(searchEmailProvider.notifier).execute(
      const NewSearchIntent(),
      session: session!,
      accountId: accountId!,
      properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
      collapseThreads: _isCollapseThreadsEnabled,
      trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
    );
  }

  void _applySearchResult(
    SearchEmailResult result, {
    required bool shouldScrollToTop,
  }) {
    final resultEmailSearchList = result.emails
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsBeforeChanges = listResultSearch;
    final emailsAfterChanges = resultEmailSearchList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);

    _searchEmailPresentationNotifier.setResultSearches(newListEmail.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      searchQuery: searchEmailFilter.text,
      isSearchEmailRunning: true
    ));

    _searchEmailPresentationNotifier.setResultSearchViewState(
      Right(SearchEmailSuccess(result.emails)),
    );
    _searchEmailPresentationNotifier.setCanSearchMore(result.canLoadMore);
    _updateSearchMoreState(result.loadMore);
    _handleLoadMoreFailureIfNeeded(result);

    if (shouldScrollToTop && resultSearchScrollController.hasClients) {
      resultSearchScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }

    if (shouldScrollToTop && PlatformInfo.isWeb) {
      refocusMailShortcutFocus();
    }
  }

  void _updateSearchMoreState(LoadMoreState loadMoreState) {
    switch (loadMoreState) {
      case LoadMoreState.inProgress:
        _searchEmailPresentationNotifier.setSearchMoreState(
          SearchMoreState.waiting,
        );
        break;
      case LoadMoreState.failure:
      case LoadMoreState.idle:
        _searchEmailPresentationNotifier.setSearchMoreState(
          SearchMoreState.completed,
        );
        break;
    }
  }

  /// Routes urgent load-more failures without clearing the list.
  void _handleLoadMoreFailureIfNeeded(SearchEmailResult result) {
    if (result.loadMore != LoadMoreState.failure) return;
    _handleUrgentSearchException(result.loadMoreException);
  }

  void _searchEmailsFailure(SearchEmailFailure failure) {
    _searchEmailPresentationNotifier.clearResultSearches();
    _searchEmailPresentationNotifier.setResultSearchViewState(Left(failure));
    showRetryToast(failure);
  }

  void searchMoreEmailsAction() {
    if (!_canSearchMoreEmails) return;

    final lastEmail = listResultSearch.last;

    appProviderContainer.read(searchEmailProvider.notifier).execute(
      LoadMoreIntent(
        currentCount: listResultSearch.length,
        lastEmailDate: lastEmail.receivedAt,
        lastEmailId: lastEmail.id,
      ),
      session: session!,
      accountId: accountId!,
      properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
      collapseThreads: _isCollapseThreadsEnabled,
      trashSpamMailboxIds: mailboxDashBoardController.trashSpamMailboxIds,
    );
  }

  bool get _canSearchMoreEmails {
    if (!_hasSearchSession) return false;
    if (!canSearchMore) return false;

    return listResultSearch.isNotEmpty;
  }

  void showAllResultSearchAction(
    WidgetRef ref,
    BuildContext context,
    String queryString,
  ) {
    setTextInputSearchForm(queryString);
    _searchEmailByQueryString(ref, context: context, queryString: queryString);
  }

  void searchEmailByRecentAction(
    WidgetRef ref,
    BuildContext context,
    RecentSearch recentSearch,
  ) {
    setTextInputSearchForm(recentSearch.value);
    _searchEmailByQueryString(
      ref,
      context: context,
      queryString: recentSearch.value,
    );
  }

  void searchEmailByEmailAddressAction(
    WidgetRef ref,
    EmailAddress emailAddress,
  ) {
    textInputSearchController.clear();
    _searchEmailPresentationNotifier.setCurrentSearchText('');
    _mutateSearchFilterAndSearch(ref, (notifier) => notifier.update(
          SearchFilterPatch()
            ..textOption = const None()
            ..fromOption = Some({emailAddress.emailAddress}),
        ));
  }

  void _searchEmailByQueryString(
    WidgetRef ref, {
    required BuildContext context,
    required String queryString,
  }) {
    log('SearchEmailController::_searchEmailByQueryString:QueryString = $queryString');
    _searchEmailPresentationNotifier.setResultSearchViewState(
      Right(SearchingState()),
    );
    _searchEmailPresentationNotifier.clearRecentSearches();
    _searchEmailPresentationNotifier.clearSuggestionSearches();
    _searchEmailPresentationNotifier.clearResultSearches();
    _searchEmailPresentationNotifier.setSearchIsRunning(false);
    final isMailAddress = EmailUtils.isEmailAddressValid(queryString);
    if (isMailAddress) {
      searchEmailByEmailAddressAction(ref, EmailAddress(null, queryString));
    } else {
      _searchEmailPresentationNotifier.setCurrentSearchText(queryString);
      _mutateSearchFilterAndSearch(
        ref,
        (notifier) => notifier.setText(SearchFilterTextInput(queryString)),
      );
    }
  }

  void selectHasAttachmentSearchFilter(WidgetRef ref) {
    _mutateSearchFilterAndSearch(
      ref,
      (notifier) => notifier.setHasAttachment(SearchFilterToggle.selected),
    );
  }

  void selectKeywordsSearchFilter(WidgetRef ref, KeyWordIdentifier keyword) {
    _mutateSearchFilterAndSearch(ref, (notifier) => notifier.setHasKeywords(
          SearchFilterKeywordSet({...searchEmailFilter.hasKeyword, keyword.value}),
        ));
  }

  void selectUnreadSearchFilter(WidgetRef ref) {
    _mutateSearchFilterAndSearch(
      ref,
      (notifier) => notifier.setUnread(SearchFilterToggle.selected),
    );
  }

  void selectNotIncludeEventsSearchFilter(WidgetRef ref) {
    _mutateSearchFilterAndSearch(
      ref,
      (notifier) =>
          notifier.setNotIncludeEvents(SearchFilterToggle.selected),
    );
  }

  bool checkQuickSearchFilterSelected(QuickSearchFilter filter) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        return searchEmailFilter.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        return true;
      case QuickSearchFilter.sortBy:
        return true;
      default:
        return false;
    }
  }

  void selectReceiveTimeQuickSearchFilter(
    WidgetRef ref,
    BuildContext context,
    EmailReceiveTimeType emailReceiveTimeType,
  ) {
    if (emailReceiveTimeType == EmailReceiveTimeType.customRange) {
      showMultipleViewDateRangePicker(
        context,
        searchEmailFilter.startDate?.value.toLocal(),
        searchEmailFilter.endDate?.value.toLocal(),
        onCallbackAction: (newStartDate, newEndDate) {
          _applyReceiveTimeFilter(
            ref,
            emailReceiveTimeType,
            newStartDate?.toUTCDate(),
            newEndDate?.toUTCDate(),
          );
        },
      );
    } else {
      final dateRange = emailReceiveTimeType.toDateRange();
      _applyReceiveTimeFilter(
        ref,
        emailReceiveTimeType,
        dateRange.start,
        dateRange.end,
      );
    }
  }

  void _applyReceiveTimeFilter(
    WidgetRef ref,
    EmailReceiveTimeType receiveTimeType,
    UTCDate? startDate,
    UTCDate? endDate,
  ) {
    _mutateSearchFilterAndSearch(ref, (notifier) => notifier.update(
          SearchFilterPatch()
            ..emailReceiveTimeTypeOption = Some(receiveTimeType)
            ..startDateOption = optionOf(startDate)
            ..endDateOption = optionOf(endDate),
        ));
  }

  void selectSortOrderQuickSearchFilter(
    WidgetRef ref,
    EmailSortOrderType sortOrderType,
  ) {
    _mutateSearchFilterAndSearch(ref, (notifier) {
      notifier.setSortOrder(sortOrderType);
      mailboxDashBoardController.storeEmailSortOrder(sortOrderType);
    });
  }

  void selectMailboxForSearchFilter(
    WidgetRef ref,
    PresentationMailbox? mailbox,
  ) async {
    final arguments = DestinationPickerArguments(
      mailboxDashBoardController.accountId.value!,
      MailboxActions.select,
      mailboxDashBoardController.sessionCurrent,
      mailboxIdSelected: mailbox?.id);

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;
    // Ignore picker result after view disposal.
    if (!ref.context.mounted) return;

    _mutateSearchFilterAndSearch(
      ref,
      (notifier) => notifier.setMailbox(destinationMailbox),
    );
  }

  Future<void> selectContactForSearchFilter(
      WidgetRef ref,
      BuildContext context,
      PrefixEmailAddress prefixEmailAddress
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (accountId == null || session == null) return;

    final selectedContactList = searchEmailFilter.getContactApplied(prefixEmailAddress);
    final arguments = ContactArguments(
      accountId: accountId!,
      session: session!,
      selectedContactList: selectedContactList,
      contactViewTitle: '${AppLocalizations.of(context).findEmails} ${prefixEmailAddress.asName(context).toLowerCase()}'
    );

    final newListContact = await push(AppRoutes.contact, arguments: arguments);

    if (newListContact is List<EmailAddress> && context.mounted) {
      final listMailAddress = newListContact
        .map((emailAddress) => emailAddress.emailAddress)
        .toSet();

      _dispatchApplyContactAction(ref, listMailAddress, prefixEmailAddress);
    }
  }

  void _dispatchApplyContactAction(
      WidgetRef ref,
      Set<String> listContactSelected,
      PrefixEmailAddress prefixEmailAddress,
  ) {
    _mutateSearchFilterAndSearch(ref, (notifier) {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.from:
          notifier.setSenders(SearchFilterEmailSet(listContactSelected));
          break;
        case PrefixEmailAddress.to:
          notifier.setRecipients(SearchFilterEmailSet(listContactSelected));
          break;
        default:
          break;
      }
    });
  }

  void onSelectLabelFilter(WidgetRef ref, Label? newLabel) {
    _mutateSearchFilterAndSearch(
      ref,
      (notifier) => notifier.toggleLabel(newLabel),
    );
  }

  void _mutateSearchFilterAndSearch(
    WidgetRef ref,
    _SearchFilterMutationAction mutation,
  ) {
    mutation(ref.read(searchFilterProvider.notifier));
    _searchEmailAction();
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onTextSearchSubmitted(WidgetRef ref, BuildContext context, String text) {
    final queryString = text.trim();
    if (queryString.isNotEmpty) {
      saveRecentSearch(queryString);
    }
    _searchEmailByQueryString(
      ref,
      context: context,
      queryString: queryString,
    );
  }

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void clearAllTextInputSearchForm({bool requestFocus = false}) {
    textInputSearchController.clear();
    _searchEmailPresentationNotifier.clearAllTextInputSearchState();
    if (requestFocus) {
      textInputSearchFocus.requestFocus();
    } else {
      textInputSearchFocus.unfocus();
    }
  }

  void clearAllResultSearch() {
    _searchEmailPresentationNotifier.clearAllResultSearchState();
    _searchFilterNotifier.set(
      SearchEmailFilter.withSortOrder(mailboxDashBoardController.currentSortOrder),
    );
  }

  void closeSearchView({BuildContext? context}) {
    clearAllTextInputSearchForm();
    clearAllResultSearch();
    mailboxDashBoardController.searchController.disableAllSearchEmail();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    if (PlatformInfo.isWeb) {
      final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
      RouteUtils.replaceBrowserHistory(
        title: currentMailbox?.browserRouteTitle ?? '',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: currentMailbox?.browserRouteMailboxId,
            labelId: currentMailbox?.labelId,
            dashboardType: DashboardType.normal
          )
        )
      );
    }
    SearchEmailBindings().disposeBindings();
  }

  void pressEmailAction(
      EmailActionType actionType,
      PresentationEmail selectedEmail,
      PresentationMailbox? mailboxContain,
  ) {
    switch(actionType) {
      case EmailActionType.preview:
        if (mailboxContain?.isDrafts == true) {
          editDraftEmail(
            presentationEmail: selectedEmail,
            draftMailboxId: mailboxContain!.id,
          );
        } else {
          previewEmail(selectedEmail);
        }
        break;
      case EmailActionType.selection:
        selectEmail(selectedEmail);
        break;
      case EmailActionType.markAsRead:
        markAsEmailRead(selectedEmail, ReadActions.markAsRead, MarkReadAction.tap);
        break;
      case EmailActionType.markAsUnread:
        markAsEmailRead(selectedEmail, ReadActions.markAsUnread, MarkReadAction.tap);
        break;
      case EmailActionType.markAsStarred:
        markAsStarEmail(selectedEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        markAsStarEmail(selectedEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        moveToMailbox(selectedEmail, mailboxContain: mailboxContain);
        break;
      case EmailActionType.moveToTrash:
        moveToTrash(selectedEmail, mailboxContain: mailboxContain);
        break;
      case EmailActionType.deletePermanently:
        if (currentContext != null) {
          deleteEmailPermanently(currentContext!, selectedEmail);
        } else {
          logWarning('SearchEmailController.pressEmailAction: currentContext is null');
        }
        break;
      case EmailActionType.moveToSpam:
        moveToSpam(selectedEmail, mailboxContain: mailboxContain);
        break;
      case EmailActionType.unSpam:
        unSpam(selectedEmail);
        break;
      case EmailActionType.editAsNewEmail:
        editAsNewEmail(selectedEmail);
        break;
      default:
        break;
    }
  }

  void selectEmail(PresentationEmail presentationEmailSelected) {
    _searchEmailPresentationNotifier.updateResultSearches(
      (current) => current
          .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
          .toList(),
    );

    if (listResultSearch.isAllSelectionInActive) {
      _searchEmailPresentationNotifier.setSelectionMode(SelectMode.INACTIVE);
    } else {
      if (selectionMode == SelectMode.INACTIVE) {
        _searchEmailPresentationNotifier.setSelectionMode(SelectMode.ACTIVE);
      }
    }

    if (PlatformInfo.isWeb) {
      refocusMailShortcutFocus();
    }
  }

  void cancelSelectionMode() {
    _searchEmailPresentationNotifier.updateResultSearches(
      (current) => current
          .map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE))
          .toList(),
    );
    _searchEmailPresentationNotifier.setSelectionMode(SelectMode.INACTIVE);
    if (PlatformInfo.isWeb) {
      clearMailShortcutFocus();
    }
  }

  void setSelectAllEmailAction() {
    _searchEmailPresentationNotifier.updateResultSearches(
      (current) => current
          .map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE))
          .toList(),
    );
    _searchEmailPresentationNotifier.setSelectionMode(SelectMode.ACTIVE);
  }

  void handleSelectionEmailAction(
      EmailActionType actionType,
      List<PresentationEmail> listEmails
  ) {
    switch(actionType) {
      case EmailActionType.markAsRead:
        cancelSelectionMode();
        markAsReadSelectedMultipleEmail(listEmails, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        cancelSelectionMode();
        markAsReadSelectedMultipleEmail(listEmails, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        cancelSelectionMode();
        markAsStarSelectedMultipleEmail(listEmails, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        cancelSelectionMode();
        markAsStarSelectedMultipleEmail(listEmails, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        moveEmailsToMailbox(listEmails, onCallbackAction: cancelSelectionMode);
        break;
      case EmailActionType.moveToTrash:
        cancelSelectionMode();
        moveEmailsToTrash(listEmails);
        break;
      case EmailActionType.deletePermanently:
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null && currentContext != null) {
          deleteSelectionEmailsPermanently(
              currentContext!,
              DeleteActionType.multiple,
              listEmails: listEmails,
              mailboxCurrent: mailboxContainCurrent,
              onCancelSelectionEmail: () => cancelSelectionMode());
        }
        break;
      case EmailActionType.moveToSpam:
        cancelSelectionMode();
        moveEmailsToSpam(listEmails);
        break;
      case EmailActionType.unSpam:
        cancelSelectionMode();
        unSpamSelectedMultipleEmail(listEmails);
        break;
      case EmailActionType.labelAs:
        Get.find<AddListLabelToListEmailsDelegate>().openChooseLabelModal(
          selectedEmails: listEmails,
          imagePaths: imagePaths,
          onCancel: cancelSelectionMode,
          onSync: mailboxDashBoardController.syncListLabelForListEmail,
        );
        break;
      default:
        break;
    }
  }

  Map<QuickSearchFilter, _SearchFilterMutationAction> get _deleteSearchFilterActions =>
      <QuickSearchFilter, _SearchFilterMutationAction>{
        QuickSearchFilter.dateTime: _resetReceiveTimeSearchFilter,
        QuickSearchFilter.last7Days: _resetReceiveTimeSearchFilter,
        QuickSearchFilter.sortBy: _resetSortOrderSearchFilter,
        QuickSearchFilter.from: _clearSenderSearchFilter,
        QuickSearchFilter.fromMe: _clearSenderSearchFilter,
        QuickSearchFilter.hasAttachment: _clearHasAttachmentSearchFilter,
        QuickSearchFilter.to: _clearRecipientSearchFilter,
        QuickSearchFilter.folder: _clearMailboxSearchFilter,
        QuickSearchFilter.starred: _clearStarredSearchFilter,
        QuickSearchFilter.unread: _clearUnreadSearchFilter,
        QuickSearchFilter.events: _clearNotIncludeEventsSearchFilter,
        QuickSearchFilter.labels: _clearLabelSearchFilter,
      };

  void onDeleteSearchFilterAction(
    WidgetRef ref,
    QuickSearchFilter searchFilter
  ) {
    _mutateSearchFilterAndSearch(
      ref,
      _deleteSearchFilterActions[searchFilter]!,
    );
  }

  void _resetReceiveTimeSearchFilter(SearchFilterNotifier notifier) {
    notifier.resetReceiveTime();
  }

  void _resetSortOrderSearchFilter(SearchFilterNotifier notifier) {
    notifier.setSortOrder(SearchEmailFilter.defaultSortOrder);
    mailboxDashBoardController.storeEmailSortOrder(
      SearchEmailFilter.defaultSortOrder,
    );
  }

  void _clearSenderSearchFilter(SearchFilterNotifier notifier) {
    notifier.setSenders(const SearchFilterEmailSet(<String>{}));
  }

  void _clearHasAttachmentSearchFilter(SearchFilterNotifier notifier) {
    notifier.setHasAttachment(SearchFilterToggle.unselected);
  }

  void _clearRecipientSearchFilter(SearchFilterNotifier notifier) {
    notifier.setRecipients(const SearchFilterEmailSet(<String>{}));
  }

  void _clearMailboxSearchFilter(SearchFilterNotifier notifier) {
    notifier.setMailbox(null);
  }

  void _clearStarredSearchFilter(SearchFilterNotifier notifier) {
    notifier.toggleStarred(SearchFilterToggle.unselected);
  }

  void _clearUnreadSearchFilter(SearchFilterNotifier notifier) {
    notifier.setUnread(SearchFilterToggle.unselected);
  }

  void _clearNotIncludeEventsSearchFilter(SearchFilterNotifier notifier) {
    notifier.setNotIncludeEvents(SearchFilterToggle.unselected);
  }

  void _clearLabelSearchFilter(SearchFilterNotifier notifier) {
    notifier.clearLabel();
  }

  void clearAllSearchFilterApplied() {
    textInputSearchController.clear();
    _searchEmailPresentationNotifier.clearAllSearchFilterAppliedState();
    _searchFilterNotifier.set(
      SearchEmailFilter.withSortOrder(mailboxDashBoardController.currentSortOrder),
    );
    _searchEmailAction();
  }

  @override
  void onClose() {
    textInputSearchController.dispose();
    textInputSearchFocus.dispose();
    resultSearchScrollController.dispose();
    listSearchFilterScrollController.dispose();
    _deBouncerTime.cancel();
    emailUIActionWorker.dispose();
    dashBoardActionWorker.dispose();
    viewStateWorker.dispose();
    _searchEmailResultSubscription?.close();
    _webSocketQueueHandler?.dispose();
    onKeyboardShortcutDispose();
    // Release keepAlive search state with the binding.
    appProviderContainer.invalidate(searchEmailPresentationProvider);
    appProviderContainer.invalidate(searchEmailProvider);
    super.onClose();
  }
}
