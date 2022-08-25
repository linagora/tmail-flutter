import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/add_recipients_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_local_copy_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';

class ForwardBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => ForwardController(
      Get.find<GetForwardInteractor>(),
      Get.find<DeleteRecipientInForwardingInteractor>(),
      Get.find<AddRecipientsInForwardingInteractor>(),
      Get.find<EditLocalCopyInForwardingInteractor>(),
    ));
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => GetForwardInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => DeleteRecipientInForwardingInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => AddRecipientsInForwardingInteractor(Get.find<ManageAccountRepository>()));
    Get.lazyPut(() => EditLocalCopyInForwardingInteractor(Get.find<ManageAccountRepository>()));
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}