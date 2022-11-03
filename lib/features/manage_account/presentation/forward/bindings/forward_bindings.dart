import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/add_recipients_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_local_copy_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forwarding_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';

class ForwardBindings extends Bindings {

  @override
  void dependencies() {
    ForwardingInteractorsBindings().dependencies();
    Get.lazyPut(() => ForwardController(
      Get.find<GetForwardInteractor>(),
      Get.find<DeleteRecipientInForwardingInteractor>(),
      Get.find<AddRecipientsInForwardingInteractor>(),
      Get.find<EditLocalCopyInForwardingInteractor>(),
    ));
  }
}