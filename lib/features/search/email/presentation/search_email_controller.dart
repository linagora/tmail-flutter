
import 'dart:async';

import 'package:core/presentation/extensions/either_view_state_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
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
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/prefix_email_address_extension.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
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
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/handle_keyboard_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/extension/update_search_filter_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/mixin/search_label_filter_modal_mixin.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/mail_list_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class SearchEmailController extends BaseController
    with EmailActionController,
        DateRangePickerMixin,
        SearchLabelFilterModalMixin {

  final networkConnectionController = Get.find<NetworkConnectionController>();

  final QuickSearchEmailInteractor _quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;
  final RefreshChangesSearchEmailInteractor _refreshChangesSearchEmailInteractor;

  final textInputSearchController = TextEditingController();
  final resultSearchScrollController = ScrollController();
  final textInputSearchFocus = FocusNode();
  final listSearchFilterScrollController = ScrollController();

  final currentSearchText = RxString('');
  final listRecentSearch = RxList<RecentSearch>();
  final listSuggestionSearch = RxList<PresentationEmail>();
  final listContactSuggestionSearch = RxList<EmailAddress>();
  final searchEmailFilter = SearchEmailFilter.initial().obs;
  final searchIsRunning = RxBool(false);
  final emailReceiveTimeType = EmailReceiveTimeType.allTime.obs;
  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);
  final emailSortOrderType = SearchEmailFilter.defaultSortOrder.obs;
  final suggestionSearchViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final resultSearchViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  late Debouncer<String> _deBouncerTime;
  late Worker emailUIActionWorker;
  late Worker dashBoardActionWorker;
  late SearchMoreState searchMoreState;
  late bool canSearchMore;
  WebSocketQueueHandler? _webSocketQueueHandler;
  FocusNode? keyboardFocusNode;
  StreamController<MailListShortcutActionViewEvent>? shortcutActionEventController;
  StreamSubscription<MailListShortcutActionViewEvent>? shortcutActionEventSubscription;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  String get ownEmailAddress => mailboxDashBoardController.ownEmailAddress.value;

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

  RxList<PresentationEmail> get listResultSearch => mailboxDashBoardController.listResultSearch;

  EmailReceiveTimeType get receiveTimeFiltered => searchEmailFilter.value.emailReceiveTimeType;

  DateTime? get startDateFiltered => searchEmailFilter.value.startDate?.value.toLocal();

  DateTime? get endDateFiltered => searchEmailFilter.value.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => searchEmailFilter.value.mailbox;

  Label? get labelFiltered => searchEmailFilter.value.label;

  Set<String> get listAddressOfToFiltered => searchEmailFilter.value.to;

  Set<String> get listAddressOfFromFiltered => searchEmailFilter.value.from;

  Set<String> get listHasKeywordFiltered => searchEmailFilter.value.hasKeyword;

  SearchEmailController(
      this._quickSearchEmailInteractor,
      this._saveRecentSearchInteractor,
      this._getAllRecentSearchLatestInteractor,
      this._searchEmailInteractor,
      this._searchMoreEmailInteractor,
      this._refreshChangesSearchEmailInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    _initializeDebounceTimeTextSearchChange();
    _initializeTextInputFocus();
    _initWorkerListener();
    _initWebSocketQueueHandler();
    onKeyboardShortcutInit();
  }

  @override
  void onReady() async {
    listRecentSearch.value = await getAllRecentSearchAction();
    textInputSearchFocus.requestFocus();
    searchMoreState = SearchMoreState.idle;
    canSearchMore = true;
    _setUpDefaultSortOrder(mailboxDashBoardController.currentSortOrder);
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is SearchEmailSuccess) {
      _searchEmailsSuccess(success);
    } else if (success is SearchingMoreState) {
      searchMoreState = SearchMoreState.waiting;
    } else if (success is SearchMoreEmailSuccess) {
      _searchMoreEmailsSuccess(success);
    } else if (success is SearchingState) {
      resultSearchViewState.value = Right(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is SearchEmailFailure) {
      _searchEmailsFailure(failure);
    } else if (failure is SearchMoreEmailFailure) {
      _searchMoreEmailsFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleUrgentExceptionOnMobile({Failure? failure, Exception? exception}) {
    super.handleUrgentExceptionOnMobile(failure: failure, exception: exception);
    if (failure is SearchEmailFailure) {
      _searchEmailsFailure(failure);
    }
  }

  @override
  void handleUrgentExceptionOnWeb({Failure? failure, Exception? exception}) {
    super.handleUrgentExceptionOnWeb(failure: failure, exception: exception);
    if (failure is SearchEmailFailure) {
      _searchEmailsFailure(failure);
    }
  }

  void _setUpDefaultSortOrder(EmailSortOrderType sortOrderType) {
    emailSortOrderType.value = sortOrderType;
    _updateSimpleSearchFilter(sortOrderTypeOption: Some(sortOrderType));
  }

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '');
    _deBouncerTime.values.listen((value) async {
      log('SearchEmailController::_initializeDebounceTimeTextSearchChange(): $value');
      suggestionSearchViewState.value = Right(LoadingState());
      currentSearchText.value = value;
      _updateSimpleSearchFilter(
        textOption: option(value.isNotEmpty, SearchQuery(value)),
        beforeOption: !searchEmailFilter.value.sortOrderType.isScrollByPosition()
          ? const None()
          : null,
        positionOption: option(searchEmailFilter.value.sortOrderType.isScrollByPosition(), 0)
      );
      if (value.isNotEmpty && session != null && accountId != null) {
        final tupleListSuggestion = await Future.wait([
          quickSearchEmails(session: session!, accountId: accountId!),
          mailboxDashBoardController.getContactSuggestion(value)
        ]);

        listSuggestionSearch.value = tupleListSuggestion[0] as List<PresentationEmail>;
        listContactSuggestionSearch.value = tupleListSuggestion[1] as List<EmailAddress>;
      } else {
        listSuggestionSearch.clear();
        listContactSuggestionSearch.clear();
      }
      if (listSuggestionSearch.isEmpty && currentSearchText.isEmpty) {
        listRecentSearch.value = await getAllRecentSearchAction(pattern: value);
      }
      suggestionSearchViewState.value = Right(UIState.idle);
    });
  }

  void _initializeTextInputFocus() {
    textInputSearchFocus.addListener(_onSearchTextInputListener);
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
          _setUpDefaultSortOrder(action.emailSortOrderType);
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

    ever(mailboxDashBoardController.viewState, (viewState) {
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
    if (accountId == null ||
        session == null ||
        mailboxDashBoardController.currentEmailState == null ||
        mailboxDashBoardController.currentEmailState == newState ||
        searchIsRunning.isFalse) {
      return;
    }
    log('SearchEmailController::_refreshEmailChanges: websocket enqueue message');
    _webSocketQueueHandler?.enqueue(WebSocketMessage(newState: newState));
  }

  void _initWebSocketQueueHandler() {
    _webSocketQueueHandler = WebSocketQueueHandler(
      processMessageCallback: _handleWebSocketMessage,
      onErrorCallback: onError,
    );
  }

  Future<void> _handleWebSocketMessage(WebSocketMessage message) async {
    try {
      if (mailboxDashBoardController.currentEmailState == null ||
          mailboxDashBoardController.currentEmailState == message.newState) {
        log('SearchEmailController::_handleWebSocketMessage:Skipping redundant state: ${message.newState}');
        return Future.value();
      }

      final limit = listResultSearch.isNotEmpty
        ? UnsignedInt(listResultSearch.length)
        : ThreadConstants.defaultLimit;

      _updateSimpleSearchFilter(
        beforeOption: !searchEmailFilter.value.sortOrderType.isScrollByPosition()
          ? const None()
          : null,
        positionOption: option(searchEmailFilter.value.sortOrderType.isScrollByPosition(), 0),
      );

      final searchViewState = await _refreshChangesSearchEmailInteractor.execute(
        session!,
        accountId!,
        limit: limit,
        position: searchEmailFilter.value.position,
        sort: searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
      ).last;

      final searchState = searchViewState
          .foldSuccessWithResult<RefreshChangesSearchEmailSuccess>();

      if (searchState is RefreshChangesSearchEmailSuccess) {
        _handleRefreshChangesSearchEmailsSuccess(searchState);
      }
    } catch (e, stackTrace) {
      logError('SearchEmailController::_handleWebSocketMessage:Error processing state: $e');
      onError(e, stackTrace);
    } finally {
      if (mailboxDashBoardController.currentEmailState != null) {
        _webSocketQueueHandler?.removeMessagesUpToCurrent(
            mailboxDashBoardController.currentEmailState!.value);
      }
    }
  }

  void _onSearchTextInputListener() {
    if (textInputSearchFocus.hasFocus) {
      searchIsRunning.value = false;
    }
  }

  void _handleRefreshChangesSearchEmailsSuccess(RefreshChangesSearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsBeforeChanges = listResultSearch;
    final emailsAfterChanges = resultEmailSearchList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);

    listResultSearch.value = newListEmail.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      searchQuery: searchQuery,
      isSearchEmailRunning: true
    );
    listResultSearch.refresh();
  }

  Future<List<RecentSearch>> getAllRecentSearchAction({String pattern = ''}) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final userName = mailboxDashBoardController.sessionCurrent?.username;

    if (accountId == null || userName == null) {
      logError('SearchEmailController::getAllRecentSearchAction: accountId or userName is null');
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
          sort: searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
          filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
          properties: EmailUtils.getPropertiesForEmailGetMethod(session, accountId))
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
      logError('SearchEmailController::_saveRecentSearch: accountId or userName is null');
      return;
    }

    consumeState(_saveRecentSearchInteractor.execute(
      accountId,
      userName,
      RecentSearch.now(queryString),
    ));
  }

  void searchEmailAction() => _searchEmailAction();

  void _searchEmailAction() {
    textInputSearchFocus.unfocus();

    if (session == null || accountId == null) {
      consumeState(Stream.value(Left(SearchEmailFailure(NotFoundSessionException()))));
      return;
    }

    resultSearchViewState.value = Right(SearchingState());
    canSearchMore = true;
    searchMoreState = SearchMoreState.idle;
    searchIsRunning.value = true;
    cancelSelectionMode();
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: 'SearchEmail',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            searchQuery: searchQuery,
            dashboardType: DashboardType.search
          )
        )
      );
    }

    _updateSimpleSearchFilter(
      positionOption: option(searchEmailFilter.value.sortOrderType.isScrollByPosition(), 0),
      beforeOption: !searchEmailFilter.value.sortOrderType.isScrollByPosition()
        ? const None()
        : null,
    );

    consumeState(_searchEmailInteractor.execute(
      session!,
      accountId!,
      limit: ThreadConstants.defaultLimit,
      position: searchEmailFilter.value.position,
      sort: searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
      filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
      properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
    ));
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsBeforeChanges = listResultSearch;
    final emailsAfterChanges = resultEmailSearchList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);

    listResultSearch.value = newListEmail.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      searchQuery: searchQuery,
      isSearchEmailRunning: true
    );

    resultSearchViewState.value = Right(success);

    if (resultSearchScrollController.hasClients) {
      resultSearchScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }

    if (PlatformInfo.isWeb) {
      refocusMailShortcutFocus();
    }
  }

  void _searchEmailsFailure(SearchEmailFailure failure) {
    listResultSearch.clear();
    resultSearchViewState.value = Left(failure);
    showRetryToast(failure);
  }

  void searchMoreEmailsAction() {
    if (canSearchMore && session != null && accountId != null) {
      final lastEmail = listResultSearch.last;

      if (searchEmailFilter.value.sortOrderType.isScrollByPosition()) {
        _updateSimpleSearchFilter(positionOption: Some(listResultSearch.length));
      } else if (searchEmailFilter.value.sortOrderType == EmailSortOrderType.oldest) {
        _updateSimpleSearchFilter(startDateOption: optionOf(lastEmail.receivedAt));
      } else {
        _updateSimpleSearchFilter(beforeOption: optionOf(lastEmail.receivedAt));
      }

      consumeState(_searchMoreEmailInteractor.execute(
        session!,
        accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: searchEmailFilter.value.sortOrderType.getSortOrder().toNullable(),
        position: searchEmailFilter.value.position,
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
        lastEmailId: lastEmail.id
      ));
    }
  }

  void _searchMoreEmailsFailure(SearchMoreEmailFailure failure) {
    searchMoreState = SearchMoreState.completed;
  }

  void _searchMoreEmailsSuccess(SearchMoreEmailSuccess success) {
    if (success.emailList.isNotEmpty) {
      final resultEmailSearchList = success.emailList
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
          .where((email) => listResultSearch.every((emailInCurrentList) => emailInCurrentList.id != email.id))
          .toList()
          .syncPresentationEmail(
            mapMailboxById: mailboxDashBoardController.mapMailboxById,
            searchQuery: searchQuery,
            isSearchEmailRunning: true
          );
      listResultSearch.addAll(resultEmailSearchList);
    } else {
      canSearchMore = false;
    }
    searchMoreState = SearchMoreState.completed;
  }

  void showAllResultSearchAction(BuildContext context, String queryString) {
    setTextInputSearchForm(queryString);
    _searchEmailByQueryString(
      context: context,
      queryString: queryString);
  }

  void searchEmailByRecentAction(BuildContext context, RecentSearch recentSearch) {
    setTextInputSearchForm(recentSearch.value);
    _searchEmailByQueryString(
      context: context,
      queryString: recentSearch.value);
  }

  void searchEmailByEmailAddressAction(EmailAddress emailAddress) {
    textInputSearchController.clear();
    currentSearchText.value = '';
    _updateSimpleSearchFilter(
      textOption: const None(),
      fromOption: Some({emailAddress.emailAddress}));
    _searchEmailAction();
  }

  void _searchEmailByQueryString({
    required BuildContext context,
    required String queryString
  }) {
    log('SearchEmailController::_searchEmailByQueryString:QueryString = $queryString');
    resultSearchViewState.value = Right(SearchingState());
    listRecentSearch.clear();
    listSuggestionSearch.clear();
    listResultSearch.clear();
    emailReceiveTimeType.value = EmailReceiveTimeType.allTime;
    emailSortOrderType.value = mailboxDashBoardController.currentSortOrder;
    searchIsRunning.value = false;
    final isMailAddress = EmailUtils.isEmailAddressValid(queryString);
    if (isMailAddress) {
      searchEmailByEmailAddressAction(EmailAddress(null, queryString));
    } else {
      _updateSimpleSearchFilter(textOption: Some(SearchQuery(queryString)));
      _searchEmailAction();
    }
  }

  void selectHasAttachmentSearchFilter() {
    _updateSimpleSearchFilter(hasAttachmentOption: const Some(true));
    _searchEmailAction();
  }

  void selectStarredSearchFilter() {
    final listKeyword = listHasKeywordFiltered;
    if (!listKeyword.contains(KeyWordIdentifier.emailFlagged.value)) {
      listKeyword.add(KeyWordIdentifier.emailFlagged.value);
    }
    _updateSimpleSearchFilter(hasKeywordOption: Some(listKeyword));
    _searchEmailAction();
  }

  void selectUnreadSearchFilter() {
    _updateSimpleSearchFilter(unreadOption: const Some(true));
    _searchEmailAction();
  }

  bool checkQuickSearchFilterSelected(QuickSearchFilter filter) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        return searchEmailFilter.value.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        return true;
      case QuickSearchFilter.sortBy:
        return true;
      default:
        return false;
    }
  }

  void _setEmailReceiveTimeType(EmailReceiveTimeType receiveTimeType) {
    emailReceiveTimeType.value = receiveTimeType;
  }

  void selectReceiveTimeQuickSearchFilter(BuildContext context, EmailReceiveTimeType emailReceiveTimeType) {
    if (emailReceiveTimeType == EmailReceiveTimeType.customRange) {
      showMultipleViewDateRangePicker(
        context,
        searchEmailFilter.value.startDate?.value.toLocal(),
        searchEmailFilter.value.endDate?.value.toLocal(),
        onCallbackAction: (newStartDate, newEndDate) {
          _updateSimpleSearchFilter(
            emailReceiveTimeTypeOption: Some(emailReceiveTimeType),
            startDateOption: optionOf(newStartDate?.toUTCDate()),
            endDateOption: optionOf(newEndDate?.toUTCDate()),
          );

          _setEmailReceiveTimeType(emailReceiveTimeType);
          _searchEmailAction();
        }
      );
    } else {
      _updateSimpleSearchFilter(
        emailReceiveTimeTypeOption: Some(emailReceiveTimeType),
        startDateOption: const None(),
        endDateOption: const None(),
      );

      _setEmailReceiveTimeType(emailReceiveTimeType);
      _searchEmailAction();
    }
  }

  void selectSortOrderQuickSearchFilter(EmailSortOrderType sortOrderType) {
    emailSortOrderType.value = sortOrderType;
    _updateSimpleSearchFilter(sortOrderTypeOption: Some(sortOrderType));
    mailboxDashBoardController.storeEmailSortOrder(sortOrderType);
    _searchEmailAction();
  }

  void selectMailboxForSearchFilter(PresentationMailbox? mailbox) async {
    final arguments = DestinationPickerArguments(
      mailboxDashBoardController.accountId.value!,
      MailboxActions.select,
      mailboxDashBoardController.sessionCurrent,
      mailboxIdSelected: mailbox?.id);

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;

    _updateSimpleSearchFilter(
      mailboxOption: destinationMailbox.id == PresentationMailbox.unifiedMailbox.id
        ? const None()
        : Some(destinationMailbox)
    );

    _searchEmailAction();
  }

  Future<void> selectContactForSearchFilter(
      BuildContext context,
      PrefixEmailAddress prefixEmailAddress
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (accountId == null || session == null) return;

    final selectedContactList = searchEmailFilter.value.getContactApplied(prefixEmailAddress);
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

      _dispatchApplyContactAction(
        context,
        listMailAddress,
        prefixEmailAddress
      );
    }
  }

  void _dispatchApplyContactAction(
      BuildContext context,
      Set<String> listContactSelected,
      PrefixEmailAddress prefixEmailAddress,
  ) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        _updateSimpleSearchFilter(
          fromOption: listContactSelected.isNotEmpty
            ? Some(listContactSelected)
            : const None()
        );
        break;
      case PrefixEmailAddress.to:
        _updateSimpleSearchFilter(
          toOption: listContactSelected.isNotEmpty
            ? Some(listContactSelected)
            : const None()
        );
        break;
      default:
        break;
    }

    _searchEmailAction();
  }

  void updateSimpleSearchFilter({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<bool>? unreadOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<Set<String>>? hasKeywordOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) => _updateSimpleSearchFilter(
    fromOption: fromOption,
    toOption: toOption,
    textOption: textOption,
    mailboxOption: mailboxOption,
    emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
    hasAttachmentOption: hasAttachmentOption,
    unreadOption: unreadOption,
    beforeOption: beforeOption,
    startDateOption: startDateOption,
    endDateOption: endDateOption,
    positionOption: positionOption,
    hasKeywordOption: hasKeywordOption,
    sortOrderTypeOption: sortOrderTypeOption,
    labelOption: labelOption,
  );

  void _updateSimpleSearchFilter({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<bool>? unreadOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<int>? positionOption,
    Option<Set<String>>? hasKeywordOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
    Option<Label>? labelOption,
  }) {
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      fromOption: fromOption,
      toOption: toOption,
      textOption: textOption,
      mailboxOption: mailboxOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      unreadOption: unreadOption,
      beforeOption: beforeOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      positionOption: positionOption,
      hasKeywordOption: hasKeywordOption,
      sortOrderTypeOption: sortOrderTypeOption,
      labelOption: labelOption,
    );
    searchEmailFilter.refresh();
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onTextSearchSubmitted(BuildContext context, String text) {
    final queryString = text.trim();
    if (queryString.isNotEmpty) {
      saveRecentSearch(queryString);
    }
    _searchEmailByQueryString(context: context, queryString: queryString);
  }

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void clearAllTextInputSearchForm({bool requestFocus = false}) {
    textInputSearchController.clear();
    currentSearchText.value = '';
    listSuggestionSearch.clear();
    listContactSuggestionSearch.clear();
    if (requestFocus) {
      textInputSearchFocus.requestFocus();
    } else {
      textInputSearchFocus.unfocus();
    }
  }

  void clearAllResultSearch() {
    searchIsRunning.value = false;
    currentSearchText.value = '';
    listRecentSearch.clear();
    listSuggestionSearch.clear();
    listContactSuggestionSearch.clear();
    listResultSearch.clear();
    searchEmailFilter.value = SearchEmailFilter.withSortOrder(
      mailboxDashBoardController.currentSortOrder,
    );
  }

  void closeSearchView({BuildContext? context}) {
    clearAllTextInputSearchForm();
    clearAllResultSearch();
    mailboxDashBoardController.searchController.disableAllSearchEmail();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: 'Mailbox-${mailboxDashBoardController.selectedMailbox.value?.id.id.value}',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: mailboxDashBoardController.selectedMailbox.value?.id,
            dashboardType: DashboardType.normal
          )
        )
      );
    }
    SearchEmailBindings().disposeBindings();
  }

  void pressEmailAction(
      BuildContext context,
      EmailActionType actionType,
      PresentationEmail selectedEmail,
      {required PresentationMailbox? mailboxContain}
  ) {
    switch(actionType) {
      case EmailActionType.preview:
        if (mailboxContain?.isDrafts == true) {
          editDraftEmail(selectedEmail);
        } else {
          previewEmail(selectedEmail);
        }
        break;
      case EmailActionType.selection:
        selectEmail(context, selectedEmail);
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
        deleteEmailPermanently(context, selectedEmail);
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

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    listResultSearch.value = listResultSearch
        .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
        .toList();

    if (listResultSearch.isAllSelectionInActive) {
      selectionMode.value = SelectMode.INACTIVE;
    } else {
      if (selectionMode.value == SelectMode.INACTIVE) {
        selectionMode.value = SelectMode.ACTIVE;
      }
    }

    if (PlatformInfo.isWeb) {
      refocusMailShortcutFocus();
    }
  }

  void cancelSelectionMode() {
    listResultSearch.value = listResultSearch
        .map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE))
        .toList();
    selectionMode.value = SelectMode.INACTIVE;
    if (PlatformInfo.isWeb) {
      clearMailShortcutFocus();
    }
  }

  void setSelectAllEmailAction() {
    listResultSearch.value = listResultSearch
        .map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE))
        .toList();
    selectionMode.value = SelectMode.ACTIVE;
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
      default:
        break;
    }
  }

  void onDeleteSearchFilterAction(
    BuildContext context,
    QuickSearchFilter searchFilter
  ) {
    switch(searchFilter) {
      case QuickSearchFilter.dateTime:
        _deleteDateTimeSearchFilter();
        break;
      case QuickSearchFilter.sortBy:
        _deleteSortOrderSearchFilter();
        break;
      case QuickSearchFilter.from:
        _deleteFromSearchFilter();
        break;
      case QuickSearchFilter.hasAttachment:
        _deleteHasAttachmentSearchFilter();
        break;
      case QuickSearchFilter.to:
        _deleteToSearchFilter();
        break;
      case QuickSearchFilter.folder:
        _deleteFolderSearchFilter();
        break;
      case QuickSearchFilter.starred:
        _deleteStarredSearchFilter();
        break;
      case QuickSearchFilter.unread:
        _deleteUnreadSearchFilter();
        break;
      case QuickSearchFilter.labels:
        deleteQuickSearchFilter(filter: QuickSearchFilter.labels);
        break;
      default:
        break;
    }
  }

  void _deleteDateTimeSearchFilter() {
    _updateSimpleSearchFilter(
      emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.allTime),
      startDateOption: const None(),
      endDateOption: const None(),
    );
    _setEmailReceiveTimeType(EmailReceiveTimeType.allTime);
    _searchEmailAction();
  }

  void _deleteSortOrderSearchFilter() {
    emailSortOrderType.value = SearchEmailFilter.defaultSortOrder;
    _updateSimpleSearchFilter(
      sortOrderTypeOption: const Some(SearchEmailFilter.defaultSortOrder),
    );
    mailboxDashBoardController.storeEmailSortOrder(
      SearchEmailFilter.defaultSortOrder,
    );
    _searchEmailAction();
  }

  void _deleteFromSearchFilter() {
    _updateSimpleSearchFilter(fromOption: const None());
    _searchEmailAction();
  }

  void _deleteToSearchFilter() {
    _updateSimpleSearchFilter(toOption: const None());
    _searchEmailAction();
  }

  void _deleteHasAttachmentSearchFilter() {
    _updateSimpleSearchFilter(hasAttachmentOption: const None());
    _searchEmailAction();
  }

  void _deleteFolderSearchFilter() {
    _updateSimpleSearchFilter(mailboxOption: const None());
    _searchEmailAction();
  }

  void _deleteStarredSearchFilter() {
    _updateSimpleSearchFilter(hasKeywordOption: const None());
    _searchEmailAction();
  }

  void _deleteUnreadSearchFilter() {
    _updateSimpleSearchFilter(unreadOption: const None());
    _searchEmailAction();
  }

  void clearAllSearchFilterApplied() {
    textInputSearchController.clear();
    currentSearchText.value = '';
    listRecentSearch.clear();
    listSuggestionSearch.clear();
    listResultSearch.clear();
    canSearchMore = true;
    searchMoreState = SearchMoreState.idle;
    emailReceiveTimeType.value = EmailReceiveTimeType.allTime;
    emailSortOrderType.value = mailboxDashBoardController.currentSortOrder;
    searchEmailFilter.value = SearchEmailFilter.withSortOrder(
      emailSortOrderType.value,
    );
    _searchEmailAction();
  }

  @override
  void onClose() {
    textInputSearchFocus.removeListener(_onSearchTextInputListener);
    textInputSearchController.dispose();
    textInputSearchFocus.dispose();
    resultSearchScrollController.dispose();
    listSearchFilterScrollController.dispose();
    _deBouncerTime.cancel();
    emailUIActionWorker.dispose();
    dashBoardActionWorker.dispose();
    _webSocketQueueHandler?.dispose();
    onKeyboardShortcutDispose();
    super.onClose();
  }
}