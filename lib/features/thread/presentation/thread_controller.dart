import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
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
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
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
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

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

  final emailList = <PresentationEmail>[].obs;
  final searchIsActive = RxBool(false);

  bool canLoadMore = true;
  bool canSearchMore = true;
  bool _isLoadingMore = false;
    get isLoadingMore => _isLoadingMore;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;
  final ScrollController listEmailController = ScrollController();
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
        } else if (failure is LoadMoreEmailsFailure) {
          stopFpsMeter();
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
        } else if (success is LoadMoreEmailsSuccess) {
          stopFpsMeter();
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _initWorker() {
    mailboxWorker = ever(mailboxDashBoardController.selectedMailbox, (mailbox) {
      if (mailbox is PresentationMailbox) {
        if (_currentMailboxId != mailbox.id) {
          _currentMailboxId = mailbox.id;
          _resetToOriginalValue();
          _getAllEmail();
        }
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
        } else if (action is OpenEmailDetailedAction) {
          pressEmailAction(action.context, EmailActionType.preview, action.presentationEmail);
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is DisableSearchEmailAction) {
          closeSearchEmailAction();
          mailboxDashBoardController.clearDashBoardAction();
        }
      }
    });

    viewStateWorker = ever(mailboxDashBoardController.viewState, (viewState) {
      if (viewState is Either) {
        viewState.map((success) {
          if (success is SearchEmailNewQuery){
            mailboxDashBoardController.clearState();
            _searchEmail();
          } else if (success is MarkAsEmailReadSuccess) {
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
    disableSearch();
    cancelSelectEmail();
    mailboxDashBoardController.dispatchRoute(AppRoutes.THREAD);
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    _currentEmailState = success.currentEmailState;
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

    if (_accountId != null) {
      _getAllEmail();
    }
  }

  void _refreshEmailChanges({jmap.State? currentEmailState}) {
    log('ThreadController::_refreshEmailChanges(): currentEmailState: $currentEmailState');
    if (isSearchActive()) {
      if (_accountId != null && searchQuery != null) {
        final limit = emailList.isNotEmpty
            ? UnsignedInt(emailList.length)
            : ThreadConstants.defaultLimit;
        _searchEmail(limit: limit);
      }
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
    if (canLoadMore && _accountId != null) {
      startFpsMeter();
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

  bool _ableAppendLoadMore(List<PresentationEmail> listEmail) {
    return !(emailList.where((email) => (email.mailboxIds != null && !email.mailboxIds!.keys.contains(currentMailbox?.id)) || emailList.contains(email)).isNotEmpty);
  }

  void _loadMoreEmailsSuccess(LoadMoreEmailsSuccess success) {
    if (success.emailList.isNotEmpty) {
      if (_ableAppendLoadMore(success.emailList)){
        emailList.addAll(success.emailList);
      }
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
    mailboxDashBoardController.dispatchRoute(AppRoutes.EMAIL);
  }

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    emailList.value = emailList
      .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
      .toList();

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

  List<PresentationEmail> get listEmailSelected {
    return emailList.where((email) => email.selectMode == SelectMode.ACTIVE).toList();
  }

  bool _isUnSelectedAll() {
    return emailList.every((email) => email.selectMode == SelectMode.INACTIVE);
  }

  void cancelSelectEmail() {
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
    mailboxDashBoardController.listEmailSelected.clear();
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail) {
    final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
    final readAction = listPresentationEmail.isAllEmailRead ? ReadActions.markAsUnread : ReadActions.markAsRead;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      cancelSelectEmail();
      consumeState(_markAsMultipleEmailReadInteractor.execute(_accountId!, listEmail, readAction));
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

    if (isSearchActive() || searchController.isAdvancedSearchHasApply.isTrue) {
      _searchEmail(filterMessageOption: _getFilterCondition());
    } else {
      refreshAllEmail();
    }
  }

  void moveSelectedMultipleEmailToMailbox(List<PresentationEmail> listEmail) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    if (currentMailbox != null && _accountId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(_accountId!, MailboxActions.moveEmail)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        if (destinationMailbox.isTrash) {
          _moveSelectedEmailMultipleToTrashAction(_accountId!, MoveToMailboxRequest(
              listEmailIds,
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToTrash));
        } else if (destinationMailbox.isSpam) {
          _moveSelectedEmailMultipleToSpamAction(_accountId!, MoveToMailboxRequest(
              listEmailIds,
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToSpam));
        } else {
          _moveSelectedEmailMultipleToMailboxAction(_accountId!, MoveToMailboxRequest(
              listEmailIds,
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToMailbox,
              destinationPath: destinationMailbox.mailboxPath));
        }
      }
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
      _appToast.showToastWithAction(
          currentOverlayContext!,
          emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: destinationPath),
          AppLocalizations.of(currentContext!).undo_action, () {
            final newCurrentMailboxId = destinationMailboxId;
            final newDestinationMailboxId = currentMailboxId;
            if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
              _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest(
                  movedEmailIds,
                  newCurrentMailboxId,
                  newDestinationMailboxId,
                  MoveAction.undo,
                  emailActionType!,
                  destinationPath: destinationPath));
            }
          },
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }

    _refreshEmailChanges(currentEmailState: currentEmailState);
  }

  void moveSelectedMultipleEmailToTrash(List<PresentationEmail> listEmail) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final trashMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleTrash);

    if (currentMailbox != null && _accountId != null && trashMailboxId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      _moveSelectedEmailMultipleToTrashAction(_accountId!, MoveToMailboxRequest(
          listEmailIds,
          currentMailbox.id,
          trashMailboxId,
          MoveAction.moving,
          EmailActionType.moveToTrash)
      );
    }
  }

  void _moveSelectedEmailMultipleToTrashAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    cancelSelectEmail();
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void moveSelectedMultipleEmailToSpam(List<PresentationEmail> listEmail) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final spamMailboxId = mailboxDashBoardController.getMailboxIdByRole(PresentationMailbox.roleSpam);

    if (currentMailbox != null && _accountId != null && spamMailboxId != null) {
      final listEmailIds = listEmail.map((email) => email.id).toList();
      _moveSelectedEmailMultipleToSpamAction(_accountId!, MoveToMailboxRequest(
          listEmailIds,
          currentMailbox.id,
          spamMailboxId,
          MoveAction.moving,
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
          listEmailIds,
          spamMailboxId,
          inboxMailboxId,
          MoveAction.moving,
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

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail) {
    final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
    final starAction = listPresentationEmail.isAllEmailStarred ? MarkStarAction.unMarkStar : MarkStarAction.markStar;
    if (_accountId != null) {
      cancelSelectEmail();
      consumeState(_markAsStarMultipleEmailInteractor.execute(_accountId!, listEmail, starAction));
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

  bool isSearchActive() => searchController.isSearchActive();

  bool isAdvanceSearchActive() => searchController.isAdvanceSearchActive();


  bool get isAllSearchInActive => !searchController.isSearchActive() &&
    searchController.isAdvancedSearchViewOpen.isFalse;

  void enableSearch(BuildContext context) {
    searchController.enableSearch();
  }

  void disableSearch() {
    searchIsActive.value = false;
    searchController.disableSearch();
  }

  void closeSearchEmailAction() {
    disableSearch();
    cancelSelectEmail();
    refreshAllEmail();
  }

  void clearTextSearch() {
    searchController.clearTextSearch();
  }

  void _searchEmail({UnsignedInt? limit, EmailFilterCondition? filterMessageOption}) {
    if (_accountId != null && searchQuery != null) {
      searchIsActive.value = true;

      if(searchController.isAdvancedSearchHasApply.isFalse){
        searchController.updateFilterEmail(mailbox: currentMailbox);
      }

      filterMessageOption = EmailFilterCondition(
        notKeyword: filterMessageOption?.notKeyword,
        hasKeyword: filterMessageOption?.hasKeyword,
        hasAttachment: filterMessageOption?.hasAttachment,
      );

      consumeState(_searchEmailInteractor.execute(
        _accountId!,
        limit: limit ?? ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: _searchEmailFilter.mappingToEmailFilterCondition(moreFilterCondition: filterMessageOption),
        properties: ThreadConstants.propertiesDefault,
      ));
    }
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
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
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
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
      case EmailActionType.markAsUnread:
        markAsReadSelectedMultipleEmail(selectionEmail);
        break;
      case EmailActionType.markAsStarred:
      case EmailActionType.unMarkAsStarred:
        markAsStarSelectedMultipleEmail(selectionEmail);
        break;
      case EmailActionType.moveToMailbox:
        moveSelectedMultipleEmailToMailbox(selectionEmail);
        break;
      case EmailActionType.moveToTrash:
        moveSelectedMultipleEmailToTrash(selectionEmail);
        break;
      case EmailActionType.deletePermanently:
        deleteSelectionEmailsPermanently(
            context,
            DeleteActionType.multiple,
            selectedEmails: selectionEmail,
            presentationMailbox: currentMailbox);
        break;
      case EmailActionType.moveToSpam:
        moveSelectedMultipleEmailToSpam(selectionEmail);
        break;
      case EmailActionType.unSpam:
        unSpamSelectedMultipleEmail(selectionEmail);
        break;
      default:
        break;
    }
  }

  void pressEmailAction(BuildContext context, EmailActionType actionType, PresentationEmail selectedEmail) {
    switch(actionType) {
      case EmailActionType.preview:
        if (mailboxDashBoardController.selectedMailbox.value?.role == PresentationMailbox.roleDrafts) {
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
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(accountId, MailboxActions.moveEmail)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        if (destinationMailbox.isTrash) {
          _moveToTrashAction(accountId, MoveToMailboxRequest(
              [email.id],
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToTrash));
        } else if (destinationMailbox.isSpam) {
          _moveToSpamAction(accountId, MoveToMailboxRequest(
              [email.id],
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToSpam));
        } else {
          _moveToMailboxAction(accountId, MoveToMailboxRequest(
              [email.id],
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToMailbox,
              destinationPath: destinationMailbox.mailboxPath));
        }
      }
    }
  }

  void _moveToMailboxAction(AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    mailboxDashBoardController.dispatchState(Right(success));

    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).moved_to_mailbox(success.destinationPath ?? ''),
          AppLocalizations.of(currentContext!).undo_action, () {
            _revertedToOriginalMailbox(MoveToMailboxRequest(
                [success.emailId],
                success.destinationMailboxId,
                success.currentMailboxId,
                MoveAction.undo,
                success.emailActionType));
          },
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
    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxId[PresentationMailbox.roleTrash];

    if (currentMailbox != null && accountId != null && trashMailboxId != null) {
      _moveToTrashAction(accountId, MoveToMailboxRequest(
          [email.id],
          currentMailbox.id,
          trashMailboxId,
          MoveAction.moving,
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
          [email.id],
          currentMailbox.id,
          spamMailboxId,
          MoveAction.moving,
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
          [email.id],
          spamMailboxId,
          inboxMailboxId,
          MoveAction.moving,
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

    final trashMailboxId = mailboxDashBoardController.mapDefaultMailboxId[PresentationMailbox.roleTrash];
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
}