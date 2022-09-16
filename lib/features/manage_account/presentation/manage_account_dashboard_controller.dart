
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
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ManageAccountDashBoardController extends ReloadableController {

  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;

  final menuDrawerKey = GlobalKey<ScaffoldState>(debugLabel: 'manage_account');

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();
  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;
  final settingsPageLevel = SettingsPageLevel.universal.obs;

  final sessionCurrent = Rxn<Session>();
  final vacationResponse = Rxn<VacationResponse>();

  final emailsForwardCreatorIsActive = false.obs;

  ManageAccountDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor
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
    injectAutoCompleteBindings();
    injectVacationBindings(sessionCurrent.value, accountId.value);
    _getVacationResponse();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    log('ManageAccountDashBoardController::_getAccountIdAndUserProfile(): $arguments');
    if (arguments is ManageAccountArguments) {
      sessionCurrent.value = arguments.session;
      accountId.value = sessionCurrent.value?.accounts.keys.first;
      _getUserProfile();
      injectAutoCompleteBindings();
      injectVacationBindings(sessionCurrent.value, accountId.value);
      _getVacationResponse();
      if (arguments.menuSettingCurrent != null) {
        _goToSettingMenuCurrent(arguments.menuSettingCurrent!);
      }
    } else {
      if (kIsWeb) {
        reload();
      }
    }
  }

  @override
  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      super.injectVacationBindings(session, accountId);
      VacationControllerBindings().dependencies();
      _getAllVacationInteractor = Get.find<GetAllVacationInteractor>();
      _updateVacationInteractor = Get.find<UpdateVacationInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::injectVacationBindings(): $e');
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('MailboxDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  void _getUserProfile() async {
    log('ManageAccountDashBoardController::_getUserProfile(): ${sessionCurrent.value}');
    userProfile.value = sessionCurrent.value != null ? UserProfile(sessionCurrent.value!.username.value) : null;
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
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
  
  void _goToSettingMenuCurrent(AccountMenuItem accountMenuItem) {
    if(accountMenuItem == AccountMenuItem.emailRules) {
      EmailRulesBindings().dependencies();
    }
    if(accountMenuItem == AccountMenuItem.forward) {
      ForwardBindings().dependencies();
    }
    accountMenuItemSelected.value = accountMenuItem;
    if (currentContext != null &&
        !_responsiveUtils.isDesktop(currentContext!)) {
      settingsPageLevel.value = SettingsPageLevel.level1;
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

  bool checkAvailableRuleFilterInSession() {
    try {
      requireCapability(sessionCurrent.value!, accountId.value!, [capabilityRuleFilter]);
      return true;
    } catch(e) {
      logError('ManageAccountDashBoardController::checkAvailableRuleFilterInSession(): exception = $e');
      return false;
    }
  }

  bool checkAvailableForwardInSession() {
    try {
      requireCapability(sessionCurrent.value!, accountId.value!, [capabilityForward]);
      return true;
    } catch(e) {
      logError('ManageAccountDashBoardController::checkAvailableRuleFilterInSession(): exception = $e');
      return false;
    }
  }

  void disableVacationResponder() {
    if (accountId.value != null && _updateVacationInteractor != null) {
      final vacationDisabled = vacationResponse.value != null
          ? vacationResponse.value!.copyWith(isEnabled: false)
          : VacationResponse(isEnabled: false);
      consumeState(_updateVacationInteractor!.execute(accountId.value!, vacationDisabled));
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

  bool inVacationSettings() {
    return accountMenuItemSelected.value == AccountMenuItem.vacation;
  }
}