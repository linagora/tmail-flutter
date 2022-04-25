
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';

class ManageAccountDashBoardController extends ReloadableController {

  final GetUserProfileInteractor _getUserProfileInteractor;

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();

  ManageAccountDashBoardController(
    this._getUserProfileInteractor,
  );

  @override
  void onReady() {
    _getUserProfile();
    super.onReady();
  }

  @override
  void onDone() {
  viewState.value.fold(
    (failure) {},
    (success) {
      if (success is GetUserProfileSuccess) {
        userProfile.value = success.userProfile;
      }
    }
  );
  }

  @override
  void onError(error) {
  }

  void _getUserProfile() async {
    consumeState(_getUserProfileInteractor.execute());
  }

}