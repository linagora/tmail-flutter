
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/contact/presentation/model/contact_arguments.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/search/domain/state/refresh_changes_search_email_state.dart';
import 'package:tmail_ui_user/features/search/domain/usecases/refresh_changes_search_email_interactor.dart';
import 'package:tmail_ui_user/features/search/presentation/model/search_more_state.dart';
import 'package:tmail_ui_user/features/search/presentation/model/simple_search_filter.dart';
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
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

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
  final simpleSearchFilter = Rx<SimpleSearchFilter>(SimpleSearchFilter());
  final searchIsRunning = RxBool(false);
  final emailReceiveTimeType = Rxn<EmailReceiveTimeType>();
  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);

  late Debouncer<String> _deBouncerTime;
  late Worker dashBoardViewStateWorker;
  late SearchMoreState searchMoreState;
  late bool canSearchMore;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;

  Session? get session => mailboxDashBoardController.sessionCurrent;

  UserProfile? get userProfile => mailboxDashBoardController.userProfile.value;

  SearchQuery? get searchQuery => simpleSearchFilter.value.text;

  RxList<PresentationEmail> get listResultSearch => mailboxDashBoardController.listResultSearch;

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

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
        const Duration(milliseconds: 500),
        initialValue: '');
    _deBouncerTime.values.listen((value) async {
      log('SearchEmailController::_initializeDebounceTimeTextSearchChange(): $value');
      currentSearchText.value = value;
      _updateSimpleSearchFilter(text: value.isNotEmpty ? SearchQuery(value) : null);
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
      simpleSearchFilter.value = simpleSearchFilter.value.toSimpleSearchFilterByBefore(newBefore: null);

      consumeState(_refreshChangesSearchEmailInteractor.execute(
        accountId!,
        limit: limit,
        sort: <Comparator>{}
          ..add(EmailComparator(EmailComparatorProperty.receivedAt)
            ..setIsAscending(false)),
        filter: simpleSearchFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
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
            filter: simpleSearchFilter.value.mappingToEmailFilterCondition(),
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
      cancelSelectionMode(context);

      consumeState(_searchEmailInteractor.execute(
        accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: <Comparator>{}
          ..add(EmailComparator(EmailComparatorProperty.receivedAt)
            ..setIsAscending(false)),
        filter: simpleSearchFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
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
      _updateSimpleSearchFilter(before: lastEmail.receivedAt);

      consumeState(_searchMoreEmailInteractor.execute(
          accountId!,
          limit: ThreadConstants.defaultLimit,
          sort: <Comparator>{}
            ..add(EmailComparator(EmailComparatorProperty.receivedAt)
              ..setIsAscending(false)),
          filter: simpleSearchFilter.value.mappingToEmailFilterCondition(),
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
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
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
    _updateSimpleSearchFilter(text: SearchQuery(query));
    _searchEmailAction(context);
  }

  void searchEmailByRecentAction(BuildContext context, RecentSearch recentSearch) {
    setTextInputSearchForm(recentSearch.value);
    _updateSimpleSearchFilter(text: SearchQuery(recentSearch.value));
    _searchEmailAction(context);
  }

  void submitSearchAction(BuildContext context, String query) {
    _updateSimpleSearchFilter(text: SearchQuery(query));
    _searchEmailAction(context);
  }

  void selectQuickSearchFilter(BuildContext context, QuickSearchFilter filter) {
    _selectQuickSearchFilter(filter);
    _searchEmailAction(context);
  }

  bool checkQuickSearchFilterSelected(QuickSearchFilter filter) {
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        return simpleSearchFilter.value.hasAttachment == true;
      case QuickSearchFilter.last7Days:
        if (emailReceiveTimeType.value != null) {
          return true;
        }
        return simpleSearchFilter.value.emailReceiveTimeType == EmailReceiveTimeType.last7Days;
      default:
        return false;
    }
  }

  void _selectQuickSearchFilter(QuickSearchFilter filter) {
    final filterSelected = checkQuickSearchFilterSelected(filter);
    switch (filter) {
      case QuickSearchFilter.hasAttachment:
        _updateSimpleSearchFilter(hasAttachment: !filterSelected);
        break;
      case QuickSearchFilter.last7Days:
        if (filterSelected) {
          _setEmailReceiveTimeType(null);
          _updateSimpleSearchFilter(emailReceiveTimeType: EmailReceiveTimeType.allTime);
        } else {
          _setEmailReceiveTimeType(EmailReceiveTimeType.last7Days);
          _updateSimpleSearchFilter(emailReceiveTimeType: EmailReceiveTimeType.last7Days);
        }
        break;
      default:
        break;
    }
  }

  void _setEmailReceiveTimeType(EmailReceiveTimeType? receiveTimeType) {
    emailReceiveTimeType.value = receiveTimeType;
  }

  void selectReceiveTimeQuickSearchFilter(BuildContext context, EmailReceiveTimeType? emailReceiveTimeType) {
    popBack();

    if (emailReceiveTimeType != null) {
      _updateSimpleSearchFilter(
          emailReceiveTimeType: emailReceiveTimeType,
          text: searchQuery == null ? SearchQuery.initial() : simpleSearchFilter.value.text);
    } else {
      _updateSimpleSearchFilter(
          emailReceiveTimeType: EmailReceiveTimeType.allTime,
          text: searchQuery == null ? SearchQuery.initial() : simpleSearchFilter.value.text);
    }
    _setEmailReceiveTimeType(emailReceiveTimeType);
    _searchEmailAction(context);
  }

  void selectMailboxForSearchFilter(BuildContext context, PresentationMailbox? mailbox) async {
    final arguments = DestinationPickerArguments(
        mailboxDashBoardController.accountId.value!,
        MailboxActions.select,
        mailboxIdSelected: mailbox?.id);

    if (BuildUtils.isWeb) {
      showDialogDestinationPicker(
          context: context,
          arguments: arguments,
          onSelectedMailbox: (destinationMailbox) {
            final mailboxSelected = destinationMailbox == PresentationMailbox.unifiedMailbox ? null : destinationMailbox;
            if (mailbox?.id != mailboxSelected?.id) {
              simpleSearchFilter.value = simpleSearchFilter.value.toSimpleSearchFilterByMailbox(newMailbox: mailboxSelected);
              _searchEmailAction(context);
            }
          });
    } else {
      final destinationMailbox = await push(
          AppRoutes.destinationPicker,
          arguments: arguments);

      if (destinationMailbox is PresentationMailbox) {
        final mailboxSelected = destinationMailbox == PresentationMailbox.unifiedMailbox ? null : destinationMailbox;
        if (mailbox?.id != mailboxSelected?.id) {
          simpleSearchFilter.value = simpleSearchFilter.value.toSimpleSearchFilterByMailbox(newMailbox: mailboxSelected);
          _searchEmailAction(context);
        }
      }
    }
  }

  void selectContactForSearchFilter(
      BuildContext context,
      PrefixEmailAddress prefixEmailAddress
  ) async {
    if (accountId != null && session != null) {
      final listContactSelected = simpleSearchFilter.value.getContactApplied(prefixEmailAddress);
      final arguments = ContactArguments(accountId!, session!, listContactSelected);

      if (BuildUtils.isWeb) {
        showDialogContactView(
            context: context,
            arguments: arguments,
            onSelectedContact: (newContact) {
              _dispatchApplyContactAction(
                  context,
                  listContactSelected,
                  prefixEmailAddress,
                  newContact);
            });
      } else {
        final newContact = await push(
            AppRoutes.contact,
            arguments: arguments);

        if (newContact is EmailAddress) {
          _dispatchApplyContactAction(
              context,
              listContactSelected,
              prefixEmailAddress,
              newContact);
        }
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
            simpleSearchFilter.value.from.clear();
          } else {
            simpleSearchFilter.value.from.clear();
            simpleSearchFilter.value.from.add(newContact.email!);
          }
          break;
        case PrefixEmailAddress.to:
          if (listContactSelected.first == newContact.email) {
            simpleSearchFilter.value.to.clear();
          } else {
            simpleSearchFilter.value.to.clear();
            simpleSearchFilter.value.to.add(newContact.email!);
          }
          break;
        default:
          break;
      }
    } else {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.from:
          simpleSearchFilter.value.from.add(newContact.email!);
          break;
        case PrefixEmailAddress.to:
          simpleSearchFilter.value.to.add(newContact.email!);
          break;
        default:
          break;
      }
    }

    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        _updateSimpleSearchFilter(from: simpleSearchFilter.value.from);
        break;
      case PrefixEmailAddress.to:
        _updateSimpleSearchFilter(to: simpleSearchFilter.value.to);
        break;
      default:
        break;
    }

    _searchEmailAction(context);
  }

  void _updateSimpleSearchFilter({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
  }) {
    simpleSearchFilter.value = simpleSearchFilter.value.copyWith(
      from: from,
      to: to,
      text: text,
      mailbox: mailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: before,
    );
    simpleSearchFilter.refresh();
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
    simpleSearchFilter.value = SimpleSearchFilter();
  }

  void closeSearchView(BuildContext context) {
    log('SearchEmailController::closeSearchView(): ');
    clearAllTextInputSearchForm();
    clearAllResultSearch();
    FocusScope.of(context).unfocus();
    mailboxDashBoardController.searchController.disableAllSearchEmail();
    mailboxDashBoardController.dispatchAction(SelectMailboxDefaultAction());
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
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
        moveToMailbox(context, selectedEmail, mailboxContain: mailboxContain);
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
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(context, listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelSelectionMode(context);
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToTrash(listEmails, mailboxContainCurrent);
        }
        break;
      case EmailActionType.deletePermanently:
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
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
        final mailboxContainCurrent = listEmails.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById);
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

  PresentationEmail generateEmailByPlatform(PresentationEmail currentEmail) {
    if (BuildUtils.isWeb) {
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          emailId: currentEmail.id,
          searchQuery: searchQuery,
          dashboardType: DashboardType.search
        )
      );
      final emailOnWeb = currentEmail.withRouteWeb(route);
      return emailOnWeb;
    } else {
      return currentEmail;
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