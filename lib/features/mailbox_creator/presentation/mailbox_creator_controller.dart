
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/model/mailbox_creator_arguments.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_logger.dart';

class MailboxCreatorController extends BaseController {

  final selectedMailbox = Rxn<PresentationMailbox>();

  List<PresentationMailbox> allMailboxes = <PresentationMailbox>[];

  MailboxCreatorController();

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments is MailboxCreatorArguments) {
      allMailboxes = arguments.allMailboxes;
      log('allMailboxes: $allMailboxes');
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  void closeMailboxCreator() {
    popBack();
  }
}