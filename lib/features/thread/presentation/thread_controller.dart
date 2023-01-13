import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_email_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_presentation_email_extensions.dart';
import 'package:tmail_ui_user/features/thread/presentation/mixin/email_action_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

typedef StartRangeSelection = int;
typedef EndRangeSelection = int;

class ThreadController extends BaseController with EmailActionController {

  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final RefreshChangesEmailsInMailboxInteractor _refreshChangesEmailsInMailboxInteractor;
  final LoadMoreEmailsInMailboxInteractor _loadMoreEmailsInMailboxInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;
  final CachingManager _cachingManager;
  final GetEmailByIdInteractor _getEmailByIdInteractor;

  final listEmailDrag = <PresentationEmail>[].obs;
  bool _rangeSelectionMode = false;
  final openingEmail = RxBool(false);

  bool canLoadMore = true;
  bool canSearchMore = true;
  bool _isLoadingMore = false;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;
  NavigationRouter? _navigationRouter;
  final ScrollController listEmailController = ScrollController();
  final FocusNode focusNodeKeyBoard = FocusNode();
  final latestEmailSelectedOrUnselected = Rxn<PresentationEmail>();

  Set<Comparator>? get _sortOrder => <Comparator>{}
    ..add(EmailComparator(EmailComparatorProperty.receivedAt)
      ..setIsAscending(false));

  bool get isLoadingMore => _isLoadingMore;

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  SearchController get searchController => mailboxDashBoardController.searchController;

  SearchEmailFilter get _searchEmailFilter => searchController.searchEmailFilter.value;

  String get currentTextSearch => searchController.searchInputController.text;

  SearchQuery? get searchQuery => searchController.searchEmailFilter.value.text;

  ThreadController(
    this._getEmailsInMailboxInteractor,
    this._refreshChangesEmailsInMailboxInteractor,
    this._loadMoreEmailsInMailboxInteractor,
    this._searchEmailInteractor,
    this._searchMoreEmailInteractor,
    this._cachingManager,
    this._getEmailByIdInteractor,
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    super.onInit();
  }

  @override
  void onReady() {
    dispatchState(Right(LoadingState()));
    super.onReady();
  }

  @override
  void onClose() {
    listEmailController.dispose();
    focusNodeKeyBoard.dispose();
    super.onClose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(
      (failure) {
        if (failure is SearchEmailFailure) {
          mailboxDashBoardController.emailsInCurrentMailbox.clear();
        } else if (failure is SearchMoreEmailFailure || failure is LoadMoreEmailsFailure) {
          _isLoadingMore = false;
        } else if (failure is GetEmailByIdFailure) {
          openingEmail.value = false;
          _navigationRouter = null;
          pushAndPop(AppRoutes.unknownRoutePage);
        }
      },
      (success) {
        if (success is GetAllEmailSuccess) {
          _getAllEmailSuccess(success);
        } else if (success is RefreshChangesAllEmailSuccess) {
          _refreshChangesAllEmailSuccess(success);
        } else if (success is LoadMoreEmailsSuccess) {
          _loadMoreEmailsSuccess(success);
        } else if (success is SearchEmailSuccess) {
          _searchEmailsSuccess(success);
        } else if (success is SearchMoreEmailSuccess) {
          _searchMoreEmailsSuccess(success);
        } else if (success is SearchingMoreState || success is LoadingMoreState) {
          _isLoadingMore = true;
        } else if (success is GetEmailByIdLoading) {
          openingEmail.value = true;
        } else if (success is GetEmailByIdSuccess) {
          openingEmail.value = false;
          _openEmailDetailView(success.email);
        }
      }
    );
  }

  @override
  void onDone() {}

  @override
  void onError(error) {
    _handleErrorGetAllOrRefreshChangesEmail(error);
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.selectedMailbox, (mailbox) {
      if (mailbox is PresentationMailbox) {
        if (_currentMailboxId != mailbox.id) {
          _currentMailboxId = mailbox.id;
          _resetToOriginalValue();
          _getAllEmail();
        }
      } else if (mailbox == null) { // disable current mailbox when search active
        _currentMailboxId = null;
        _resetToOriginalValue();
      }
    });

    ever(searchController.searchState, (searchState) {
      if (searchState is SearchState) {
        if (searchState.searchStatus == SearchStatus.ACTIVE) {
          cancelSelectEmail();
        }
      }
    });

