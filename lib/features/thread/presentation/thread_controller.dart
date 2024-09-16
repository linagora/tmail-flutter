import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/store_event_attendance_status_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/unsubscribe_email_state.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart' as search;
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/get_email_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_email_by_id_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/refresh_all_email_state.dart';
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
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:universal_html/html.dart' as html;

typedef StartRangeSelection = int;
typedef EndRangeSelection = int;

class ThreadController extends BaseController with EmailActionController {

  final networkConnectionController = Get.find<NetworkConnectionController>();

  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final RefreshChangesEmailsInMailboxInteractor _refreshChangesEmailsInMailboxInteractor;
  final LoadMoreEmailsInMailboxInteractor _loadMoreEmailsInMailboxInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;
  final GetEmailByIdInteractor _getEmailByIdInteractor;

  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;

  final listEmailDrag = <PresentationEmail>[].obs;
  bool _rangeSelectionMode = false;
  final openingEmail = RxBool(false);
  final loadingMoreStatus = Rx(LoadingMoreStatus.idle);

  bool canLoadMore = false;
  bool canSearchMore = false;
  MailboxId? _currentMemoryMailboxId;
  jmap.State? _currentEmailState;
  final ScrollController listEmailController = ScrollController();
  final FocusNode focusNodeKeyBoard = FocusNode();
  final latestEmailSelectedOrUnselected = Rxn<PresentationEmail>();

  StreamSubscription<html.Event>? _resizeBrowserStreamSubscription;

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  Session? get _session => mailboxDashBoardController.sessionCurrent;

  PresentationMailbox? get selectedMailbox => mailboxDashBoardController.selectedMailbox.value;

  MailboxId? get selectedMailboxId => selectedMailbox?.id;

  search.SearchController get searchController => mailboxDashBoardController.searchController;

  SearchEmailFilter get _searchEmailFilter => searchController.searchEmailFilter.value;

  SearchQuery? get searchQuery => _searchEmailFilter.text;

  ThreadController(
    this._getEmailsInMailboxInteractor,
    this._refreshChangesEmailsInMailboxInteractor,
    this._loadMoreEmailsInMailboxInteractor,
    this._searchEmailInteractor,
    this._searchMoreEmailInteractor,
    this._getEmailByIdInteractor,
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    if (PlatformInfo.isWeb) {
      _registerBrowserResizeListener();
    }
    super.onInit();
  }

  @override
  void onReady() {
    consumeState(Stream.value(Right(GetAllEmailLoading())));
    super.onReady();
  }

