
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_user_profile_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_property.dart';

class ManageAccountDashBoardController extends ReloadableController {

  final GetUserProfileInteractor _getUserProfileInteractor;

  final menuDrawerKey = GlobalKey<ScaffoldState>();

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();
  final accountPropertySelected = AccountProperty.profiles.obs;

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

  void openMenuDrawer() {
    menuDrawerKey.currentState?.openDrawer();
  }

  void closeMenuDrawer() {
    menuDrawerKey.currentState?.openEndDrawer();
  }

  bool get isMenuDrawerOpen => menuDrawerKey.currentState?.isDrawerOpen == true;
}