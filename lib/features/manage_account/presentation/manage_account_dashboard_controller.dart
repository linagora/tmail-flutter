
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:flutter/material.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mixin/user_setting_popup_menu_mixin.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/notification/bindings/notification_binding.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/profiles_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller_bindings.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ManageAccountDashBoardController extends ReloadableController with UserSettingPopupMenuMixin {

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;

  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;
  final settingsPageLevel = SettingsPageLevel.universal.obs;
  final vacationResponse = Rxn<VacationResponse>();
  final dashboardSettingAction = Rxn<UIAction>();

  Session? sessionCurrent;
  bool? isVacationDateDialogDisplayed;
  Uri? previousUri;

  @override
  void onInit() {
    BackButtonInterceptor.add(_onBackButtonInterceptor, name: AppRoutes.settings);
    super.onInit();
  }

  @override
  void onReady() {
    _initialPageLevel();
    _getArguments();
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAllVacationSuccess) {
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
    log('ManageAccountDashBoardController::handleReloaded:');
    sessionCurrent = session;
    accountId.value = session.accountId;
    _bindingInteractorForMenuItemView(sessionCurrent, accountId.value);
    _getVacationResponse();
    _getParametersRouter();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is ManageAccountArguments) {
      sessionCurrent = arguments.session;
      accountId.value = arguments.session?.personalAccount.accountId;
      previousUri = arguments.previousUri;
      _bindingInteractorForMenuItemView(sessionCurrent, accountId.value);
      _getVacationResponse();
      if (arguments.menuSettingCurrent != null) {
        selectAccountMenuItem(arguments.menuSettingCurrent!);
      }
    } else if (PlatformInfo.isWeb) {
      reload();
    }
  }

  void _getParametersRouter() {
    final parameters = Get.parameters;
    log('ManageAccountDashBoardController::_getParametersRouter:parameters: $parameters');
    final navigationRouter = RouteUtils.parsingRouteParametersToNavigationRouter(parameters);
    log('ManageAccountDashBoardController::_getParametersRouter:navigationRouter: $navigationRouter');
    if (navigationRouter.accountMenuItem == AccountMenuItem.none &&
        currentContext != null &&
        responsiveUtils.isWebDesktop(currentContext!)
    ) {
      selectAccountMenuItem(AccountMenuItem.profiles);
    } else {
      selectAccountMenuItem(navigationRouter.accountMenuItem);
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
    _replaceBrowserHistory();
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
      case AccountMenuItem.preferences:
        PreferencesBindings().dependencies();
        break;
      case AccountMenuItem.forward:
        ForwardBindings().dependencies();
        break;
      case AccountMenuItem.mailboxVisibility:
        MailboxVisibilityBindings().dependencies();
        break;
      case AccountMenuItem.notification:
        NotificationBinding().dependencies();
        break;
      default:
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

  void backToMailboxDashBoard({BuildContext? context}) {
    if (context != null && canBack(context)) {
      popBack(result: Tuple2(vacationResponse.value, previousUri));
    } else {
      log('ManageAccountDashBoardController::backToMailboxDashBoard(): canBack: FALSE');
      pushAndPopAll(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
        arguments: sessionCurrent);
    }
  }

  bool get isVacationCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return CapabilityIdentifier.jmapVacationResponse.isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isFcmCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return [FirebaseCapability.fcmIdentifier].isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isServerSettingsCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return capabilityServerSettings.isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isRuleFilterCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return capabilityRuleFilter.isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  bool get isForwardCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return capabilityForward.isSupported(sessionCurrent!, accountId.value!);
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

  void selectSettings(AccountMenuItem accountMenuItem) {
    log('ManageAccountDashBoardController::selectSettings(): $accountMenuItem');
    selectAccountMenuItem(accountMenuItem);
    settingsPageLevel.value = SettingsPageLevel.level1;
  }

  void backToUniversalSettings() {
    log('ManageAccountDashBoardController::backToUniversalSettings()');
    clearInputFormView();
    selectAccountMenuItem(AccountMenuItem.none);
    settingsPageLevel.value = SettingsPageLevel.universal;
    NotificationBinding().close();
    _replaceBrowserHistory();
  }

  void _replaceBrowserHistory() {
    if (PlatformInfo.isWeb) {
      RouteUtils.replaceBrowserHistory(
        title: accountMenuItemSelected.value == AccountMenuItem.none
          ? 'Setting'
          : 'Setting-${accountMenuItemSelected.value.getAliasBrowser()}',
        url: RouteUtils.createUrlWebLocationBar(
          AppRoutes.settings,
          router: NavigationRouter(accountMenuItem: accountMenuItemSelected.value)
        )
      );
    }
  }

  bool _navigateToScreen() {
    log('ManageAccountDashBoardController::_navigateToScreen: settingsPageLevel: $settingsPageLevel');
    if (currentContext != null && responsiveUtils.isWebDesktop(currentContext!)) {
      if (accountMenuItemSelected.value == AccountMenuItem.profiles) {
        backToMailboxDashBoard(context: currentContext);
        return true;
      } else {
        selectSettings(AccountMenuItem.profiles);
        return true;
      }
    } else {
      switch(settingsPageLevel.value) {
        case SettingsPageLevel.level1:
          backToUniversalSettings();
          return true;
        case SettingsPageLevel.universal:
          backToMailboxDashBoard(context: currentContext);
          return true;
      }
    }
  }

  bool get _isDialogViewOpen => Get.isOverlaysOpen == true;

  bool _onBackButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    log('ManageAccountDashBoardController::_onBackButtonInterceptor:currentRoute: ${Get.currentRoute} | _isDialogViewOpen: $_isDialogViewOpen');
    if (_isDialogViewOpen || isVacationDateDialogDisplayed == true) {
      popBack();
      _replaceBrowserHistory();
      return true;
    }

    if (Get.currentRoute.startsWith(AppRoutes.settings)) {
      return _navigateToScreen();
    }

    return false;
  }

  void handleClickAvatarAction(BuildContext context, RelativeRect position) {
    openPopupMenuAction(
      context,
      position,
      popupMenuUserSettingActionTile(
        context,
        getOwnEmailAddress(),
        onLogoutAction: () {
          popBack();
          logout(context, sessionCurrent, accountId.value);
        }
      )
    );
  }

  int get minInputLengthAutocomplete {
    if (sessionCurrent == null || accountId.value == null) {
      return AppConfig.defaultMinInputLengthAutocomplete;
    }
    return getMinInputLengthAutocomplete(
      session: sessionCurrent!,
      accountId: accountId.value!);
  }

  String getOwnEmailAddress() {
    try {
      return sessionCurrent?.getOwnEmailAddress() ?? '';
    } catch (e) {
      logError('ManageAccountDashBoardController::getOwnEmailAddress:Exception: $e');
      return '';
    }
  }

  @override
  void onClose() {
    BackButtonInterceptor.removeByName(AppRoutes.settings);
    super.onClose();
  }
}