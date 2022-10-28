import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rxdart/transformers.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/search_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/create_new_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/move_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/rename_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/search_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/open_mailbox_view_event.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_utils.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/duplicate_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/new_mailbox_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
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
  final _uuid = Get.find<Uuid>();

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final RefreshAllMailboxInteractor _refreshAllMailboxInteractor;
  final CreateNewMailboxInteractor _createNewMailboxInteractor;
  final SearchMailboxInteractor _searchMailboxInteractor;
  final DeleteMultipleMailboxInteractor _deleteMultipleMailboxInteractor;
  final VerifyNameInteractor _verifyNameInteractor;
  final RenameMailboxInteractor _renameMailboxInteractor;
  final MoveMailboxInteractor _moveMailboxInteractor;

  final listMailboxSearched = <PresentationMailbox>[].obs;
  final searchState = SearchState.initial().obs;
  final searchQuery = SearchQuery.initial().obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final mailboxCategoriesExpandMode = MailboxCategoriesExpandMode.initial().obs;

  final _openMailboxEventController = StreamController<OpenMailboxViewEvent>();
  final searchInputController = TextEditingController();
  final searchFocus = FocusNode();
  final mailboxListScrollController = ScrollController();

  jmap.State? _currentMailboxState;
  List<String> listMailboxNameAsStringExist = <String>[];

  late Worker accountIdWorker, viewStateWorker;

  MailboxController(
    this._getAllMailboxInteractor,
    this._refreshAllMailboxInteractor,
    this._createNewMailboxInteractor,
    this._searchMailboxInteractor,
    this._deleteMultipleMailboxInteractor,
    this._verifyNameInteractor,
    this._renameMailboxInteractor,
    this._moveMailboxInteractor,
    treeBuilder,
  ) : super(treeBuilder);

  @override
  void onInit() {
    _initWorker();
    _registerSearchFocusListener();
    super.onInit();
  }

  @override
  void onReady() {
    _openMailboxEventController.stream.throttleTime(const Duration(milliseconds: 800)).listen((event) {
      _handleOpenMailbox(event.buildContext, event.presentationMailbox);
    });

    _initCollapseMailboxCategories();
    super.onReady();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    searchFocus.dispose();
    _openMailboxEventController.close();
    mailboxListScrollController.dispose();
    _clearWorker();
    super.onClose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) async {
      if (success is GetAllMailboxSuccess) {
        _currentMailboxState = success.currentMailboxState;
        await buildTree(success.mailboxList);
        _setUpMapMailbox(success.mailboxList, defaultMailboxTree.value, folderMailboxTree.value);
      } else if (success is RefreshChangesAllMailboxSuccess) {
        _currentMailboxState = success.currentMailboxState;
        await refreshTree(success.mailboxList);
        _setUpMapMailbox(success.mailboxList, defaultMailboxTree.value, folderMailboxTree.value);
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
          } else if (success is DeleteMultipleMailboxAllSuccess) {
            _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
          } else if (success is DeleteMultipleMailboxHasSomeSuccess) {
            _deleteMultipleMailboxSuccess(success.listMailboxIdDeleted, success.currentMailboxState);
          } else if ((success is GetAllMailboxSuccess || success is RefreshChangesAllMailboxSuccess) && isSearchActive()) {
            _searchMailboxAction(allMailboxes, searchQuery.value);
          } else if (success is RenameMailboxSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MoveMailboxSuccess) {
            _moveMailboxSuccess(success);
          }
        }
    );
  }

  void _initWorker() {
    accountIdWorker = ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        getAllMailboxAction(accountId);
      }
    });

    viewStateWorker = ever(mailboxDashBoardController.viewState, (state) {
      if (state is Either) {
        state.fold((failure) => null, (success) {
          if (success is MarkAsMultipleEmailReadAllSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MoveMultipleEmailToMailboxAllSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is EmptyTrashFolderSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MarkAsEmailReadSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MoveToMailboxSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is DeleteEmailPermanentlySuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is SaveEmailAsDraftsSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is RemoveEmailDraftsSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is SendEmailSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MarkAsMailboxReadAllSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          } else if (success is UpdateEmailDraftsSuccess) {
            refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
          }
        });
      }
    });
  }

  void _registerSearchFocusListener() {
    searchFocus.addListener(() {
      final hasFocus = searchFocus.hasFocus;
      final query = searchQuery.value.value;
      log('MailboxController::_registerSearchFocusListener(): hasFocus: $hasFocus | query: $query');
      if (!hasFocus && query.isEmpty) {
        disableSearch();
      }
    });
  }

  void _clearWorker() {
    accountIdWorker.call();
    viewStateWorker.call();
  }

  void _initCollapseMailboxCategories() {
    if (kIsWeb && currentContext != null
        && (_responsiveUtils.isMobile(currentContext!) || _responsiveUtils.isTablet(currentContext!))) {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode(
          defaultMailbox: ExpandMode.COLLAPSE,
          folderMailbox: ExpandMode.COLLAPSE);
    } else {
      mailboxCategoriesExpandMode.value = MailboxCategoriesExpandMode.initial();
    }
  }

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

  void refreshMailboxChanges({jmap.State? currentMailboxState}) {
    log('MailboxController::refreshMailboxChanges(): currentMailboxState: $currentMailboxState');
    final newMailboxState = currentMailboxState ?? _currentMailboxState;
    log('MailboxController::refreshMailboxChanges(): newMailboxState: $newMailboxState');
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && newMailboxState != null) {
      consumeState(_refreshAllMailboxInteractor.execute(accountId, newMailboxState));
    }
  }

  void _setUpMapMailbox(List<PresentationMailbox> allMailbox, MailboxTree defaultTree, MailboxTree folderTree) {
    final mapDefaultMailboxIdByRole = {
      for (var mailboxNode
          in defaultTree.root.childrenItems ?? List<MailboxNode>.empty())
        mailboxNode.item.role!: mailboxNode.item.id
    };

    final mapDefaultMailbox = {
      for (var mailboxNode
          in defaultTree.root.childrenItems ?? List<MailboxNode>.empty())
        mailboxNode.item.role!: mailboxNode.item
    };

    final mapMailboxById = {
      for (var presentationMailbox in allMailbox)
        presentationMailbox.id: presentationMailbox
    };

    mailboxDashBoardController.setMapDefaultMailboxIdByRole(mapDefaultMailboxIdByRole);
    mailboxDashBoardController.setMapMailboxById(mapMailboxById);

    try {
      final outboxMailboxIdByRole = mapDefaultMailboxIdByRole[PresentationMailbox.roleOutbox];
      if (outboxMailboxIdByRole == null) {
        final outboxMailboxByName = allMailbox
            .firstWhere((mailbox) => mailbox.name?.toLowerCase() == PresentationMailbox.lowerCaseOutboxMailboxName);
        mailboxDashBoardController.setOutboxMailbox(outboxMailboxByName);
      } else {
        mailboxDashBoardController.setOutboxMailbox(mapMailboxById[outboxMailboxIdByRole]!);
      }
    } catch (e) {
      logError('MailboxController::_setUpMapMailboxIdDefault: Not found outbox mailbox');
      mailboxDashBoardController.setOutboxMailbox(null);
    }

    var mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;

    if (mailboxCurrent != null) {
      if (mailboxCurrent.hasRole()) {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapDefaultMailbox.containsKey(mailboxCurrent.role)
          ? mapDefaultMailbox[mailboxCurrent.role]
          : mailboxCurrent);
      } else {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapMailboxById.containsKey(mailboxCurrent.id)
          ? mapMailboxById[mailboxCurrent.id]
          : mailboxCurrent);
      }
    } else {
      if (!mailboxDashBoardController.searchController.isSearchEmailRunning) {
        if (mapDefaultMailbox.containsKey(PresentationMailbox.roleInbox)) {
          mailboxDashBoardController.setNewFirstSelectedMailbox(mapDefaultMailbox[PresentationMailbox.roleInbox]);
        } else {
          if (allMailbox.isNotEmpty) {
            mailboxDashBoardController.setNewFirstSelectedMailbox(allMailbox.first);
          }
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

    if (mailboxDashBoardController.searchController.isSearchActive()) {
      mailboxDashBoardController.searchController.disableSearch();
    }

    if (_responsiveUtils.hasLeftMenuDrawerActive(context)) {
      mailboxDashBoardController.closeMailboxMenuDrawer();
    } else {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
  }

  void openMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    _openMailboxEventController.add(OpenMailboxViewEvent(context, presentationMailboxSelected));
  }

  void goToCreateNewMailboxView(BuildContext context) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      final arguments = MailboxCreatorArguments(
          accountId,
          defaultMailboxTree.value,
          folderMailboxTree.value);

      if (BuildUtils.isWeb) {
        showDialogMailboxCreator(
            context: context,
            arguments: arguments,
            onCreatedMailbox: (newMailboxArguments) {
              final generateCreateId = Id(_uuid.v1());
              _createNewMailboxAction(accountId, CreateNewMailboxRequest(
                  generateCreateId,
                  newMailboxArguments.newName,
                  parentId: newMailboxArguments.mailboxLocation?.id));
            });
      } else {
        final newMailboxArguments = await push(
            AppRoutes.mailboxCreator,
            arguments: arguments);

        if (newMailboxArguments != null && newMailboxArguments is NewMailboxArguments) {
          final generateCreateId = Id(_uuid.v1());
          _createNewMailboxAction(accountId, CreateNewMailboxRequest(
              generateCreateId,
              newMailboxArguments.newName,
              parentId: newMailboxArguments.mailboxLocation?.id));
        }
      }
    }
  }

  void _createNewMailboxAction(AccountId accountId, CreateNewMailboxRequest request) async {
    consumeState(_createNewMailboxInteractor.execute(accountId, request));
  }

  void _createNewMailboxSuccess(CreateNewMailboxSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).new_mailbox_is_created(success.newMailbox.name?.name ?? ''),
          leadingIcon: SvgPicture.asset(
              _imagePaths.icFolderMailbox,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
    }

    refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _createNewMailboxFailure(CreateNewMailboxFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final exception = failure.exception;
      var messageError = AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      if (exception is ErrorMethodResponse) {
        messageError = exception.description ?? AppLocalizations.of(currentContext!).create_new_mailbox_failure;
      }

      _appToast.showBottomToast(
          currentOverlayContext!,
          messageError,
          leadingIcon: SvgPicture.asset(
              _imagePaths.icNotConnection,
              width: 24,
              height: 24,
              color: Colors.white,
              fit: BoxFit.fill),
          backgroundColor: AppColor.toastErrorBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
    }
  }

  bool isSearchActive() => searchState.value.searchStatus == SearchStatus.ACTIVE;

  void enableSearch() {
    _cancelSelectMailbox();
    searchState.value = searchState.value.enableSearchState();
  }

  void disableSearch() {
    _cancelSelectMailbox();
    listMailboxSearched.clear();
    searchState.value = searchState.value.disableSearchState();
    searchQuery.value = SearchQuery.initial();
    searchInputController.clear();
    searchFocus.unfocus();
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
    final mailboxesSearchedWithPath = findMailboxPath(success.mailboxesSearched);
    listMailboxSearched.value = mailboxesSearchedWithPath;
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

  void selectMailboxSearched(BuildContext context, PresentationMailbox mailboxSelected) {
    listMailboxSearched.value = listMailboxSearched
        .map((mailbox) => mailbox.id == mailboxSelected.id ? mailbox.toggleSelectPresentationMailbox() : mailbox)
        .toList();
  }

  void _cancelSelectMailbox() {
    if (isSearchActive()) {
      listMailboxSearched.value = listMailboxSearched
          .map((mailbox) => mailbox.toSelectedPresentationMailbox(selectMode: SelectMode.INACTIVE))
          .toList();
    } else {
      unAllSelectedMailboxNode();
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
        _openDialogRenameMailboxAction(context, selectedMailboxList.first);
        break;
      case MailboxActions.markAsRead:
        _markAsReadMailboxAction(context, selectedMailboxList.first);
        break;
      case MailboxActions.move:
        _moveMailboxAction(context, selectedMailboxList.first);
        break;
      default:
        break;
    }
  }

  void _openConfirmationDialogDeleteMailboxAction(
      BuildContext context,
      PresentationMailbox presentationMailbox
  ) {
    if (_responsiveUtils.isLandscapeMobile(context) ||
        _responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
          ..messageText(AppLocalizations.of(context)
              .message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
          ..onCancelAction(AppLocalizations.of(context).cancel, () =>
              popBack())
          ..onConfirmAction(AppLocalizations.of(context).delete, () =>
              _deleteMailboxAction(presentationMailbox)))
        .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_mailbox'))
              ..title(AppLocalizations.of(context).delete_mailboxes)
              ..content(AppLocalizations.of(context)
                  .message_confirmation_dialog_delete_mailbox(presentationMailbox.name?.name ?? ''))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog,
                  fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
                  _deleteMailboxAction(presentationMailbox))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                  popBack()))
            .build()));
    }
  }

  void _deleteMailboxAction(PresentationMailbox presentationMailbox) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (session != null && accountId != null) {
      final tupleMap = MailboxUtils.generateMapDescendantIdsAndMailboxIdList(
          [presentationMailbox],
          defaultMailboxTree.value,
          folderMailboxTree.value);
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
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).delete_mailboxes_successfully,
          icon: _imagePaths.icSelected);
    }
    if (listMailboxIdDeleted.contains(mailboxDashBoardController.selectedMailbox.value?.id)) {
      _switchBackToMailboxDefault();
    }
    refreshMailboxChanges(currentMailboxState: currentMailboxState);
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
          folderMailboxTree.value);
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
    mailboxListScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
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
          ..key(const Key('rename_mailbox_modal_sheet'))
          ..title(AppLocalizations.of(context).rename_mailbox)
          ..cancelText(AppLocalizations.of(context).cancel)
          ..boxConstraints(_responsiveUtils.isLandscapeMobile(context)
              ? const BoxConstraints(maxWidth: 400)
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
                  ..key(const Key('rename_mailbox_dialog'))
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

  void _markAsReadMailboxAction(BuildContext context, PresentationMailbox presentationMailbox) {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxId = presentationMailbox.id;
    final mailboxName = presentationMailbox.name;
    final countEmailsUnread = presentationMailbox.unreadEmails?.value.value ?? 0;
    if (accountId != null && mailboxName != null) {
      mailboxDashBoardController.markAsReadMailbox(
          accountId,
          mailboxId,
          mailboxName,
          countEmailsUnread.toInt());

      closeMailboxScreen(context);
    }
  }

  void _moveMailboxAction(BuildContext context, PresentationMailbox mailboxSelected) async {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      final arguments = DestinationPickerArguments(
          accountId,
          MailboxActions.move,
          mailboxIdSelected: mailboxSelected.id);

      if (BuildUtils.isWeb) {
        showDialogDestinationPicker(
            context: context,
            arguments: arguments,
            onSelectedMailbox: (destinationMailbox) {
              _handleMovingMailbox(
                  accountId,
                  MoveAction.moving,
                  mailboxSelected,
                  destinationMailbox: destinationMailbox == PresentationMailbox.unifiedMailbox ? null : destinationMailbox);

              _cancelSelectMailbox();
            });
      } else {
        final destinationMailbox = await push(
            AppRoutes.destinationPicker,
            arguments: arguments);

        if (destinationMailbox is PresentationMailbox) {
          _handleMovingMailbox(
              accountId,
              MoveAction.moving,
              mailboxSelected,
              destinationMailbox: destinationMailbox == PresentationMailbox.unifiedMailbox ? null : destinationMailbox);

          _cancelSelectMailbox();
        }
      }
    }
  }

  void _handleMovingMailbox(
      AccountId accountId,
      MoveAction moveAction,
      PresentationMailbox mailboxSelected,
      {PresentationMailbox? destinationMailbox}) {
    consumeState(_moveMailboxInteractor.execute(accountId,
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
      _appToast.showBottomToast(
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
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
    }

    refreshMailboxChanges(currentMailboxState: success.currentMailboxState);
  }

  void _undoMovingMailbox(MoveMailboxRequest newMoveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_moveMailboxInteractor.execute(accountId, newMoveRequest));
    }
  }

  void _createListMailboxNameAsStringInMailboxParent(PresentationMailbox mailboxRenamed) {
    if (mailboxRenamed.parentId == null) {
      final allChildrenAtMailboxLocation = (defaultMailboxTree.value.root.childrenItems ?? <MailboxNode>[]) + (folderMailboxTree.value.root.childrenItems ?? <MailboxNode>[]);
      if (allChildrenAtMailboxLocation.isNotEmpty) {
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      } else {
        listMailboxNameAsStringExist = [];
      }
    } else {
      final mailboxNodeLocation = findMailboxNodeById(mailboxRenamed.parentId!);
      if (mailboxNodeLocation != null && mailboxNodeLocation.childrenItems?.isNotEmpty == true) {
        final allChildrenAtMailboxLocation =  mailboxNodeLocation.childrenItems!;
        listMailboxNameAsStringExist = allChildrenAtMailboxLocation
            .where((mailboxNode) => mailboxNode.nameNotEmpty)
            .map((mailboxNode) => mailboxNode.mailboxNameAsString)
            .toList();
      } else {
        listMailboxNameAsStringExist = [];
      }
    }

    log('MailboxController::_createListMailboxNameAsStringInMailboxLocation(): $listMailboxNameAsStringExist');
  }

  void toggleMailboxCategories(MailboxCategories categories) {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.folders:
        final newExpandMode = mailboxCategoriesExpandMode.value.folderMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.folderMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
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
        _openConfirmationDialogDeleteMailboxAction(context, mailbox);
        break;
      case MailboxActions.rename:
        _openDialogRenameMailboxAction(context, mailbox);
        break;
      case MailboxActions.move:
        _moveMailboxAction(context, mailbox);
        break;
      case MailboxActions.markAsRead:
        _markAsReadMailboxAction(context, mailbox);
        break;
      default:
        break;
    }
  }

  void closeMailboxScreen(BuildContext context) {
    _cancelSelectMailbox();
    mailboxDashBoardController.closeMailboxMenuDrawer();
  }
}