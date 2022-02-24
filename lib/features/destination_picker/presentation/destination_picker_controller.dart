
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/list_mailbox_node_extension.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class DestinationPickerController extends BaseController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final TreeBuilder _treeBuilder;

  MailboxTree folderMailboxTree = MailboxTree(MailboxNode.root());
  final defaultMailboxList = <PresentationMailbox>[].obs;
  final folderMailboxNodeList = <MailboxNode>[].obs;
  final mailboxAction = Rxn<MailboxActions>();
  AccountId? accountId;

  DestinationPickerController(
    this._getAllMailboxInteractor,
    this._treeBuilder,
  );

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments != null && arguments is DestinationPickerArguments) {
      mailboxAction.value = arguments.mailboxAction;
      accountId = arguments.accountId;
      getAllMailboxAction();
    }
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
      }
    });
  }

  @override
  void onError(error) {}

  void getAllMailboxAction() {
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId!));
    }
  }

  void _buildTree(List<PresentationMailbox> folderMailboxList) async {
    folderMailboxTree = await _treeBuilder.generateMailboxTree(folderMailboxList);
    folderMailboxNodeList.value = folderMailboxTree.root.childrenItems ?? [];
  }

  void toggleMailboxFolder(MailboxNode selectedMailboxNode) {
    final newExpandMode = selectedMailboxNode.expandMode == ExpandMode.COLLAPSE
      ? ExpandMode.EXPAND
      : ExpandMode.COLLAPSE;

    final newMailboxNodeList = folderMailboxNodeList.updateNode(
        selectedMailboxNode.item.id,
        selectedMailboxNode.copyWith(newExpandMode: newExpandMode));

    folderMailboxNodeList.value = newMailboxNodeList;
  }

  void selectMailboxAction(PresentationMailbox? destinationMailbox) {
    popBack(result: destinationMailbox);
  }

  void closeDestinationPicker() {
    popBack();
  }
}