  @override
  void onClose() {
    _currentMemoryMailboxId = null;
    _currentEmailState = null;
    listEmailController.dispose();
    focusNodeKeyBoard.dispose();
    if (PlatformInfo.isWeb) {
      _resizeBrowserStreamSubscription?.cancel();
    }
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
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
    } else if (success is SearchingMoreState || success is LoadingMoreEmails) {
      loadingMoreStatus.value = LoadingMoreStatus.running;
    } else if (success is GetEmailByIdLoading) {
      openingEmail.value = true;
    } else if (success is GetEmailByIdSuccess) {
      openingEmail.value = false;
      if (searchController.isSearchEmailRunning) {
        _openEmailSearchedFromLocationBar(
          email: success.email,
          searchQuery: searchQuery
        );
      } else {
        if (success.mailboxContain != null) {
          _openEmailInsideMailboxFromLocationBar(success.email, success.mailboxContain!);
        } else {
          _openEmailWithoutMailboxFromLocationBar(success.email);
        }
      }
    } else if (success is CreateNewRuleFilterSuccess) {
      _createNewRuleFilterSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is SearchEmailFailure) {
      mailboxDashBoardController.updateRefreshAllEmailState(Left(RefreshAllEmailFailure()));
      canSearchMore = false;
      mailboxDashBoardController.emailsInCurrentMailbox.clear();
    } else if (failure is SearchMoreEmailFailure) {
      loadingMoreStatus.value = LoadingMoreStatus.completed;
      canSearchMore = true;
    }  else if (failure is LoadMoreEmailsFailure) {
      loadingMoreStatus.value = LoadingMoreStatus.completed;
      canLoadMore = true;
    } else if (failure is GetEmailByIdFailure) {
      openingEmail.value = false;
      popAndPush(AppRoutes.unknownRoutePage);
    } else if (failure is GetAllEmailFailure) {
      mailboxDashBoardController.updateRefreshAllEmailState(Left(RefreshAllEmailFailure()));
      canLoadMore = true;
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    logError('ThreadController::handleErrorViewState(): error: $error | stackTrace: $stackTrace');
    _resetLoadingMore();
    _handleErrorGetAllOrRefreshChangesEmail(error, stackTrace);
  }

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    _resetLoadingMore();
    clearState();
    super.handleUrgentException(failure: failure, exception: exception);
  }

  @override
  void onDone() {
    viewState.value.map((success) {
      if (success is GetAllEmailSuccess) {
        _handleOnDoneGetAllEmailSuccess(success);
      }
    });
  }

  void _resetLoadingMore() {
    if (loadingMoreStatus.value == LoadingMoreStatus.running) {
      loadingMoreStatus.value = LoadingMoreStatus.idle;
    }
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.selectedMailbox, (mailbox) {
      log('ThreadController::_registerObxStreamListener:SelectedMailbox: ${mailbox?.id} - ${mailbox?.name} | CurrentMemoryMailboxId: $_currentMemoryMailboxId');
      if (mailbox is PresentationMailbox
          && mailbox.mailboxId != _currentMemoryMailboxId) {
        _currentMemoryMailboxId = mailbox.id;
        consumeState(Stream.value(Right(GetAllEmailLoading())));
        _resetToOriginalValue();
        _getAllEmailAction();
      } else if (mailbox == null) { // disable current mailbox when search active
        _currentMemoryMailboxId = null;
        _resetToOriginalValue();
      }
    });

    ever(searchController.searchState, (searchState) {
      if (searchState.searchStatus == SearchStatus.ACTIVE) {
        cancelSelectEmail();
      }
    });

    ever(searchController.isAdvancedSearchViewOpen, (hasOpen) {
      if (hasOpen == true) {
        mailboxDashBoardController.filterMessageOption.value = FilterMessageOption.all;
      }
    });

    ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is SelectionAllEmailAction) {
        setSelectAllEmailAction();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is CancelSelectionAllEmailAction) {
        cancelSelectEmail();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is FilterMessageAction) {
        filterMessagesAction(action.option);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is HandleEmailActionTypeAction) {
        pressEmailSelectionAction(action.emailAction, action.listEmailSelected);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is OpenEmailDetailedFromSuggestionQuickSearchAction) {
        final mailboxContain = action.presentationEmail.findMailboxContain(mailboxDashBoardController.mapMailboxById);
        final newEmail = generateEmailByPlatform(action.presentationEmail);
        handleEmailActionType(
          EmailActionType.preview,
          newEmail,
          mailboxContain: mailboxContain,
        );
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is StartSearchEmailAction) {
        cancelSelectEmail();
        _replaceBrowserHistory();
        _searchEmail();
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is EmptyTrashAction && currentContext != null) {
        deleteSelectionEmailsPermanently(currentContext!, DeleteActionType.all);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is OpenEmailInsideMailboxFromLocationBar) {
        _getEmailByIdFromLocationBar(
          action.emailId,
          mailboxContain: action.presentationMailbox,
        );
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is OpenEmailWithoutMailboxFromLocationBar) {
        _getEmailByIdFromLocationBar(action.emailId);
        mailboxDashBoardController.clearDashBoardAction();
      } else if (action is OpenEmailSearchedFromLocationBar) {
        _handleOpenEmailSearchedFromLocationBar(
          emailId: action.emailId,
          searchQuery: action.searchQuery
        );
      } else if (action is SearchEmailFromLocationBar) {
        _handleSearchEmailFromLocationBar(action.searchQuery);
      } else if (action is SelectDateRangeToAdvancedSearch || action is ClearDateRangeToAdvancedSearch) {
        if (listEmailController.hasClients) {
          listEmailController.jumpTo(0);
        }
        canSearchMore = true;
        mailboxDashBoardController.emailsInCurrentMailbox.clear();
      }
    });

    ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is RefreshChangeEmailAction) {
        if (action.newState != _currentEmailState) {
          _refreshEmailChanges();
        }
        mailboxDashBoardController.clearEmailUIAction();
      } else if (action is RefreshAllEmailAction) {
        refreshAllEmail();
        mailboxDashBoardController.clearEmailUIAction();
      }
    });

    ever(mailboxDashBoardController.viewState, (viewState) {
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
        } else if (success is EmptyTrashFolderSuccess || success is EmptySpamFolderSuccess) {
          refreshAllEmail();
        } else if (success is UnsubscribeEmailSuccess) {
          _refreshEmailChanges(currentEmailState: success.currentEmailState);
        } else if (success is StoreEventAttendanceStatusSuccess) {
          _refreshEmailChanges(currentEmailState: success.currentEmailState);
        }
      });
    });
  }

  void _registerBrowserResizeListener() {
    _resizeBrowserStreamSubscription = html.window.onResize.listen((_) {
      _validateBrowserHeight();
    });
  }

  void _validateBrowserHeight() {
    final browserInnerHeight = html.window.innerHeight ?? 0;
    final currentListEmails = mailboxDashBoardController.emailsInCurrentMailbox;
    final totalHeightListEmails = currentListEmails.isEmpty
      ? 0
      : currentListEmails.length * ThreadConstants.defaultMaxHeightEmailItemOnBrowser;
    if (browserInnerHeight >= ThreadConstants.defaultMaxHeightBrowser &&
        totalHeightListEmails <= browserInnerHeight) {
      _performAutomaticallyLoadMoreEmails();
    }
  }

  void _performAutomaticallyLoadMoreEmails() {
    log('ThreadController::_performAutomaticallyLoadMoreEmails:');
    handleLoadMoreEmailsRequest();
  }

  void _handleErrorGetAllOrRefreshChangesEmail(Object error, StackTrace stackTrace) async {
    logError('ThreadController::_handleErrorGetAllOrRefreshChangesEmail():Error: $error');
    if (error is CannotCalculateChangesMethodResponseException) {
      if (_accountId != null && _session != null) {
        await cachingManager.clearEmailCacheAndStateCacheByTupleKey(_accountId!, _session!);
      } else {
        await cachingManager.clearEmailCacheAndAllStateCache();
      }
      _getAllEmailAction();
    } else if (error is MethodLevelErrors) {
      if (currentOverlayContext != null && error.message != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          error.message?.toString() ?? ''
        );
      }
      clearState();
    }
  }

  void _resetToOriginalValue() {
    log('ThreadController::_resetToOriginalValue');
    mailboxDashBoardController.emailsInCurrentMailbox.clear();
    mailboxDashBoardController.listEmailSelected.clear();
    mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
    canLoadMore = true;
    loadingMoreStatus.value = LoadingMoreStatus.idle;
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    mailboxDashBoardController.updateRefreshAllEmailState(Right(RefreshAllEmailSuccess()));

    if (success.currentMailboxId != selectedMailboxId) {
      log('ThreadController::_getAllEmailSuccess: GetAllForMailboxId = ${success.currentMailboxId?.asString} | SELECTED_MAILBOX_ID = ${selectedMailboxId?.asString} | SELECTED_MAILBOX_NAME = ${selectedMailbox?.name?.name}');
      return;
    }
    _currentEmailState = success.currentEmailState;
    log('ThreadController::_getAllEmailSuccess():COUNT = ${success.emailList.length} | EMAIL_STATE = $_currentEmailState');
    final newListEmail = success.emailList.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: selectedMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(newListEmail);

    canLoadMore = newListEmail.length >= ThreadConstants.maxCountEmails;

    if (listEmailController.hasClients) {
      listEmailController.jumpTo(0);
    }
  }

  void _handleOnDoneGetAllEmailSuccess(GetAllEmailSuccess success) {
    if (PlatformInfo.isWeb) {
      _validateBrowserHeight();
    }
  }

  void _refreshChangesAllEmailSuccess(RefreshChangesAllEmailSuccess success) {
    if (success.currentMailboxId != selectedMailboxId) {
      log('ThreadController::_refreshChangesAllEmailSuccess: RefreshedMailboxId = ${success.currentMailboxId?.asString} | SELECTED_MAILBOX_ID = ${selectedMailboxId?.asString} | SELECTED_MAILBOX_NAME = ${selectedMailbox?.name?.name}');
      return;
    }

    _currentEmailState = success.currentEmailState;
    log('ThreadController::_refreshChangesAllEmailSuccess: COUNT = ${success.emailList.length}');
    final emailsBeforeChanges = mailboxDashBoardController.emailsInCurrentMailbox;
    final emailsAfterChanges = success.emailList;
    final newListEmail = emailsAfterChanges.combine(emailsBeforeChanges);
    final emailListSynced = newListEmail.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: selectedMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(emailListSynced);

    canLoadMore = newListEmail.length >= ThreadConstants.maxCountEmails;

    if (mailboxDashBoardController.emailsInCurrentMailbox.isEmpty) {
      refreshAllEmail();
    } else if (PlatformInfo.isWeb) {
      _validateBrowserHeight();
    }
  }

  void _getAllEmailAction() {
    log('ThreadController::_getAllEmailAction:');
    if (_session != null &&_accountId != null) {
      consumeState(_getEmailsInMailboxInteractor.execute(
        _session!,
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: searchController.sortOrderFiltered.value.getSortOrder().toNullable(),
        emailFilter: EmailFilter(
          filter: _getFilterCondition(mailboxIdSelected: selectedMailboxId),
          filterOption: mailboxDashBoardController.filterMessageOption.value,
          mailboxId: selectedMailboxId
        ),
        propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      ));
    } else {
      consumeState(Stream.value(Left(GetAllEmailFailure(NotFoundSessionException()))));
    }
  }

  EmailFilterCondition _getFilterCondition({PresentationEmail? oldestEmail, MailboxId? mailboxIdSelected}) {
    switch(mailboxDashBoardController.filterMessageOption.value) {
      case FilterMessageOption.all:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          before: oldestEmail?.receivedAt
        );
      case FilterMessageOption.unread:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          notKeyword: KeyWordIdentifier.emailSeen.value,
          before: oldestEmail?.receivedAt
        );
      case FilterMessageOption.attachments:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasAttachment: true,
          before: oldestEmail?.receivedAt
        );
      case FilterMessageOption.starred:
        return EmailFilterCondition(
          inMailbox: mailboxIdSelected,
          hasKeyword: KeyWordIdentifier.emailFlagged.value,
          before: oldestEmail?.receivedAt
        );
    }
  }

  void refreshAllEmail() {
    if (searchController.isSearchEmailRunning) {
      consumeState(Stream.value(Right(SearchingState())));
    } else {
      consumeState(Stream.value(Right(GetAllEmailLoading())));
    }

    canLoadMore = false;
    loadingMoreStatus.value == LoadingMoreStatus.idle;
    cancelSelectEmail();

    if (searchController.isSearchEmailRunning) {
      _searchEmail(limit: limitEmailFetched);
    } else {
      _getAllEmailAction();
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
      _searchEmail(limit: limitEmailFetched);
    } else {
      final newEmailState = currentEmailState ?? _currentEmailState;
      log('ThreadController::_refreshEmailChanges(): newEmailState: $newEmailState');
      if (_session != null && _accountId != null && newEmailState != null) {
        consumeState(_refreshChangesEmailsInMailboxInteractor.execute(
          _session!,
          _accountId!,
          newEmailState,
          sort: searchController.sortOrderFiltered.value.getSortOrder().toNullable(),
          propertiesCreated: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
          propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
          emailFilter: EmailFilter(
            filter: _getFilterCondition(mailboxIdSelected: selectedMailboxId),
            filterOption: mailboxDashBoardController.filterMessageOption.value,
            mailboxId: selectedMailboxId
          )
        ));
      }
    }
  }

  void _loadMoreEmails() {
    log('ThreadController::_loadMoreEmails()::canLoadMore = $canLoadMore');
    if (canLoadMore && _session != null && _accountId != null) {
      final oldestEmail = mailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty
        ? mailboxDashBoardController.emailsInCurrentMailbox.last
        : null;
      log('ThreadController::_loadMoreEmails: OldestEmailID = ${oldestEmail?.id?.asString}');
      consumeState(_loadMoreEmailsInMailboxInteractor.execute(
        GetEmailRequest(
          _session!,
          _accountId!,
          limit: ThreadConstants.defaultLimit,
          position: _searchEmailFilter.position,
          sort: searchController.sortOrderFiltered.value.getSortOrder().toNullable(),
          filterOption: mailboxDashBoardController.filterMessageOption.value,
          filter: _getFilterCondition(oldestEmail: oldestEmail, mailboxIdSelected: selectedMailboxId),
          properties: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
          lastEmailId: oldestEmail?.id
        )
      ));
    }
  }

  bool _validatePresentationEmail(PresentationEmail email) {
    return _belongToCurrentMailboxId(email)
      && _notDuplicatedInCurrentList(email);
  }

  bool _belongToCurrentMailboxId(PresentationEmail email) {
    return email.mailboxIds != null && email.mailboxIds!.keys.contains(selectedMailboxId);
  }

  bool _notDuplicatedInCurrentList(PresentationEmail email) {
    final emailsInCurrentMailbox = mailboxDashBoardController.emailsInCurrentMailbox;
    return emailsInCurrentMailbox.isEmpty ||
      !emailsInCurrentMailbox.map((element) => element.id).contains(email.id);
  }

  void _loadMoreEmailsSuccess(LoadMoreEmailsSuccess success) {
    canLoadMore = success.emailList.isNotEmpty;
    loadingMoreStatus.value = LoadingMoreStatus.completed;
    final appendableList = validateListEmailsLoadMore(success.emailList);
    log('ThreadController::_loadMoreEmailsSuccess: emailList = ${success.emailList.length} | appendableList = ${appendableList.length}');
    if (appendableList.isNotEmpty) {
      mailboxDashBoardController.emailsInCurrentMailbox.addAll(appendableList);
    }
    if (PlatformInfo.isWeb) {
      _validateBrowserHeight();
    }
  }

  List<PresentationEmail> validateListEmailsLoadMore(List<PresentationEmail> emailList) {
    log('ThreadController::validateListEmailsLoadMore: BEFORE_EMAIL_LIST = ${emailList.length}');
    final appendableList = emailList
      .where(_validatePresentationEmail)
      .toList()
      .syncPresentationEmail(
        mapMailboxById: mailboxDashBoardController.mapMailboxById,
        selectedMailbox: selectedMailbox,
        searchQuery: searchController.searchQuery,
        isSearchEmailRunning: searchController.isSearchEmailRunning
      );
    log('ThreadController::validateListEmailsLoadMore: AFTER_EMAIL_LIST = ${appendableList.length}');
    return appendableList;
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

  void selectEmail(PresentationEmail presentationEmailSelected) {
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

    if (!PlatformInfo.isMobile) {
      focusNodeKeyBoard.requestFocus();
    }

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

  void filterMessagesAction(FilterMessageOption filterOption) {
    popBack();

    final newFilterOption = mailboxDashBoardController.filterMessageOption.value == filterOption
        ? FilterMessageOption.all
        : filterOption;

    mailboxDashBoardController.filterMessageOption.value = newFilterOption;

    if (currentContext != null && currentOverlayContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        newFilterOption.getMessageToast(currentContext!),
        leadingSVGIcon: newFilterOption.getIconToast(imagePaths));
    }

    if (searchController.isSearchEmailRunning) {
      _searchEmail();
    } else {
      refreshAllEmail();
    }
  }

  bool get isSearchActive => searchController.isSearchEmailRunning;

  void clearTextSearch() {
    searchController.clearTextSearch();
  }

  void _searchEmail({UnsignedInt? limit}) {
    if (_session != null && _accountId != null) {
      if (listEmailController.hasClients) {
        listEmailController.jumpTo(0);
      }
      mailboxDashBoardController.emailsInCurrentMailbox.clear();
      canSearchMore = false;

      if (searchController.sortOrderFiltered.value.isScrollByPosition()) {
        searchController.updateFilterEmail(
          positionOption: const Some(0),
          beforeOption: const None(),
        );
      } else {
        searchController.updateFilterEmail(
          positionOption: const None(),
          beforeOption: const None(),
        );
      }

      searchController.activateSimpleSearch();

      consumeState(_searchEmailInteractor.execute(
        _session!,
        _accountId!,
        limit: limit ?? ThreadConstants.defaultLimit,
        position: _searchEmailFilter.position,
        sort: searchController.sortOrderFiltered.value.getSortOrder().toNullable(),
        filter: _searchEmailFilter.mappingToEmailFilterCondition(
          sortOrderType: searchController.sortOrderFiltered.value,
          moreFilterCondition: _getFilterCondition()
        ),
        properties: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
      ));
    } else {
      consumeState(Stream.value(Left(SearchEmailFailure(NotFoundSessionException()))));
    }
  }

  void _replaceBrowserHistory() {
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: 'SearchEmail',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.dashboard,
          router: NavigationRouter(
            mailboxId: _searchEmailFilter.mailbox?.mailboxId,
            searchQuery: searchQuery,
            dashboardType: DashboardType.search
          )
        )
      );
    }
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    mailboxDashBoardController.updateRefreshAllEmailState(Right(RefreshAllEmailSuccess()));
    log('ThreadController::_searchEmailsSuccess: COUNT = ${success.emailList.length}');
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
        .toList();

    final emailsSearchBeforeChanges = mailboxDashBoardController.emailsInCurrentMailbox;
    final emailsSearchAfterChanges = resultEmailSearchList;
    final newListEmailSearch = emailsSearchAfterChanges.combine(emailsSearchBeforeChanges);
    final newEmailListSynced = newListEmailSearch.syncPresentationEmail(
      mapMailboxById: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: selectedMailbox,
      searchQuery: searchController.searchQuery,
      isSearchEmailRunning: searchController.isSearchEmailRunning
    );
    mailboxDashBoardController.updateEmailList(newEmailListSynced);

    canSearchMore = newEmailListSynced.length >= ThreadConstants.maxCountEmails;

    if (PlatformInfo.isWeb) {
      _validateBrowserHeight();
    }
  }

  void _searchMoreEmails() {
    log('ThreadController::_searchMoreEmails:');
    if (canSearchMore && _session != null && _accountId != null) {
      final lastEmail = mailboxDashBoardController.emailsInCurrentMailbox.isNotEmpty
        ? mailboxDashBoardController.emailsInCurrentMailbox.last
        : null;

      if (searchController.sortOrderFiltered.value.isScrollByPosition()) {
        final nextPosition = mailboxDashBoardController.emailsInCurrentMailbox.length;
        log('ThreadController::_searchMoreEmails:nextPosition: $nextPosition');
        searchController.updateFilterEmail(
          positionOption: Some(nextPosition),
          beforeOption: const None()
        );
      } else if (searchController.sortOrderFiltered.value == EmailSortOrderType.oldest) {
        searchController.updateFilterEmail(startDateOption: optionOf(lastEmail?.receivedAt));
      } else {
        searchController.updateFilterEmail(beforeOption: optionOf(lastEmail?.receivedAt));
      }

      consumeState(_searchMoreEmailInteractor.execute(
        _session!,
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: searchController.sortOrderFiltered.value.getSortOrder().toNullable(),
        position: _searchEmailFilter.position,
        filter: _searchEmailFilter.mappingToEmailFilterCondition(
          sortOrderType: searchController.sortOrderFiltered.value,
          moreFilterCondition: _getFilterCondition()
        ),
        properties: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
        lastEmailId: lastEmail?.id
      ));
    }
  }

  void _searchMoreEmailsSuccess(SearchMoreEmailSuccess success) {
    log('ThreadController::_searchMoreEmailsSuccess: COUNT = ${success.emailList.length}');
    if (success.emailList.isNotEmpty) {
      final resultEmailSearchList = success.emailList
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailboxById))
          .where((email) => mailboxDashBoardController.emailsInCurrentMailbox.every((emailInCurrentMailbox) => emailInCurrentMailbox.id != email.id))
          .toList()
          .syncPresentationEmail(
            mapMailboxById: mailboxDashBoardController.mapMailboxById,
            selectedMailbox: selectedMailbox,
            searchQuery: searchController.searchQuery,
            isSearchEmailRunning: searchController.isSearchEmailRunning
          );
      mailboxDashBoardController.emailsInCurrentMailbox.addAll(resultEmailSearchList);
    }
    canSearchMore = success.emailList.isNotEmpty;
    loadingMoreStatus.value = LoadingMoreStatus.completed;

    if (PlatformInfo.isWeb) {
      _validateBrowserHeight();
    }
  }

  void pressEmailSelectionAction(
    EmailActionType actionType,
    List<PresentationEmail> selectionEmail
  ) {
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
            : selectedMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToMailbox(selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.moveToTrash:
        cancelSelectEmail();
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : selectedMailbox;
        if (mailboxContainCurrent != null) {
          moveSelectedMultipleEmailToTrash(selectionEmail, mailboxContainCurrent);
        }
        break;
      case EmailActionType.deletePermanently:
        final mailboxContainCurrent = searchController.isSearchEmailRunning
            ? selectionEmail.getCurrentMailboxContain(mailboxDashBoardController.mapMailboxById)
            : selectedMailbox;
        if (mailboxContainCurrent != null && currentContext != null) {
          deleteSelectionEmailsPermanently(
            currentContext!,
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
            : selectedMailbox;
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

  void handleEmailActionType(
    EmailActionType actionType,
    PresentationEmail selectedEmail,
    {
      PresentationMailbox? mailboxContain,
    }
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
        }
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
        openEmailInNewTabAction(selectedEmail);
        break;
      default:
        break;
    }
  }

  bool get isMailboxTrash => selectedMailbox?.isTrash == true;

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openMailboxMenuDrawer();
  }

  void goToSearchView() {
    SearchEmailBindings().dependencies();
    _replaceBrowserHistory();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
  }

  void calculateDragValue(PresentationEmail? currentPresentationEmail) {
    if (currentPresentationEmail != null) {
      if (currentPresentationEmail.id != null && mailboxDashBoardController.listEmailSelected.findEmail(currentPresentationEmail.id!) != null){
        listEmailDrag.clear();
        listEmailDrag.addAll(mailboxDashBoardController.listEmailSelected);
      } else {
        listEmailDrag.clear();
        listEmailDrag.add(currentPresentationEmail);
      }
    }
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    final shiftEvent = event.logicalKey == LogicalKeyboardKey.shiftLeft || event.logicalKey == LogicalKeyboardKey.shiftRight;
    if (event is KeyDownEvent && shiftEvent) {
      _rangeSelectionMode = true;
    }

    if (event is KeyUpEvent && shiftEvent) {
      _rangeSelectionMode = false;
    }
    return shiftEvent
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  PresentationEmail generateEmailByPlatform(PresentationEmail currentEmail) {
    if (PlatformInfo.isWeb) {
      final route = RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          emailId: currentEmail.id,
          mailboxId: searchController.isSearchEmailRunning
            ? currentEmail.mailboxContain?.mailboxId
            : selectedMailboxId,
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

  void _getEmailByIdFromLocationBar(
    EmailId emailId,
    {
      PresentationMailbox? mailboxContain,
    }
  ) {
    if (_session != null && _accountId != null) {
      consumeState(_getEmailByIdInteractor.execute(
        _session!,
        _accountId!,
        emailId,
        properties: EmailUtils.getPropertiesForEmailGetMethod(_session!, _accountId!),
        mailboxContain: mailboxContain,
      ));
    } else {
      logError('ThreadController::_getEmailByIdFromLocationBar: session & accountId is NULL');
      popAndPush(AppRoutes.unknownRoutePage);
    }
  }

  void _openEmailInsideMailboxFromLocationBar(
    PresentationEmail email,
    PresentationMailbox mailboxContain
  ) {
    final presentationEmailWithRouter = email.withRouteWeb(RouteUtils.createUrlWebLocationBar(
      AppRoutes.dashboard,
      router: NavigationRouter(
        emailId: email.id,
        mailboxId: mailboxContain.mailboxId,
        dashboardType: DashboardType.normal
      )
    ));
    handleEmailActionType(
      EmailActionType.preview,
      presentationEmailWithRouter,
      mailboxContain: mailboxContain
    );
  }

  void _openEmailWithoutMailboxFromLocationBar(PresentationEmail email) {
    final mailboxContain = email.findMailboxContain(mailboxDashBoardController.mapMailboxById);
    if (mailboxContain != null) {
      mailboxDashBoardController.setSelectedMailbox(mailboxContain);
      final presentationEmailWithRouter = email.withRouteWeb(RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          emailId: email.id,
          mailboxId: mailboxContain.mailboxId,
          dashboardType: DashboardType.normal
        )
      ));
      handleEmailActionType(
        EmailActionType.preview,
        presentationEmailWithRouter,
        mailboxContain: mailboxContain
      );
    } else {
      searchController.enableSearch();
      _searchEmail();

      final presentationEmailWithRouter = email.withRouteWeb(RouteUtils.createUrlWebLocationBar(
        AppRoutes.dashboard,
        router: NavigationRouter(
          emailId: email.id,
          dashboardType: DashboardType.search
        )
      ));
      handleEmailActionType(
        EmailActionType.preview,
        presentationEmailWithRouter,
        mailboxContain: mailboxContain
      );
    }
  }

  void _openEmailSearchedFromLocationBar({
    required PresentationEmail email,
    SearchQuery? searchQuery,
  }) {
    final presentationEmailWithRouter = email.withRouteWeb(RouteUtils.createUrlWebLocationBar(
      AppRoutes.dashboard,
      router: NavigationRouter(
        emailId: email.id,
        searchQuery: searchQuery,
        dashboardType: DashboardType.search
      )
    ));
    handleEmailActionType(
      EmailActionType.preview,
      presentationEmailWithRouter,
      mailboxContain: email.findMailboxContain(mailboxDashBoardController.mapMailboxById)
    );
  }

  void onDragMailBox(bool isDrag) {
    mailboxDashBoardController.onDragMailbox(isDrag);
  }

  void goToCreateEmailRuleView() async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      final arguments = RulesFilterCreatorArguments(
        accountId,
        session,
        mailboxDestination: selectedMailbox
      );

      final newRuleFilterRequest = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.rulesFilterCreator, arguments: arguments)
        : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

      if (newRuleFilterRequest is CreateNewEmailRuleFilterRequest) {
        _createNewRuleFilterAction(accountId, newRuleFilterRequest);
      }
    } else {
      logError('ThreadController::goToCreateEmailRuleView: Account or Session is NULL');
    }
  }

  void _createNewRuleFilterAction(
    AccountId accountId,
    CreateNewEmailRuleFilterRequest ruleFilterRequest
  ) async {
    _createNewEmailRuleFilterInteractor = getBinding<CreateNewEmailRuleFilterInteractor>();
    if (_createNewEmailRuleFilterInteractor != null) {
      consumeState(_createNewEmailRuleFilterInteractor!.execute(accountId, ruleFilterRequest));
    }
  }

  void _createNewRuleFilterSuccess(CreateNewRuleFilterSuccess success) {
    if (success.newListRules.isNotEmpty == true &&
        currentOverlayContext != null &&
        currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).newFilterWasCreated
      );
    }
  }

  Future<bool> swipeEmailAction(BuildContext context, PresentationEmail email, DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      ReadActions readActions = !email.hasRead ? ReadActions.markAsRead : ReadActions.markAsUnread;
      markAsEmailRead(email, readActions, MarkReadAction.swipeOnThread);
    } else if (direction == DismissDirection.endToStart) {
      archiveMessage(context, email);
    }
    return false;
  }

  DismissDirection getSwipeDirection(bool isWebDesktop, SelectMode selectMode, PresentationEmail email) {
    if (isWebDesktop) {
      return DismissDirection.none;
    } 
    
    if (selectMode == SelectMode.ACTIVE) {
      return DismissDirection.none;
    }

    return isInArchiveMailbox(email)
      ? DismissDirection.startToEnd
      : DismissDirection.horizontal;
  }

  bool isInArchiveMailbox(PresentationEmail email) => email.mailboxContain?.isArchive == true;

  void scrollToTop() {
    if (listEmailController.hasClients) {
      listEmailController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  void _handleOpenEmailSearchedFromLocationBar({
    required EmailId emailId,
    SearchQuery? searchQuery,
  }) {
    searchController.enableSearch();
    if (searchQuery != null) {
      searchController.updateTextSearch(searchQuery.value);
      searchController.updateFilterEmail(text: searchQuery);
      if (currentContext != null) {
        FocusScope.of(currentContext!).unfocus();
      }
      searchController.searchFocus.unfocus();
    }
    _searchEmail();
    _getEmailByIdFromLocationBar(emailId);
    mailboxDashBoardController.clearDashBoardAction();
  }

  void _handleSearchEmailFromLocationBar(SearchQuery searchQuery) {
    dispatchState(Right(SearchingState()));
    searchController.enableSearch();
    searchController.updateTextSearch(searchQuery.value);
    searchController.updateFilterEmail(text: searchQuery);
    if (currentContext != null) {
      FocusScope.of(currentContext!).unfocus();
    }
    searchController.searchFocus.unfocus();
    _searchEmail();
    mailboxDashBoardController.clearDashBoardAction();
  }

  void handleLoadMoreEmailsRequest() {
    log('ThreadController::handleLoadMoreEmailsRequest:');
    if (isSearchActive) {
      _searchMoreEmails();
    } else  {
      _loadMoreEmails();
    }
  }
}