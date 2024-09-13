
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
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
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_event_attendance_status_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/datetime_extension.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/search/email/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/email/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class SearchEmailController extends BaseController
    with EmailActionController,
        DateRangePickerMixin {

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
  final emailSortOrderType = EmailSortOrderType.mostRecent.obs;
  final suggestionSearchViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  late Debouncer<String> _deBouncerTime;
  late Worker dashBoardViewStateWorker;
  late Worker dashBoardActionWorker;
  late SearchMoreState searchMoreState;
  late bool canSearchMore;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

  RxList<PresentationEmail> get listResultSearch => mailboxDashBoardController.listResultSearch;

  EmailReceiveTimeType get receiveTimeFiltered => searchEmailFilter.value.emailReceiveTimeType;

  DateTime? get startDateFiltered => searchEmailFilter.value.startDate?.value.toLocal();

  DateTime? get endDateFiltered => searchEmailFilter.value.endDate?.value.toLocal();

  PresentationMailbox? get mailboxFiltered => searchEmailFilter.value.mailbox;

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
  }

  @override
  void onReady() async {
    listRecentSearch.value = await getAllRecentSearchAction();
    textInputSearchFocus.requestFocus();
    searchMoreState = SearchMoreState.idle;
    canSearchMore = true;
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is SearchEmailSuccess) {
      _searchEmailsSuccess(success);
    } else if (success is SearchingMoreState) {
      searchMoreState = SearchMoreState.waiting;
    } else if (success is SearchMoreEmailSuccess) {
      _searchMoreEmailsSuccess(success);
    } else if (success is RefreshChangesSearchEmailSuccess) {
      _refreshChangesSearchEmailsSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is SearchEmailFailure) {
      _searchEmailsFailure(failure);
    } else if (failure is SearchMoreEmailFailure) {
      _searchMoreEmailsFailure(failure);
    }
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
        textOption: value.isNotEmpty ? Some(SearchQuery(value)) : const None(),
        beforeOption: const None(),
        positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
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
    dashBoardViewStateWorker = ever(mailboxDashBoardController.viewState, (viewState) {
      viewState.map((success) {
        if (success is MarkAsEmailReadSuccess ||
            success is MoveToMailboxSuccess ||
            success is MarkAsStarEmailSuccess ||
            success is DeleteEmailPermanentlySuccess ||
            success is MarkAsMultipleEmailReadAllSuccess ||
            success is MarkAsMultipleEmailReadHasSomeEmailFailure ||
            success is MarkAsStarMultipleEmailAllSuccess ||
            success is MarkAsStarMultipleEmailHasSomeEmailFailure ||
            success is MoveMultipleEmailToMailboxAllSuccess ||
            success is MoveMultipleEmailToMailboxHasSomeEmailFailure ||
            success is EmptyTrashFolderSuccess ||
            success is EmptySpamFolderSuccess ||
            success is DeleteMultipleEmailsPermanentlyAllSuccess ||
            success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure ||
            success is UnsubscribeEmailSuccess ||
            success is StoreEventAttendanceStatusSuccess
        ) {
          _refreshEmailChanges();
        }
      });
    });

    dashBoardActionWorker = ever(
      mailboxDashBoardController.dashBoardAction,
      (action) {
        if (action is CloseSearchEmailViewAction) {
          closeSearchView(context: currentContext);
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is CancelSelectionSearchEmailAction) {
          cancelSelectionMode();
          mailboxDashBoardController.clearDashBoardAction();
        }
      }
    );
  }

  void _onSearchTextInputListener() {
    if (textInputSearchFocus.hasFocus) {
      searchIsRunning.value = false;
    }
  }

  void _refreshEmailChanges() {
    if (searchIsRunning.isTrue && session != null && accountId != null) {
      final limit = listResultSearch.isNotEmpty
          ? UnsignedInt(listResultSearch.length)
          : ThreadConstants.defaultLimit;
      _updateSimpleSearchFilter(
        beforeOption: const None(),
        positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
      );
      consumeState(_refreshChangesSearchEmailInteractor.execute(
        session!,
        accountId!,
        limit: limit,
        position: searchEmailFilter.value.position,
        sort: emailSortOrderType.value.getSortOrder().toNullable(),
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(sortOrderType: emailSortOrderType.value),
        properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
      ));
    }
  }

  void _refreshChangesSearchEmailsSuccess(RefreshChangesSearchEmailSuccess success) {
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
    return _getAllRecentSearchLatestInteractor
        .execute(pattern: pattern)
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
          sort: emailSortOrderType.value.getSortOrder().toNullable(),
          filter: searchEmailFilter.value.mappingToEmailFilterCondition(sortOrderType: emailSortOrderType.value),
          properties: ThreadConstants.propertiesQuickSearch)
        .then((result) => result.fold(
            (failure) => <PresentationEmail>[],
            (success) => success is QuickSearchEmailSuccess
                ? success.emailList
                : <PresentationEmail>[]));
  }

  void saveRecentSearch(RecentSearch recentSearch) {
    consumeState(_saveRecentSearchInteractor.execute(recentSearch));
  }

  void _searchEmailAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    textInputSearchFocus.unfocus();

    if (session != null && accountId != null) {
      canSearchMore = true;
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

      if (emailSortOrderType.value.isScrollByPosition()) {
        _updateSimpleSearchFilter(
          positionOption: const Some(0),
          beforeOption: const None(),
        );
      } else {
        _updateSimpleSearchFilter(
          positionOption: const None(),
          beforeOption: const None(),
        );
      }

      consumeState(_searchEmailInteractor.execute(
        session!,
        accountId!,
        limit: ThreadConstants.defaultLimit,
        position: searchEmailFilter.value.position,
        sort: emailSortOrderType.value.getSortOrder().toNullable(),
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(sortOrderType: emailSortOrderType.value),
        properties: EmailUtils.getPropertiesForEmailGetMethod(session!, accountId!),
      ));
    }
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

    if (resultSearchScrollController.hasClients) {
      resultSearchScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }
  }

  void _searchEmailsFailure(SearchEmailFailure failure) {
    listResultSearch.clear();
  }

  void searchMoreEmailsAction() {
    if (canSearchMore && session != null && accountId != null) {
      final lastEmail = listResultSearch.last;

      if (emailSortOrderType.value.isScrollByPosition()) {
        _updateSimpleSearchFilter(
          positionOption: Some(listResultSearch.length),
          beforeOption: const None()
        );
      } else if (emailSortOrderType.value == EmailSortOrderType.oldest) {
        _updateSimpleSearchFilter(startDateOption: optionOf(lastEmail.receivedAt));
      } else {
        _updateSimpleSearchFilter(beforeOption: optionOf(lastEmail.receivedAt));
      }

      consumeState(_searchMoreEmailInteractor.execute(
        session!,
        accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: emailSortOrderType.value.getSortOrder().toNullable(),
        position: searchEmailFilter.value.position,
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(sortOrderType: emailSortOrderType.value),
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

  void showAllResultSearchAction(BuildContext context, String query) {
    setTextInputSearchForm(query);
    _updateSimpleSearchFilter(
      textOption: Some(SearchQuery(query)),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
    );
    _searchEmailAction(context);
  }

  void searchEmailByRecentAction(BuildContext context, RecentSearch recentSearch) {
    setTextInputSearchForm(recentSearch.value);
    _updateSimpleSearchFilter(
      textOption: Some(SearchQuery(recentSearch.value)),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
    );
    _searchEmailAction(context);
  }

  void searchEmailByEmailAddressAction(
    BuildContext context,
    EmailAddress emailAddress
  ) {
    _updateSimpleSearchFilter(
      fromOption: Some({emailAddress.emailAddress}),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
    );
    _searchEmailAction(context);
  }

  void submitSearchAction(BuildContext context, String query) {
    _updateSimpleSearchFilter(
      textOption: Some(SearchQuery(query)),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
    );
    _searchEmailAction(context);
  }

  void selectHasAttachmentSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      hasAttachmentOption: const Some(true),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  void selectStarredSearchFilter(BuildContext context) {
    final listKeyword = listHasKeywordFiltered;
    if (!listKeyword.contains(KeyWordIdentifier.emailFlagged.value)) {
      listKeyword.add(KeyWordIdentifier.emailFlagged.value);
    }
    _updateSimpleSearchFilter(
      hasKeywordOption: Some(listKeyword),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
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
    popBack();

    if (emailReceiveTimeType == EmailReceiveTimeType.customRange) {
      showMultipleViewDateRangePicker(
        context,
        searchEmailFilter.value.startDate?.value.toLocal(),
        searchEmailFilter.value.endDate?.value.toLocal(),
        onCallbackAction: (newStartDate, newEndDate) {
          _updateSimpleSearchFilter(
            emailReceiveTimeTypeOption: Some(emailReceiveTimeType),
            textOption: searchQuery == null
              ? Some(SearchQuery.initial())
              : optionOf(searchEmailFilter.value.text),
            beforeOption: const None(),
            startDateOption: optionOf(newStartDate?.toUTCDate()),
            endDateOption: optionOf(newEndDate?.toUTCDate()),
            positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
          );

          _setEmailReceiveTimeType(emailReceiveTimeType);
          _searchEmailAction(context);
        }
      );
    } else {
      _updateSimpleSearchFilter(
        emailReceiveTimeTypeOption: Some(emailReceiveTimeType),
        textOption: searchQuery == null
          ? Some(SearchQuery.initial())
          : optionOf(searchEmailFilter.value.text),
        beforeOption: const None(),
        startDateOption: const None(),
        endDateOption: const None(),
        positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
      );

      _setEmailReceiveTimeType(emailReceiveTimeType);
      _searchEmailAction(context);
    }
  }

  void selectSortOrderQuickSearchFilter(BuildContext context, EmailSortOrderType sortOrderType) {
    popBack();
    _updateSimpleSearchFilter(
      sortOrderOption: sortOrderType.getSortOrder(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
    );
    emailSortOrderType.value = sortOrderType;
    _searchEmailAction(context);
  }

  void selectMailboxForSearchFilter(BuildContext context, PresentationMailbox? mailbox) async {
    final arguments = DestinationPickerArguments(
      mailboxDashBoardController.accountId.value!,
      MailboxActions.select,
      mailboxDashBoardController.sessionCurrent,
      mailboxIdSelected: mailbox?.id);

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is! PresentationMailbox) return;

    _updateSimpleSearchFilter(
      mailboxOption: destinationMailbox.id == PresentationMailbox.unifiedMailbox.id
        ? const None()
        : Some(destinationMailbox),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );

    if (context.mounted) {
      _searchEmailAction(context);
    }
  }

  void selectContactForSearchFilter(
      BuildContext context,
      PrefixEmailAddress prefixEmailAddress
  ) async {
    if (accountId != null && session != null) {
      final listContactSelected = searchEmailFilter.value.getContactApplied(prefixEmailAddress);
      final arguments = ContactArguments(accountId!, session!, listContactSelected);

      final newContact = await push(AppRoutes.contact, arguments: arguments);

      if (newContact is EmailAddress && context.mounted) {
        _dispatchApplyContactAction(
          context,
          listContactSelected,
          prefixEmailAddress,
          newContact);
      }
    }
  }

  void _dispatchApplyContactAction(
      BuildContext context,
      Set<String> listContactSelected,
      PrefixEmailAddress prefixEmailAddress,
      EmailAddress newContact
  ) {
    if (listContactSelected.isNotEmpty) {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.from:
          if (listContactSelected.first == newContact.email) {
            searchEmailFilter.value.from.clear();
          } else {
            searchEmailFilter.value.from.clear();
            searchEmailFilter.value.from.add(newContact.email!);
          }
          break;
        case PrefixEmailAddress.to:
          if (listContactSelected.first == newContact.email) {
            searchEmailFilter.value.to.clear();
          } else {
            searchEmailFilter.value.to.clear();
            searchEmailFilter.value.to.add(newContact.email!);
          }
          break;
        default:
          break;
      }
    } else {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.from:
          searchEmailFilter.value.from.add(newContact.email!);
          break;
        case PrefixEmailAddress.to:
          searchEmailFilter.value.to.add(newContact.email!);
          break;
        default:
          break;
      }
    }

    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        _updateSimpleSearchFilter(
          fromOption: Some(searchEmailFilter.value.from),
          beforeOption: const None(),
          positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
        );
        break;
      case PrefixEmailAddress.to:
        _updateSimpleSearchFilter(
          toOption: Some(searchEmailFilter.value.to),
          beforeOption: const None(),
          positionOption: emailSortOrderType.value.isScrollByPosition() ? const Some(0) : const None()
        );
        break;
      default:
        break;
    }

    _searchEmailAction(context);
  }

  void _updateSimpleSearchFilter({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<Set<Comparator>>? sortOrderOption,
    Option<int>? positionOption,
    Option<Set<String>>? hasKeywordOption,
  }) {
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      fromOption: fromOption,
      toOption: toOption,
      textOption: textOption,
      mailboxOption: mailboxOption,
      emailReceiveTimeTypeOption: emailReceiveTimeTypeOption,
      hasAttachmentOption: hasAttachmentOption,
      beforeOption: beforeOption,
      startDateOption: startDateOption,
      endDateOption: endDateOption,
      sortOrderOption: sortOrderOption,
      positionOption: positionOption,
      hasKeywordOption: hasKeywordOption,
    );
    searchEmailFilter.refresh();
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onTextSearchSubmitted(BuildContext context, String text) {
    final query = text.trim();
    if (query.isNotEmpty) {
      saveRecentSearch(RecentSearch.now(query));
      submitSearchAction(context, query);
    }
  }

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    currentSearchText.value = '';
    listSuggestionSearch.clear();
    listContactSuggestionSearch.clear();
  }

  void clearAllResultSearch() {
    searchIsRunning.value = false;
    currentSearchText.value = '';
    listRecentSearch.clear();
    listSuggestionSearch.clear();
    listContactSuggestionSearch.clear();
    listResultSearch.clear();
    searchEmailFilter.value = SearchEmailFilter.initial();
  }

  void closeSearchView({BuildContext? context}) {
    clearAllTextInputSearchForm();
    clearAllResultSearch();
    if (context != null) {
      KeyboardUtils.hideKeyboard(context);
    }
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
      {PresentationMailbox? mailboxContain}
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
        popBack();
        moveToSpam(selectedEmail, mailboxContain: mailboxContain);
        break;
      case EmailActionType.unSpam:
        popBack();
        unSpam(selectedEmail);
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
  }

  void cancelSelectionMode() {
    listResultSearch.value = listResultSearch
        .map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE))
        .toList();
    selectionMode.value = SelectMode.INACTIVE;
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
        cancelSelectionMode();
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelSelectionMode();
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToTrash(listEmails, mailboxContainCurrent);
        }
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
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToSpam(listEmails, mailboxContainCurrent);
        }
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
        _deleteDateTimeSearchFilter(context);
        break;
      case QuickSearchFilter.sortBy:
        _deleteSortOrderSearchFilter(context);
        break;
      case QuickSearchFilter.from:
        _deleteFromSearchFilter(context);
        break;
      case QuickSearchFilter.hasAttachment:
        _deleteHasAttachmentSearchFilter(context);
        break;
      case QuickSearchFilter.to:
        _deleteToSearchFilter(context);
        break;
      case QuickSearchFilter.folder:
        _deleteFolderSearchFilter(context);
        break;
      case QuickSearchFilter.starred:
        _deleteStarredSearchFilter(context);
        break;
      default:
        break;
    }
  }

  void _deleteDateTimeSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      emailReceiveTimeTypeOption: const Some(EmailReceiveTimeType.allTime),
      textOption: searchQuery == null
        ? Some(SearchQuery.initial())
        : optionOf(searchEmailFilter.value.text),
      beforeOption: const None(),
      startDateOption: const None(),
      endDateOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _setEmailReceiveTimeType(EmailReceiveTimeType.allTime);
    _searchEmailAction(context);
  }

  void _deleteSortOrderSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      sortOrderOption: EmailSortOrderType.mostRecent.getSortOrder(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    emailSortOrderType.value = EmailSortOrderType.mostRecent;
    _searchEmailAction(context);
  }

  void _deleteFromSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      fromOption: const None(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  void _deleteToSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      toOption: const None(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  void _deleteHasAttachmentSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      hasAttachmentOption: const None(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  void _deleteFolderSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      mailboxOption: const None(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  void _deleteStarredSearchFilter(BuildContext context) {
    _updateSimpleSearchFilter(
      hasKeywordOption: const None(),
      beforeOption: const None(),
      positionOption: emailSortOrderType.value.isScrollByPosition()
        ? const Some(0)
        : const None()
    );
    _searchEmailAction(context);
  }

  @override
  void onClose() {
    textInputSearchFocus.removeListener(_onSearchTextInputListener);
    textInputSearchController.dispose();
    textInputSearchFocus.dispose();
    resultSearchScrollController.dispose();
    listSearchFilterScrollController.dispose();
    _deBouncerTime.cancel();
    dashBoardViewStateWorker.dispose();
    dashBoardActionWorker.dispose();
    super.onClose();
  }
}