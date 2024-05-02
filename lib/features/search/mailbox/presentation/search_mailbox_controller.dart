
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_action_handler_mixin.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/constants/mailbox_constants.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_starred_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_search_as_unread_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SearchMailboxController extends BaseMailboxController with MailboxActionHandlerMixin {

  final SearchMailboxInteractor _searchMailboxInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final SubscribeMailboxInteractor _subscribeMailboxInteractor;
  final SubscribeMultipleMailboxInteractor _subscribeMultipleMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;

  final dashboardController = Get.find<MailboxDashBoardController>();

  final currentSearchQuery = RxString('');
  final listMailboxSearched = RxList<PresentationMailbox>();
  final textInputSearchController = TextEditingController();
  late Debouncer<String> _deBouncerTime;

  PresentationMailbox? get selectedMailbox => dashboardController.selectedMailbox.value;

  PresentationEmail? get selectedEmail => dashboardController.selectedEmail.value;

  SearchMailboxController(
    this._searchMailboxInteractor,
    this._renameMailboxInteractor,
    this._moveMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._subscribeMailboxInteractor,
    this._subscribeMultipleMailboxInteractor,
    this._createNewMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor refreshAllMailboxInteractor
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    super.onInit();
    _initializeDebounceTimeTextSearchChange();
    _getAllMailboxAction();
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is SearchMailboxFailure) {
      _handleSearchMailboxFailure(failure);
    } else if (failure is CreateNewMailboxFailure) {
      _createNewMailboxFailure(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess) {
      currentMailboxState = success.currentMailboxState;
      await buildTree(success.mailboxList);
      if (currentContext != null) {
        await syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is RefreshChangesAllMailboxSuccess) {
      currentMailboxState = success.currentMailboxState;
      await refreshTree(success.mailboxList);
      if (currentContext != null) {
        await syncAllMailboxWithDisplayName(currentContext!);
      }
      searchMailboxAction();
    } else if (success is SearchMailboxSuccess) {
      _handleSearchMailboxSuccess(success);
    } else if (success is MarkAsMailboxReadAllSuccess) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is RenameMailboxSuccess) {
      _refreshMailboxChanges(
        mailboxState: success.currentMailboxState,
        properties: MailboxConstants.propertiesDefault
      );
    } else if (success is MoveMailboxSuccess) {
      _moveMailboxSuccess(success);
    } else if (success is DeleteMultipleMailboxAllSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is SubscribeMailboxSuccess) {
      _handleSubscribeMailboxSuccess(success);
    } else if (success is SubscribeMultipleMailboxAllSuccess) {
      _handleSubscribeMultipleMailboxAllSuccess(success);
    } else if (success is SubscribeMultipleMailboxHasSomeSuccess) {
      _handleSubscribeMultipleMailboxHasSomeSuccess(success);
    } else if (success is CreateNewMailboxSuccess) {
      _createNewMailboxSuccess(success);
    } else if (success is MarkAllAsUnreadSelectionAllEmailsAllSuccess) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MoveAllSelectionAllEmailsAllSuccess) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MoveAllSelectionAllEmailsHasSomeEmailFailure) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is DeleteAllPermanentlyEmailsSuccess) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAllAsStarredSelectionAllEmailsAllSuccess) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure) {
      _refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAllSearchAsReadSuccess
        || success is MarkAllSearchAsUnreadSuccess
        || success is MarkAllSearchAsStarredSuccess
        || success is MoveAllEmailSearchedToFolderSuccess) {
      _refreshMailboxChanges();
    }
  }

  void _initializeDebounceTimeTextSearchChange() {
    _deBouncerTime = Debouncer<String>(
      const Duration(milliseconds: 300),
      initialValue: ''
    );

    _deBouncerTime.values.listen((value) async {
      log('SearchMailboxController::_initializeDebounceTimeTextSearchChange():query: $value');
      currentSearchQuery.value = value;
      searchMailboxAction();
    });
  }

  void _getAllMailboxAction() {
    final session = dashboardController.sessionCurrent;
    final accountId = dashboardController.accountId.value;
    if (session != null && accountId != null) {
      getAllMailbox(session, accountId);
    }
  }

  void _refreshMailboxChanges({jmap.State? mailboxState, Properties? properties}) {
    dashboardController.dispatchMailboxUIAction(RefreshChangeMailboxAction(null));
    final newMailboxState = mailboxState ?? currentMailboxState;
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null && newMailboxState != null) {
      refreshMailboxChanges(
        session,
        accountId,
        newMailboxState,
        properties: properties
      );
    }
  }

  void searchMailboxAction() {
    if (currentSearchQuery.value.isNotEmpty) {
      consumeState(_searchMailboxInteractor.execute(
        allMailboxes,
        SearchQuery(currentSearchQuery.value)
      ));
    } else {
      listMailboxSearched.clear();
    }
  }

  void handleSearchButtonPressed(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    searchMailboxAction();
  }

  void _handleSearchMailboxSuccess(SearchMailboxSuccess success) {
    final mailboxesSearchedWithPath = findMailboxPath(success.mailboxesSearched);
    listMailboxSearched.value = mailboxesSearchedWithPath;
  }

  void _handleSearchMailboxFailure(SearchMailboxFailure failure) {
    listMailboxSearched.clear();
  }

  void onTextSearchChange(String text) {
    _deBouncerTime.value = text;
  }

  void onTextSearchSubmitted(BuildContext context, String text) {
    final query = text.trim();
    if (query.isNotEmpty) {
      submitSearchAction(context, query);
    }
  }

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void submitSearchAction(BuildContext context, String query) {
    KeyboardUtils.hideKeyboard(context);
    currentSearchQuery.value = query;
    searchMailboxAction();
  }

  void handleMailboxAction(
    BuildContext context,
    MailboxActions actions,
    PresentationMailbox mailbox,
    {bool isFocusedMenu = false}
  ) {
    if (!isFocusedMenu) {
      popBack();
    }

    switch(actions) {
      case MailboxActions.openInNewTab:
        openMailboxInNewTabAction(mailbox);
        break;
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        dashboardController.storeSpamReportStateAction();
        break;
      case MailboxActions.confirmMailSpam:
      case MailboxActions.markAsRead:
        markAsReadMailboxAction(context, mailbox, dashboardController);
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          mailbox,
          responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          mailbox,
          dashboardController,
          onMovingMailboxAction: (mailboxSelected, destinationMailbox) => _invokeMovingMailboxAction(context, mailboxSelected, destinationMailbox)
        );
        break;
      case MailboxActions.delete:
        openConfirmationDialogDeleteMailboxAction(
          context,
          responsiveUtils,
          imagePaths,
          mailbox,
          onDeleteMailboxAction: _deleteMailboxAction
        );
        break;
      case MailboxActions.disableMailbox:
        _updateSubscribeStateOfMailboxAction(
          mailbox.id,
          MailboxSubscribeState.disabled,
          MailboxSubscribeAction.unSubscribe
        );
        break;
      case MailboxActions.enableMailbox:
        _updateSubscribeStateOfMailboxAction(
          mailbox.id,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.subscribe
        );
        break;
      case MailboxActions.emptyTrash:
        emptyTrashAction(context, mailbox, dashboardController);
        break;
      case MailboxActions.emptySpam:
        emptySpamAction(context, mailbox, dashboardController);
        break;
      case MailboxActions.newSubfolder:
        goToCreateNewMailboxView(context, parentMailbox: mailbox);
        break;
      default:
        break;
    }
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, MailboxName newMailboxName) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      consumeState(_renameMailboxInteractor.execute(
        session,
        accountId,
        RenameMailboxRequest(presentationMailbox.id, newMailboxName)
      ));
    }
  }

  void _invokeMovingMailboxAction(
    BuildContext context,
    PresentationMailbox mailboxSelected,
    PresentationMailbox? destinationMailbox
  ) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      _handleMovingMailbox(
        context,
        session,
        accountId,
        MoveAction.moving,
        mailboxSelected,
        destinationMailbox: destinationMailbox
      );
    }
  }

  void _handleMovingMailbox(
    BuildContext context,
    Session session,
    AccountId accountId,
    MoveAction moveAction,
    PresentationMailbox mailboxSelected,
    {PresentationMailbox? destinationMailbox}
  ) {
    consumeState(_moveMailboxInteractor.execute(
      session,
      accountId,
      MoveMailboxRequest(
        mailboxSelected.id,
        moveAction,
        destinationMailboxId: destinationMailbox?.id,
        destinationMailboxDisplayName: destinationMailbox?.getDisplayName(context),
        parentId: mailboxSelected.parentId
      )
    ));
  }

  void _moveMailboxSuccess(MoveMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving && currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).movedToFolder(success.destinationMailboxDisplayName ?? AppLocalizations.of(currentContext!).allFolders),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          _undoMovingMailbox(MoveMailboxRequest(
            success.mailboxIdSelected,
            MoveAction.undo,
            destinationMailboxId: success.parentId,
            parentId: success.destinationMailboxId)
          );
        },
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo)
      );
    }

    _refreshMailboxChanges(
      mailboxState: success.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      consumeState(_moveMailboxInteractor.execute(session, accountId, newMoveRequest));
    }
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;

    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
        [presentationMailbox],
        defaultMailboxTree.value,
        personalMailboxTree.value
      );
      final mapDescendantIds = tupleMap.value1;
      final listMailboxId = tupleMap.value2;

      consumeState(_deleteMultipleMailboxInteractor.execute(
        session,
        accountId,
        mapDescendantIds,
        listMailboxId
      ));
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    popBack();
  }

  void _deleteMultipleMailboxSuccess(List<MailboxId> listMailboxIdDeleted, jmap.State? currentMailboxState) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteFoldersSuccessfully);
    }

    if (listMailboxIdDeleted.contains(dashboardController.selectedMailbox.value?.id)) {
      dashboardController.selectedMailbox.value = null;
      dashboardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
    }

    _refreshMailboxChanges(mailboxState: currentMailboxState);
  }

  void _deleteMailboxFailure(DeleteMultipleMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteFoldersFailure);
    }
  }

  void _updateSubscribeStateOfMailboxAction(
    MailboxId mailboxId,
    MailboxSubscribeState subscribeState,
    MailboxSubscribeAction subscribeAction
  ) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;

    if (session != null && accountId != null) {
      final subscribeRequest = generateSubscribeRequest(mailboxId, subscribeState, subscribeAction);

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(session, accountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(session, accountId, subscribeRequest));
      }
    }
  }

  void openMailboxAction(BuildContext context, PresentationMailbox mailbox) {
    KeyboardUtils.hideKeyboard(context);
    dashboardController.openMailboxAction(mailbox);

    if (!responsiveUtils.isWebDesktop(context)) {
      closeSearchView(context);
    }
  }

  void _handleSubscribeMailboxSuccess(SubscribeMailboxSuccess success) {
    if (success.subscribeAction != MailboxSubscribeAction.undo) {
      _showToastSubscribeMailboxSuccess(success.mailboxId, success.subscribeAction);

      if (success.mailboxId == selectedMailbox?.id) {
        dashboardController.selectedMailbox.value = null;
        dashboardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
        _closeEmailViewIfMailboxDisabledOrNotExist([success.mailboxId]);
      }
    }

    _refreshMailboxChanges(
      mailboxState: success.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _handleSubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess success) {
    if(success.subscribeAction != MailboxSubscribeAction.undo) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        success.subscribeAction,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        dashboardController.selectedMailbox.value = null;
        dashboardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }

    _refreshMailboxChanges(
      mailboxState: success.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _handleSubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess success) {
    if(success.subscribeAction != MailboxSubscribeAction.undo) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        success.subscribeAction,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        dashboardController.selectedMailbox.value = null;
        dashboardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }

    _refreshMailboxChanges(
      mailboxState: success.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      MailboxSubscribeAction subscribeAction,
      {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        subscribeAction.getToastMessageSuccess(currentContext!),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          if (subscribeAction == MailboxSubscribeAction.unSubscribe) {
            _undoUnsubscribeMailboxAction(
              mailboxIdSubscribed,
              listDescendantMailboxIds: listDescendantMailboxIds
            );
          } else {
            _undoSubscribeMailboxAction(
              mailboxIdSubscribed,
              listDescendantMailboxIds: listDescendantMailboxIds
            );
          }
        },
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  void _undoUnsubscribeMailboxAction(
    MailboxId mailboxIdSubscribed,
    {List<MailboxId>? listDescendantMailboxIds}
  ) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      SubscribeRequest? subscribeRequest;

      if (listDescendantMailboxIds != null) {
        subscribeRequest = SubscribeMultipleMailboxRequest(
          mailboxIdSubscribed,
          listDescendantMailboxIds,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo
        );
      } else {
        subscribeRequest = SubscribeMailboxRequest(
          mailboxIdSubscribed,
          MailboxSubscribeState.enabled,
          MailboxSubscribeAction.undo
        );
      }

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(session, accountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(session, accountId, subscribeRequest));
      }
    }
  }

  void _undoSubscribeMailboxAction(
    MailboxId mailboxIdSubscribed,
    {List<MailboxId>? listDescendantMailboxIds}
  ) {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      SubscribeRequest? subscribeRequest;

      if (listDescendantMailboxIds != null) {
        subscribeRequest = SubscribeMultipleMailboxRequest(
          mailboxIdSubscribed,
          listDescendantMailboxIds,
          MailboxSubscribeState.disabled,
          MailboxSubscribeAction.undo
        );
      } else {
        subscribeRequest = SubscribeMailboxRequest(
          mailboxIdSubscribed,
          MailboxSubscribeState.disabled,
          MailboxSubscribeAction.undo
        );
      }

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(session, accountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(session, accountId, subscribeRequest));
      }
    }
  }

  void _closeEmailViewIfMailboxDisabledOrNotExist(List<MailboxId> mailboxIdsDisabled) {
    if (selectedEmail == null) {
      return;
    }

    final mailboxContain = selectedEmail!.findMailboxContain(dashboardController.mapMailboxById);
    if (mailboxContain != null && mailboxIdsDisabled.contains(mailboxContain.id)) {
      dashboardController.clearSelectedEmail();
      dashboardController.dispatchRoute(DashboardRoutes.thread);
    }
  }

  void goToCreateNewMailboxView(BuildContext context, {PresentationMailbox? parentMailbox}) async {
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null) {
      final arguments = MailboxCreatorArguments(
          accountId,
          defaultMailboxTree.value,
          personalMailboxTree.value,
          teamMailboxesTree.value,
          dashboardController.sessionCurrent!,
          parentMailbox
        );

      final result = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.mailboxCreator, arguments: arguments)
        : await push(AppRoutes.mailboxCreator, arguments: arguments);

      if (result != null && result is NewMailboxArguments) {
        _createNewMailboxAction(session, accountId, CreateNewMailboxRequest(
          result.newName,
          parentId: result.mailboxLocation?.id));
      }
    }
  }

  void _createNewMailboxAction(Session session, AccountId accountId, CreateNewMailboxRequest request) async {
    consumeState(_createNewMailboxInteractor.execute(session, accountId, request));
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).createFolderSuccessfullyMessage(success.newMailbox.name?.name ?? ''),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox);
    }

    _refreshMailboxChanges(mailboxState: success.currentMailboxState);
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).createNewFolderFailure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).createNewFolderFailure;
      }
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    currentSearchQuery.value = '';
    searchMailboxAction();
  }

  void closeSearchView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    if (PlatformInfo.isWeb) {
      dashboardController.searchMailboxActivated.value = false;
      clearAllTextInputSearchForm();
      SearchMailboxBindings().disposeBindings();
    } else {
      popBack();
    }
  }

  @override
  void onClose() {
    textInputSearchController.dispose();
    _deBouncerTime.cancel();
    super.onClose();
  }
}