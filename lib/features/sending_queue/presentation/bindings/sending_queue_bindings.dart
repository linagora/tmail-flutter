
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_multiple_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/get_stored_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/sending_queue_controller.dart';

class SendingQueueBindings extends Bindings {

  @override
  void dependencies() {
    _bindingsController();
  }

  void _bindingsController() {
    Get.put(SendingQueueController(
      Get.find<DeleteMultipleSendingEmailInteractor>(),
      Get.find<UpdateSendingEmailInteractor>(),
      Get.find<DeleteSendingEmailInteractor>(),
      Get.find<GetStoredSendingEmailInteractor>(),
    ));
  }
}