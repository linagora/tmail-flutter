import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final TreeBuilder _treeBuilder;
  final ResponsiveUtils responsiveUtils;

  final defaultMailboxList = <PresentationMailbox>[].obs;
  final folderMailboxNodeList = <MailboxNode>[].obs;

  MailboxController(
    this._getAllMailboxInteractor,
    this._deleteCredentialInteractor,
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
          refreshGetAllMailboxAction();
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          mailboxDashBoardController.clearState();
          refreshGetAllMailboxAction();
        }
      });
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.accountId.close();
    super.onClose();
  }

  void refreshGetAllMailboxAction() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      getAllMailboxAction(accountId);
    }
  }

  void getAllMailboxAction(AccountId accountId) async {
    consumeState(_getAllMailboxInteractor.execute(accountId));
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
        defaultMailboxList.value = success.defaultMailboxList;
        _setUpMapMailboxIdDefault(success.defaultMailboxList);
      }
    });
  }

  @override
  void onError(error) {}

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
    var mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;

    defaultMailboxList.forEach((presentationMailbox) {
      if (mailboxCurrent == null && presentationMailbox.role == PresentationMailbox.roleInbox) {
        mailboxCurrent = presentationMailbox;
      } else if (mailboxCurrent?.role == presentationMailbox.role) {
        mailboxCurrent = presentationMailbox;
      }

      mailboxDashBoardController.addMailboxIdToMap(presentationMailbox.role!, presentationMailbox.id);
    });

    if (mailboxCurrent != null) {
      mailboxDashBoardController.setNewFirstSelectedMailbox(mailboxCurrent);
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