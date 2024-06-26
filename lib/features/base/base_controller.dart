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
import 'package:core/utils/fps_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:fcm/model/firebase_capability.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:flutter/material.dart';
import 'package:forward/forward/capability_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/authentication_type.dart';
import 'package:rule_filter/rule_filter/capability_rule_filter.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/mdn_interactor_bindings.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/contact_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/tmail_autocomplete_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/log_out_oidc_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/email_rules/bindings/email_rules_interactor_bindings.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/bindings/forwarding_interactors_bindings.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/destroy_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/get_stored_firebase_registration_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/destroy_firebase_registration_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/get_stored_firebase_registration_interactor.dart';
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
import 'package:uuid/uuid.dart';

abstract class BaseController extends GetxController
    with MessageDialogActionMixin,
        PopupContextMenuActionMixin {

  final CachingManager cachingManager = Get.find<CachingManager>();
  final LanguageCacheManager languageCacheManager = Get.find<LanguageCacheManager>();
  final AuthorizationInterceptors authorizationInterceptors = Get.find<AuthorizationInterceptors>();
  final AuthorizationInterceptors authorizationIsolateInterceptors = Get.find<AuthorizationInterceptors>(tag: BindingTag.isolateTag);
  final DynamicUrlInterceptors dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();
  final DeleteCredentialInteractor deleteCredentialInteractor = Get.find<DeleteCredentialInteractor>();
  final LogoutOidcInteractor logoutOidcInteractor = Get.find<LogoutOidcInteractor>();
  final DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor = Get.find<DeleteAuthorityOidcInteractor>();
  final AppToast appToast = Get.find<AppToast>();
  final ImagePaths imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils responsiveUtils = Get.find<ResponsiveUtils>();
  final Uuid uuid = Get.find<Uuid>();

  bool _isFcmEnabled = false;

  GetStoredFirebaseRegistrationInteractor? _getStoredFirebaseRegistrationInteractor;
  DestroyFirebaseRegistrationInteractor? _destroyFirebaseRegistrationInteractor;

  final viewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  FpsCallback? fpsCallback;

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
    if (exception is ConnectionError) {
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
      clearDataAndGoToLoginPage();
    }
  }

  void handleFailureViewState(Failure failure) async {
    logError('BaseController::handleFailureViewState(): ${failure.runtimeType}');
    if (failure is LogoutOidcFailure) {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    } else if (failure is GetStoredFirebaseRegistrationFailure ||
        failure is DestroyFirebaseRegistrationFailure) {
      await clearDataAndGoToLoginPage();
    }
  }

  void handleSuccessViewState(Success success) async {
    log('BaseController::handleSuccessViewState(): ${success.runtimeType}');
    if (success is LogoutOidcSuccess) {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    } else if (success is GetStoredFirebaseRegistrationSuccess) {
      _destroyFirebaseRegistration(success.firebaseRegistration.id!);
    } else if (success is DestroyFirebaseRegistrationSuccess) {
      await clearDataAndGoToLoginPage();
    }
  }

  void startFpsMeter() {
    FpsManager().start();
    fpsCallback = (fpsInfo) {
      log('BaseController::startFpsMeter(): $fpsInfo');
    };
    if (fpsCallback != null) {
      FpsManager().addFpsCallback(fpsCallback!);
    }
  }

  void stopFpsMeter() {
    FpsManager().stop();
    if (fpsCallback != null) {
      FpsManager().removeFpsCallback(fpsCallback!);
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

  Future<void> injectFCMBindings(Session? session, AccountId? accountId) async {
    try {
      requireCapability(session!, accountId!, [FirebaseCapability.fcmIdentifier]);
      log('BaseController::injectFCMBindings: fcmAvailable = ${AppConfig.fcmAvailable}');
      if (AppConfig.fcmAvailable) {
        await FcmConfiguration.initialize();
        FcmInteractorBindings().dependencies();
        FcmService.instance.initialStreamController();
        FcmMessageController.instance.initialize(accountId: accountId, session: session);
        FcmTokenController.instance.initialBindingInteractor();
        await FcmReceiver.instance.onInitialFcmListener();
        if (PlatformInfo.isMobile) {
          await LocalNotificationManager.instance.setUp(groupId: session.username.value);
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

  void goToLogin() {
    if (Get.currentRoute != AppRoutes.login) {
      pushAndPopAll(
        AppRoutes.login,
        arguments: LoginArguments(
          PlatformInfo.isMobile ? LoginFormType.dnsLookupForm : LoginFormType.none
        )
      );
    }
  }

  void logout(Session? session, AccountId? accountId) async {
    if (session == null || accountId == null) {
      await clearDataAndGoToLoginPage();
      return;
    }
    _isFcmEnabled = _isFcmActivated(session, accountId);
    if (isAuthenticatedWithOidc) {
      consumeState(logoutOidcInteractor.execute());
    } else {
      if (_isFcmEnabled) {
        _getStoredFirebaseRegistrationFromCache();
      } else {
        await clearDataAndGoToLoginPage();
      }
    }
  }

  void _destroyFirebaseRegistration(FirebaseRegistrationId firebaseRegistrationId) async {
    _destroyFirebaseRegistrationInteractor = getBinding<DestroyFirebaseRegistrationInteractor>();
    if (_destroyFirebaseRegistrationInteractor != null) {
      consumeState(_destroyFirebaseRegistrationInteractor!.execute(firebaseRegistrationId));
    } else {
      await clearDataAndGoToLoginPage();
    }
  }

  void _getStoredFirebaseRegistrationFromCache() async {
    _getStoredFirebaseRegistrationInteractor = getBinding<GetStoredFirebaseRegistrationInteractor>();
    if (_getStoredFirebaseRegistrationInteractor != null) {
      consumeState(_getStoredFirebaseRegistrationInteractor!.execute());
    } else {
      await clearDataAndGoToLoginPage();
    }
  }

  Future<void> clearDataAndGoToLoginPage() async {
    log('BaseController::clearDataAndGoToLoginPage:');
    await clearAllData();
    goToLogin();
  }

  Future<void> clearAllData() async {
    if (isAuthenticatedWithOidc) {
      await _clearOidcAuthData();
    } else {
      await _clearBasicAuthData();
    }
  }

  Future<void> _clearBasicAuthData() async {
    await Future.wait([
      deleteCredentialInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    if (PlatformInfo.isMobile) {
      await cachingManager.clearAllFileInStorage();
    }
    authorizationInterceptors.clear();
    authorizationIsolateInterceptors.clear();
    await cachingManager.closeHive();
  }

  Future<void> _clearOidcAuthData() async {
    await Future.wait([
      deleteAuthorityOidcInteractor.execute(),
      cachingManager.clearAll(),
      languageCacheManager.removeLanguage(),
    ]);
    if (PlatformInfo.isMobile) {
      await cachingManager.clearAllFileInStorage();
    }
    authorizationIsolateInterceptors.clear();
    authorizationInterceptors.clear();
    await cachingManager.closeHive();
  }
}
