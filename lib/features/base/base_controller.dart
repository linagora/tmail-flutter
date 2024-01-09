import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/toast/tmail_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_basic_auth_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/logout_current_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/set_current_account_active_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forwarding_interactors_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/vacation_interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/remove_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/bindings/fcm_interactor_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/config/fcm_configuration.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_message_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/fcm_token_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_service.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_store.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:tmail_ui_user/main/utils/authenticated_account_manager.dart';
import 'package:uuid/uuid.dart';

abstract class BaseController extends GetxController
    with MessageDialogActionMixin,
        PopupContextMenuActionMixin {

  final CachingManager cachingManager = Get.find<CachingManager>();
  final LanguageCacheManager languageCacheManager = Get.find<LanguageCacheManager>();
  final AuthorizationInterceptors authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final AuthorizationInterceptors authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final DynamicUrlInterceptors dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final LogoutCurrentAccountInteractor _logoutCurrentAccountInteractor = Get.find<LogoutCurrentAccountInteractor>();
  final AppToast appToast = Get.find<AppToast>();
  final ImagePaths imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils responsiveUtils = Get.find<ResponsiveUtils>();
  final Uuid uuid = Get.find<Uuid>();
  final AppStore appStore = Get.find<AppStore>();
  final SetCurrentAccountActiveInteractor _setCurrentAccountActiveInteractor = Get.find<SetCurrentAccountActiveInteractor>();
  final AuthenticatedAccountManager authenticatedAccountManager = Get.find<AuthenticatedAccountManager>();

  final _fcmReceiver = FcmReceiver.instance;
  bool _isFcmEnabled = false;

  RemoveFirebaseRegistrationInteractor? _removeFirebaseRegistrationInteractor;

  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));

  void consumeState(Stream<Either<Failure, Success>> newStateStream) async {
    newStateStream.listen(onData, onError: onError, onDone: onDone);
  }

  void dispatchState(Either<Failure, Success> newState) {
    viewState.value = newState;
  }

  void clearState() {
    viewState.value = Right(UIState.idle);
  }

  void onData(Either<Failure, Success> newState) {
    viewState.value = newState;
    viewState.value.fold(
      (failure) {
        if (failure is FeatureFailure) {
          final exception = _performFilterExceptionInError(failure.exception);
          logError('BaseController::onData:exception: $exception');
          if (exception != null) {
            handleExceptionAction(failure: failure, exception: exception);
          } else {
            handleFailureViewState(failure);
          }
        } else {
          handleFailureViewState(failure);
        }
      },
      handleSuccessViewState);
  }

  void onError(Object error, StackTrace stackTrace) {
    logError('BaseController::onError():error: $error | stackTrace: $stackTrace');
    final exception = _performFilterExceptionInError(error);
    if (exception != null) {
      handleExceptionAction(exception: exception);
    } else {
      handleErrorViewState(error, stackTrace);
    }
  }

  void onDone() {}

  Exception? _performFilterExceptionInError(dynamic error) {
    logError('BaseController::_performFilterExceptionInError(): $error');
    if (error is NoNetworkError || error is ConnectionTimeout || error is InternalServerError) {
      if (PlatformInfo.isWeb && currentOverlayContext != null && currentContext != null) {
        appToast.showToastMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).no_internet_connection,
          actionName: AppLocalizations.of(currentContext!).skip,
          onActionClick: ToastView.dismiss,
          leadingSVGIcon: imagePaths.icNotConnection,
          backgroundColor: AppColor.textFieldErrorBorderColor,
          textColor: Colors.white,
          infinityToast: true,
        );
      }
      return error;
    } else if (error is BadCredentialsException || error is ConnectionError) {
      return error;
    }

    return null;
  }

  void handleErrorViewState(Object error, StackTrace stackTrace) {}

  void handleExceptionAction({Failure? failure, Exception? exception}) {
    logError('BaseController::handleExceptionAction():failure: $failure | exception: $exception');
    if (exception is BadCredentialsException) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).badCredentials
        );
      }
    } else if (exception is ConnectionError) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).connectionError
        );
      }
    }

    if (!authorizationInterceptors.isAppRunning) {
      return;
    }
    if (exception is BadCredentialsException || exception is ConnectionError) {
      _handleBadCredentials();
    }
  }

  void handleFailureViewState(Failure failure) async {
    logError('BaseController::handleFailureViewState(): ${failure.runtimeType}');
    if (failure is LogoutCurrentAccountOidcFailure ||
        failure is LogoutCurrentAccountBasicAuthFailure ||
        failure is LogoutCurrentAccountFailure) {
      _handleLogoutCurrentAccountFailure(failure);
    } else if (failure is DestroyFirebaseRegistrationFailure) {
      _handleDestroyFirebaseRegistrationFailure(failure);
    }
  }

  void handleSuccessViewState(Success success) async {
    log('BaseController::handleSuccessViewState(): ${success.runtimeType}');
    if (success is LogoutCurrentAccountOidcSuccess || success is LogoutCurrentAccountBasicAuthSuccess) {
      _handleLogoutCurrentAccountSuccess(success);
    } else if (success is DestroyFirebaseRegistrationSuccess) {
      _handleDestroyFirebaseRegistrationSuccess(success);
    }
  }

  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      ContactAutoCompleteBindings().dependencies();
      requireCapability(session!, accountId!, [tmailContactCapabilityIdentifier]);
      TMailAutoCompleteBindings().dependencies();
    } catch (e) {
      logError('BaseController::injectAutoCompleteBindings(): exception: $e');
    }
  }

  void injectMdnBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapMdn]);
      MdnInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectMdnBindings(): exception: $e');
    }
  }

  void injectForwardBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityForward]);
      ForwardingInteractorsBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectForwardBindings(): exception: $e');
    }
  }

  void injectRuleFilterBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [capabilityRuleFilter]);
      EmailRulesInteractorBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectRuleFilterBindings(): exception: $e');
    }
  }

  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      requireCapability(session!, accountId!, [CapabilityIdentifier.jmapVacationResponse]);
      VacationInteractorsBindings().dependencies();
    } catch(e) {
      logError('BaseController::injectVacationBindings(): exception: $e');
    }
  }

  Future<void> injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      if (AppConfig.fcmAvailable) {
        final mapEnvData = Map<String, String>.from(dotenv.env);
        await AppUtils.loadFcmConfigFileToEnv(currentMapEnvData: mapEnvData);
        await FcmConfiguration.initialize();
        FcmInteractorBindings().dependencies();
        FcmService.instance.initialStreamController();
        FcmMessageController.instance.initialize(accountId: accountId, session: session);
        FcmTokenController.instance.initialBindingInteractor();
        await FcmReceiver.instance.onInitialFcmListener();
        if (PlatformInfo.isMobile) {
          await LocalNotificationManager.instance.setUp();
        }
      } else {
        throw NotSupportFCMException();
      }
    } catch(e) {
      logError('BaseController::injectFCMBindings(): exception: $e');
    }
  }

  AuthenticationType get authenticationType => authorizationInterceptors.authenticationType;

  bool get isAuthenticatedWithOidc => authenticationType == AuthenticationType.oidc;

  bool _isFcmActivated(Session session, AccountId accountId) =>
    FirebaseCapability.fcmIdentifier.isSupported(session, accountId) && AppConfig.fcmAvailable;


  void removeAllRouteAndNavigateToTwakeIdPage() {
    pushAndPopAll(AppRoutes.twakeId);
  }

  void navigateToTwakeIdPage() {
    popAndPush(AppRoutes.twakeId);
  }

  void navigateToLoginPage({LoginArguments? arguments}) {
    if (Get.currentRoute == AppRoutes.login) {
      return;
    }
    pushAndPopAll(AppRoutes.login, arguments: arguments);
  }

  void logout({
    required Session session,
    required AccountId accountId
  }) async {
    _isFcmEnabled = _isFcmActivated(session, accountId);
    consumeState(_logoutCurrentAccountInteractor.execute());
  }

  void _removeFirebaseRegistration(PersonalAccount deletedAccount) async {
    _removeFirebaseRegistrationInteractor = getBinding<RemoveFirebaseRegistrationInteractor>();
    if (_removeFirebaseRegistrationInteractor != null) {
      consumeState(_removeFirebaseRegistrationInteractor!.execute(deletedAccount));
    } else {
      if (PlatformInfo.isMobile) {
        await clearDataByAccount(deletedAccount);
        _handleNavigationRouteAfterLogoutCurrentAccountSuccess();
      } else {
        await clearAllDataAndBackToLogin();
      }
    }
  }

  Future<void> clearAllDataAndBackToLogin() async {
    log('BaseController::clearAllDataAndBackToLogin:');
    await clearAllData();
    if (PlatformInfo.isMobile) {
      removeAllRouteAndNavigateToTwakeIdPage();
    } else {
      navigateToLoginPage(arguments: LoginArguments(LoginFormType.none));
    }
  }

  Future<void> clearAllData() async {
    log('BaseController::clearAllData:');
    try {
      authorizationInterceptors.clear();
      authorizationIsolateInterceptors.clear();

      await Future.wait([
        cachingManager.clearAll(),
        languageCacheManager.removeLanguage(),
      ]);

      await cachingManager.closeHive();

      if (PlatformInfo.isMobile) {
        await cachingManager.clearAllFolderInStorage();
      }

      if (_isFcmEnabled) {
        await _fcmReceiver.deleteFcmToken();
      }
    } catch (e, s) {
      logError('BaseController::clearAllData: Exception: $e | Stack: $s');
    }
  }

  Future<void> clearDataByAccount(PersonalAccount currentAccount) async {
    log('BaseController::clearDataByAccount:currentAccount: $currentAccount');
    try {
      authorizationInterceptors.clear();
      authorizationIsolateInterceptors.clear();

      await cachingManager.clearCacheByAccount(currentAccount);
      await cachingManager.closeHive();

      await cachingManager.clearFolderStorageByAccount(currentAccount);
    } catch (e, s) {
      logError('BaseController::clearAllDataByAccount: Exception: $e | Stack: $s');
    }
  }

  void _handleLogoutCurrentAccountSuccess(Success success) async {
    PersonalAccount? deletedAccount;

    if (success is LogoutCurrentAccountOidcSuccess) {
      deletedAccount = success.deletedAccount;
    } else if (success is LogoutCurrentAccountBasicAuthSuccess) {
      deletedAccount = success.deletedAccount;
    }

    if (deletedAccount == null) {
      await clearAllDataAndBackToLogin();
      return;
    }

    if (_isFcmEnabled) {
      _removeFirebaseRegistration(deletedAccount);
    } else {
      if (PlatformInfo.isMobile) {
        await clearDataByAccount(deletedAccount);
        _handleNavigationRouteAfterLogoutCurrentAccountSuccess();
      } else {
        await clearAllDataAndBackToLogin();
      }
    }
  }

  void _handleLogoutCurrentAccountFailure(Failure failure) async {
    PersonalAccount? deletedAccount;

    if (failure is LogoutCurrentAccountOidcFailure) {
      deletedAccount = failure.deletedAccount;
    } else if (failure is LogoutCurrentAccountBasicAuthFailure) {
      deletedAccount = failure.deletedAccount;
    } else if (failure is LogoutCurrentAccountFailure) {
      deletedAccount = failure.deletedAccount;
    }

    if (deletedAccount == null) {
      await clearAllDataAndBackToLogin();
      return;
    }

    if (_isFcmEnabled) {
      _removeFirebaseRegistration(deletedAccount);
    } else {
      if (PlatformInfo.isMobile) {
        await clearDataByAccount(deletedAccount);
        _handleNavigationRouteAfterLogoutCurrentAccountSuccess();
      } else {
        await clearAllDataAndBackToLogin();
      }
    }
  }

  void setUpInterceptors(PersonalAccount personalAccount) {
    dynamicUrlInterceptors.setJmapUrl(personalAccount.baseUrl);
    dynamicUrlInterceptors.changeBaseUrl(personalAccount.baseUrl);

    switch(personalAccount.authType) {
      case AuthenticationType.oidc:
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: personalAccount.tokenOidc,
          newConfig: personalAccount.tokenOidc!.oidcConfiguration
        );
        authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
          newToken: personalAccount.tokenOidc,
          newConfig: personalAccount.tokenOidc!.oidcConfiguration
        );
        break;
      case AuthenticationType.basic:
        authorizationInterceptors.setBasicAuthorization(
          personalAccount.basicAuth!.userName,
          personalAccount.basicAuth!.password,
        );
        authorizationIsolateInterceptors.setBasicAuthorization(
          personalAccount.basicAuth!.userName,
          personalAccount.basicAuth!.password,
        );
        break;
      default:
        break;
    }
  }

  void setCurrentAccountActive(PersonalAccount activeAccount) {
    consumeState(_setCurrentAccountActiveInteractor.execute(activeAccount));
  }

  void _handleBadCredentials() async {
    await clearAllDataAndBackToLogin();
  }

  void _handleDestroyFirebaseRegistrationFailure(DestroyFirebaseRegistrationFailure failure) async {
    if (PlatformInfo.isMobile) {
      await clearDataByAccount(failure.currentAccount);
      _handleNavigationRouteAfterLogoutCurrentAccountSuccess();
    } else {
      await clearAllDataAndBackToLogin();
    }
  }

  void _handleDestroyFirebaseRegistrationSuccess(DestroyFirebaseRegistrationSuccess success) async {
    if (PlatformInfo.isMobile) {
      await clearDataByAccount(success.currentAccount);
      _handleNavigationRouteAfterLogoutCurrentAccountSuccess();
    } else {
      await clearAllDataAndBackToLogin();
    }
  }

  void _handleNavigationRouteAfterLogoutCurrentAccountSuccess() async {
    log('BaseController::_handleNavigationRouteAfterLogoutCurrentAccountSuccess:');
    final listAccounts = await authenticatedAccountManager.getAllPersonalAccount();
    if (listAccounts.isEmpty) {
      removeAllRouteAndNavigateToTwakeIdPage();
    } else {
      pushAndPopAll(
        AppRoutes.home,
        arguments: LoginNavigateArguments(
          navigateType: LoginNavigateType.selectActiveAccount
        ));
    }
  }
}
