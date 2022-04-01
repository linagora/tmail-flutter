import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmapState;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_trash_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/open_mailbox_view_event.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/special_character_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_trash_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/search_status.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class MailboxController extends BaseMailboxController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final RefreshAllMailboxInteractor _refreshAllMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final Uuid _uuid;

  final listMailboxSearched = <PresentationMailbox>[].obs;
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;

  final _openMailboxEventController = StreamController<OpenMailboxViewEvent>();
  final searchInputController = TextEditingController();
  final searchFocus = FocusNode();
  final mailboxListScrollController = ScrollController();

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];
  jmapState.State? currentMailboxState;
  List<String> listMailboxNameAsStringExist = <String>[];

  MailboxController(
    this._getAllMailboxInteractor,
    this._refreshAllMailboxInteractor,
    this._createNewMailboxInteractor,
    this._searchMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._verifyNameInteractor,
    this._renameMailboxInteractor,
    this._uuid,
    treeBuilder,
  ) : super(treeBuilder);

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.accountId.listen((accountId) {
      log('MailboxController::onReady(): accountId: $accountId');
      if (accountId != null) {
        getAllMailboxAction(accountId);
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        log('MailboxController::onReady(): ${success.runtimeType}');

        if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          mailboxDashBoardController.clearState();
          refreshMailboxChanges();
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          mailboxDashBoardController.clearState();
          refreshMailboxChanges();
        } else if (success is MoveMultipleEmailToTrashAllSuccess
            || success is MoveMultipleEmailToTrashHasSomeEmailFailure) {
          mailboxDashBoardController.clearState();
          refreshMailboxChanges();
        } else if (success is MarkAsEmailReadSuccess
            || success is MoveToMailboxSuccess
            || success is MoveToTrashSuccess
            || success is SaveEmailAsDraftsSuccess
            || success is RemoveEmailDraftsSuccess
            || success is SendEmailSuccess
            || success is UpdateEmailDraftsSuccess) {
          refreshMailboxChanges();
        }
      });
    });

    _openMailboxEventController.stream.throttleTime(Duration(milliseconds: 800)).listen((event) {
      _handleOpenMailbox(event.buildContext, event.presentationMailbox);
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
    newState.map((success) async {
      if (success is GetAllMailboxSuccess) {
        log('MailboxController::onData(): ${allMailboxes.length}');
        allMailboxes = success.mailboxList;
        currentMailboxState = success.currentMailboxState;
        await buildTree(allMailboxes);

        _setUpMapMailboxIdDefault(allMailboxes, defaultMailboxTree.value, folderMailboxTree.value);
      } else if (success is RefreshChangesAllMailboxSuccess) {
        log('MailboxController::onData(): ${allMailboxes.length}');
        allMailboxes = success.mailboxList;
        currentMailboxState = success.currentMailboxState;
        await refreshTree(allMailboxes);

        _setUpMapMailboxIdDefault(allMailboxes, defaultMailboxTree.value, folderMailboxTree.value);
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
          } else if (failure is DeleteMultipleMailboxFailure) {
            _deleteMailboxFailure(failure);
          }
        },
        (success) {
          if (success is CreateNewMailboxSuccess) {
            _createNewMailboxSuccess(success);
          } else if (success is SearchMailboxSuccess) {
            _searchMailboxSuccess(success);
          } else if (success is DeleteMultipleMailboxSuccess) {
            _deleteMailboxSuccess(success);
          } else if ((success is GetAllMailboxSuccess || success is RefreshChangesAllMailboxSuccess) && isSearchActive()) {
            _searchMailboxAction(allMailboxes, searchQuery.value);
          } else if (success is RenameMailboxSuccess) {
            refreshMailboxChanges();
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

  void _setUpMapMailboxIdDefault(List<PresentationMailbox> allMailbox, MailboxTree defaultTree, MailboxTree folderTree) {

    final mapDefaultMailboxId = Map<Role, MailboxId>.fromIterable(
      defaultTree.root.childrenItems ?? List<MailboxNode>.empty(),
      key: (mailboxNode) => mailboxNode.item.role!,
      value: (mailboxNode) => mailboxNode.item.id);

    final mapDefaultMailbox = Map<Role, PresentationMailbox>.fromIterable(
      defaultTree.root.childrenItems ?? List<MailboxNode>.empty(),
      key: (mailboxNode) => mailboxNode.item.role!,
      value: (mailboxNode) => mailboxNode.item);

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

  void _handleOpenMailbox(
    BuildContext context,
    PresentationMailbox presentationMailboxSelected
  ) {
    FocusScope.of(context).unfocus();

    mailboxDashBoardController.setSelectedMailbox(presentationMailboxSelected);
    mailboxDashBoardController.clearSelectedEmail();

    if (mailboxDashBoardController.isSearchActive()) {
      mailboxDashBoardController.disableSearch();
    }

    if (!_responsiveUtils.isDesktop(context) && !_responsiveUtils.isTabletLarge(context)) {
      mailboxDashBoardController.closeDrawer();
    } else {
      mailboxDashBoardController.dispatchRoute(AppRoutes.THREAD);
    }
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    _openMailboxEventController.add(OpenMailboxViewEvent(context, presentationMailboxSelected));
  }

  void goToCreateNewMailboxView() async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      final newMailboxArguments = await push(
          AppRoutes.MAILBOX_CREATOR,
          arguments: MailboxCreatorArguments(accountId, defaultMailboxTree.value, folderMailboxTree.value)
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
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          textColor: AppColor.toastSuccessBackgroundColor,
          message: AppLocalizations.of(currentContext!).new_mailbox_is_created(success.newMailbox.name?.name ?? ''),
          icon: _imagePaths.icFolderMailbox);
    }

    refreshMailboxChanges();
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(currentContext!).create_new_mailbox_failure,
          icon: _imagePaths.icFolderMailbox);
    }
  }

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() {
    _cancelSelectMailbox();
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch(BuildContext context) {
    _cancelSelectMailbox();

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
        final mailboxNodePath = findNodePath(presentationMailbox.id);
        if (mailboxNodePath != null) {
          return presentationMailbox.toPresentationMailboxWithMailboxPath(mailboxNodePath);
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
    }
  }

  void _cancelSelectMailbox() {
    if (isSearchActive()) {
      listMailboxSearched.value = listMailboxSearched
          .map((mailbox) => mailbox.toSelectedPresentationMailbox(selectMode: SelectMode.INACTIVE))
          .toList();
    } else {
      defaultMailboxTree.value.updateNodesUIMode(SelectMode.INACTIVE, ExpandMode.COLLAPSE);
      folderMailboxTree.value.updateNodesUIMode(SelectMode.INACTIVE, ExpandMode.COLLAPSE);
    }
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  List<PresentationMailbox> get listMailboxSelected {
    if (isSearchActive()) {
      return listMailboxSearched
        .where((mailbox) => mailbox.selectMode == SelectMode.ACTIVE)
        .toList();
    } else {
      final defaultMailboxSelected = defaultMailboxTree.value
        .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

      final folderMailboxSelected = folderMailboxTree.value
        .findNodes((node) => node.selectMode == SelectMode.ACTIVE);

      return [defaultMailboxSelected, folderMailboxSelected]
        .expand((node) => node)
        .map((node) => node.item)
        .toList();
    }
  }

  void pressMailboxSelectionAction(BuildContext context, MailboxActions actions,
      List<PresentationMailbox> selectionMailbox) {
    switch(actions) {
      case MailboxActions.delete:
        _openConfirmationDialogDeleteMailboxAction(context, selectionMailbox.first);
        break;
      case MailboxActions.rename:
        _openDialogRenameMailboxAction(context, selectionMailbox.first);
        break;
      default:
        break;
    }
  }

  void _openConfirmationDialogDeleteMailboxAction(BuildContext context, PresentationMailbox presentationMailbox) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(AppLocalizations.of(context).message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
          ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
          ..onConfirmAction(AppLocalizations.of(context).delete, () => _deleteMailboxAction(presentationMailbox)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(Key('confirm_dialog_delete_mailbox'))
              ..title(AppLocalizations.of(context).delete_mailboxes)
              ..content(AppLocalizations.of(context).message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog, fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(AppLocalizations.of(context).delete, () => _deleteMailboxAction(presentationMailbox))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
            .build()));
    }
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    final matchedNode = findMailboxNodeById(presentationMailbox.id);

    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null) {
      if (matchedNode != null && accountId != null) {
        final descendantIds = matchedNode.descendantsAsList()
            .map((node) => node.item.id)
            .toList();

        final descendantIdsReversed = descendantIds.reversed.toList();
        consumeState(_deleteMultipleMailboxInteractor.execute(
            session, accountId, descendantIdsReversed, presentationMailbox.id));
      } else {
        _deleteMailboxFailure(DeleteMultipleMailboxFailure(null));
      }
    }

    _cancelSelectMailbox();
    popBack();
  }

  void _deleteMailboxSuccess(DeleteMultipleMailboxSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).delete_mailboxes_successfully,
          icon: _imagePaths.icSelected);
    }
    if (success.mailboxIdDeleted == mailboxDashBoardController.selectedMailbox.value?.id) {
      _switchBackToMailboxDefault();
    }
    refreshMailboxChanges();
  }

  void _switchBackToMailboxDefault() {
    final inboxMailbox = findMailboxNodeByRole(PresentationMailbox.roleInbox);
    mailboxDashBoardController.setSelectedMailbox(inboxMailbox?.item);
    mailboxListScrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  void _deleteMailboxFailure(DeleteMultipleMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).delete_mailboxes_failure,
          icon: _imagePaths.icDeleteToast);
    }
  }

  void _openDialogRenameMailboxAction(BuildContext context, PresentationMailbox presentationMailbox) {
    _createListMailboxNameAsStringInMailboxParent(presentationMailbox);

    if (_responsiveUtils.isMobile(context)) {
      (EditTextModalSheetBuilder()
          ..key(Key('rename_mailbox_modal_sheet'))
          ..title(AppLocalizations.of(context).rename_mailbox)
          ..cancelText(AppLocalizations.of(context).cancel)
          ..boxConstraints(_responsiveUtils.isMobileDevice(context) && _responsiveUtils.isLandscape(context)
              ? BoxConstraints(maxWidth: 400)
              : null)
          ..onConfirmAction(AppLocalizations.of(context).rename,
              (value) => _renameMailboxAction(presentationMailbox, value))
          ..setErrorString((value) => getErrorInputNameStringRenameMailbox(context, value))
          ..setTextController(TextEditingController.fromValue(
            TextEditingValue(
                text: presentationMailbox.name?.name ?? '',
                selection: TextSelection(
                    baseOffset: 0,
                    extentOffset: presentationMailbox.name?.name.length ?? 0
                )
            ))))
          .show(context);
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) =>
              PointerInterceptor(child: (EditTextDialogBuilder()
                  ..key(Key('rename_mailbox_dialog'))
                  ..title(AppLocalizations.of(context).rename_mailbox)
                  ..cancelText(AppLocalizations.of(context).cancel)
                  ..setErrorString((value) => getErrorInputNameStringRenameMailbox(context, value))
                  ..setTextController(TextEditingController.fromValue(
                      TextEditingValue(
                          text: presentationMailbox.name?.name ?? '',
                          selection: TextSelection(
                              baseOffset: 0,
                              extentOffset: presentationMailbox.name?.name.length ?? 0
                          )
                      )))
                  ..onConfirmButtonAction(AppLocalizations.of(context).rename,
                      (value) => _renameMailboxAction(presentationMailbox, value)))
                .build()));
    }
  }

  String? getErrorInputNameStringRenameMailbox(BuildContext context, String newName) {
    return _verifyNameInteractor.execute(
        newName,
        [
          EmptyNameValidator(),
          DuplicateNameValidator(listMailboxNameAsStringExist),
          SpecialCharacterValidator(),
        ]
    ).fold(
        (failure) {
          if (failure is VerifyNameFailure) {
            return failure.getMessage(context, actions: MailboxActions.rename);
          } else {
            return null;
          }
        },
        (success) => null
    );
  }

  void _renameMailboxAction(PresentationMailbox presentationMailbox, String newName) {
    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      consumeState(_renameMailboxInteractor.execute(
          accountId,
          RenameMailboxRequest(presentationMailbox.id, MailboxName(newName))));
    }

    _cancelSelectMailbox();
  }

  void _createListMailboxNameAsStringInMailboxParent(PresentationMailbox mailboxRenamed) {
    if (mailboxRenamed.parentId == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree.value.root.childrenItems ?? <MailboxNode>[]) + (folderMailboxTree.value.root.childrenItems ?? <MailboxNode>[]);
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.item.name != null && mailboxNode.item.name?.name.isNotEmpty == true)
            .map((mailboxNode) => mailboxNode.item.name!.name)
            .toList();
      }
    } else {
      final mailboxNodeLocation = defaultMailboxTree.value.findNode((node) => node.item.id == mailboxRenamed.parentId)
          ?? folderMailboxTree.value.findNode((node) => node.item.id == mailboxRenamed.parentId);
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.item.name != null && mailboxNode.item.name?.name.isNotEmpty == true)
            .map((mailboxNode) => mailboxNode.item.name!.name)
            .toList();
      }
    }

    log('MailboxController::_createListMailboxNameAsStringInMailboxLocation(): $listMailboxNameAsStringExist');
  }

  void closeMailboxScreen(BuildContext context) {
    _cancelSelectMailbox();
    mailboxDashBoardController.closeDrawer();
  }

  @override
  void dispose() {
    _openMailboxEventController.close();
    super.dispose();
  }
}