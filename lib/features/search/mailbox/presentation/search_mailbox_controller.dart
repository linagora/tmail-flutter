
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_action_handler_mixin.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class SearchMailboxController extends BaseMailboxController with MailboxActionHandlerMixin {

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final RefreshAllMailboxInteractor _refreshAllMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final SubscribeMailboxInteractor _subscribeMailboxInteractor;

  final dashboardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final currentSearchQuery = RxString('');
  final listMailboxSearched = RxList<PresentationMailbox>();
  final textInputSearchController = TextEditingController();
  late Debouncer<String> _deBouncerTime;

  SearchMailboxController(
    this._getAllMailboxInteractor,
    this._refreshAllMailboxInteractor,
    this._searchMailboxInteractor,
    this._renameMailboxInteractor,
    this._moveMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._subscribeMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor
  ) : super(treeBuilder, verifyNameInteractor);

  @override
  void onInit() {
    super.onInit();
    _initializeDebounceTimeTextSearchChange();
    _getAllMailboxAction();
  }

  @override
  void onDone() {
    viewState.value.fold(_handleFailureViewState, _handleSuccessViewState);
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold((failure) => null, (success) async {
      if (success is GetAllMailboxSuccess) {
        currentMailboxState = success.currentMailboxState;
        buildTree(success.mailboxList);
      } else if (success is RefreshChangesAllMailboxSuccess) {
        currentMailboxState = success.currentMailboxState;
        await refreshTree(success.mailboxList);
        searchMailboxAction();
      }
    });
  }

  void _handleFailureViewState(Failure failure) {
    if (failure is SearchMailboxFailure) {
      _handleSearchMailboxFailure(failure);
    }
  }

  void _handleSuccessViewState(Success success) {
    if (success is SearchMailboxSuccess) {
      _handleSearchMailboxSuccess(success);
    } else if (success is MarkAsMailboxReadAllSuccess) {
      refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is RenameMailboxSuccess) {
      refreshMailboxChanges(mailboxState: success.currentMailboxState);
    } else if (success is MoveMailboxSuccess) {
      _moveMailboxSuccess(success);
    }else if (success is DeleteMultipleMailboxAllSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is SubscribeMailboxSuccess) {
      _handleSubscribeMailboxSuccess(success);
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
      consumeState(_getAllMailboxInteractor.execute(session, accountId));
    }
  }

  void refreshMailboxChanges({jmap.State? mailboxState}) {
    dashboardController.dispatchMailboxUIAction(RefreshChangeMailboxAction(null));
    final newMailboxState = mailboxState ?? currentMailboxState;
    final accountId = dashboardController.accountId.value;
    final session = dashboardController.sessionCurrent;
    if (session != null && accountId != null && newMailboxState != null) {
      consumeState(_refreshAllMailboxInteractor.execute(session, accountId, newMailboxState));
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
    FocusScope.of(context).unfocus();
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

  void setTextInputSearchForm(String value) {
    textInputSearchController.text = value;
  }

  void submitSearchAction(BuildContext context, String query) {
    FocusScope.of(context).unfocus();
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
        return;
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
          onMovingMailboxAction: _invokeMovingMailboxAction
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
        _subscribeMailboxAction(SubscribeMailboxRequest(
          mailbox.id,
          MailboxSubscribeState.disabled,
          MailboxSubscribeAction.unSubscribe
        ));
        break;
      default:
        break;
    }
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, MailboxName newMailboxName) {
    final accountId = dashboardController.accountId.value;
    if (accountId != null) {
      consumeState(_renameMailboxInteractor.execute(
        accountId,
        RenameMailboxRequest(presentationMailbox.id, newMailboxName)
      ));
    }
  }

  void _invokeMovingMailboxAction(PresentationMailbox mailboxSelected, PresentationMailbox? destinationMailbox) {
    final accountId = dashboardController.accountId.value;
    if (accountId != null) {
      _handleMovingMailbox(
        accountId,
        MoveAction.moving,
        mailboxSelected,
        destinationMailbox: destinationMailbox
      );
    }
  }

  void _handleMovingMailbox(
    AccountId accountId,
    MoveAction moveAction,
    PresentationMailbox mailboxSelected,
    {PresentationMailbox? destinationMailbox}
  ) {
    consumeState(_moveMailboxInteractor.execute(
      accountId,
      MoveMailboxRequest(
        mailboxSelected.id,
        moveAction,
        destinationMailboxId: destinationMailbox?.id,
        destinationMailboxName: destinationMailbox?.name,
        parentId: mailboxSelected.parentId
      )
    ));
  }

  void _moveMailboxSuccess(MoveMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving && currentOverlayContext != null && currentContext != null) {
      _appToast.showBottomToast(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).moved_to_mailbox(success.destinationMailboxName?.name ?? AppLocalizations.of(currentContext!).allMailboxes),
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () {
          _undoMovingMailbox(MoveMailboxRequest(
            success.mailboxIdSelected,
            MoveAction.undo,
            destinationMailboxId: success.parentId,
            parentId: success.destinationMailboxId)
          );
        },
        leadingIcon: SvgPicture.asset(
          imagePaths.icFolderMailbox,
          width: 24,
          height: 24,
          color: Colors.white,
          fit: BoxFit.fill),
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        textActionColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
        maxWidth: responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }

    refreshMailboxChanges(mailboxState: success.currentMailboxState);
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    final accountId = dashboardController.accountId.value;
    if (accountId != null) {
      consumeState(_moveMailboxInteractor.execute(accountId, newMoveRequest));
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
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).delete_mailboxes_successfully,
        icon: imagePaths.icSelected
      );
    }

    if (listMailboxIdDeleted.contains(dashboardController.selectedMailbox.value?.id)) {
      dashboardController.selectedMailbox.value = null;
      dashboardController.dispatchMailboxUIAction(SelectMailboxDefaultAction());
    }

    refreshMailboxChanges(mailboxState: currentMailboxState);
  }

  void _deleteMailboxFailure(DeleteMultipleMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).delete_mailboxes_failure,
        icon: imagePaths.icDeleteToast
      );
    }
  }

  void _subscribeMailboxAction(SubscribeMailboxRequest subscribeMailboxRequest) {
    final _accountId = dashboardController.accountId.value;
    if (_accountId != null) {
      consumeState(_subscribeMailboxInteractor.execute(
        _accountId,
        subscribeMailboxRequest
      ));
    }
  }

  void _handleSubscribeMailboxSuccess(SubscribeMailboxSuccess success) {
    if(success.mailboxSubscribeStateAction == MailboxSubscribeAction.unSubscribe
      && currentOverlayContext != null
      && currentContext != null
    ) {
      _appToast.showBottomToast(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideMailboxSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _invokeUndoUnsubscribeMailboxAction(success.mailboxId),
        leadingIcon: SvgPicture.asset(
          imagePaths.icFolderMailbox,
          width: 24,
          height: 24,
          color: Colors.white,
          fit: BoxFit.fill
        ),
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        textActionColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
        maxWidth: responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }

    refreshMailboxChanges(mailboxState: success.currentMailboxState);
  }

  void _invokeUndoUnsubscribeMailboxAction(MailboxId mailboxId) {
    _subscribeMailboxAction(SubscribeMailboxRequest(
      mailboxId,
      MailboxSubscribeState.enabled,
      MailboxSubscribeAction.undo
    ));
  }

  void openMailboxAction(BuildContext context, PresentationMailbox mailbox) {
    FocusScope.of(context).unfocus();
    dashboardController.openMailboxAction(context, mailbox);

    if (!responsiveUtils.isWebDesktop(context)) {
      closeSearchView(context);
    }
  }

  void clearAllTextInputSearchForm() {
    textInputSearchController.clear();
    currentSearchQuery.value = '';
    searchMailboxAction();
  }

  void closeSearchView(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (BuildUtils.isWeb) {
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