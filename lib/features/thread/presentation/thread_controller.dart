import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
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
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_changes_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef StartRangeSelection = int;
typedef EndRangeSelection = int;

class ThreadController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _appToast = Get.find<AppToast>();

  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final RefreshChangesEmailsInMailboxInteractor _refreshChangesEmailsInMailboxInteractor;
  final LoadMoreEmailsInMailboxInteractor _loadMoreEmailsInMailboxInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;
  final DeleteMultipleEmailsPermanentlyInteractor _deleteMultipleEmailsPermanentlyInteractor;
  final EmptyTrashFolderInteractor _emptyTrashFolderInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final CachingManager _cachingManager;

  final listEmailDrag = <PresentationEmail>[].obs;
  bool _rangeSelectionMode = false;
  bool canLoadMore = true;
  bool canSearchMore = true;
  bool _isLoadingMore = false;
    get isLoadingMore => _isLoadingMore;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;
  final ScrollController listEmailController = ScrollController();
  final FocusNode focusNodeKeyBoard = FocusNode();
  final latestEmailSelectedOrUnselected = Rxn<PresentationEmail>();
  late Worker mailboxWorker, searchWorker, dashboardActionWorker, viewStateWorker, advancedSearchFilterWorker;

  Set<Comparator>? get _sortOrder => <Comparator>{}
    ..add(EmailComparator(EmailComparatorProperty.receivedAt)
      ..setIsAscending(false));

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

  SearchController get searchController => mailboxDashBoardController.searchController;

  SearchEmailFilter get _searchEmailFilter => searchController.searchEmailFilter.value;

  String get currentTextSearch => searchController.searchInputController.text;

  SearchQuery? get searchQuery => searchController.searchEmailFilter.value.text;

  RxList<PresentationEmail> get emailList => mailboxDashBoardController.emailsInCurrentMailbox;

  ThreadController(
    this._getEmailsInMailboxInteractor,
    this._markAsMultipleEmailReadInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._markAsStarEmailInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._refreshChangesEmailsInMailboxInteractor,
    this._loadMoreEmailsInMailboxInteractor,
    this._searchEmailInteractor,
    this._searchMoreEmailInteractor,
    this._deleteMultipleEmailsPermanentlyInteractor,
    this._emptyTrashFolderInteractor,
    this._markAsEmailReadInteractor,
    this._moveToMailboxInteractor,
    this._cachingManager,
  );

  @override
  void onInit() {
    _initWorker();
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
    _clearWorker();
    super.onClose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(
      (failure) {
        if (failure is SearchEmailFailure) {
          emailList.clear();
        } else if (failure is SearchMoreEmailFailure || failure is LoadMoreEmailsFailure) {
          _isLoadingMore = false;
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
        }
      }
    );
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is MarkAsMultipleEmailReadAllFailure
            || failure is MarkAsMultipleEmailReadFailure) {
          _markAsReadSelectedMultipleEmailFailure(failure);
        } else if (failure is MarkAsStarMultipleEmailAllFailure
            || failure is MarkAsStarMultipleEmailFailure) {
          _markAsStarMultipleEmailFailure(failure);
        }
      },
      (success) {
        if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsReadSelectedMultipleEmailSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is MarkAsStarEmailSuccess) {
          _markAsStarEmailSuccess(success);
        } else if (success is MarkAsStarMultipleEmailAllSuccess
            || success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
          _markAsStarMultipleEmailSuccess(success);
        } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess
            || success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
          _deleteMultipleEmailsPermanentlySuccess(success);
        } else if (success is EmptyTrashFolderSuccess) {
          _emptyTrashFolderSuccess(success);
        } else if (success is MarkAsEmailReadSuccess) {
          _markAsEmailReadSuccess(success);
        } else if (success is MoveToMailboxSuccess) {
          _moveToMailboxSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {
    _handleErrorGetAllOrRefreshChangesEmail(error);
  }

  void _initWorker() {
    mailboxWorker = ever(mailboxDashBoardController.selectedMailbox, (mailbox) {
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

    searchWorker = ever(searchController.searchState, (searchState) {
      if (searchState is SearchState) {
        if (searchState.searchStatus == SearchStatus.ACTIVE) {
          cancelSelectEmail();
        }
      }
    });

    advancedSearchFilterWorker = ever(searchController.isAdvancedSearchViewOpen, (hasOpen) {
      if (hasOpen == true) {
        mailboxDashBoardController.filterMessageOption.value = FilterMessageOption.all;
      }
    });

    dashboardActionWorker = ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is DashBoardAction) {
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
          final mailboxContain = action.presentationEmail
              .findMailboxContain(mailboxDashBoardController.mapMailboxById);
          pressEmailAction(
              action.context,
              EmailActionType.preview,
              action.presentationEmail,
              mailboxContain: mailboxContain);
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is StartSearchEmailAction) {
          cancelSelectEmail();
          _searchEmail();
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is EmptyTrashAction) {
          deleteSelectionEmailsPermanently(action.context, DeleteActionType.all);
          mailboxDashBoardController.clearDashBoardAction();
        }
      }
    });

    viewStateWorker = ever(mailboxDashBoardController.viewState, (viewState) {
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
          }
        });
      }
    });
  }

  void _clearWorker() {
    mailboxWorker.call();
    dashboardActionWorker.call();
    searchWorker.call();
    advancedSearchFilterWorker.call();
    viewStateWorker.call();
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
    emailList.clear();
    canLoadMore = true;
    _isLoadingMore = false;
    cancelSelectEmail();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    _currentEmailState = success.currentEmailState;
    log('ThreadController::_getAllEmailSuccess():_currentEmailState: $_currentEmailState');
    emailList.value = success.emailList;
    if (listEmailController.hasClients) {
      listEmailController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  void _refreshChangesAllEmailSuccess(RefreshChangesAllEmailSuccess success) {
    _currentEmailState = success.currentEmailState;

    final emailsBeforeChanges = emailList;
    final emailsAfterChanges = success.emailList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);
    emailList.value = newListEmail;

    if (emailList.isEmpty) {
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
    switch(mailboxDashBoardController.filterMessageOption.value) {
      case FilterMessageOption.all:
        return EmailFilterCondition(
          inMailbox: mailboxDashBoardController.selectedMailbox.value?.id,
          before: isLoadMore ? emailList.last.receivedAt : null
        );
      case FilterMessageOption.unread:
        return EmailFilterCondition(
            inMailbox: mailboxDashBoardController.selectedMailbox.value?.id,
            notKeyword: KeyWordIdentifier.emailSeen.value,
            before: isLoadMore ? emailList.last.receivedAt : null
        );
      case FilterMessageOption.attachments:
        return EmailFilterCondition(
            inMailbox: mailboxDashBoardController.selectedMailbox.value?.id,
            hasAttachment: true,
            before: isLoadMore ? emailList.last.receivedAt : null
        );
      case FilterMessageOption.starred:
        return EmailFilterCondition(
            inMailbox: mailboxDashBoardController.selectedMailbox.value?.id,
            hasKeyword: KeyWordIdentifier.emailFlagged.value,
            before: isLoadMore ? emailList.last.receivedAt : null
        );
    }
  }

  void refreshAllEmail() {
    dispatchState(Right(LoadingState()));
    canLoadMore = true;
    cancelSelectEmail();

    if (searchController.isSearchEmailRunning) {
      final limit = emailList.isNotEmpty ? UnsignedInt(emailList.length) : ThreadConstants.defaultLimit;
      searchController.searchEmailFilter.value = _searchEmailFilter.clearBeforeDate();
      _searchEmail(limit: limit);
    } else {
      _getAllEmail();
    }
  }

  void _refreshEmailChanges({jmap.State? currentEmailState}) {
    log('ThreadController::_refreshEmailChanges(): currentEmailState: $currentEmailState');
    if (searchController.isSearchEmailRunning) {
      final limit = emailList.isNotEmpty ? UnsignedInt(emailList.length) : ThreadConstants.defaultLimit;
      searchController.searchEmailFilter.value = _searchEmailFilter.clearBeforeDate();
      _searchEmail(limit: limit);
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
            lastEmailId: emailList.last.id)
      ));
    }
  }

  bool _belongToCurrentMailboxId(PresentationEmail email) {
    return (email.mailboxIds != null && email.mailboxIds!.keys.contains(currentMailbox?.id));
  }

  bool _notDuplicatedInCurrentList(PresentationEmail email) {
    return emailList.isEmpty || !emailList.map((element) => element.id).contains(email.id);
  }

  void _loadMoreEmailsSuccess(LoadMoreEmailsSuccess success) {
    if (success.emailList.isNotEmpty) {
      final appendableList = success.emailList
        .where(_belongToCurrentMailboxId)
        .where(_notDuplicatedInCurrentList);

      emailList.addAll(appendableList);
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

  void previewEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    mailboxDashBoardController.setSelectedEmail(presentationEmailSelected);
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.emailDetailed);
  }

  Tuple2<StartRangeSelection,EndRangeSelection> _getSelectionEmailsRange(PresentationEmail presentationEmailSelected) {
    final emailSelectedIndex = emailList.indexWhere((e) => e.id == presentationEmailSelected.id);
    final latestEmailSelectedOrUnselectedIndex = emailList.indexWhere((e) => e.id == latestEmailSelectedOrUnselected.value?.id);
    if (emailSelectedIndex > latestEmailSelectedOrUnselectedIndex) {
      return Tuple2(latestEmailSelectedOrUnselectedIndex, emailSelectedIndex);
    } else {
      return Tuple2(emailSelectedIndex, latestEmailSelectedOrUnselectedIndex);
    }
  }

  bool _checkAllowMakeRangeEmailsSelected(Tuple2<StartRangeSelection,EndRangeSelection> selectionEmailsRange) {
    return latestEmailSelectedOrUnselected.value?.selectMode == SelectMode.ACTIVE &&
      !emailList.sublist(selectionEmailsRange.value1, selectionEmailsRange.value2).every((e) => e.selectMode == SelectMode.ACTIVE) ||
      latestEmailSelectedOrUnselected.value?.selectMode == SelectMode.INACTIVE &&
      emailList.sublist(selectionEmailsRange.value1, selectionEmailsRange.value2).every((e) => e.selectMode == SelectMode.INACTIVE);
  }

  void _applySelectModeToRangeEmails(Tuple2<StartRangeSelection,EndRangeSelection> selectionEmailsRange, SelectMode selectMode) {
    emailList.value = emailList.asMap().map((index, email) {
      return MapEntry(index, index >= selectionEmailsRange.value1 && index <= selectionEmailsRange.value2 ? email.toSelectedEmail(selectMode: selectMode) : email);
    }).values.toList();
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
    if (_rangeSelectionMode && latestEmailSelectedOrUnselected.value != null && latestEmailSelectedOrUnselected.value?.id != presentationEmailSelected.id) {
      _rangeSelectionEmailsAction(presentationEmailSelected);
    } else {
      emailList.value = emailList
        .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
        .toList();
    }
    latestEmailSelectedOrUnselected.value = emailList.firstWhereOrNull((e) => e.id == presentationEmailSelected.id);
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
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE)).toList();
    mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
    mailboxDashBoardController.listEmailSelected.value = listEmailSelected;
  }

  List<PresentationEmail> get listEmailSelected => emailList.listEmailSelected;

  bool _isUnSelectedAll() {
    return emailList.every((email) => email.selectMode == SelectMode.INACTIVE);
  }

  void cancelSelectEmail() {
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
    mailboxDashBoardController.listEmailSelected.clear();
  }

  void markAsReadSelectedMultipleEmail(
      List<PresentationEmail> listPresentationEmail,
      ReadActions readActions
  ) {
    if (_accountId != null) {
      cancelSelectEmail();
      consumeState(_markAsMultipleEmailReadInteractor.execute(
          _accountId!,
          listPresentationEmail.listEmail,
          readActions));
    }
  }

  void _markAsReadSelectedMultipleEmailSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    ReadActions? readActions;
    jmap.State? currentEmailState;

    if (success is MarkAsMultipleEmailReadAllSuccess) {
      readActions = success.readActions;
      currentEmailState = success.currentEmailState;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      readActions = success.readActions;
      currentEmailState = success.currentEmailState;
    }

    if (currentContext != null && readActions != null && currentOverlayContext != null) {
      final message = readActions == ReadActions.markAsUnread
        ? AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).unread)
        : AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).read);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: readActions == ReadActions.markAsUnread ? _imagePaths.icUnreadToast : _imagePaths.icReadToast);
    }
    _refreshEmailChanges(currentEmailState: currentEmailState);
  }

  void _markAsReadSelectedMultipleEmailFailure(Failure failure) {
    if (currentContext != null) {
      _appToast.showErrorToast(AppLocalizations.of(currentContext!).an_error_occurred);
    }
  }

  void openFilterMessagesCupertinoActionSheet(BuildContext context, List<Widget> actionTiles, {Widget? cancelButton}) {
    (CupertinoActionSheetBuilder(context)
        ..addTiles(actionTiles)
        ..addCancelButton(cancelButton))
      .show();
  }

  void openFilterMessagesForTablet(BuildContext context, RelativeRect? position, List<PopupMenuEntry> popupMenuItems) async {
    await showMenu(
        context: context,
        position: position ?? const RelativeRect.fromLTRB(16, 40, 16, 16),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        items: popupMenuItems);
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

  void moveSelectedMultipleEmailToMailbox(
      BuildContext context,
      List<PresentationEmail> listEmail,
      PresentationMailbox currentMailbox
  ) async {
    if (_accountId != null) {
      final arguments = DestinationPickerArguments(_accountId!, MailboxActions.moveEmail);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              if (mailboxDashBoardController.sessionCurrent != null) {
                _dispatchMoveToMultipleAction(
                    _accountId!,
                    mailboxDashBoardController.sessionCurrent!,
                    listEmail.listEmailIds,
                    currentMailbox,
                    destinationMailbox);
              }
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox != null &&
            destinationMailbox is PresentationMailbox &&
            mailboxDashBoardController.sessionCurrent != null) {
          _dispatchMoveToMultipleAction(
              _accountId!,
              mailboxDashBoardController.sessionCurrent!,
              listEmail.listEmailIds,
              currentMailbox,
              destinationMailbox);
        }
      }
    }
  }

  void _dispatchMoveToMultipleAction(
      AccountId accountId,
      Session session,
      List<EmailId> listEmailIds,
      PresentationMailbox currentMailbox,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      _moveSelectedEmailMultipleToTrashAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveSelectedEmailMultipleToSpamAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveSelectedEmailMultipleToMailboxAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveSelectedEmailMultipleToMailboxAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    cancelSelectEmail();
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;
    EmailActionType? emailActionType;
    jmap.State? currentEmailState;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
      currentEmailState = success.currentEmailState;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
      currentEmailState = success.currentEmailState;
    }

    if (currentContext != null && currentOverlayContext != null
        && emailActionType != null && moveAction == MoveAction.moving) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: destinationPath),
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            final newCurrentMailboxId = destinationMailboxId;
            final newDestinationMailboxId = currentMailboxId;
            if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
              _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest(
                  {newCurrentMailboxId: movedEmailIds},
                  newDestinationMailboxId,
                  MoveAction.undo,
                  mailboxDashBoardController.sessionCurrent!,
                  emailActionType!,
                  destinationPath: destinationPath));
            }
          },
          leadingIcon: SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }

    _refreshEmailChanges(currentEmailState: currentEmailState);
  }

  void moveSelectedMultipleEmailToTrash(
      List<PresentationEmail> listEmail,
      PresentationMailbox currentMailbox
  ) {
    final trashMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleTrash);

    if (_accountId != null && trashMailboxId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      _moveSelectedEmailMultipleToTrashAction(_accountId!, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          trashMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToTrash)
      );
    }
  }

  void _moveSelectedEmailMultipleToTrashAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    cancelSelectEmail();
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void moveSelectedMultipleEmailToSpam(
      List<PresentationEmail> listEmail,
      PresentationMailbox currentMailbox
  ) {
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);

    if (_accountId != null && spamMailboxId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      _moveSelectedEmailMultipleToSpamAction(_accountId!, MoveToMailboxRequest(
          {currentMailbox.id: listEmailIds},
          spamMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToSpam)
      );
    }
  }

  void _moveSelectedEmailMultipleToSpamAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    cancelSelectEmail();
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void unSpamSelectedMultipleEmail(List<PresentationEmail> listEmail) async {
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (inboxMailboxId != null && _accountId != null && spamMailboxId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      _moveSelectedEmailMultipleToMailboxAction(_accountId!, MoveToMailboxRequest(
          {spamMailboxId: listEmailIds},
          inboxMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.unSpam)
      );
    }
  }

  void _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    if (_accountId != null) {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(_accountId!, newMoveRequest));
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    if (_accountId != null) {
      consumeState(_markAsEmailReadInteractor.execute(_accountId!, presentationEmail.toEmail(), readActions));
    }
  }

  void _markAsEmailReadSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    if (_accountId != null) {
      consumeState(_markAsStarEmailInteractor.execute(_accountId!, presentationEmail.toEmail(), action));
    }
  }

  void _markAsStarEmailSuccess(MarkAsStarEmailSuccess success) {
    _refreshEmailChanges(currentEmailState: success.currentEmailState);
  }

  void markAsStarSelectedMultipleEmail(
      List<PresentationEmail> listPresentationEmail,
      MarkStarAction markStarAction
  ) {
    if (_accountId != null) {
      cancelSelectEmail();
      consumeState(_markAsStarMultipleEmailInteractor.execute(
          _accountId!,
          listPresentationEmail.listEmail,
          markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(Success success) {
    MarkStarAction? markStarAction;
    int countMarkStarSuccess = 0;
    jmap.State? currentEmailState;

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
      currentEmailState = success.currentEmailState;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
      currentEmailState = success.currentEmailState;
    }

    if (currentContext != null && markStarAction != null && currentOverlayContext != null) {
      final message = markStarAction == MarkStarAction.unMarkStar
          ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
          : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: markStarAction == MarkStarAction.unMarkStar ? _imagePaths.icUnStar : _imagePaths.icStar);
    }

    _refreshEmailChanges(currentEmailState: currentEmailState);
  }

  void _markAsStarMultipleEmailFailure(Failure failure) {
    if (currentContext != null) {
      _appToast.showErrorToast(AppLocalizations.of(currentContext!).an_error_occurred);
    }
  }

  bool isSearchActive() => searchController.isSearchEmailRunning;

  bool get isAllSearchInActive => !searchController.isSearchActive() &&
    searchController.isAdvancedSearchViewOpen.isFalse;

  void clearTextSearch() {
    searchController.clearTextSearch();
  }

  void _searchEmail({UnsignedInt? limit, EmailFilterCondition? filterCondition}) {
    if (_accountId != null && searchQuery != null) {
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

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsSearchBeforeChanges = emailList;
    final emailsSearchAfterChanges = resultEmailSearchList;
    final newListEmailSearch = emailsSearchAfterChanges.combine(emailsSearchBeforeChanges);
    emailList.value = newListEmailSearch;
  }

  void searchMoreEmails() {
    if (canSearchMore && _accountId != null) {
      searchController.updateFilterEmail(before: emailList.last.receivedAt);
      consumeState(_searchMoreEmailInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: searchController.searchEmailFilter.value.mappingToEmailFilterCondition(),
        properties: ThreadConstants.propertiesDefault,
        lastEmailId: emailList.last.id
      ));
    }
  }

  void _searchMoreEmailsSuccess(SearchMoreEmailSuccess success) {
    if (success.emailList.isNotEmpty) {
      final resultEmailSearchList = success.emailList
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
          .where((email) => !emailList.contains(email))
          .toList();
      emailList.addAll(resultEmailSearchList);
    } else {
      canSearchMore = false;
    }
    _isLoadingMore = false;
  }

  bool isSelectionEnabled() => mailboxDashBoardController.isSelectionEnabled();

  void pressEmailSelectionAction(BuildContext context, EmailActionType actionType, List<PresentationEmail> selectionEmail) {
    switch(actionType) {
      case EmailActionType.markAsRead:
        markAsReadSelectedMultipleEmail(selectionEmail, ReadActions.markAsRead);
        break;
      case EmailActionType.markAsUnread:
        markAsReadSelectedMultipleEmail(selectionEmail, ReadActions.markAsUnread);
        break;
      case EmailActionType.markAsStarred:
        markAsStarSelectedMultipleEmail(selectionEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        markAsStarSelectedMultipleEmail(selectionEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(context, selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
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
              selectedEmails: selectionEmail,
              presentationMailbox: mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToSpam:
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : currentMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToSpam(selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.unSpam:
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

  void moveToMailbox(BuildContext context, PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;

    if (currentMailbox != null && accountId != null) {
      final arguments = DestinationPickerArguments(accountId, MailboxActions.moveEmail);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              if (mailboxDashBoardController.sessionCurrent != null) {
                _dispatchMoveToAction(
                    context,
                    accountId,
                    mailboxDashBoardController.sessionCurrent!,
                    email,
                    currentMailbox,
                    destinationMailbox);
              }
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox != null &&
            destinationMailbox is PresentationMailbox &&
            mailboxDashBoardController.sessionCurrent != null) {
          _dispatchMoveToAction(
              context,
              accountId,
              mailboxDashBoardController.sessionCurrent!,
              email,
              currentMailbox,
              destinationMailbox);
        }
      }
    }
  }

  void _dispatchMoveToAction(
      BuildContext context,
      AccountId accountId,
      Session session,
      EmailId emailId,
      MailboxId mailboxId,
      PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      _moveToTrashAction(accountId, MoveToMailboxRequest(
          {mailboxId: [emailId]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToTrash));
    } else if (destinationMailbox.isSpam) {
      _moveToSpamAction(accountId, MoveToMailboxRequest(
          {mailboxId: [emailId]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToSpam));
    } else {
      _moveToMailboxAction(accountId, MoveToMailboxRequest(
          {mailboxId: [emailId]},
          destinationMailbox.id,
          MoveAction.moving,
          session,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath));
    }
  }

  void _moveToMailboxAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));

    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).moved_to_mailbox(success.destinationPath ?? ''),
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            _revertedToOriginalMailbox(MoveToMailboxRequest(
                {success.destinationMailboxId: [success.emailId]},
                success.currentMailboxId,
                MoveAction.undo,
                mailboxDashBoardController.sessionCurrent!,
                success.emailActionType));
          },
          leadingIcon: SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      _moveToMailboxAction(accountId, newMoveRequest);
    }
  }

  void _moveToTrashAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void moveToTrash(PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];

    if (currentMailbox != null && accountId != null && trashMailboxId != null) {
      _moveToTrashAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: [email.id]},
          trashMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToTrash)
      );
    }
  }

  void moveToSpam(PresentationEmail email) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);

    if (currentMailbox != null && accountId != null && spamMailboxId != null) {
      _moveToSpamAction(accountId, MoveToMailboxRequest(
          {currentMailbox.id: [email.id]},
          spamMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpam(PresentationEmail email) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleInbox);

    if (inboxMailboxId != null && accountId != null && spamMailboxId != null) {
      _moveToSpamAction(accountId, MoveToMailboxRequest(
          {spamMailboxId: [email.id]},
          inboxMailboxId,
          MoveAction.moving,
          mailboxDashBoardController.sessionCurrent!,
          EmailActionType.unSpam)
      );
    }
  }

  void _moveToSpamAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    mailboxDashBoardController.moveToMailbox(accountId, moveRequest);
  }

  void deleteEmailPermanently(BuildContext context, PresentationEmail email) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(DeleteActionType.single.getContentDialog(context))
          ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_email_permanently'))
              ..title(DeleteActionType.single.getTitleDialog(context))
              ..content(DeleteActionType.single.getContentDialog(context))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog, fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(DeleteActionType.single.getConfirmActionName(context), () => _deleteEmailPermanentlyAction(context, email))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
            .build()));
    }
  }

  void _deleteEmailPermanentlyAction(BuildContext context, PresentationEmail email) {
    popBack();
    mailboxDashBoardController.deleteEmailPermanently(email);
  }

  bool get isMailboxTrash => mailboxDashBoardController.selectedMailbox.value?.role == PresentationMailbox.roleTrash;

  void deleteSelectionEmailsPermanently(
      BuildContext context,
      DeleteActionType actionType,
      {
        List<PresentationEmail>? selectedEmails,
        PresentationMailbox? presentationMailbox
      }
  ) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(actionType.getContentDialog(
              context,
              count: selectedEmails?.length,
              mailboxName: presentationMailbox?.name?.name))
          ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(actionType.getConfirmActionName(context), () => _deleteSelectionEmailsPermanentlyAction(actionType)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_emails_permanently'))
              ..title(actionType.getTitleDialog(context))
              ..content(actionType.getContentDialog(
                  context,
                  count: selectedEmails?.length,
                  mailboxName: presentationMailbox?.name?.name))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog, fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(actionType.getConfirmActionName(context), () => _deleteSelectionEmailsPermanentlyAction(actionType))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
            .build()));
    }
  }

  void _deleteSelectionEmailsPermanentlyAction(DeleteActionType actionType) {
    popBack();

    switch(actionType) {
      case DeleteActionType.all:
        _emptyTrashFolderAction();
        break;
      case DeleteActionType.multiple:
        _deleteMultipleEmailsPermanently(listEmailSelected);
        break;
      case DeleteActionType.single:
        break;
    }
  }

  void _deleteMultipleEmailsPermanently(List<PresentationEmail> emailList) {
    final listEmailIds = emailList.map((email) => email.id).toList();
    cancelSelectEmail();
    if ( _accountId != null && listEmailIds.isNotEmpty) {
      consumeState(_deleteMultipleEmailsPermanentlyInteractor.execute(_accountId!, listEmailIds));
    }
  }

  void _deleteMultipleEmailsPermanentlySuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    jmap.State? currentEmailState;
    List<EmailId> listEmailIdResult = <EmailId>[];
    if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
      listEmailIdResult = success.emailIds;
      currentEmailState = success.currentEmailState;
    } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      listEmailIdResult = success.emailIds;
      currentEmailState = success.currentEmailState;
    }

    if (currentContext != null && currentOverlayContext != null && listEmailIdResult.isNotEmpty) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length),
          icon: _imagePaths.icDeleteToast);
    }

    _refreshEmailChanges(currentEmailState: currentEmailState);
  }

  void _emptyTrashFolderAction() {
    cancelSelectEmail();

    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];
    log('ThreadController::_emptyTrashFolderAction(): trashMailboxId: $trashMailboxId');
    if (_accountId != null && trashMailboxId != null) {
      consumeState(_emptyTrashFolderInteractor.execute(_accountId!, trashMailboxId));
    }
  }

  void _emptyTrashFolderSuccess(EmptyTrashFolderSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));

    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success,
          icon: _imagePaths.icDeleteToast);
    }

    refreshAllEmail();
  }

  void selectQuickSearchFilter(QuickSearchFilter filter) {
    mailboxDashBoardController.selectQuickSearchFilter(
      quickSearchFilter: filter,
    );
    _searchEmail();
  }

  void openPopupReceiveTimeQuickSearchFilter(
      BuildContext context,
      RelativeRect position,
      List<PopupMenuEntry> entries) {
    openPopupMenuAction(context, position, entries);
  }

  void selectReceiveTimeQuickSearchFilter(EmailReceiveTimeType? emailReceiveTimeType) {
    popBack();

    if (emailReceiveTimeType != null) {
      searchController.updateFilterEmail(emailReceiveTimeType: emailReceiveTimeType);
    } else {
      searchController.updateFilterEmail(emailReceiveTimeType: EmailReceiveTimeType.allTime);
    }
    searchController.setEmailReceiveTimeType(emailReceiveTimeType);
    searchController.updateFilterEmail();
    if(searchQuery == null){
      searchController.updateFilterEmail(text: SearchQuery.initial());
    }
    _searchEmail();
  }

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openMailboxMenuDrawer();
  }

  void editEmail(PresentationEmail presentationEmail) {
    final arguments = ComposerArguments(
        emailActionType: EmailActionType.edit,
        presentationEmail: presentationEmail,
        mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

    mailboxDashBoardController.goToComposer(arguments);
  }

  void goToSearchView() {
    SearchEmailBindings().dependencies();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
  }

  void calculateDragValue(PresentationEmail? currentPresentationEmail) {
    if(currentPresentationEmail != null) {
      if(mailboxDashBoardController.listEmailSelected.contains(currentPresentationEmail)){
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
}