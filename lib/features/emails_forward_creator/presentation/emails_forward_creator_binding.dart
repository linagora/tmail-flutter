import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/emails_forward_creator/presentation/emails_forward_creator_controller.dart';

class EmailsForwardCreatorBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => EmailsForwardCreatorController());
  }

  @override
  void bindingsDataSource() {}

  @override
  void bindingsDataSourceImpl() {}

  @override
  void bindingsInteractor() {}

  @override
  void bindingsRepository() {}

  @override
  void bindingsRepositoryImpl() {}
}