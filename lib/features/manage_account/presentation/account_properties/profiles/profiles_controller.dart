
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/profiles_tab_type.dart';

class ProfilesController extends BaseController {

  final tabTypeSelected = ProfilesTabType.identities.obs;

  @override
  void onDone() {
  }

  @override
  void onError(error) {
  }
}