    ever(searchController.isAdvancedSearchViewOpen, (hasOpen) {
      if (hasOpen == true) {
        mailboxDashBoardController.filterMessageOption.value = FilterMessageOption.all;
      }
    });

    ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is RefreshAllEmailAction) {
        refreshAllEmail();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is SelectionAllEmailAction) {
        setSelectAllEmailAction();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is CancelSelectionAllEmailAction) {
        cancelSelectEmail();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is FilterMessageAction) {
        filterMessagesAction(action.context, action.option);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is HandleEmailActionTypeAction) {
        pressEmailSelectionAction(action.context, action.emailAction, action.listEmailSelected);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is OpenEmailDetailedFromSuggestionQuickSearchAction) {
        final mailboxContain = action.presentationEmail.findMailboxContain(mailboxDashBoardController.mapMailboxById);
        final newEmail = generateEmailByPlatform(action.presentationEmail);
        pressEmailAction(
          action.context,
          EmailActionType.preview,
          newEmail,
          mailboxContain: mailboxContain
        );
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is StartSearchEmailAction) {
        cancelSelectEmail();
        _updateSearchRouteOnBrowser();
        _searchEmail();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is EmptyTrashAction) {
        deleteSelectionEmailsPermanently(action.context, DeleteActionType.all);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is SelectEmailByIdAction) {
        _navigationRouter = action.navigationRouter;
        if (_navigationRouter!.searchQuery != null) {
          _activateSearchFromRouter();
        }
        _getEmailByIdAction(_navigationRouter!.emailId!);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is SearchEmailByQueryAction) {
        _navigationRouter = action.navigationRouter;
        _activateSearchFromRouter();
        mailboxDashBoardController.clearDashBoardAction();
      }
    });

    ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is RefreshChangeEmailAction) {
        if (action.newState != _currentEmailState) {
          _refreshEmailChanges();
        }
        mailboxDashBoardController.clearEmailUIAction();
      }
    });

    ever(mailboxDashBoardController.viewState, (viewState) {
      if (viewState is Either) {
        viewState.map((success) {
          if (success is MarkAsEmailReadSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MoveToMailboxSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsStarEmailSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is DeleteEmailPermanentlySuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is SaveEmailAsDraftsSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is RemoveEmailDraftsSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is SendEmailSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is UpdateEmailDraftsSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsMailboxReadAllSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MoveMultipleEmailToMailboxAllSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsStarMultipleEmailAllSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsMultipleEmailReadAllSuccess) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
            _refreshEmailChanges(currentEmailState: success.currentEmailState);
          } else if (success is EmptyTrashFolderSuccess) {
            refreshAllEmail();
          }
        });
      }
    });
  }

  void _activateSearchFromRouter() {
    searchController.autoFocus.value = false;
    searchController.enableSearch();
    searchController.updateTextSearch(_navigationRouter!.searchQuery!.value);
    searchController.updateFilterEmail(text: _navigationRouter!.searchQuery!);
    if (currentContext != null) {
      FocusScope.of(currentContext!).unfocus();
    }
    searchController.searchFocus.unfocus();
    _searchEmail();
  }

  void _handleErrorGetAllOrRefreshChangesEmail(dynamic error) async {
    logError('ThreadController::_handleErrorGetAllOrRefreshChangesEmail():Error: $error');
    if (error is CannotCalculateChangesMethodResponseException) {
      await _cachingManager.cleanEmailCache();
      _getAllEmail();
    } else {
      super.onError(error);
    }
  }

  void _getAllEmail() {
    if (_accountId != null) {
      _getAllEmailAction(_accountId!, mailboxId: _currentMailboxId);
    }
  }

  void _resetToOriginalValue() {
    dispatchState(Right(LoadingState()));
    mailboxDashBoardController.emailsInCurrentMailbox.clear();
    canLoadMore = true;
    _isLoadingMore = false;
    cancelSelectEmail();
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    _currentEmailState = success.currentEmailState;
    log('ThreadController::_getAllEmailSuccess():_currentEmailState: $_currentEmailState');
    final newListEmail = success.emailList.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: currentMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(newListEmail);
    if (listEmailController.hasClients) {
      listEmailController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  void _refreshChangesAllEmailSuccess(RefreshChangesAllEmailSuccess success) {
    _currentEmailState = success.currentEmailState;

    final emailsBeforeChanges = mailboxDashBoardController.emailsInCurrentMailbox;
    final emailsAfterChanges = success.emailList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);
    final emailListSynced = newListEmail.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: currentMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(emailListSynced);

    if (mailboxDashBoardController.emailsInCurrentMailbox.isEmpty) {
      refreshAllEmail();
    }
  }

  void _getAllEmailAction(AccountId accountId, {MailboxId? mailboxId}) {
    consumeState(_getEmailsInMailboxInteractor.execute(
      accountId,
      limit: ThreadConstants.defaultLimit,
      sort: _sortOrder,
      emailFilter: EmailFilter(
        filter: _getFilterCondition(),
        filterOption: mailboxDashBoardController.filterMessageOption.value,
        mailboxId: mailboxId ?? _currentMailboxId),
      propertiesCreated: ThreadConstants.propertiesDefault,
      propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
    ));
  }

  EmailFilterCondition _getFilterCondition({bool isLoadMore = false}) {
    final lastEmail = mailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty
      ? mailboxDashBoardController.emailsInCurrentMailbox.last
      : null;
    final mailboxIdSelected = mailboxDashBoardController.selectedMailbox.value?.id;
    switch(mailboxDashBoardController.filterMessageOption.value) {
      case FilterMessageOption.all:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          before: isLoadMore ? lastEmail?.receivedAt : null
        );
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: isLoadMore ? lastEmail?.receivedAt : null
        );
      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasAttachment: true,
          before: isLoadMore ? lastEmail?.receivedAt : null
        );
      case FilterMessageOption.starred:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: isLoadMore ? lastEmail?.receivedAt : null
        );
    }
  }

  void refreshAllEmail() {
    dispatchState(Right(LoadingState()));
    canLoadMore = true;
    cancelSelectEmail();

    if (searchController.isSearchEmailRunning) {
      searchController.searchEmailFilter.value = _searchEmailFilter.clearBeforeDate();
      _searchEmail(limit: limitEmailFetched);
    } else {
      _getAllEmail();
    }
  }

  UnsignedInt get limitEmailFetched {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;
    final limit = emailsInCurrentMailbox.isNotEmpty
      ? UnsignedInt(emailsInCurrentMailbox.length)
      : ThreadConstants.defaultLimit;
    return limit;
  }

  void _refreshEmailChanges({jmap.State? currentEmailState}) {
    log('ThreadController::_refreshEmailChanges(): currentEmailState: $currentEmailState');
    if (searchController.isSearchEmailRunning) {
      searchController.searchEmailFilter.value = _searchEmailFilter.clearBeforeDate();
      _searchEmail(limit: limitEmailFetched);
    } else {
      final newEmailState = currentEmailState ?? _currentEmailState;
      log('ThreadController::_refreshEmailChanges(): newEmailState: $newEmailState');
      if (_accountId != null && newEmailState != null) {
        consumeState(_refreshChangesEmailsInMailboxInteractor.execute(
            _accountId!,
            newEmailState,
            sort: _sortOrder,
            propertiesCreated: ThreadConstants.propertiesDefault,
            propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
            emailFilter: EmailFilter(
              filter: _getFilterCondition(),
              filterOption: mailboxDashBoardController.filterMessageOption.value,
              mailboxId: _currentMailboxId),
        ));
      }
    }
  }

  void loadMoreEmails() {
    log('ThreadController::loadMoreEmails()');
    if (canLoadMore && _accountId != null) {
      consumeState(_loadMoreEmailsInMailboxInteractor.execute(
        GetEmailRequest(
            _accountId!,
            limit: ThreadConstants.defaultLimit,
            sort: _sortOrder,
            filterOption: mailboxDashBoardController.filterMessageOption.value,
            filter: _getFilterCondition(isLoadMore: true),
            properties: ThreadConstants.propertiesDefault,
            lastEmailId: mailboxDashBoardController.emailsInCurrentMailbox.last.id)
      ));
    }
  }

  bool _belongToCurrentMailboxId(PresentationEmail email) {
    return (email.mailboxIds != null && email.mailboxIds!.keys.contains(currentMailbox?.id));
  }

  bool _notDuplicatedInCurrentList(PresentationEmail email) {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;
    return emailsInCurrentMailbox.isEmpty ||
      !emailsInCurrentMailbox.map((element) => element.id).contains(email.id);
  }

  void _loadMoreEmailsSuccess(LoadMoreEmailsSuccess success) {
    if (success.emailList.isNotEmpty) {
      final appendableList = success.emailList
        .where(_belongToCurrentMailboxId)
        .where(_notDuplicatedInCurrentList)
        .toList()
        .syncPresentationEmail(
          mapMailboxById: mailboxDashBoardController.mapMailboxById,
          selectedMailbox: currentMailbox,
          searchQuery: searchController.searchQuery,
          isSearchEmailRunning: searchController.isSearchEmailRunning
        );

      mailboxDashBoardController.emailsInCurrentMailbox.addAll(appendableList);
    } else {
      canLoadMore = false;
    }
    _isLoadingMore = false;
  }

  SelectMode getSelectMode(PresentationEmail presentationEmail, PresentationEmail? selectedEmail) {
    return presentationEmail.id == selectedEmail?.id
      ? SelectMode.ACTIVE
      : SelectMode.INACTIVE;
  }

  Tuple2<StartRangeSelection,EndRangeSelection> _getSelectionEmailsRange(PresentationEmail presentationEmailSelected) {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;
    final emailSelectedIndex = emailsInCurrentMailbox
      .indexWhere((e) => e.id == presentationEmailSelected.id);
    final latestEmailSelectedOrUnselectedIndex = emailsInCurrentMailbox
      .indexWhere((e) => e.id == latestEmailSelectedOrUnselected.value?.id);
    if (emailSelectedIndex > latestEmailSelectedOrUnselectedIndex) {
      return Tuple2(latestEmailSelectedOrUnselectedIndex, emailSelectedIndex);
    } else {
      return Tuple2(emailSelectedIndex, latestEmailSelectedOrUnselectedIndex);
    }
  }

  bool _checkAllowMakeRangeEmailsSelected(Tuple2<StartRangeSelection,EndRangeSelection> selectionEmailsRange) {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;
    return latestEmailSelectedOrUnselected.value?.selectMode == SelectMode.ACTIVE &&
      !emailsInCurrentMailbox.sublist(selectionEmailsRange.value1, selectionEmailsRange.value2).every((e) => e.selectMode == SelectMode.ACTIVE) ||
      latestEmailSelectedOrUnselected.value?.selectMode == SelectMode.INACTIVE &&
      emailsInCurrentMailbox.sublist(selectionEmailsRange.value1, selectionEmailsRange.value2).every((e) => e.selectMode == SelectMode.INACTIVE);
  }

  void _applySelectModeToRangeEmails(Tuple2<StartRangeSelection,EndRangeSelection> selectionEmailsRange, SelectMode selectMode) {
    final newEmailList = mailboxDashBoardController.emailsInCurrentMailbox
      .asMap()
      .map((index, email) {
        return MapEntry(index, index >= selectionEmailsRange.value1 && index <= selectionEmailsRange.value2 ? email.toSelectedEmail(selectMode: selectMode) : email);
      })
      .values
      .toList();
    mailboxDashBoardController.updateEmailList(newEmailList);
  }

  void _rangeSelectionEmailsAction(PresentationEmail presentationEmailSelected) {
    final selectionEmailsRange = _getSelectionEmailsRange(presentationEmailSelected);

    if (_checkAllowMakeRangeEmailsSelected(selectionEmailsRange)) {
      _applySelectModeToRangeEmails(selectionEmailsRange, SelectMode.ACTIVE);
    } else {
      _applySelectModeToRangeEmails(selectionEmailsRange, SelectMode.INACTIVE);
    }
  }

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;

    if (_rangeSelectionMode && latestEmailSelectedOrUnselected.value != null && latestEmailSelectedOrUnselected.value?.id != presentationEmailSelected.id) {
      _rangeSelectionEmailsAction(presentationEmailSelected);
    } else {
      final newEmailList = emailsInCurrentMailbox
        .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
        .toList();
      mailboxDashBoardController.updateEmailList(newEmailList);
    }

    latestEmailSelectedOrUnselected.value = emailsInCurrentMailbox
      .firstWhereOrNull((e) => e.id == presentationEmailSelected.id);
    focusNodeKeyBoard.requestFocus();
    if (_isUnSelectedAll()) {
      mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
      mailboxDashBoardController.listEmailSelected.clear();
    } else {
      if (mailboxDashBoardController.currentSelectMode.value == SelectMode.INACTIVE) {
        mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
      }
      mailboxDashBoardController.listEmailSelected.value = listEmailSelected;
    }
  }

  void enableSelectionEmail() {
    mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
  }

  void setSelectAllEmailAction() {
    final newEmailList = mailboxDashBoardController.emailsInCurrentMailbox
      .map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE))
      .toList();
    mailboxDashBoardController.updateEmailList(newEmailList);
    mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
    mailboxDashBoardController.listEmailSelected.value = listEmailSelected;
  }

  List<PresentationEmail> get listEmailSelected =>
    mailboxDashBoardController.emailsInCurrentMailbox.listEmailSelected;

  bool _isUnSelectedAll() {
    return mailboxDashBoardController.emailsInCurrentMailbox
      .every((email) => email.selectMode == SelectMode.INACTIVE);
  }

  void cancelSelectEmail() {
    final newEmailList = mailboxDashBoardController.emailsInCurrentMailbox
      .map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE))
      .toList();
    mailboxDashBoardController.updateEmailList(newEmailList);
    mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
    mailboxDashBoardController.listEmailSelected.clear();
  }

  void closeFilterMessageActionSheet() {
    popBack();
  }

  void filterMessagesAction(BuildContext context, FilterMessageOption filterOption) {
    popBack();

    final newFilterOption = mailboxDashBoardController.filterMessageOption.value == filterOption
        ? FilterMessageOption.all
        : filterOption;

    mailboxDashBoardController.filterMessageOption.value = newFilterOption;

    _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: newFilterOption.getMessageToast(context),
        icon: newFilterOption.getIconToast(_imagePaths));

    if (searchController.isSearchEmailRunning) {
      _searchEmail(filterCondition: _getFilterCondition());
    } else {
      refreshAllEmail();
    }
  }

  bool isSearchActive() => searchController.isSearchEmailRunning;

  bool get isAllSearchInActive => !searchController.isSearchActive() &&
    searchController.isAdvancedSearchViewOpen.isFalse;

  void clearTextSearch() {
    searchController.clearTextSearch();
  }

  void _searchEmail({UnsignedInt? limit, EmailFilterCondition? filterCondition}) {
    if (_accountId != null) {
      searchController.activateSimpleSearch();

      filterCondition = EmailFilterCondition(
        notKeyword: filterCondition?.notKeyword,
        hasKeyword: filterCondition?.hasKeyword,
        hasAttachment: filterCondition?.hasAttachment,
      );

      consumeState(_searchEmailInteractor.execute(
        _accountId!,
        limit: limit ?? ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: _searchEmailFilter.mappingToEmailFilterCondition(moreFilterCondition: filterCondition),
        properties: ThreadConstants.propertiesDefault,
      ));
    }
  }

  void _updateSearchRouteOnBrowser() {
    if (BuildUtils.isWeb) {
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          searchQuery: searchQuery,
          dashboardType: DashboardType.search)
      );
      RouteUtils.updateRouteOnBrowser('SearchEmail', route);
    }
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsSearchBeforeChanges = mailboxDashBoardController.emailsInCurrentMailbox;
    final emailsSearchAfterChanges = resultEmailSearchList;
    final newListEmailSearch = emailsSearchAfterChanges.combine(emailsSearchBeforeChanges);
    final newEmailListSynced = newListEmailSearch.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: currentMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(newEmailListSynced);
    searchController.autoFocus.value = true;
  }

  void searchMoreEmails() {
    if (canSearchMore && _accountId != null) {
      final lastEmail = mailboxDashBoardController.emailsInCurrentMailbox.last;
      searchController.updateFilterEmail(before: lastEmail.receivedAt);
      consumeState(_searchMoreEmailInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
        lastEmailId: lastEmail.id
      ));
    }
  }

  void _searchMoreEmailsSuccess(SearchMoreEmailSuccess success) {
    if (success.emailList.isNotEmpty) {
      final resultEmailSearchList = success.emailList
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
          .where((email) => !mailboxDashBoardController.emailsInCurrentMailbox.contains(email))
          .toList()
          .syncPresentationEmail(
            mapMailboxById: mailboxDashBoardController.mapMailboxById,
            selectedMailbox: currentMailbox,
            searchQuery: searchController.searchQuery,
            isSearchEmailRunning: searchController.isSearchEmailRunning
          );
      mailboxDashBoardController.emailsInCurrentMailbox.addAll(resultEmailSearchList);
    } else {
      canSearchMore = false;
    }
    _isLoadingMore = false;
  }

  bool isSelectionEnabled() => mailboxDashBoardController.isSelectionEnabled();

  void pressEmailSelectionAction(BuildContext context, EmailActionType actionType, List<PresentationEmail> selectionEmail) {
    switch(actionType) {
      case EmailActionType.markAsRead:
        cancelSelectEmail();
        markAsReadSelectedMultipleEmail(selectionEmail, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        cancelSelectEmail();
        markAsReadSelectedMultipleEmail(selectionEmail, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        cancelSelectEmail();
        markAsStarSelectedMultipleEmail(selectionEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        cancelSelectEmail();
        markAsStarSelectedMultipleEmail(selectionEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        cancelSelectEmail();
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(context, selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelSelectEmail();
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToTrash(selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.deletePermanently:
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          deleteSelectionEmailsPermanently(
            context,
            DeleteActionType.multiple,
            listEmails: selectionEmail,
            mailboxCurrent: mailboxContainCurrent,
            onCancelSelectionEmail: () => cancelSelectEmail());
        }
        break;
      case EmailActionType.moveToSpam:
        cancelSelectEmail();
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToSpam(selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.unSpam:
        cancelSelectEmail();
        unSpamSelectedMultipleEmail(selectionEmail);
        break;
      default:
        break;
    }
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
          previewEmail(selectedEmail);
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
      case EmailActionType.openInNewTab:
        openEmailInNewTabAction(context, selectedEmail);
        break;
      default:
        break;
    }
  }

  bool get isMailboxTrash => mailboxDashBoardController.selectedMailbox.value?.isTrash == true;

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openMailboxMenuDrawer();
  }

  void goToSearchView() {
    SearchEmailBindings().dependencies();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
  }

  void calculateDragValue(PresentationEmail? currentPresentationEmail) {
    if(currentPresentationEmail != null) {
      if(mailboxDashBoardController.listEmailSelected.findEmail(currentPresentationEmail.id) != null){
        listEmailDrag.clear();
        listEmailDrag.addAll(mailboxDashBoardController.listEmailSelected);
      } else {
        listEmailDrag.clear();
        listEmailDrag.add(currentPresentationEmail);
      }
    }
  }

  KeyEventResult handleKeyEvent(FocusNode node, RawKeyEvent event) {
    final shiftEvent = event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight;
    if (event is RawKeyDownEvent && shiftEvent) {
      _rangeSelectionMode = true;
    }

    if (event is RawKeyUpEvent && shiftEvent) {
      _rangeSelectionMode = false;
    }
    return shiftEvent
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  PresentationEmail generateEmailByPlatform(PresentationEmail currentEmail) {
    if (BuildUtils.isWeb) {
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          emailId: currentEmail.id,
          mailboxId: currentMailbox?.id,
          searchQuery: searchController.isSearchEmailRunning
            ? searchQuery
            : null,
          dashboardType: searchController.isSearchEmailRunning
            ? DashboardType.search
            : DashboardType.normal
        )
      );
      final emailOnWeb = currentEmail.withRouteWeb(route);
      return emailOnWeb;
    } else {
      return currentEmail;
    }
  }

  void _getEmailByIdAction(EmailId emailId) {
    if (_accountId != null) {
      consumeState(_getEmailByIdInteractor.execute(
        _accountId!,
        emailId,
        properties: ThreadConstants.propertiesDefault));
    }
  }

  void _openEmailDetailView(PresentationEmail email) {
    if (currentContext != null) {
      final mailboxContain = email.findMailboxContain(mailboxDashBoardController.mapMailboxById);
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          emailId: email.id,
          mailboxId: _navigationRouter?.mailboxId,
          searchQuery: _navigationRouter?.searchQuery,
          dashboardType: _navigationRouter?.dashboardType ?? DashboardType.normal
        )
      );
      pressEmailAction(
        currentContext!,
        EmailActionType.preview,
        email.withRouteWeb(route),
        mailboxContain: mailboxContain
      );
    }
    _navigationRouter = null;
  }
}