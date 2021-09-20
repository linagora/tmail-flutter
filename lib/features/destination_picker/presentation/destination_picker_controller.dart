
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class DestinationPickerController extends BaseController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;
  final TreeBuilder _treeBuilder;

  final folderMailboxTree = MailboxTree(MailboxNode.root()).obs;

  DestinationPickerArguments? destinationPickerArguments;

  DestinationPickerController(
    this._getAllMailboxInteractor,
    this._treeBuilder,
  );

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments != null && Get.arguments is DestinationPickerArguments) {
      destinationPickerArguments = Get.arguments;
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
  void onDone() {}

  @override
  void onError(error) {}

  void getAllMailboxAction() {
    final accountId = destinationPickerArguments?.accountId;
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId));
    }
  }

  void _buildTree(List<PresentationMailbox> folderMailboxList) async {
    folderMailboxTree.value = await _treeBuilder.generateMailboxTree(folderMailboxList);
  }

  void moveEmailToMailboxAction(PresentationMailbox destinationMailbox) {
    popBack();
  }

  void closeDestinationPicker() {
    popBack();
  }
}