
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_all_recent_search_latest_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/quick_search_email_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_recent_search_latest_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/quick_search_email_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_recent_search_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SearchEmailController extends BaseController
    with EmailActionController {

  final QuickSearchEmailInteractor _quickSearchEmailInteractor;
  final SaveRecentSearchInteractor _saveRecentSearchInteractor;
  final GetAllRecentSearchLatestInteractor _getAllRecentSearchLatestInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;
  final RefreshChangesSearchEmailInteractor _refreshChangesSearchEmailInteractor;

  final textInputSearchController = TextEditingController();
  final resultSearchScrollController = ScrollController();
  final textInputSearchFocus = FocusNode();

  final currentSearchText = RxString('');
  final listRecentSearch = RxList<RecentSearch>();
  final listSuggestionSearch = RxList<PresentationEmail>();
  final listResultSearch = RxList<PresentationEmail>();
  final searchEmailFilter = Rx<SearchEmailFilter>(SearchEmailFilter());
  final searchIsRunning = RxBool(false);
  final emailReceiveTimeType = Rxn<EmailReceiveTimeType>();
  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);

  late Debouncer<String> _deBouncerTime;
  late Worker dashBoardViewStateWorker;
  late SearchMoreState searchMoreState;
  late bool canSearchMore;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  UserProfile? get userProfile => mailboxDashBoardController.userProfile.value;

  SearchQuery? get searchQuery => searchEmailFilter.value.text;

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
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(
        (failure) {
          if (failure is SearchEmailFailure) {
            _searchEmailsFailure(failure);
          } else if (failure is SearchMoreEmailFailure) {
            _searchMoreEmailsFailure(failure);
          }
        },
        (success) {
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
    );
  }

  @override
  void onDone() {}

  @override
  void onError(error) {}

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '');
    _deBouncerTime.values.listen((value) async {
      log('SearchEmailController::_initializeDebounceTimeTextSearchChange(): $value');
      currentSearchText.value = value;
      _updateFilterEmail(text: value.isNotEmpty ? SearchQuery(value) : null);
      if (value.isNotEmpty && accountId != null) {
        listSuggestionSearch.value = await quickSearchEmails(accountId: accountId!);
      } else {
        listSuggestionSearch.clear();
      }
      if (listSuggestionSearch.isEmpty && currentSearchText.isEmpty) {
        listRecentSearch.value = await getAllRecentSearchAction(pattern: value);
      }
    });
  }

  void _initializeTextInputFocus() {
    textInputSearchFocus.addListener(() {
      if (textInputSearchFocus.hasFocus) {
        searchIsRunning.value = false;
      }
    });
  }

  void _initWorkerListener() {
    dashBoardViewStateWorker = ever(mailboxDashBoardController.viewState, (viewState) {
      if (viewState is Either) {
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
              success is DeleteMultipleEmailsPermanentlyAllSuccess ||
              success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure
          ) {
            _refreshEmailChanges();
          }
        });
      }
    });
  }

  void _refreshEmailChanges() {
    if (searchIsRunning.isTrue && accountId != null) {
      final limit = listResultSearch.isNotEmpty
          ? UnsignedInt(listResultSearch.length)
          : ThreadConstants.defaultLimit;
      searchEmailFilter.value = searchEmailFilter.value.toSearchEmailFilter(newBefore: null);

      consumeState(_refreshChangesSearchEmailInteractor.execute(
        accountId!,
        limit: limit,
        sort: <Comparator>{}
          ..add(EmailComparator(EmailComparatorProperty.receivedAt)
            ..setIsAscending(false)),
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
      ));
    }
  }

  void _refreshChangesSearchEmailsSuccess(RefreshChangesSearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
        .toList();

    final emailsBeforeChanges = listResultSearch;
    final emailsAfterChanges = resultEmailSearchList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);

    listResultSearch.value = newListEmail;
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

  Future<List<PresentationEmail>> quickSearchEmails({required AccountId accountId}) async {
    return _quickSearchEmailInteractor
        .execute(accountId,
            limit: UnsignedInt(5),
            sort: <Comparator>{}..add(
                EmailComparator(EmailComparatorProperty.receivedAt)
                  ..setIsAscending(false)),
            filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
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
    FocusScope.of(context).unfocus();

    if (accountId != null) {
      searchIsRunning.value = true;

      consumeState(_searchEmailInteractor.execute(
        accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: <Comparator>{}
          ..add(EmailComparator(EmailComparatorProperty.receivedAt)
            ..setIsAscending(false)),
        filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
      ));
    }
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
        .toList();

    final emailsBeforeChanges = listResultSearch;
    final emailsAfterChanges = resultEmailSearchList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);

    listResultSearch.value = newListEmail;

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
    if (canSearchMore && accountId != null) {
      final lastEmail = listResultSearch.last;
      _updateFilterEmail(before: lastEmail.receivedAt);

      consumeState(_searchMoreEmailInteractor.execute(
          accountId!,
          limit: ThreadConstants.defaultLimit,
          sort: <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: searchEmailFilter.value.mappingToEmailFilterCondition(),
          properties: ThreadConstants.propertiesDefault,
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
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
          .where((email) => !listResultSearch.contains(email))
          .toList();
      listResultSearch.addAll(resultEmailSearchList);
    } else {
      canSearchMore = false;
    }
    searchMoreState = SearchMoreState.completed;
  }

  void showAllResultSearchAction(BuildContext context, String query) {
    setTextInputSearchForm(query);
    _updateFilterEmail(text: SearchQuery(query));
    _searchEmailAction(context);
  }

  void searchEmailByRecentAction(BuildContext context, RecentSearch recentSearch) {
    setTextInputSearchForm(recentSearch.value);
    _updateFilterEmail(text: SearchQuery(recentSearch.value));
    _searchEmailAction(context);
  }

  void submitSearchAction(BuildContext context, String query) {
    _updateFilterEmail(text: SearchQuery(query));
    _searchEmailAction(context);
  }

  void selectQuickSearchFilter(BuildContext context, QuickSearchFilter filter) {
    _selectQuickSearchFilter(filter);
    _searchEmailAction(context);
  }

  bool checkQuickSearchFilterSelected(QuickSearchFilter filter) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        return searchEmailFilter.value.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        if (emailReceiveTimeType.value != null) {
          return true;
        }
        return searchEmailFilter.value.emailReceiveTimeType == EmailReceiveTimeType.last7Days;
      case QuickSearchFilter.fromMe:
        return userProfile != null &&
            searchEmailFilter.value.from.contains(userProfile!.email) &&
            searchEmailFilter.value.from.length == 1;
    }
  }

  void _selectQuickSearchFilter(QuickSearchFilter filter) {
    final filterSelected = checkQuickSearchFilterSelected(filter);

    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        _updateFilterEmail(hasAttachment: !filterSelected);
        break;
      case QuickSearchFilter.last7Days:
        if (filterSelected) {
          _setEmailReceiveTimeType(null);
          _updateFilterEmail(emailReceiveTimeType: EmailReceiveTimeType.allTime);
        } else {
          _setEmailReceiveTimeType(EmailReceiveTimeType.last7Days);
          _updateFilterEmail(emailReceiveTimeType: EmailReceiveTimeType.last7Days);
        }
        break;
      case QuickSearchFilter.fromMe:
        if (userProfile != null) {
          filterSelected
              ? searchEmailFilter.value.from.removeWhere((e) => e == userProfile!.email)
              : searchEmailFilter.value.from.add(userProfile!.email);
          _updateFilterEmail(from: searchEmailFilter.value.from);
        }
        break;
    }
  }

  void _setEmailReceiveTimeType(EmailReceiveTimeType? receiveTimeType) {
    emailReceiveTimeType.value = receiveTimeType;
  }

  void selectReceiveTimeQuickSearchFilter(BuildContext context, EmailReceiveTimeType? emailReceiveTimeType) {
    popBack();

    if (emailReceiveTimeType != null) {
      _updateFilterEmail(
          emailReceiveTimeType: emailReceiveTimeType,
          text: searchQuery == null ? SearchQuery.initial() : searchEmailFilter.value.text);
    } else {
      _updateFilterEmail(
          emailReceiveTimeType: EmailReceiveTimeType.allTime,
          text: searchQuery == null ? SearchQuery.initial() : searchEmailFilter.value.text);
    }
    _setEmailReceiveTimeType(emailReceiveTimeType);
    _searchEmailAction(context);
  }

  void _updateFilterEmail({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    Set<String>? hasKeyword,
    Set<String>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
  }) {
    searchEmailFilter.value = searchEmailFilter.value.copyWith(
      from: from,
      to: to,
      text: text,
      subject: subject,
      hasKeyword: hasKeyword,
      notKeyword: notKeyword,
      mailbox: mailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: before,
    );
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    currentSearchText.value = '';
    listSuggestionSearch.clear();
    textInputSearchFocus.requestFocus();
  }

  void clearAllResultSearch() {
    searchIsRunning.value = false;
    currentSearchText.value = '';
    listRecentSearch.clear();
    listSuggestionSearch.clear();
    listResultSearch.clear();
    searchEmailFilter.value = SearchEmailFilter();
  }

  void closeSearchView(BuildContext context) {
    clearAllTextInputSearchForm();
    clearAllResultSearch();
    FocusScope.of(context).unfocus();
    mailboxDashBoardController.searchController.disableSearch();
    mailboxDashBoardController.dispatchRoute(AppRoutes.THREAD);
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
          editEmail(selectedEmail);
        } else {
          previewEmail(context, selectedEmail);
        }
        break;
      case EmailActionType.selection:
        selectEmail(context, selectedEmail);
        break;
      case EmailActionType.markAsRead:
        markAsEmailRead(selectedEmail, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        markAsEmailRead(selectedEmail, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        markAsStarEmail(selectedEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        markAsStarEmail(selectedEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        moveToMailbox(context, selectedEmail);
        break;
      case EmailActionType.moveToTrash:
        moveToTrash(selectedEmail);
        break;
      case EmailActionType.deletePermanently:
        deleteEmailPermanently(context, selectedEmail);
        break;
      case EmailActionType.moveToSpam:
        popBack();
        moveToSpam(selectedEmail);
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
        .map((email) => email.id == presentationEmailSelected.id
        ? email.toggleSelect()
        : email)
        .toList();

    if (listResultSearch.isAllSelectionInActive) {
      selectionMode.value = SelectMode.INACTIVE;
    } else {
      if (selectionMode.value == SelectMode.INACTIVE) {
        selectionMode.value = SelectMode.ACTIVE;
      }
    }
  }

  void cancelSelectionMode(BuildContext context) {
    listResultSearch.value = listResultSearch
        .map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE))
        .toList();
    selectionMode.value = SelectMode.INACTIVE;
  }

  void handleSelectionEmailAction(
      BuildContext context,
      EmailActionType actionType,
      List<PresentationEmail> listEmails
  ) {
    switch(actionType) {
      case EmailActionType.markAsRead:
        cancelSelectionMode(context);
        markAsReadSelectedMultipleEmail(listEmails, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        cancelSelectionMode(context);
        markAsReadSelectedMultipleEmail(listEmails, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        cancelSelectionMode(context);
        markAsStarSelectedMultipleEmail(listEmails, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        cancelSelectionMode(context);

        markAsStarSelectedMultipleEmail(listEmails, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        cancelSelectionMode(context);
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailbox);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelSelectionMode(context);
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailbox);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToTrash(listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.deletePermanently:
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailbox);
        if (mailboxContainCurrent != null) {
          deleteSelectionEmailsPermanently(
              context,
              DeleteActionType.multiple,
              listEmails: listEmails,
              mailboxCurrent: mailboxContainCurrent,
              onCancelSelectionEmail: () => cancelSelectionMode(context));
        }
        break;
      case EmailActionType.moveToSpam:
        cancelSelectionMode(context);
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailbox);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToSpam(listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.unSpam:
        cancelSelectionMode(context);
        unSpamSelectedMultipleEmail(listEmails);
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    textInputSearchController.dispose();
    resultSearchScrollController.dispose();
    _deBouncerTime.cancel();
    dashBoardViewStateWorker.dispose();
    super.onClose();
  }
}