
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardController extends ReloadableController {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final menuDrawerKey = GlobalKey<ScaffoldState>(debugLabel: 'manage_account');

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();
  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;

  final sessionCurrent = Rxn<Session>();

  ManageAccountDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
  ) : super(logoutOidcInteractor,
      deleteAuthorityOidcInteractor,
      getAuthenticatedAccountInteractor);

  @override
  void onReady() {
    _getArguments();
    _getAppVersion();
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

  @override
  void handleReloaded(Session session) {
    sessionCurrent.value = session;
    accountId.value = session.accounts.keys.first;
    _getUserProfile();
    injectAutoCompleteBindings();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    log('ManageAccountDashBoardController::_getAccountIdAndUserProfile(): $arguments');
    if (arguments is ManageAccountArguments) {
      sessionCurrent.value = arguments.session;
      accountId.value = sessionCurrent.value?.accounts.keys.first;
      _getUserProfile();
      injectAutoCompleteBindings();
    } else {
      if (kIsWeb) {
        reload();
      }
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('MailboxDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  void _getUserProfile() async {
    userProfile.value = sessionCurrent.value != null ? UserProfile(sessionCurrent.value!.username.value) : null;
  }

  void openMenuDrawer() {
    menuDrawerKey.currentState?.openDrawer();
  }

  void closeMenuDrawer() {
    menuDrawerKey.currentState?.openEndDrawer();
  }

  bool get isMenuDrawerOpen => menuDrawerKey.currentState?.isDrawerOpen == true;

  void selectAccountMenuItem(AccountMenuItem newAccountMenuItem) {
    if(newAccountMenuItem == AccountMenuItem.emailRules) {
      EmailRulesBindings().dependencies();
    }
    accountMenuItemSelected.value = newAccountMenuItem;
    if (currentContext != null && !_responsiveUtils.isDesktop(currentContext!)) {
      closeMenuDrawer();
    }
  }

  void goToSettings() {
    pushAndPop(AppRoutes.MANAGE_ACCOUNT,
        arguments: ManageAccountArguments(sessionCurrent.value));
  }

  void backToMailboxDashBoard(BuildContext context) {
    if (isMenuDrawerOpen) {
      closeMenuDrawer();
    }
    if (canBack(context)) {
      popBack();
    } else {
      log('ManageAccountDashBoardController::backToMailboxDashBoard(): canBack: FALSE');
      pushAndPopAll(AppRoutes.MAILBOX_DASHBOARD, arguments: sessionCurrent);
    }
  }

  bool checkAvailableRuleFilterInSession() => sessionCurrent.value?.capabilities.containsKey(capabilityRuleFilter) ?? false;

}