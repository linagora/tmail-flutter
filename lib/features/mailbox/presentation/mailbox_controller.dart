import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/mailbox_action_handler_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
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
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/action/mailbox_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/open_mailbox_view_event.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/mailbox/presentation/search_mailbox_bindings.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:uuid/uuid.dart';

class MailboxController extends BaseMailboxController with MailboxActionHandlerMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _uuid = Get.find<Uuid>();
  final isMailboxListScrollable = false.obs;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;
  final SubscribeMailboxInteractor _subscribeMailboxInteractor;
  final SubscribeMultipleMailboxInteractor _subscribeMultipleMailboxInteractor;

  final currentSelectMode = SelectMode.INACTIVE.obs;
  final _activeScrollTop = RxBool(false);
  final _activeScrollBottom = RxBool(true);

  final _openMailboxEventController = StreamController<OpenMailboxViewEvent>();
  final mailboxListScrollController = ScrollController();

  PresentationMailbox? get selectedMailbox => mailboxDashBoardController.selectedMailbox.value;

  PresentationEmail? get selectedEmail => mailboxDashBoardController.selectedEmail.value;

  MailboxController(
    this._createNewMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._renameMailboxInteractor,
    this._moveMailboxInteractor,
    this._subscribeMailboxInteractor,
    this._subscribeMultipleMailboxInteractor,
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor  refreshAllMailboxInteractor,
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    _registerObxStreamListener();
    super.onInit();
  }

  @override
  void onReady() {
    _openMailboxEventController.stream.debounceTime(const Duration(milliseconds: 500)).listen((event) {
      _handleOpenMailbox(event.buildContext, event.presentationMailbox);
    });
    _initCollapseMailboxCategories();
    mailboxListScrollController.addListener(_mailboxListScrollControllerListener);
    super.onReady();
  }

  @override
  void onClose() {
    _openMailboxEventController.close();
    mailboxListScrollController.dispose();
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess) {
      _handleGetAllMailboxSuccess(success);
    } else if (success is RefreshChangesAllMailboxSuccess) {
      _handleRefreshChangesAllMailboxSuccess(success);
    } else if (success is CreateNewMailboxSuccess) {
      _createNewMailboxSuccess(success);
    } else if (success is DeleteMultipleMailboxAllSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
      _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
    } else if (success is RenameMailboxSuccess) {
      _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
    } else if (success is MoveMailboxSuccess) {
      _moveMailboxSuccess(success);
    } else if (success is SubscribeMailboxSuccess) {
      _handleUnsubscribeMailboxSuccess(success);
    } else if (success is SubscribeMultipleMailboxAllSuccess) {
      _handleUnsubscribeMultipleMailboxAllSuccess(success);
    } else if (success is SubscribeMultipleMailboxHasSomeSuccess) {
      _handleUnsubscribeMultipleMailboxHasSomeSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is CreateNewMailboxFailure) {
      _createNewMailboxFailure(failure);
    } else if (failure is DeleteMultipleMailboxFailure) {
      _deleteMailboxFailure(failure);
    }
  }

  @override
  void onDone() {
    super.onDone();
    viewState.value.fold((failure) => null, (success) {
      if (success is GetAllMailboxSuccess) {
        _initialMailboxVariableStorage();
        mailboxDashBoardController.getSpamReportBanner();
      } else if (success is RefreshChangesAllMailboxSuccess) {
        _initialMailboxVariableStorage(isRefreshChange: true);
        mailboxDashBoardController.refreshSpamReportBanner();
      }
    });
  }

  void handleScrollEnable() {
    isMailboxListScrollable.value = mailboxListScrollController.hasClients && mailboxListScrollController.position.maxScrollExtent > 0;
  }

  void _registerObxStreamListener() {
    ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId != null && mailboxDashBoardController.sessionCurrent != null) {
        getAllMailbox(mailboxDashBoardController.sessionCurrent!, accountId);
      }
    });

    ever<Map<String, String?>?>(
      mailboxDashBoardController.routerParameters,
      _handleNavigationRouteParameters
    );

    ever(mailboxDashBoardController.viewState, (state) {
      state.fold((failure) => null, (success) {
        if (success is MarkAsMultipleEmailReadAllSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is EmptyTrashFolderSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MarkAsEmailReadSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MoveToMailboxSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is DeleteEmailPermanentlySuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is SaveEmailAsDraftsSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is RemoveEmailDraftsSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is SendEmailSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MarkAsMailboxReadAllSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        } else if (success is UpdateEmailDraftsSuccess) {
          _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
        }
      });
    });

    ever(mailboxDashBoardController.dashBoardAction, (action) {
      if (action is ClearSearchEmailAction) {
        _switchBackToMailboxDefault();
      }
    });

    ever(mailboxDashBoardController.mailboxUIAction, (action) {
      if (action is SelectMailboxDefaultAction) {
        if (mailboxDashBoardController.selectedMailbox.value == null) {
          _switchBackToMailboxDefault();
        }
        mailboxDashBoardController.clearMailboxUIAction();
      } else if (action is RefreshChangeMailboxAction) {
        if (action.newState != currentMailboxState) {
          _refreshMailboxChanges();
        }
        mailboxDashBoardController.clearMailboxUIAction();
      } else if (action is OpenMailboxAction) {
        if (currentContext != null) {
          openMailbox(currentContext!, action.presentationMailbox);
        }
        mailboxDashBoardController.clearMailboxUIAction();
      }
    });
  }

  void _initCollapseMailboxCategories() {
    if (kIsWeb && currentContext != null
        && (_responsiveUtils.isMobile(currentContext!) || _responsiveUtils.isTablet(currentContext!))) {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode(
          defaultMailbox: ExpandMode.COLLAPSE,
          personalMailboxes: ExpandMode.COLLAPSE,
          teamMailboxes: ExpandMode.COLLAPSE);
    } else {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode.initial();
    }
  }

  void refreshAllMailbox() {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      consumeState(getAllMailboxInteractor!.execute(session, accountId));
    }
  }
  
  void _refreshMailboxChanges({jmap.State? currentMailboxState}) {
    log('MailboxController::_refreshMailboxChanges(): currentMailboxState: $currentMailboxState');
    final newMailboxState = currentMailboxState ?? this.currentMailboxState;
    log('MailboxController::_refreshMailboxChanges(): newMailboxState: $newMailboxState');
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null && newMailboxState != null) {
      refreshMailboxChanges(session, accountId, newMailboxState);
    }
  }

  void _initialMailboxVariableStorage({bool isRefreshChange = false}) {
    _setMapMailbox();
    _setOutboxMailbox();

    if (isRefreshChange) {
      _selectSelectedMailboxDefault();
    } else {
      _handleDataFromNavigationRouter();
    }
  }

  void _setMapMailbox() {
    final mapDefaultMailboxIdByRole = {
      for (var mailboxNode in defaultMailboxTree.value.root.childrenItems ?? List<MailboxNode>.empty())
        mailboxNode.item.role!: mailboxNode.item.id
    };

    final mapMailboxById = {
      for (var presentationMailbox in allMailboxes)
        presentationMailbox.id: presentationMailbox
    };

    mailboxDashBoardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
    mailboxDashBoardController.setMapMailboxById(mapMailboxById);
  }

  void _setOutboxMailbox() {
    try {
      final outboxMailboxIdByRole = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleOutbox];
      if (outboxMailboxIdByRole == null) {
        final outboxMailboxByName = allMailboxes
            .firstWhere((mailbox) => mailbox.name?.toLowerCase() == PresentationMailbox.lowerCaseOutboxMailboxName);
        mailboxDashBoardController.setOutboxMailbox(outboxMailboxByName);
      } else {
        mailboxDashBoardController.setOutboxMailbox(mailboxDashBoardController.mapMailboxById[outboxMailboxIdByRole]!);
      }
    } catch (e) {
      logError('MailboxController::_setOutboxMailbox: Not found outbox mailbox');
      mailboxDashBoardController.setOutboxMailbox(null);
    }
  }

  void _selectSelectedMailboxDefault() {
    final isSearchEmailRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
    if (isSearchEmailRunning) {
      log('MailboxController::_selectMailboxDefault(): isSearchEmailRunning is $isSearchEmailRunning');
      return;
    }
    final mailboxSelected = _getCurrentSelectedMailbox();
    mailboxDashBoardController.setSelectedMailbox(mailboxSelected);
  }

  PresentationMailbox? _getCurrentSelectedMailbox() {
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    final mapMailboxById = mailboxDashBoardController.mapMailboxById;
    final isSearchEmailRunning = mailboxDashBoardController.searchController.isSearchEmailRunning;
    final mapDefaultPresentationMailboxByRole = defaultMailboxTree.value.mapPresentationMailboxByRole;

    if (mailboxCurrent != null) {
      if (mailboxCurrent.hasRole()) {
        return mapDefaultPresentationMailboxByRole.containsKey(mailboxCurrent.role)
          ? mapDefaultPresentationMailboxByRole[mailboxCurrent.role]
          : mailboxCurrent;
      } else {
        return mapMailboxById.containsKey(mailboxCurrent.id)
          ? mapMailboxById[mailboxCurrent.id]
          : mailboxCurrent;
      }
    } else if (!isSearchEmailRunning) {
      if (mapDefaultPresentationMailboxByRole.containsKey(PresentationMailbox.roleInbox)) {
        return mapDefaultPresentationMailboxByRole[PresentationMailbox.roleInbox];
      } else if (allMailboxes.isNotEmpty) {
        return allMailboxes.first;
      }
    }

    return null;
  }

  void _handleDataFromNavigationRouter() {
    log('MailboxController::_handleDataFromNavigationRouter():navigationRouter: $navigationRouter');

    if (isHasDataFromRoute) {
      if (mailboxIdFromNavigationRouter != null) {
        _selectMailboxFromRouter();
      } else if (emailIdFromNavigationRouter != null) {
        mailboxDashBoardController.dispatchAction(SelectEmailByIdAction(navigationRouter!));
        _clearNavigationRouter();
      } else if (searchQueryFromNavigationRouter != null && searchQueryFromNavigationRouter?.value.isNotEmpty == true) {
        mailboxDashBoardController.dispatchAction(SearchEmailByQueryAction(navigationRouter!));
        _clearNavigationRouter();
      } else {
        _clearNavigationRouter();
        _selectSelectedMailboxDefault();
        _updateSelectedMailboxRouteOnBrowser();
      }
    } else {
      _selectSelectedMailboxDefault();
      _updateSelectedMailboxRouteOnBrowser();
    }
  }

  NavigationRouter? get navigationRouter => mailboxDashBoardController.navigationRouter;

  bool get isHasDataFromRoute => PlatformInfo.isWeb && navigationRouter != null;

  MailboxId? get mailboxIdFromNavigationRouter => navigationRouter?.mailboxId;

  EmailId? get emailIdFromNavigationRouter => navigationRouter?.emailId;

  SearchQuery? get searchQueryFromNavigationRouter => navigationRouter?.searchQuery;

  void _clearNavigationRouter() {
    mailboxDashBoardController.navigationRouter = null;
  }

  void _selectMailboxFromRouter() {
    final matchedMailboxNode = findMailboxNodeById(mailboxIdFromNavigationRouter!);
    if (matchedMailboxNode != null) {
      mailboxDashBoardController.setSelectedMailbox(matchedMailboxNode.item);
      if (emailIdFromNavigationRouter != null) {
        mailboxDashBoardController.dispatchAction(SelectEmailByIdAction(navigationRouter!));
      } else {
        _updateSelectedMailboxRouteOnBrowser();
      }
      _clearNavigationRouter();
    } else {
      _clearNavigationRouter();
      pushAndPop(AppRoutes.unknownRoutePage);
    }
  }

  void _handleOpenMailbox(
    BuildContext context,
    PresentationMailbox presentationMailboxSelected
  ) {
    log('MailboxController::_handleOpenMailbox():MailboxName: ${presentationMailboxSelected.name}');
    KeyboardUtils.hideKeyboard(context);
    mailboxDashBoardController.setSelectedMailbox(presentationMailboxSelected);
    mailboxDashBoardController.clearSelectedEmail();
    if (presentationMailboxSelected.id != mailboxDashBoardController.selectedMailbox.value?.id) {
      mailboxDashBoardController.clearFilterMessageOption();
    }
    _disableAllSearchEmail();
    _updateSelectedMailboxRouteOnBrowser();
    mailboxDashBoardController.closeMailboxMenuDrawer();
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
  }

  void _disableAllSearchEmail() {
    mailboxDashBoardController.dispatchAction(ClearAllFieldOfAdvancedSearchAction());
    mailboxDashBoardController.searchController.disableAllSearchEmail();
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    _openMailboxEventController.add(OpenMailboxViewEvent(context, presentationMailboxSelected));
  }

  void goToCreateNewMailboxView(BuildContext context) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (session !=null && accountId != null) {
      final arguments = MailboxCreatorArguments(
        accountId,
        defaultMailboxTree.value,
        personalMailboxTree.value,
        teamMailboxesTree.value,
        mailboxDashBoardController.sessionCurrent!);

      final result = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.mailboxCreator, arguments: arguments)
        : await push(AppRoutes.mailboxCreator, arguments: arguments);

      if (result != null && result is NewMailboxArguments) {
        final generateCreateId = Id(_uuid.v1());
        _createNewMailboxAction(session, accountId, CreateNewMailboxRequest(
          generateCreateId,
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
      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).new_mailbox_is_created(success.newMailbox.name?.name ?? ''),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: _imagePaths.icFolderMailbox);
    }

    _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      }
      _appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void openSearchViewAction(BuildContext context) {
    if (PlatformInfo.isWeb) {
      SearchMailboxBindings().dependencies();
      mailboxDashBoardController.searchMailboxActivated.value = true;
    } else {
      push(AppRoutes.searchMailbox);
    }
    closeMailboxScreen(context);
  }

  void enableSelectionMailbox() {
    currentSelectMode.value = SelectMode.ACTIVE;
  }

  void disableSelectionMailbox() {
    _cancelSelectMailbox();
  }

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  List<MailboxActions> get listActionOfMailboxSelected {
    final currentMailboxesSelected = listMailboxSelected;

    if (currentMailboxesSelected.length == 1) {
      if (currentMailboxesSelected.isAllDefaultMailboxes && currentMailboxesSelected.isAllUnreadMailboxes) {
        return [MailboxActions.markAsRead];
      } else if (currentMailboxesSelected.isAllPersonalMailboxes) {
        return [
          MailboxActions.move,
          MailboxActions.rename,
          if (currentMailboxesSelected.isAllUnreadMailboxes)
            MailboxActions.markAsRead,
          MailboxActions.delete
        ];
      } else {
        return [];
      }
    } else if (currentMailboxesSelected.length > 1
      && currentMailboxesSelected.isAllPersonalMailboxes) {
      return [MailboxActions.delete];
    } else {
      return [];
    }
  }

  void _cancelSelectMailbox() {
    unAllSelectedMailboxNode();
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  List<PresentationMailbox> get listMailboxSelected {
    final defaultMailboxSelected = defaultMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    final folderMailboxSelected = personalMailboxTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    final teamMailboxesSelected = teamMailboxesTree.value
      .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

    return [defaultMailboxSelected, folderMailboxSelected, teamMailboxesSelected]
      .expand((node) => node)
      .map((node) => node.item)
      .toList();
  }

  void pressMailboxSelectionAction(
      BuildContext context,
      MailboxActions actions,
      List<PresentationMailbox> selectedMailboxList
  ) {
    switch(actions) {
      case MailboxActions.delete:
        _openConfirmationDialogDeleteMultipleMailboxAction(context, selectedMailboxList);
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          selectedMailboxList.first,
          _responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction
        );
        break;
      case MailboxActions.markAsRead:
        markAsReadMailboxAction(
          context,
          selectedMailboxList.first,
          mailboxDashBoardController,
          onCallbackAction: closeMailboxScreen
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          selectedMailboxList.first,
          mailboxDashBoardController,
          onMovingMailboxAction: _invokeMovingMailboxAction
        );
        break;
      default:
        break;
    }
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          [presentationMailbox],
          defaultMailboxTree.value,
          personalMailboxTree.value);
      final mapDescendantIds = tupleMap.value1;
      final listMailboxId = tupleMap.value2;

      consumeState(_deleteMultipleMailboxInteractor.execute(
          session,
          accountId,
          mapDescendantIds,
          listMailboxId));
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    _cancelSelectMailbox();
    popBack();
  }

  void _deleteMultipleMailboxSuccess(
      List<MailboxId> listMailboxIdDeleted,
      jmap.State? currentMailboxState
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).delete_mailboxes_successfully);
    }

    if (listMailboxIdDeleted.contains(selectedMailbox?.id)) {
      _switchBackToMailboxDefault();
      _closeEmailViewIfMailboxDisabledOrNotExist(listMailboxIdDeleted);
    }
    _refreshMailboxChanges(currentMailboxState: currentMailboxState);
  }

  void _openConfirmationDialogDeleteMultipleMailboxAction(
      BuildContext context,
      List<PresentationMailbox> selectedMailboxList
  ) {
    if (_responsiveUtils.isLandscapeMobile(context) ||
        _responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context)
            .messageConfirmationDialogDeleteMultipleMailbox(selectedMailboxList.length))
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () =>
            _deleteMultipleMailboxAction(selectedMailboxList)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
            ..key(const Key('confirm_dialog_delete_multiple_mailbox'))
            ..title(AppLocalizations.of(context).delete_mailboxes)
            ..content(AppLocalizations.of(context)
                .messageConfirmationDialogDeleteMultipleMailbox(selectedMailboxList.length))
            ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog,
                fit: BoxFit.fill))
            ..colorConfirmButton(AppColor.colorConfirmActionDialog)
            ..styleTextConfirmButton(const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColor.colorActionDeleteConfirmDialog))
            ..onCloseButtonAction(() => popBack())
            ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
                _deleteMultipleMailboxAction(selectedMailboxList))
            ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                popBack()))
            .build()));
    }
  }

  void _deleteMultipleMailboxAction(List<PresentationMailbox> selectedMailboxList) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          selectedMailboxList,
          defaultMailboxTree.value,
          personalMailboxTree.value);
      final mapDescendantIds = tupleMap.value1;
      final listMailboxId = tupleMap.value2;
      consumeState(_deleteMultipleMailboxInteractor.execute(
          session,
          accountId,
          mapDescendantIds,
          listMailboxId));
    } else {
      _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
    }

    _cancelSelectMailbox();
    popBack();
  }

  void _switchBackToMailboxDefault() {
    final inboxMailbox = findMailboxNodeByRole(PresentationMailbox.roleInbox);
    mailboxDashBoardController.setSelectedMailbox(inboxMailbox?.item);
    _updateSelectedMailboxRouteOnBrowser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mailboxListScrollController.hasClients){
        mailboxListScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
      }
    });
  }

  void _deleteMailboxFailure(DeleteMultipleMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).delete_mailboxes_failure,
        leadingSVGIcon: _imagePaths.icDeleteToast
      );
    }
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, MailboxName newMailboxName) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && accountId != null) {
      consumeState(_renameMailboxInteractor.execute(
        session,
        accountId,
        RenameMailboxRequest(presentationMailbox.id, newMailboxName))
      );
    }

    _cancelSelectMailbox();
  }

  void _handleMovingMailbox(
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
        destinationMailboxName: destinationMailbox?.name,
        parentId: mailboxSelected.parentId)));
  }

  void _moveMailboxSuccess(MoveMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving
        && currentOverlayContext != null
        && currentContext != null) {
      _appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).moved_to_mailbox(
              success.destinationMailboxName?.name ?? AppLocalizations.of(currentContext!).allMailboxes),
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            _undoMovingMailbox(MoveMailboxRequest(
                success.mailboxIdSelected,
                MoveAction.undo,
                destinationMailboxId: success.parentId,
                parentId: success.destinationMailboxId));
          },
          leadingSVGIcon: _imagePaths.icFolderMailbox,
          leadingSVGIconColor: Colors.white,
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo));
    }

    _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      consumeState(_moveMailboxInteractor.execute(session, accountId, newMoveRequest));
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) async {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.personalMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.personalMailboxes == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.personalMailboxes = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        if (personalMailboxTree.value.root.hasChildren()) {
          _triggerToggleMailboxCategories();
        }
        break;
      case MailboxCategories.teamMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.teamMailboxes = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        if (personalMailboxTree.value.root.hasChildren() && mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.COLLAPSE) {
          _triggerToggleMailboxCategories();
        }
        break;
      case MailboxCategories.appGrid:
        final currentExpandMode = mailboxDashBoardController.appGridDashboardController.appDashboardExpandMode.value;
        if (currentExpandMode == ExpandMode.COLLAPSE) {
          _showAppDashboardAction();
        } else {
          mailboxDashBoardController.appGridDashboardController.toggleAppGridDashboard();
        }
        break;
    }
  }

  void _triggerToggleMailboxCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    mailboxListScrollController.animateTo(
      mailboxListScrollController.offset + 100,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInToLinear);
  }

  void _handleNavigationRouteParameters(Map<String, String?>? parameters) {
    log('MailboxController::_handleNavigationRouteParameters(): parameters: $parameters');
    if (parameters != null) {
      final navigationRouter = RouteUtils.parsingRouteParametersToNavigationRouter(parameters);
      log('MailboxController::_handleNavigationRouteParameters():navigationRouter: $navigationRouter');
      mailboxDashBoardController.navigationRouter = navigationRouter;
    }
  }

  void _showAppDashboardAction() {
    mailboxDashBoardController.showAppDashboardAction();
  }

  void handleMailboxAction(
      BuildContext context,
      MailboxActions actions,
      PresentationMailbox mailbox
  ) {
    popBack();

    switch(actions) {
      case MailboxActions.delete:
        openConfirmationDialogDeleteMailboxAction(
          context,
          _responsiveUtils,
          _imagePaths,
          mailbox,
          onDeleteMailboxAction: _deleteMailboxAction
        );
        break;
      case MailboxActions.rename:
        openDialogRenameMailboxAction(
          context,
          mailbox,
          _responsiveUtils,
          onRenameMailboxAction: _renameMailboxAction
        );
        break;
      case MailboxActions.move:
        moveMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onMovingMailboxAction: _invokeMovingMailboxAction
        );
        break;
      case MailboxActions.markAsRead:
        markAsReadMailboxAction(
          context,
          mailbox,
          mailboxDashBoardController,
          onCallbackAction: closeMailboxScreen
        );
        break;
      case MailboxActions.openInNewTab:
        openMailboxInNewTabAction(mailbox);
        break;
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        mailboxDashBoardController.storeSpamReportStateAction();
        break;
      case MailboxActions.disableMailbox:
        _unsubscribeMailboxAction(mailbox.id);
        break;
      case MailboxActions.emptyTrash:
        emptyTrashAction(context, mailbox, mailboxDashBoardController);
        break;
      default:
        break;
    }
  }

  void _invokeMovingMailboxAction(PresentationMailbox mailboxSelected, PresentationMailbox? destinationMailbox) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (session != null && accountId != null) {
      _handleMovingMailbox(
        session,
        accountId,
        MoveAction.moving,
        mailboxSelected,
        destinationMailbox: destinationMailbox
      );
      _cancelSelectMailbox();
    }
  }

  void _updateSelectedMailboxRouteOnBrowser() {
    if (PlatformInfo.isWeb) {
      final selectedMailboxId = selectedMailbox?.id;
      final route = RouteUtils.generateRouteBrowser(
        AppRoutes.dashboard,
        NavigationRouter(
          mailboxId: selectedMailboxId,
          searchQuery: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? mailboxDashBoardController.searchController.searchQuery
            : null,
          dashboardType: mailboxDashBoardController.searchController.isSearchEmailRunning
            ? DashboardType.search
            : DashboardType.normal
        )
      );
      RouteUtils.updateRouteOnBrowser('Mailbox-${selectedMailboxId?.id.value}', route);
    }
  }

  void closeMailboxScreen(BuildContext context) {
    _cancelSelectMailbox();
    mailboxDashBoardController.closeMailboxMenuDrawer();
  }

  void autoScrollTop() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.minScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear);
  }

  void autoScrollBottom() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInToLinear);
  }

  void stopAutoScroll() {
    mailboxListScrollController.animateTo(
      mailboxListScrollController.offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn);
  }

  void _handleGetAllMailboxSuccess(GetAllMailboxSuccess success) async {
    currentMailboxState = success.currentMailboxState;
    final listMailboxDisplayed = success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes;
    await buildTree(listMailboxDisplayed);
    if (currentContext != null) {
      await syncAllMailboxWithDisplayName(currentContext!);
    }
  }

  void _handleRefreshChangesAllMailboxSuccess(RefreshChangesAllMailboxSuccess success) async {
    currentMailboxState = success.currentMailboxState;
    final listMailboxDisplayed = success.mailboxList.listSubscribedMailboxesAndDefaultMailboxes;
    await refreshTree(listMailboxDisplayed);
    if (currentContext != null) {
      await syncAllMailboxWithDisplayName(currentContext!);
    }
  }

  void _unsubscribeMailboxAction(MailboxId mailboxId) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (session != null && accountId != null) {
      final subscribeRequest = generateSubscribeRequest(
        mailboxId,
        MailboxSubscribeState.disabled,
        MailboxSubscribeAction.unSubscribe
      );

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor.execute(session, accountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor.execute(session, accountId, subscribeRequest));
      }
    }
  }

  void _handleUnsubscribeMailboxSuccess(SubscribeMailboxSuccess success) {
    if (success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(success.mailboxId);

      if (success.mailboxId == selectedMailbox?.id) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist([success.mailboxId]);
      }
    }

    _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _handleUnsubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess success) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }

    _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _handleUnsubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess success) {
    if(success.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        success.parentMailboxId,
        listDescendantMailboxIds: success.mailboxIdsSubscribe
      );

      if (success.mailboxIdsSubscribe.contains(selectedMailbox?.id)) {
        _switchBackToMailboxDefault();
        _closeEmailViewIfMailboxDisabledOrNotExist(success.mailboxIdsSubscribe);
      }
    }

    _refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _closeEmailViewIfMailboxDisabledOrNotExist(List<MailboxId> mailboxIdsDisabled) {
    if (selectedEmail == null) {
      return;
    }

    final mailboxContain = selectedEmail!.findMailboxContain(mailboxDashBoardController.mapMailboxById);
    if (mailboxContain != null && mailboxIdsDisabled.contains(mailboxContain.id)) {
      mailboxDashBoardController.clearSelectedEmail();
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
  }

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideMailboxSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _undoUnsubscribeMailboxAction(
          mailboxIdSubscribed,
          listDescendantMailboxIds: listDescendantMailboxIds
        ),
        leadingSVGIcon: _imagePaths.icFolderMailbox,
        leadingSVGIconColor: Colors.white,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(_imagePaths.icUndo));
    }
  }

  void _undoUnsubscribeMailboxAction(
    MailboxId mailboxIdSubscribed,
    {List<MailboxId>? listDescendantMailboxIds}
  ) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

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

  void _mailboxListScrollControllerListener() {
    _handleScrollTop();
    _handleScrollBottom();
  }

  void _handleScrollTop() {
    if (mailboxListScrollController.position.pixels == 0) {
      _activeScrollTop.value = false;
    }

    if (mailboxListScrollController.position.pixels > 40) {
      _activeScrollTop.value = true;
    }
  }

  void _handleScrollBottom() {
    if (mailboxListScrollController.position.pixels - mailboxListScrollController.position.maxScrollExtent == 0) {
      _activeScrollBottom.value = false;
    }

    if (mailboxListScrollController.position.maxScrollExtent - mailboxListScrollController.position.pixels > 40) {
      _activeScrollBottom.value = true;
    }
  }

  bool get activeScrollTop => _activeScrollTop.value;

  bool get activeScrollBottom => _activeScrollBottom.value;

  void openSendingQueueViewAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    _disableAllSearchEmail();
    mailboxDashBoardController.clearSelectedEmail();
    mailboxDashBoardController.clearFilterMessageOption();
    mailboxDashBoardController.setSelectedMailbox(null);
    closeMailboxScreen(context);
    mailboxDashBoardController.dispatchRoute(DashboardRoutes.sendingQueue);
  }
}