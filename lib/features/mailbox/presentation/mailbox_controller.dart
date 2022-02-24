import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmapState;
import 'package:uuid/uuid.dart';

class MailboxController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final RefreshAllMailboxInteractor _refreshAllMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;
  final TreeBuilder _treeBuilder;
  final Uuid _uuid;
  final AppToast _appToast;
  final ImagePaths _imagePaths;
  final ResponsiveUtils responsiveUtils;
  final CachingManager _cachingManager;

  final defaultMailboxList = <PresentationMailbox>[].obs;
  final folderMailboxNodeList = <MailboxNode>[].obs;
  final listMailboxSearched = <PresentationMailbox>[].obs;
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;

  MailboxTree folderMailboxTree = MailboxTree(MailboxNode.root());
  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];
  TextEditingController searchInputController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  jmapState.State? currentMailboxState;

  MailboxController(
    this._getAllMailboxInteractor,
    this._deleteCredentialInteractor,
    this._refreshAllMailboxInteractor,
    this._createNewMailboxInteractor,
    this._searchMailboxInteractor,
    this._treeBuilder,
    this._uuid,
    this._appToast,
    this._imagePaths,
    this.responsiveUtils,
    this._cachingManager,
  );

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.accountId.listen((accountId) {
      if (accountId != null) {
        getAllMailboxAction(accountId);
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        if (success is MarkAsEmailReadSuccess ||
            success is MarkAsMultipleEmailReadAllSuccess ||
            success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          refreshMailboxChanges();
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          mailboxDashBoardController.clearState();
          refreshMailboxChanges();
        } else if (success is SaveEmailAsDraftsSuccess
          || success is RemoveEmailDraftsSuccess
          || success is SendEmailSuccess
          || success is UpdateEmailDraftsSuccess) {
          refreshMailboxChanges();
        }
      });
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.accountId.close();
    searchInputController.dispose();
    searchFocus.dispose();
    super.onClose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) {
      if (success is GetAllMailboxSuccess) {
        allMailboxes = success.defaultMailboxList + success.folderMailboxList;
        currentMailboxState = success.currentMailboxState;
        defaultMailboxList.value = success.defaultMailboxList;
        _setUpMapMailboxIdDefault(success.defaultMailboxList, success.folderMailboxList);
        _buildTree(success.folderMailboxList);
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
        (failure) {
          if (failure is CreateNewMailboxFailure) {
            _createNewMailboxFailure(failure);
          } else if (failure is SearchMailboxFailure) {
            _searchMailboxFailure(failure);
          }
        },
        (success) {
          if (success is CreateNewMailboxSuccess) {
            _createNewMailboxSuccess(success);
          } else if (success is SearchMailboxSuccess) {
            _searchMailboxSuccess(success);
          }
        }
    );
  }

  @override
  void onError(error) {}

  void getAllMailboxAction(AccountId accountId) async {
    consumeState(_getAllMailboxInteractor.execute(accountId));
  }

  void refreshAllMailbox() {
    if (!isSearchActive()) {
      final accountId = mailboxDashBoardController.accountId.value;
      if (accountId != null) {
        consumeState(_getAllMailboxInteractor.execute(accountId));
      }
    } else {
      _searchMailboxAction(allMailboxes, searchQuery.value);
    }
  }

  void refreshMailboxChanges() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && currentMailboxState != null) {
      consumeState(_refreshAllMailboxInteractor.execute(accountId, currentMailboxState!));
    }
  }

  void _buildTree(List<PresentationMailbox> folderMailboxList) async {
    folderMailboxTree = await _treeBuilder.generateMailboxTree(folderMailboxList);
    folderMailboxNodeList.value = folderMailboxTree.root.childrenItems ?? [];
  }

  void toggleMailboxFolder(MailboxNode mailboxNode) {
    final newExpandMode = mailboxNode.expandMode == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;

    final newMailboxNodeList = folderMailboxNodeList.updateNode(
        mailboxNode.item.id,
        mailboxNode.copyWith(newExpandMode: newExpandMode));
    folderMailboxNodeList.value = newMailboxNodeList;
  }

  void _setUpMapMailboxIdDefault(List<PresentationMailbox> defaultMailboxList, List<PresentationMailbox> folderMailboxList) {
    final allMailbox = defaultMailboxList + folderMailboxList;

    final mapDefaultMailboxId = Map<Role, MailboxId>.fromIterable(
      defaultMailboxList,
      key: (presentationMailbox) => presentationMailbox.role!,
      value: (presentationMailbox) => presentationMailbox.id);

    final mapDefaultMailbox = Map<Role, PresentationMailbox>.fromIterable(
      defaultMailboxList,
      key: (presentationMailbox) => presentationMailbox.role!,
      value: (presentationMailbox) => presentationMailbox);

    final mapMailbox = Map<MailboxId, PresentationMailbox>.fromIterable(
      allMailbox,
      key: (presentationMailbox) => presentationMailbox.id,
      value: (presentationMailbox) => presentationMailbox);

    mailboxDashBoardController.setMapDefaultMailboxId(mapDefaultMailboxId);

    mailboxDashBoardController.setMapMailbox(mapMailbox);

    var mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;

    if (mailboxCurrent != null) {
      if (mailboxCurrent.hasRole()) {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapDefaultMailbox.containsKey(mailboxCurrent.role)
          ? mapDefaultMailbox[mailboxCurrent.role]
          : mailboxCurrent);
      } else {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapMailbox.containsKey(mailboxCurrent.id)
          ? mapMailbox[mailboxCurrent.id]
          : mailboxCurrent);
      }
    } else {
      if (mapDefaultMailbox.containsKey(PresentationMailbox.roleInbox)) {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapDefaultMailbox[PresentationMailbox.roleInbox]);
      } else {
        if (allMailbox.isNotEmpty) {
          mailboxDashBoardController.setNewFirstSelectedMailbox(allMailbox.first);
        }
      }
    }
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    FocusScope.of(context).unfocus();

    mailboxDashBoardController.setSelectedMailbox(presentationMailboxSelected);
    mailboxDashBoardController.clearSelectedEmail();

    if (!responsiveUtils.isDesktop(context)) {
      mailboxDashBoardController.closeDrawer();
    }
  }

  void _deleteCredential() async {
    await _deleteCredentialInteractor.execute();
  }

  void _clearAllCache() async {
    await _cachingManager.clearAll();
  }

  void goToCreateNewMailboxView() async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      final newMailboxArguments = await push(
          AppRoutes.MAILBOX_CREATOR,
          arguments: MailboxCreatorArguments(accountId, allMailboxes)
      );

      if (newMailboxArguments != null && newMailboxArguments is NewMailboxArguments) {
        final generateCreateId = Id(_uuid.v1());
        _createNewMailboxAction(accountId, CreateNewMailboxRequest(
            generateCreateId,
            newMailboxArguments.newName,
            parentId: newMailboxArguments.mailboxLocation?.id));
      }
    }
  }

  void _createNewMailboxAction(AccountId accountId, CreateNewMailboxRequest request) async {
    consumeState(_createNewMailboxInteractor.execute(accountId, request));
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (Get.overlayContext != null && Get.context != null) {
      _appToast.showToastWithIcon(
          Get.overlayContext!,
          textColor: AppColor.toastSuccessBackgroundColor,
          message: AppLocalizations.of(Get.context!).new_mailbox_is_created(success.newMailbox.name?.name ?? ''),
          icon: _imagePaths.icFolderMailbox);
    }

    refreshMailboxChanges();
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (Get.overlayContext != null && Get.context != null) {
      _appToast.showToastWithIcon(
          Get.overlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(Get.context!).create_new_mailbox_failure,
          icon: _imagePaths.icFolderMailbox);
    }
  }

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() => searchState.value = searchState.value.enableSearchState();

  void disableSearch(BuildContext context) {
    listMailboxSearched.clear();
    searchState.value = searchState.value.disableSearchState();
    searchQuery.value = SearchQuery.initial();
    searchInputController.clear();
    FocusScope.of(context).unfocus();
  }

  void clearSearchText() {
    searchQuery.value = SearchQuery.initial();
    searchFocus.requestFocus();
    listMailboxSearched.clear();
  }

  void searchMailbox(String value) {
    searchQuery.value = SearchQuery(value);
    _searchMailboxAction(allMailboxes, searchQuery.value);
  }

  void _searchMailboxAction(List<PresentationMailbox> allMailboxes, SearchQuery searchQuery) {
    if (searchQuery.value.isNotEmpty) {
      consumeState(_searchMailboxInteractor.execute(allMailboxes, searchQuery));
    } else {
      listMailboxSearched.clear();
    }
  }

  void _searchMailboxSuccess(SearchMailboxSuccess success) {
    final mailboxesSearchedWithPath = _findMailboxPath(success.mailboxesSearched);
    listMailboxSearched.value = mailboxesSearchedWithPath;
  }

  List<PresentationMailbox> _findMailboxPath(List<PresentationMailbox> mailboxes) {
    return mailboxes.map((presentationMailbox) {
      if (!presentationMailbox.hasParentId()) {
        return presentationMailbox;
      } else {
        final mailboxNode = folderMailboxTree.findNode(presentationMailbox.id);
        if (mailboxNode != null) {
          String mailboxPath = mailboxNode.getPathMailboxNode(folderMailboxTree, defaultMailboxList);
          if (mailboxPath.contains('/')) {
            mailboxPath = mailboxPath.substring(0, mailboxPath.lastIndexOf('/')).replaceAll('/', ' / ');
          }
          return presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxPath);
        } else {
          return presentationMailbox;
        }
      }
    }).toList();
  }

  void _searchMailboxFailure(SearchMailboxFailure failure) {
    listMailboxSearched.clear();
  }

  void enableSelectionMailbox() {
    currentSelectMode.value = SelectMode.ACTIVE;
  }

  void disableSelectionMailbox() {
    _cancelSelectMailbox();
  }

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void selectMailbox(BuildContext context, PresentationMailbox mailboxSelected) {
    if (isSearchActive()) {
      listMailboxSearched.value = listMailboxSearched
          .map((mailbox) => mailbox.id == mailboxSelected.id
              ? mailbox.toggleSelectPresentationMailbox()
              : mailbox)
          .toList();
    } else {
      defaultMailboxList.value = defaultMailboxList
          .map((mailbox) => mailbox.id == mailboxSelected.id
              ? mailbox.toggleSelectPresentationMailbox()
              : mailbox)
          .toList();
    }
  }

  void selectMailboxNode(BuildContext context, MailboxNode mailboxNodeSelected) {
    final newMailboxNodeList = folderMailboxNodeList.toggleSelectMailboxNode(mailboxNodeSelected);
    folderMailboxNodeList.value = newMailboxNodeList;
  }

  void _cancelSelectMailbox() {
    if (isSearchActive()) {
      listMailboxSearched.value = listMailboxSearched
          .map((mailbox) => mailbox.toSelectedPresentationMailbox(selectMode: SelectMode.INACTIVE))
          .toList();
    } else {
      defaultMailboxList.value = defaultMailboxList
          .map((mailbox) => mailbox.toSelectedPresentationMailbox(selectMode: SelectMode.INACTIVE))
          .toList();

      final newMailboxNodeList = folderMailboxNodeList.toSelectMailboxNode(
          selectMode: SelectMode.INACTIVE,
          newExpandMode: ExpandMode.COLLAPSE);
      folderMailboxNodeList.value = newMailboxNodeList;
    }
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  List<PresentationMailbox> get listMailboxSelected {
    if (isSearchActive()) {
      return listMailboxSearched
          .where((mailbox) => mailbox.selectMode == SelectMode.ACTIVE)
          .toList();
    } else {
      final defaultMailboxSelected = defaultMailboxList
          .where((mailbox) => mailbox.selectMode == SelectMode.ACTIVE)
          .toList();

      final newFolderMailboxTree = MailboxTree(MailboxNode(
          MailboxNode.rootItem(),
          childrenItems: folderMailboxNodeList));
      final folderMailboxList = allMailboxes.where((mailbox) => !mailbox.hasRole()).toList();

      final folderMailboxSelected = folderMailboxList
          .where((mailbox) {
            final node = newFolderMailboxTree.findNode(mailbox.id);
            return node != null && node.selectMode == SelectMode.ACTIVE;
          })
          .toList();

      return defaultMailboxSelected + folderMailboxSelected;
    }
  }

  void pressMailboxSelectionAction(BuildContext context, MailboxActions actions,
      List<PresentationMailbox> selectionMailbox) {
    switch(actions) {
      case MailboxActions.delete:
        break;
      default:
        break;
    }
  }

  void closeMailboxScreen(BuildContext context) {
    mailboxDashBoardController.closeDrawer();
  }

  void logoutAction() {
    _deleteCredential();
    _clearAllCache();
    pushAndPopAll(AppRoutes.LOGIN);
  }
}