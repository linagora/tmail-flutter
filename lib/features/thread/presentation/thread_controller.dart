import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_action.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/load_more_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/search_more_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/load_more_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_all_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/search_more_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/filter_message_option_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _appToast = Get.find<AppToast>();

  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final RefreshAllEmailsInMailboxInteractor _refreshAllEmailsInMailboxInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final RefreshChangesEmailsInMailboxInteractor _refreshChangesEmailsInMailboxInteractor;
  final LoadMoreEmailsInMailboxInteractor _loadMoreEmailsInMailboxInteractor;
  final SearchEmailInteractor _searchEmailInteractor;
  final SearchMoreEmailInteractor _searchMoreEmailInteractor;

  final emailList = <PresentationEmail>[].obs;
  final emailListSearch = <PresentationEmail>[].obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;

  bool canLoadMore = true;
  bool canSearchMore = true;
  bool _isLoadingMore = false;
    get isLoadingMore => _isLoadingMore;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;
  final ScrollController listEmailController = ScrollController();

  SearchQuery? get searchQuery => mailboxDashBoardController.searchQuery;

  Set<Comparator>? get _sortOrder => Set()
    ..add(EmailComparator(EmailComparatorProperty.receivedAt)
      ..setIsAscending(false));

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  ThreadController(
    this._getEmailsInMailboxInteractor,
    this._refreshAllEmailsInMailboxInteractor,
    this._markAsMultipleEmailReadInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._markAsStarEmailInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._refreshChangesEmailsInMailboxInteractor,
    this._loadMoreEmailsInMailboxInteractor,
    this._searchEmailInteractor,
    this._searchMoreEmailInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    dispatchState(Right(LoadingState()));
  }

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedMailbox.listen((selectedMailbox) {
      if (_currentMailboxId != selectedMailbox?.id) {
        log('ThreadController::onReady(): selectMailbox: ${selectedMailbox?.name?.name}(${selectedMailbox?.id})');
        _currentMailboxId = selectedMailbox?.id;
        _resetToOriginalValue();
        _getAllEmail();
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        if (success is MarkAsEmailReadSuccess
            || success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure
            || success is MoveToMailboxSuccess
            || success is MarkAsStarEmailSuccess) {
          cancelSelectEmail();
          _refreshEmailChanges();
          mailboxDashBoardController.clearState();
        } else if (success is SearchEmailNewQuery){
          _searchEmail();
          mailboxDashBoardController.clearState();
        } else if (success is SaveEmailAsDraftsSuccess
            || success is RemoveEmailDraftsSuccess
            || success is SendEmailSuccess
            || success is UpdateEmailDraftsSuccess) {
          cancelSelectEmail();
          _refreshEmailChanges();
        }
      });
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.selectedMailbox.close();
    mailboxDashBoardController.viewState.close();
    listEmailController.dispose();
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
          _markAsSelectedEmailReadFailure(failure);
        } else if (failure is MarkAsStarMultipleEmailAllFailure
            || failure is MarkAsStarMultipleEmailFailure) {
          _markAsStarMultipleEmailFailure(failure);
        }
      },
      (success) {
        if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsSelectedEmailReadSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is MarkAsStarEmailSuccess) {
          _markAsStarEmailSuccess(success);
        } else if (success is MarkAsStarMultipleEmailAllSuccess
            || success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
          _markAsStarMultipleEmailSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

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
  }

  void _getAllEmailSuccess(GetAllEmailSuccess success) {
    log('ThreadController::_getAllEmailSuccess(): ${success.emailList.length}');
    _currentEmailState = success.currentEmailState;
    emailList.value = success.emailList;
  }

  void _getAllEmailAction(AccountId accountId, {MailboxId? mailboxId}) {
    log('ThreadController::_getAllEmailAction(): mailboxId = $mailboxId');
    consumeState(_getEmailsInMailboxInteractor.execute(
      accountId,
      limit: ThreadConstants.defaultLimit,
      sort: _sortOrder,
      emailFilter: EmailFilter(
        filter: _getFilterCondition(),
        filterOption: filterMessageOption.value,
        mailboxId: mailboxId ?? _currentMailboxId),
      propertiesCreated: ThreadConstants.propertiesDefault,
      propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
    ));
  }

  EmailFilterCondition _getFilterCondition({bool isLoadMore = false}) {
    switch(filterMessageOption.value) {
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
      consumeState(_refreshAllEmailsInMailboxInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        emailFilter: EmailFilter(
            filter: _getFilterCondition(),
            filterOption: filterMessageOption.value,
            mailboxId: _currentMailboxId),
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      ));
    }
  }

  void _refreshEmailChanges() {
    if (isSearchActive()) {
      if (_accountId != null && searchQuery != null) {
        final limit = emailListSearch.length > 0 ? UnsignedInt(emailListSearch.length) : ThreadConstants.defaultLimit;
        consumeState(_searchEmailInteractor.execute(
          _accountId!,
          limit: limit,
          sort: _sortOrder,
          filter: EmailFilterCondition(text: searchQuery!.value),
          properties: ThreadConstants.propertiesDefault,
        ));
      }
    } else {
      if (_accountId != null && _currentEmailState != null) {
        consumeState(_refreshChangesEmailsInMailboxInteractor.execute(
          _accountId!,
          _currentEmailState!,
          sort: _sortOrder,
          propertiesCreated: ThreadConstants.propertiesDefault,
          propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
          inMailboxId: _currentMailboxId,
          filterOption: filterMessageOption.value
        ));
      }
    }
  }

  void loadMoreEmails() {
    if (canLoadMore && _accountId != null) {
      log('ThreadController::loadMoreEmails(): latest: ${emailList.last.receivedAt}');
      consumeState(_loadMoreEmailsInMailboxInteractor.execute(
        _accountId!,
        limit: ThreadConstants.defaultLimit,
        sort: _sortOrder,
        filter: _getFilterCondition(isLoadMore: true),
        properties: ThreadConstants.propertiesDefault,
        lastEmailId: emailList.last.id
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
      currentSelectMode.value = SelectMode.INACTIVE;
    } else {
      if (currentSelectMode.value == SelectMode.INACTIVE) {
        currentSelectMode.value = SelectMode.ACTIVE;
      }
    }
  }

  void enableSelectionEmail() {
    currentSelectMode.value = SelectMode.ACTIVE;
  }

  List<PresentationEmail> getListEmailSelected() {
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

  bool isAllEmailRead(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isReadEmail());

  bool isAllEmailMarkAsStar(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isFlaggedEmail());

  void cancelSelectEmail() {
    if (isSearchActive()) {
      emailListSearch.value = emailListSearch.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    } else {
      emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    }
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  void markAsSelectedEmailRead(List<PresentationEmail> listPresentationEmail, {bool fromContextMenuAction = false}) {
    if (fromContextMenuAction) {
      popBack();
    }

    final readAction = isAllEmailRead(listPresentationEmail) ? ReadActions.markAsUnread : ReadActions.markAsRead;

    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
      consumeState(_markAsMultipleEmailReadInteractor.execute(_accountId!, listEmail, readAction));
    }
  }

  void _markAsSelectedEmailReadSuccess(Success success) {
    cancelSelectEmail();

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
  }

  void _markAsSelectedEmailReadFailure(Failure failure) {
    cancelSelectEmail();
    _appToast.showErrorToast(AppLocalizations.of(currentContext!).an_error_occurred);
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
        position: position ?? RelativeRect.fromLTRB(16, 40, 16, 16),
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

    final newFilterOption = filterMessageOption.value == filterOption ? FilterMessageOption.all : filterOption;
    filterMessageOption.value = newFilterOption;

    _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: newFilterOption.getMessageToast(context),
        icon: newFilterOption.getIconToast(_imagePaths));

    refreshAllEmail();
  }

  void moveSelectedMultipleEmailToMailboxAction(List<PresentationEmail> listEmail) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    if (currentMailbox != null && _accountId != null) {
      popBack();

      final listEmailIds = listEmail.map((email) => email.id).toList();
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(_accountId!, MailboxActions.moveEmail)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        _moveSelectedEmailMultipleToMailbox(
            _accountId!,
            MoveRequest(
              listEmailIds,
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moveTo,
              destinationPath: destinationMailbox.mailboxPath));
      }
    }
  }

  void _moveSelectedEmailMultipleToMailbox(AccountId accountId, MoveRequest moveRequest) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    cancelSelectEmail();
    mailboxDashBoardController.dispatchState(Right(success));

    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
    }

    if (currentContext != null && currentOverlayContext != null
        && destinationPath != null && moveAction == MoveAction.moveTo) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).moved_to_mailbox(destinationPath),
          AppLocalizations.of(currentContext!).undo_action,
          () {
            final newCurrentMailboxId = destinationMailboxId;
            final newDestinationMailboxId = currentMailboxId;
            if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
              _undoMoveSelectedMultipleEmailToMailbox(MoveRequest(
                  movedEmailIds,
                  newCurrentMailboxId,
                  newDestinationMailboxId,
                  MoveAction.undo,
                  destinationPath: destinationPath));
            }
          }
      );
    }

    _refreshEmailChanges();
  }

  void _undoMoveSelectedMultipleEmailToMailbox(MoveRequest moveRequest) {
    if (_accountId != null) {
      _moveSelectedEmailMultipleToMailbox(_accountId!, moveRequest);
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail) {
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final importantAction = presentationEmail.isFlaggedEmail() ? MarkStarAction.unMarkStar : MarkStarAction.markStar;
      consumeState(_markAsStarEmailInteractor.execute(_accountId!, presentationEmail.toEmail(), importantAction));
    }
  }

  void _markAsStarEmailSuccess(Success success) {
    _refreshEmailChanges();
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    popBack();

    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
      consumeState(_markAsStarMultipleEmailInteractor.execute(_accountId!, listEmail, markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(Success success) {
    cancelSelectEmail();
    _refreshEmailChanges();

    MarkStarAction? markStarAction;
    int countMarkStarSuccess = 0;

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    }

    if (currentContext != null && markStarAction != null) {
      _appToast.showSuccessToast(markStarAction == MarkStarAction.unMarkStar
          ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
          : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess));
    }
  }

  void _markAsStarMultipleEmailFailure(Failure failure) {
    cancelSelectEmail();
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

    emailListSearch.value = resultEmailSearchList;
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

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void pressEmailSelectionAction(BuildContext context, EmailActionType actionType, List<PresentationEmail> selectionEmail) {
    switch(actionType) {
      case EmailActionType.markAsRead:
      case EmailActionType.markAsUnread:
        markAsSelectedEmailRead(selectionEmail);
        break;
      case EmailActionType.move:
        moveSelectedMultipleEmailToMailboxAction(selectionEmail);
        break;
      case EmailActionType.markAsFlag:
      case EmailActionType.markAsSpam:
      case EmailActionType.delete:
        _appToast.showToast(AppLocalizations.of(context).the_feature_is_under_development);
        break;
      default:
        break;
    }
  }

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openDrawer();
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
      mailboxDashBoardController.dispatchDashBoardAction(DashBoardAction.compose, arguments: arguments);
    } else {
      push(AppRoutes.COMPOSER, arguments: arguments);
    }
  }

  void composeEmailAction() {
    if (kIsWeb) {
      if (mailboxDashBoardController.dashBoardAction != DashBoardAction.compose) {
        mailboxDashBoardController.dispatchDashBoardAction(DashBoardAction.compose, arguments: ComposerArguments());
      }
    } else {
      push(AppRoutes.COMPOSER, arguments: ComposerArguments());
    }
  }
}