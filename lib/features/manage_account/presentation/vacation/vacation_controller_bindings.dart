import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/utils/vacation_utils.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller.dart';

class VacationControllerBindings extends BaseBindings {

  @override
  void bindingsController() {
    Get.lazyPut(() => RichTextWebController(), tag: VacationUtils.vacationTagName);
    Get.lazyPut(() => VacationController(
        Get.find<GetAllVacationInteractor>(),
        Get.find<UpdateVacationInteractor>(),
        Get.find<VerifyNameInteractor>()));
  }

  @override
  void bindingsDataSource() {
  }

  @override
  void bindingsDataSourceImpl() {
  }

  @override
  void bindingsInteractor() {
    Get.lazyPut(() => VerifyNameInteractor());
  }

  @override
  void bindingsRepository() {
  }

  @override
  void bindingsRepositoryImpl() {
  }

  void dispose() {
    Get.delete<RichTextWebController>(tag: VacationUtils.vacationTagName);
  }
}