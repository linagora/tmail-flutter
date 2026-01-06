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
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:model/model.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:scribe/scribe/ai/presentation/utils/ai_scribe_constants.dart';
import 'package:server_settings/server_settings/capability_server_settings.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/mixin/ai_scribe_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/own_email_address_mixin.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/color_dialog_picker.dart';
import 'package:tmail_ui_user/features/base/widget/dialog_picker/date_time_dialog_picker.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/export_trace_log_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_label_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_label_visibility_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_label_visibility_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/action/dashboard_setting_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/export_trace_log_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/handle_setup_label_visibility_in_setting_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/handle_vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/validate_setting_capability_supported_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/validate_storage_menu_visible_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forward_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identity_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/bindings/mailbox_visibility_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/settings_page_level.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/bindings/notification_binding.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/bindings/preferences_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/storage/storage_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_controller_bindings.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ManageAccountDashBoardController extends ReloadableController
  with OwnEmailAddressMixin, AiScribeMixin {

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;
  PaywallController? paywallController;
  GetQuotasInteractor? getQuotasInteractor;
  SaveLabelVisibilityInteractor? saveLabelVisibilityInteractor;
  GetLabelVisibilityInteractor? getLabelVisibilityInteractor;

  final accountId = Rxn<AccountId>();
  final accountMenuItemSelected = AccountMenuItem.profiles.obs;
  final settingsPageLevel = SettingsPageLevel.universal.obs;
  final vacationResponse = Rxn<VacationResponse>();
  final dashboardSettingAction = Rxn<UIAction>();
  final octetsQuota = Rxn<Quota>();
  final isLabelVisibilityEnabled = RxBool(PlatformInfo.isIntegrationTesting);

  Uri? previousUri;
  AccountMenuItem? selectedMenu;
  int minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete;

  @override
  void onInit() {
    BackButtonInterceptor.add(_onBackButtonInterceptor, name: AppRoutes.settings);
    super.onInit();
    if (LogTracking().isEnabled) {
      injectTraceLogDependencies();
    }
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
      syncVacationResponse(success.listVacationResponse.firstOrNull);
    } else if (success is UpdateVacationSuccess) {
      _handleUpdateVacationSuccess(success);
    } else if (success is ExportTraceLogSuccess) {
      handleExportTraceLogSuccess(success);
    } else if (success is GetQuotasSuccess) {
      handleGetQuotasSuccess(success);
    } else if (success is GetLabelVisibilitySuccess) {
      handleGetLabelVisibilitySuccess(success.visible);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is ExportTraceLogFailure) {
      handleExportTraceLogFailure(failure);
    } else if (failure is UpdateVacationFailure) {
      setUpVacation(null);
    } else if (failure is GetQuotasFailure) {
      handleGetQuotasFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleReloaded(Session session) {
    log('ManageAccountDashBoardController::handleReloaded:');
    _setUpComponentsFromSession(session: session);
    _getParametersRouter();
  }

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is ManageAccountArguments) {
      previousUri = arguments.previousUri;
      _setUpComponentsFromSession(
        session: arguments.session,
        quota: arguments.quota,
      );
      selectedMenu = arguments.menuSettingCurrent;
      if (selectedMenu != null && selectedMenu != AccountMenuItem.storage) {
        selectAccountMenuItem(selectedMenu!);
      }
    } else if (PlatformInfo.isWeb) {
      selectedMenu = null;
      reload();
    }
  }

  void _setUpComponentsFromSession({
    Session? session,
    Quota? quota,
  }) {
    sessionCurrent = session;
    accountId.value = session?.accountId;
    synchronizeOwnEmailAddress(session?.getOwnEmailAddressOrEmpty() ?? '');
    _setUpMinInputLengthAutocomplete();
    _bindingInteractorForMenuItemView(sessionCurrent, accountId.value);
    _getVacationResponse();
    injectAIScribeBindings(sessionCurrent, accountId.value);
    paywallController = PaywallController(
      ownEmailAddress: ownEmailAddress.value,
    );

    if (quota != null) {
      octetsQuota.value = quota;
    } else if (isStorageCapabilitySupported) {
      getQuotas(accountId.value);
    }

    if (isLabelCapabilitySupported) {
      setUpLabelVisibility();
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
      selectedMenu = navigationRouter.accountMenuItem;
      if (selectedMenu != null && selectedMenu != AccountMenuItem.storage) {
        selectAccountMenuItem(selectedMenu!);
      }
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
    if (isStorageCapabilitySupported) {
      injectQuotaBindings();
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
      logError('ManageAccountDashBoardController::injectVacationBindings(): $e');
    }
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
    }
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
        IdentityBindings().dependencies();
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
      case AccountMenuItem.storage:
        StorageBindings().dependencies();
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

  bool get isLanguageSettingDisplayed {
    if (!isServerSettingsCapabilitySupported) return true;

    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }

    return !sessionCurrent!.isLanguageReadOnly(accountId.value!);
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

  bool get isAICapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return AiScribeConstants.aiCapability.isSupported(sessionCurrent!, accountId.value!);
    } else {
      return false;
    }
  }

  void disableVacationResponder(
    VacationResponse vacation, {
    bool isAuto = false,
  }) {
    if (accountId.value != null && _updateVacationInteractor != null) {
      consumeState(_updateVacationInteractor!.execute(
        accountId.value!,
        vacation.clearAllExceptHtmlBody(),
        isAuto: isAuto,
      ));
    } else {
      consumeState(
        Stream.value(Left(UpdateVacationFailure(ParametersIsNullException()))),
      );
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty &&
        !success.isAuto &&
        currentContext != null &&
        currentOverlayContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully,
      );
    }
    setUpVacation(success.listVacationResponse.firstOrNull);
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
    if (_isDialogViewOpen ||
        DateTimeDialogPicker().isOpened.isTrue ||
        ColorDialogPicker().isOpened.isTrue) {
      popBack();
      _replaceBrowserHistory();
      return true;
    }

    if (Get.currentRoute.startsWith(AppRoutes.settings)) {
      return _navigateToScreen();
    }

    return false;
  }

  void _setUpMinInputLengthAutocomplete() {
    if (sessionCurrent == null || accountId.value == null) {
      minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete;
    }
    minInputLengthAutocomplete = getMinInputLengthAutocomplete(
      session: sessionCurrent!,
      accountId: accountId.value!,
    );
  }

  @override
  void onClose() {
    BackButtonInterceptor.removeByName(AppRoutes.settings);
    if (LogTracking().isEnabled) {
      disposeTraceLogDependencies();
    }
    paywallController?.onClose();
    paywallController = null;
    previousUri = null;
    selectedMenu = null;
    super.onClose();
  }
}