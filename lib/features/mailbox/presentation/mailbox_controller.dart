import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_mailboxes_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmapState;

class MailboxController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final RefreshMailboxesInteractor _refreshMailboxesInteractor;
  final TreeBuilder _treeBuilder;
  final ResponsiveUtils responsiveUtils;

  final defaultMailboxList = <PresentationMailbox>[].obs;
  final folderMailboxNodeList = <MailboxNode>[].obs;

  jmapState.State? currentMailboxState;

  MailboxController(
    this._getAllMailboxInteractor,
    this._deleteCredentialInteractor,
    this._refreshMailboxesInteractor,
    this._treeBuilder,
    this.responsiveUtils
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
        }
      });
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.accountId.close();
    super.onClose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) {
      if (success is GetAllMailboxSuccess) {
        _buildTree(success.folderMailboxList);
      }
    });
  }

  @override
  void onDone() {
    viewState.value.map((success) {
      if (success is GetAllMailboxSuccess) {
        currentMailboxState = success.currentMailboxState;
        defaultMailboxList.value = success.defaultMailboxList;
        _setUpMapMailboxIdDefault(success.defaultMailboxList);
      }
    });
  }

  @override
  void onError(error) {}

  void getAllMailboxAction(AccountId accountId) async {
    consumeState(_getAllMailboxInteractor.execute(accountId));
  }

  void refreshAllMailbox() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId));
    }
  }

  void refreshMailboxChanges() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null && currentMailboxState != null) {
      consumeState(_refreshMailboxesInteractor.execute(accountId, currentMailboxState!));
    }
  }

  void _buildTree(List<PresentationMailbox> folderMailboxList) async {
    final _folderMailboxTree = await _treeBuilder.generateMailboxTree(folderMailboxList);
    folderMailboxNodeList.value = _folderMailboxTree.root.childrenItems ?? [];
  }

  void toggleMailboxFolder(MailboxNode mailboxNode) {
    final newExpandMode = mailboxNode.expandMode == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND
        : ExpandMode.COLLAPSE;

    final newMailboxNodeList = folderMailboxNodeList.updateNode(
        mailboxNode.item.id,
        mailboxNode.copyWith(newExpandMode: newExpandMode)) ?? [];

    folderMailboxNodeList.value = newMailboxNodeList;
  }

  void _setUpMapMailboxIdDefault(List<PresentationMailbox> defaultMailboxList) {
    final mapMailboxId = Map<Role, MailboxId>.fromIterable(
      defaultMailboxList,
      key: (presentationMailbox) => presentationMailbox.role!,
      value: (presentationMailbox) => presentationMailbox.id);

    final mapMailboxDefault = Map<Role, PresentationMailbox>.fromIterable(
        defaultMailboxList,
        key: (presentationMailbox) => presentationMailbox.role!,
        value: (presentationMailbox) => presentationMailbox);

    mailboxDashBoardController.setMapMailboxId(mapMailboxId);

    var mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;

    if (mailboxCurrent != null) {
      if (mapMailboxDefault.containsKey(mailboxCurrent.role)) {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapMailboxDefault[mailboxCurrent.role]);
      } else {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mailboxCurrent);
      }
    } else {
      if (mapMailboxDefault.containsKey(PresentationMailbox.roleInbox)) {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapMailboxDefault[PresentationMailbox.roleInbox]);
      } else {
        mailboxDashBoardController.setNewFirstSelectedMailbox(mapMailboxDefault.values.first);
      }
    }
  }

  SelectMode getSelectMode(PresentationMailbox presentationMailbox, PresentationMailbox? selectedMailbox) {
    return presentationMailbox.id == selectedMailbox?.id
      ? SelectMode.ACTIVE
      : SelectMode.INACTIVE;
  }

  void selectMailbox(
      BuildContext context,
      PresentationMailbox presentationMailboxSelected
  ) {
    mailboxDashBoardController.setSelectedMailbox(presentationMailboxSelected);
    mailboxDashBoardController.clearSelectedEmail();

    if (responsiveUtils.isMobile(context)) {
      mailboxDashBoardController.closeDrawer();
    }
  }

  void _deleteCredential() async {
    await _deleteCredentialInteractor.execute();
  }

  void closeMailboxScreen() {
    _deleteCredential();
    pushAndPopAll(AppRoutes.LOGIN);
  }
}