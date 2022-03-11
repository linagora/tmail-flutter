
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class DestinationPickerController extends BaseMailboxController {

  final GetAllMailboxInteractor _getAllMailboxInteractor;

  final mailboxAction = Rxn<MailboxActions>();
  AccountId? accountId;

  DestinationPickerController(
    this._getAllMailboxInteractor,
    treeBuilder,
  ) : super(treeBuilder);

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
        buildTree(success.mailboxList);
      }
    });
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  void getAllMailboxAction() {
    if (accountId != null) {
      consumeState(_getAllMailboxInteractor.execute(accountId!));
    }
  }

  void selectMailboxAction(PresentationMailbox? destinationMailbox) {
    popBack(result: destinationMailbox);
  }

  void closeDestinationPicker() {
    popBack();
  }
}