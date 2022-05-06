import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
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
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_extension.dart';
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
  final emailListSearch = <PresentationEmail>[].obs;

  bool canLoadMore = true;
  bool canSearchMore = true;
  bool _isLoadingMore = false;
    get isLoadingMore => _isLoadingMore;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;
  final ScrollController listEmailController = ScrollController();
  late Worker mailboxWorker, searchWorker, dashboardActionWorker, viewStateWorker;

  SearchQuery? get searchQuery => mailboxDashBoardController.searchQuery;

  Set<Comparator>? get _sortOrder => <Comparator>{}
    ..add(EmailComparator(EmailComparatorProperty.receivedAt)
      ..setIsAscending(false));

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  PresentationMailbox? get currentMailbox => mailboxDashBoardController.selectedMailbox.value;

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
          emailListSearch.clear();
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
        log('ThreadController::onDone(): failure: $failure');
        if (failure is MarkAsMultipleEmailReadAllFailure
            || failure is MarkAsMultipleEmailReadFailure) {
          _markAsReadSelectedMultipleEmailFailure(failure);
        } else if (failure is MarkAsStarMultipleEmailAllFailure
            || failure is MarkAsStarMultipleEmailFailure) {
          _markAsStarMultipleEmailFailure(failure);
        } else if (failure is EmptyTrashFolderFailure) {
          _emptyTrashFolderFailure(failure);
        }  else if (failure is LoadMoreEmailsFailure) {
          stopFpsMeter();
        }
      },
      (success) {
        if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          log('ThreadController::onDone(): success: $success');
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

    searchWorker = ever(mailboxDashBoardController.searchState, (searchState) {
      if (searchState is SearchState) {
        if (searchState.searchStatus == SearchStatus.INACTIVE) {
          emailListSearch.clear();
        } else if (searchState.searchStatus == SearchStatus.ACTIVE) {
          cancelSelectEmail();
        }
      }
    });

    dashboardActionWorker = ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is DashBoardAction) {
        if (action is RefreshAllEmailAction) {
          refreshAllEmail();
          mailboxDashBoardController.clearDashBoardAction();
        } else if (action is MarkAsReadAllEmailAction) {
          markAsReadAllEmails();
          mailboxDashBoardController.clearDashBoardAction();
        } if (action is SelectionAllEmailAction) {
          setSelectAllEmailAction();
          mailboxDashBoardController.clearDashBoardAction();
        } if (action is CancelSelectionAllEmailAction) {
          cancelSelectEmail();
          mailboxDashBoardController.clearDashBoardAction();
        } if (action is FilterMessageAction) {
          filterMessagesAction(action.context, action.option);
          mailboxDashBoardController.clearDashBoardAction();
        } if (action is HandleEmailActionTypeAction) {
          pressEmailSelectionAction(action.context, action.emailAction, action.listEmailSelected);
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
          } else if (success is MarkAsEmailReadSuccess
              || success is MoveToMailboxSuccess
              || success is MarkAsStarEmailSuccess
              || success is DeleteEmailPermanentlySuccess
              || success is SaveEmailAsDraftsSuccess
              || success is RemoveEmailDraftsSuccess
              || success is SendEmailSuccess
              || success is UpdateEmailDraftsSuccess) {
            _refreshEmailChanges();
          }
        });
      }
    });
  }

  void _clearWorker() {
    mailboxWorker.call();
    dashboardActionWorker.call();
    searchWorker.call();
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
    disableSearch();
    cancelSelectEmail();
    mailboxDashBoardController.dispatchRoute(AppRoutes.THREAD);
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    log('ThreadController::_getAllEmailSuccess(): ${success.emailList.length}');
    _currentEmailState = success.currentEmailState;
    emailList.value = success.emailList;
    if (listEmailController.hasClients) {
      listEmailController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  void _refreshChangesAllEmailSuccess(RefreshChangesAllEmailSuccess success) {
    log('ThreadController::_refreshChangesAllEmailSuccess(): ${success.emailList.length}');
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
    log('ThreadController::_getAllEmailAction(): mailboxId = $mailboxId');
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

  void _refreshEmailChanges() {
    log('ThreadController::_refreshEmailChanges(): ');
    if (isSearchActive()) {
      if (_accountId != null && searchQuery != null) {
        final limit = emailListSearch.isNotEmpty ? UnsignedInt(emailListSearch.length) : ThreadConstants.defaultLimit;
        consumeState(_searchEmailInteractor.execute(
          _accountId!,
          limit: limit,
          sort: _sortOrder,
          filter: EmailFilterCondition(text: searchQuery!.value),
          properties: ThreadConstants.propertiesDefault,
        ));
      }
    }
    if (_accountId != null && _currentEmailState != null) {
      consumeState(_refreshChangesEmailsInMailboxInteractor.execute(
        _accountId!,
        _currentEmailState!,
        sort: _sortOrder,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        inMailboxId: _currentMailboxId,
        filterOption: mailboxDashBoardController.filterMessageOption.value
      ));
    }
  }

  void loadMoreEmails() {
    if (canLoadMore && _accountId != null) {
      log('ThreadController::loadMoreEmails(): latest: ${emailList.last.receivedAt}');
      startFpsMeter();
      consumeState(_loadMoreEmailsInMailboxInteractor.execute(
        GetEmailRequest(
            _accountId!,
            limit: ThreadConstants.defaultLimit,
            sort: _sortOrder,
            filter: _getFilterCondition(isLoadMore: true),
            properties: ThreadConstants.propertiesDefault,
            lastEmailId: emailList.last.id)
      ));
    }
  }

  void _loadMoreEmailsSuccess(LoadMoreEmailsSuccess success) {
    log('ThreadController::_loadMoreEmailsSuccess(): [BEFORE] totalEmailList = ${emailList.length}');
    if (success.emailList.isNotEmpty) {
      log('ThreadController::_loadMoreEmailsSuccess(): add success: ${success.emailList.length}');
      emailList.addAll(success.emailList);
      log('ThreadController::_loadMoreEmailsSuccess(): [AFTER] totalEmailList = ${emailList.length}');
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
    if (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context)) {
      mailboxDashBoardController.dispatchRoute(AppRoutes.EMAIL);
    } else {
      goToEmail(context);
    }
  }

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    if (isSearchActive()) {
      emailListSearch.value = emailListSearch
        .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
        .toList();
    } else {
      emailList.value = emailList
        .map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email)
        .toList();
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

  void enableSelectionEmail() {
    mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
  }

  void setSelectAllEmailAction() {
    if (isSearchActive()) {
      emailListSearch.value = emailListSearch.map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE)).toList();
    } else {
      emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.ACTIVE)).toList();
    }
    mailboxDashBoardController.currentSelectMode.value = SelectMode.ACTIVE;
    mailboxDashBoardController.listEmailSelected.value = listEmailSelected;
  }

  List<PresentationEmail> get listEmailSelected {
    if (isSearchActive()) {
      return emailListSearch.where((email) => email.selectMode == SelectMode.ACTIVE).toList();
    } else {
      return emailList.where((email) => email.selectMode == SelectMode.ACTIVE).toList();
    }
  }

  bool _isUnSelectedAll() {
    if (isSearchActive()) {
      return emailListSearch.every((email) => email.selectMode == SelectMode.INACTIVE);
    } else {
      return emailList.every((email) => email.selectMode == SelectMode.INACTIVE);
    }
  }

  void cancelSelectEmail() {
    emailListSearch.value = emailListSearch.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    mailboxDashBoardController.currentSelectMode.value = SelectMode.INACTIVE;
    mailboxDashBoardController.listEmailSelected.clear();
  }

  void markAsReadAllEmails() {
    final listEmail = isSearchActive() ? emailListSearch.allEmailUnread : emailList.allEmailUnread;
    log('ThreadController::markAsReadAllEmails(): ${listEmail.length}');
    if (listEmail.isNotEmpty) {
      markAsReadSelectedMultipleEmail(listEmail);
    }
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail) {
    final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
    log('ThreadController::markAsReadSelectedMultipleEmail(): listPresentationEmail: ${listPresentationEmail.length}');
    final readAction = listPresentationEmail.isAllEmailRead ? ReadActions.markAsUnread : ReadActions.markAsRead;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      cancelSelectEmail();
      log('ThreadController::markAsReadSelectedMultipleEmail(): listEmail: ${listEmail.length}');
      consumeState(_markAsMultipleEmailReadInteractor.execute(_accountId!, listEmail, readAction));
    }
  }

  void _markAsReadSelectedMultipleEmailSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    ReadActions? readActions;

    if (success is MarkAsMultipleEmailReadAllSuccess) {
      readActions = success.readActions;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      readActions = success.readActions;
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
    log('ThreadController::_markAsReadSelectedMultipleEmailSuccess(): _refreshEmailChanges');
    _refreshEmailChanges();
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

    log('ThreadController::filterMessagesAction(): newFilterOption: $newFilterOption');

    mailboxDashBoardController.filterMessageOption.value = newFilterOption;

    log('ThreadController::filterMessagesAction(): filterMessageOption: ${mailboxDashBoardController.filterMessageOption}');

    _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: newFilterOption.getMessageToast(context),
        icon: newFilterOption.getIconToast(_imagePaths));

    refreshAllEmail();
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

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
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
          }
      );
    }

    _refreshEmailChanges();
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

  void _markAsStarEmailSuccess(Success success) {
    _refreshEmailChanges();
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

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
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

    _refreshEmailChanges();
  }

  void _markAsStarMultipleEmailFailure(Failure failure) {
    if (currentContext != null) {
      _appToast.showErrorToast(AppLocalizations.of(currentContext!).an_error_occurred);
    }
  }

  bool isSearchActive() => mailboxDashBoardController.isSearchActive();

  void enableSearch(BuildContext context) {
    mailboxDashBoardController.enableSearch();
  }

  void disableSearch() {
    emailListSearch.clear();
    mailboxDashBoardController.disableSearch();
    cancelSelectEmail();
  }

  void _searchEmail() {
    emailListSearch.clear();

    if (_accountId != null && searchQuery != null) {
      consumeState(_searchEmailInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: EmailFilterCondition(text: searchQuery!.value),
        properties: ThreadConstants.propertiesDefault,
      ));
    }
  }

  void _searchEmailsSuccess(SearchEmailSuccess success) {
    final resultEmailSearchList = success.emailList
        .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
        .toList();

    final emailsSearchBeforeChanges = emailListSearch;
    final emailsSearchAfterChanges = resultEmailSearchList;
    final newListEmailSearch = emailsSearchAfterChanges.combine(emailsSearchBeforeChanges);
    emailListSearch.value = newListEmailSearch;
  }

  void searchMoreEmails() {
    if (canSearchMore && _accountId != null) {
      consumeState(_searchMoreEmailInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: EmailFilterCondition(
            text: searchQuery!.value,
            before: emailListSearch.last.receivedAt),
        properties: ThreadConstants.propertiesDefault,
        lastEmailId: emailListSearch.last.id
      ));
    }
  }

  void _searchMoreEmailsSuccess(SearchMoreEmailSuccess success) {
    if (success.emailList.isNotEmpty) {
      final resultEmailSearchList = success.emailList
          .map((email) => email.toSearchPresentationEmail(mailboxDashBoardController.mapMailbox))
          .where((email) => !emailListSearch.contains(email))
          .toList();
      emailListSearch.addAll(resultEmailSearchList);
    } else {
      canSearchMore = false;
    }
    _isLoadingMore = false;
  }

  bool isSelectionEnabled() => mailboxDashBoardController.isSelectionEnabled();

  void pressEmailSelectionAction(BuildContext context, EmailActionType actionType, List<PresentationEmail> selectionEmail) {
    log('ThreadController::pressEmailSelectionAction(): selectionEmail: ${selectionEmail.length}');
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
        deleteSelectionEmailsPermanently(context, DeleteActionType.multiple, selectedEmails: selectionEmail);
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
          }
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

  void deleteSelectionEmailsPermanently(BuildContext context, DeleteActionType actionType, {List<PresentationEmail>? selectedEmails}) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(actionType.getContentDialog(context, count: selectedEmails?.length))
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
              ..content(actionType.getContentDialog(context, count: selectedEmails?.length))
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

    List<EmailId> listEmailIdResult = <EmailId>[];
    if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
      listEmailIdResult = success.emailIds;
    } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      listEmailIdResult = success.emailIds;
    }

    if (currentContext != null && currentOverlayContext != null && listEmailIdResult.isNotEmpty) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length),
          icon: _imagePaths.icDeleteToast);
    }

    _refreshEmailChanges();
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

  void _emptyTrashFolderFailure(EmptyTrashFolderFailure failure) {
    mailboxDashBoardController.dispatchState(Left(failure));
    refreshAllEmail();
  }

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openMailboxMenuDrawer();
  }

  void goToEmail(BuildContext context) {
    push(AppRoutes.EMAIL);
  }

  void editEmail(PresentationEmail presentationEmail) {
    final arguments = ComposerArguments(
        emailActionType: EmailActionType.edit,
        presentationEmail: presentationEmail,
        mailboxRole: mailboxDashBoardController.selectedMailbox.value?.role);

    if (kIsWeb) {
      mailboxDashBoardController.dispatchAction(ComposeEmailAction(arguments: arguments));
    } else {
      push(AppRoutes.COMPOSER, arguments: arguments);
    }
  }

  void composeEmailAction() {
    mailboxDashBoardController.composeEmailAction();
  }
}