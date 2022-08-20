
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/email_rules_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardController extends ReloadableController {

  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();

  final GetAllVacationInteractor _getAllVacationInteractor;
  final UpdateVacationInteractor _updateVacationInteractor;

  final menuDrawerKey = GlobalKey<ScaffoldState>(debugLabel: 'manage_account');

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();
  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;
  final sessionCurrent = Rxn<Session>();
  final vacationResponse = Rxn<VacationResponse>();

  final emailsForwardCreatorIsActive = false.obs;

  ManageAccountDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    this._getAllVacationInteractor,
    this._updateVacationInteractor,
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
        } else if (success is GetAllVacationSuccess) {
          if (success.listVacationResponse.isNotEmpty) {
            vacationResponse.value = success.listVacationResponse.first;
          }
        } else if (success is UpdateVacationSuccess) {
          _handleUpdateVacationSuccess(success);
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
    _getVacationResponse();
    injectAutoCompleteBindings();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    log('ManageAccountDashBoardController::_getAccountIdAndUserProfile(): $arguments');
    if (arguments is ManageAccountArguments) {
      sessionCurrent.value = arguments.session;
      accountId.value = sessionCurrent.value?.accounts.keys.first;
      _getUserProfile();
      _getVacationResponse();
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

  void _getVacationResponse() {
    if (accountId.value != null) {
      consumeState(_getAllVacationInteractor.execute(accountId.value!));
    }
  }

  void updateVacationResponse(VacationResponse? newVacation) {
    vacationResponse.value = newVacation;
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
    if(newAccountMenuItem == AccountMenuItem.forward) {
      ForwardBindings().dependencies();
    }
    accountMenuItemSelected.value = newAccountMenuItem;
    if (isMenuDrawerOpen) {
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
      popBack(result: vacationResponse.value);
    } else {
      log('ManageAccountDashBoardController::backToMailboxDashBoard(): canBack: FALSE');
      pushAndPopAll(AppRoutes.MAILBOX_DASHBOARD, arguments: sessionCurrent);
    }
  }

  bool checkAvailableRuleFilterInSession() => sessionCurrent.value?.capabilities.containsKey(capabilityRuleFilter) ?? false;

  bool checkAvailableForwardInSession() => sessionCurrent.value?.capabilities.containsKey(capabilityForward) ?? false;

  void disableVacationResponder() {
    if (accountId.value != null) {
      final vacationDisabled = vacationResponse.value != null
          ? vacationResponse.value!.copyWith(isEnabled: false)
          : VacationResponse(isEnabled: false);
      consumeState(_updateVacationInteractor.execute(accountId.value!, vacationDisabled));
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully,
            icon: _imagePaths.icChecked);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('ManageAccountDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }
}