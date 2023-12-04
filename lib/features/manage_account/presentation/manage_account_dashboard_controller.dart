
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_user_profile_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/action/dashboard_setting_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forward_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/bindings/mailbox_visibility_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

class ManageAccountDashBoardController extends ReloadableController {

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;

  final appInformation = Rxn<PackageInfo>();
  final userProfile = Rxn<UserProfile>();
  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;
  final settingsPageLevel = SettingsPageLevel.universal.obs;
  final vacationResponse = Rxn<VacationResponse>();
  final dashboardSettingAction = Rxn<UIAction>();

  Session? sessionCurrent;

  @override
  void onReady() {
    _initialPageLevel();
    _getArguments();
    _getAppVersion();
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetUserProfileSuccess) {
      userProfile.value = success.userProfile;
    } else if (success is GetAllVacationSuccess) {
      if (success.listVacationResponse.isNotEmpty) {
        vacationResponse.value = success.listVacationResponse.first;
      }
    } else if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleReloaded(Session session) {
    sessionCurrent = session;
    accountId.value = session.personalAccount.accountId;
    _getUserProfile();
    _bindingInteractorForMenuItemView(sessionCurrent, accountId.value);
    _getVacationResponse();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    log('ManageAccountDashBoardController::_getArguments(): $arguments');
    if (arguments is ManageAccountArguments) {
      sessionCurrent = arguments.session;
      accountId.value = arguments.session?.personalAccount.accountId;
      _getUserProfile();
      _bindingInteractorForMenuItemView(sessionCurrent, accountId.value);
      _getVacationResponse();
      if (arguments.menuSettingCurrent != null) {
        _goToSettingMenuCurrent(arguments.menuSettingCurrent!);
      }
    } else if (PlatformInfo.isWeb) {
      reload();
    }
  }

  void _initialPageLevel() {
    if (currentContext != null && responsiveUtils.isWebDesktop(currentContext!)) {
      settingsPageLevel.value = SettingsPageLevel.level1;
    } else {
      settingsPageLevel.value = SettingsPageLevel.universal;
    }
  }

  void _bindingInteractorForMenuItemView(Session? session, AccountId? accountId) {
    injectAutoCompleteBindings(session, accountId);
    injectVacationBindings(session, accountId);
    injectForwardBindings(session, accountId);
    injectRuleFilterBindings(session, accountId);
  }

  @override
  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      super.injectVacationBindings(session, accountId);
      VacationControllerBindings().dependencies();
      _getAllVacationInteractor = Get.find<GetAllVacationInteractor>();
      _updateVacationInteractor = Get.find<UpdateVacationInteractor>();
    } catch (e) {
      logError('ManageAccountDashBoardController::injectVacationBindings(): $e');
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('ManageAccountDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  void _getUserProfile() async {
    log('ManageAccountDashBoardController::_getUserProfile(): $sessionCurrent');
    userProfile.value = sessionCurrent != null ? UserProfile(sessionCurrent!.username.value) : null;
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
    }
  }

  void updateVacationResponse(VacationResponse? newVacation) {
    vacationResponse.value = newVacation;
  }

  void selectAccountMenuItem(AccountMenuItem newAccountMenuItem) {
    settingsPageLevel.value = newAccountMenuItem == AccountMenuItem.none
      ? SettingsPageLevel.universal
      : SettingsPageLevel.level1;

    clearInputFormView();
    _bindingControllerMenuItemView(newAccountMenuItem);
    accountMenuItemSelected.value = newAccountMenuItem;
  }

  void _bindingControllerMenuItemView(AccountMenuItem item) {
    switch (item) {
      case AccountMenuItem.profiles:
        ProfileBindings().dependencies();
        break;
      case AccountMenuItem.languageAndRegion:
        LanguageAndRegionBindings().dependencies();
        break;
      case AccountMenuItem.emailRules:
        EmailRulesBindings().dependencies();
        break;
      case AccountMenuItem.forward:
        ForwardBindings().dependencies();
        break;
      case AccountMenuItem.mailboxVisibility:
        MailboxVisibilityBindings().dependencies();
        break;
      case AccountMenuItem.vacation:
      case AccountMenuItem.none:
        break;
    }
  }

  void clearInputFormView() {
    switch(accountMenuItemSelected.value) {
      case AccountMenuItem.forward:
        dispatchAction(ClearAllInputForwarding());
        break;
      default:
        break;
    }
  }

  void _goToSettingMenuCurrent(AccountMenuItem accountMenuItem) {
    selectAccountMenuItem(accountMenuItem);
  }

  void goToSettings() {
    popAndPush(AppRoutes.settings,
        arguments: ManageAccountArguments(sessionCurrent));
  }

  void backToMailboxDashBoard(BuildContext context) {
    if (canBack(context)) {
      popBack(result: vacationResponse.value);
    } else {
      log('ManageAccountDashBoardController::backToMailboxDashBoard(): canBack: FALSE');
      pushAndPopAll(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
        arguments: sessionCurrent);
    }
  }

  bool get isVacationCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return [CapabilityIdentifier.jmapVacationResponse].isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isRuleFilterCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return [capabilityRuleFilter].isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isForwardCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return [capabilityForward].isSupported(sessionCurrent!, accountId.value!);
    } else {
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
        appToast.showToastSuccessMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('ManageAccountDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  bool inVacationSettings() {
    return accountMenuItemSelected.value == AccountMenuItem.vacation;
  }

  void dispatchAction(UIAction newAction) {
    log('ManageAccountDashBoardController::dispatchAction(): ${newAction.runtimeType}');
    final previousAction = dashboardSettingAction.value;
    if (newAction == previousAction) {
      dashboardSettingAction.value = newAction;
      dashboardSettingAction.refresh();
    } else {
      dashboardSettingAction.value = newAction;
    }
  }

  void backButtonPressedCallbackAction(BuildContext context) {
    backToMailboxDashBoard(context);
  }
}